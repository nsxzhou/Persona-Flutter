import 'dart:convert';

import '../../../core/analysis/analysis_text_tools.dart';
import '../../../core/llm/application/markdown_completion_service.dart';
import '../../../core/tasks/application/prompt_trace_recorder.dart';
import '../../../core/tasks/application/workflow_task_repository.dart';
import '../../settings/domain/provider_config.dart';
import '../domain/plot_analysis_run.dart';
import '../domain/plot_chunk_sketch.dart';
import '../domain/plot_lab_repository.dart';
import 'plot_chunk_sketch_document.dart';
import 'plot_input_classification.dart';
import 'plot_lab_prompts.dart';
import 'story_engine_normalizer.dart';

class PlotAnalysisPipeline {
  const PlotAnalysisPipeline({
    required PlotLabRepository repository,
    required MarkdownCompletionService completionService,
    required WorkflowTaskRepository workflowTaskRepository,
    PlotLabPromptBuilder promptBuilder = const PlotLabPromptBuilder(),
    StoryEngineNormalizer storyEngineNormalizer = const StoryEngineNormalizer(),
    PlotChunkSketchDocumentParser sketchDocumentParser =
        const PlotChunkSketchDocumentParser(),
  }) : _repository = repository,
       _completionService = completionService,
       _workflowTaskRepository = workflowTaskRepository,
       _promptBuilder = promptBuilder,
       _storyEngineNormalizer = storyEngineNormalizer,
       _sketchDocumentParser = sketchDocumentParser;

  final PlotLabRepository _repository;
  final MarkdownCompletionService _completionService;
  final WorkflowTaskRepository _workflowTaskRepository;
  final PlotLabPromptBuilder _promptBuilder;
  final StoryEngineNormalizer _storyEngineNormalizer;
  final PlotChunkSketchDocumentParser _sketchDocumentParser;

  static const skeletonHierarchicalTokenThreshold = 80000;
  static const skeletonGroupSize = 40;

  Future<void> run({
    required String runId,
    required ProviderConfig provider,
  }) async {
    final run = await _repository.findRun(runId);
    if (run == null) {
      throw StateError('Plot analysis run does not exist: $runId');
    }
    final sample = await _repository.findSample(run.sampleId);
    if (sample == null) {
      throw StateError('Plot sample does not exist: ${run.sampleId}');
    }

    var currentStage = run.stage;
    final traceRecorder = PromptTraceRecorder(
      repository: _workflowTaskRepository,
      workflowTaskId: run.workflowTaskId,
      workflowKind: plotAnalysisWorkflowTaskKind,
      runId: run.id,
      providerId: provider.id,
      providerApiKey: provider.apiKey,
      modelName: run.modelName,
      stageLabel: () => currentStage?.name,
    );
    final log = StringBuffer(run.logs);
    Future<void> transition(
      PlotAnalysisStatus status,
      PlotAnalysisStage? stage, {
      String? message,
      String? errorMessage,
      String? analysisReportMarkdown,
      String? plotSkeletonMarkdown,
      String? storyEngineMarkdown,
      int? chunkCount,
      DateTime? startedAt,
      DateTime? completedAt,
    }) async {
      currentStage = stage;
      if (message != null && message.trim().isNotEmpty) {
        _appendLog(log, message);
      }
      await _repository.updateRunState(
        id: runId,
        status: status,
        stage: stage,
        errorMessage: errorMessage,
        logs: log.toString(),
        analysisReportMarkdown: analysisReportMarkdown,
        plotSkeletonMarkdown: plotSkeletonMarkdown,
        storyEngineMarkdown: storyEngineMarkdown,
        chunkCount: chunkCount,
        startedAt: startedAt,
        completedAt: completedAt,
      );
    }

    try {
      await transition(
        PlotAnalysisStatus.running,
        PlotAnalysisStage.preparingInput,
        message: '阶段: 准备输入。准备样本文本。',
        startedAt: DateTime.now(),
      );
      final chunks = splitAnalysisTextIntoChunks(sample.content);
      if (chunks.isEmpty) {
        throw StateError('样本文本没有可分析的有效内容。');
      }
      final classification = PlotInputClassification.detect(
        text: sample.content,
        chunkCount: chunks.length,
      );

      await transition(
        PlotAnalysisStatus.running,
        PlotAnalysisStage.sketchingChunks,
        message: '阶段: 分块速写。开始生成 ${chunks.length} 个 chunk 的剧情账本。',
        chunkCount: chunks.length,
      );
      final sketches = <PlotChunkSketch>[];
      for (var index = 0; index < chunks.length; index += 1) {
        final raw = await _completionService.completeMarkdown(
          provider: provider,
          modelName: run.modelName,
          prompt: _promptBuilder.buildSketchPrompt(
            chunk: chunks[index],
            chunkIndex: index,
            chunkCount: chunks.length,
            classification: classification,
          ),
          temperature: 0.25,
          promptTrace: traceRecorder.config(label: 'sketch_chunk_${index + 1}'),
        );
        final sketch = await _parseSketch(
          raw: raw,
          chunkIndex: index,
          chunkCount: chunks.length,
          provider: provider,
          traceRecorder: traceRecorder,
        );
        sketches.add(sketch);
        await transition(
          PlotAnalysisStatus.running,
          PlotAnalysisStage.sketchingChunks,
          message: '完成 sketch ${index + 1}/${chunks.length}。',
        );
      }

      await transition(
        PlotAnalysisStatus.running,
        PlotAnalysisStage.buildingSkeleton,
        message: '阶段: 构建骨架。聚合剧情账本为全书骨架。',
      );
      final skeleton = await _buildSkeleton(
        provider: provider,
        modelName: run.modelName,
        sketches: sketches,
        classification: classification,
        chunkCount: chunks.length,
        traceRecorder: traceRecorder,
      );

      await transition(
        PlotAnalysisStatus.running,
        PlotAnalysisStage.reporting,
        message: '阶段: 生成报告。生成最终剧情分析报告。',
        plotSkeletonMarkdown: skeleton,
      );
      final report = await _completionService.completeMarkdown(
        provider: provider,
        prompt: _promptBuilder.buildReportPrompt(
          plotSkeletonMarkdown: skeleton,
          classification: classification,
        ),
        modelName: run.modelName,
        promptTrace: traceRecorder.config(label: 'build_report'),
      );

      await transition(
        PlotAnalysisStatus.running,
        PlotAnalysisStage.postprocessing,
        message: '阶段: 生成 Story Engine。生成可复用剧情写作规则。',
        analysisReportMarkdown: report,
        plotSkeletonMarkdown: skeleton,
      );
      final storyEngineRaw = await _completionService.completeMarkdown(
        provider: provider,
        prompt: _promptBuilder.buildStoryEnginePrompt(
          reportMarkdown: report,
          plotName: run.plotName,
        ),
        temperature: 0.35,
        modelName: run.modelName,
        promptTrace: traceRecorder.config(label: 'build_story_engine'),
      );
      final storyEngine = _storyEngineNormalizer.normalize(storyEngineRaw);
      if (storyEngine.trim().isEmpty) {
        throw StateError('模型没有返回可保存的 Story Engine。');
      }

      await transition(
        PlotAnalysisStatus.succeeded,
        null,
        message: '分析完成。',
        analysisReportMarkdown: report,
        plotSkeletonMarkdown: skeleton,
        storyEngineMarkdown: storyEngine,
        completedAt: DateTime.now(),
      );
    } on Object catch (error) {
      await transition(
        PlotAnalysisStatus.failed,
        null,
        message: '分析失败。',
        errorMessage: sanitizeAnalysisError(error, provider),
        completedAt: DateTime.now(),
      );
      rethrow;
    }
  }

  Future<PlotChunkSketch> _parseSketch({
    required String raw,
    required int chunkIndex,
    required int chunkCount,
    required ProviderConfig provider,
    required PromptTraceRecorder traceRecorder,
  }) async {
    final normalized = _stripMarkdownFence(raw);
    try {
      return _sketchDocumentParser.parse(
        markdown: normalized,
        chunkIndex: chunkIndex,
        chunkCount: chunkCount,
      );
    } on Object catch (error) {
      return _repairAndParseSketch(
        invalidSketchMarkdown: normalized,
        parseError: error,
        chunkIndex: chunkIndex,
        chunkCount: chunkCount,
        provider: provider,
        traceRecorder: traceRecorder,
      );
    }
  }

  Future<PlotChunkSketch> _repairAndParseSketch({
    required String invalidSketchMarkdown,
    required Object parseError,
    required int chunkIndex,
    required int chunkCount,
    required ProviderConfig provider,
    required PromptTraceRecorder traceRecorder,
  }) async {
    try {
      final repaired = await _completionService.completeMarkdown(
        provider: provider,
        prompt: _promptBuilder.buildSketchRepairPrompt(
          invalidSketchMarkdown: invalidSketchMarkdown,
          parseError: parseError.toString(),
        ),
        temperature: 0,
        maxAttempts: 1,
        modelName: traceRecorder.modelName,
        promptTrace: traceRecorder.config(
          label: 'repair_sketch_chunk_${chunkIndex + 1}',
        ),
      );
      return _sketchDocumentParser.parse(
        markdown: _stripMarkdownFence(repaired),
        chunkIndex: chunkIndex,
        chunkCount: chunkCount,
      );
    } on Object catch (repairError) {
      throw FormatException(
        'Sketch chunk ${chunkIndex + 1} produced invalid YAML+MD: '
        '$parseError; repair failed: $repairError',
      );
    }
  }

  Future<String> _buildSkeleton({
    required ProviderConfig provider,
    required String modelName,
    required List<PlotChunkSketch> sketches,
    required PlotInputClassification classification,
    required int chunkCount,
    required PromptTraceRecorder traceRecorder,
  }) async {
    final sketchPayload = sketches.map((item) => item.toJson()).toList();
    final roughTokens =
        sketchPayload
            .map((item) => jsonEncode(item).length)
            .fold<int>(0, (sum, length) => sum + length) ~/
        3;
    if (roughTokens <= skeletonHierarchicalTokenThreshold) {
      return _completionService.completeMarkdown(
        provider: provider,
        prompt: _promptBuilder.buildSkeletonPrompt(
          sketches: sketchPayload,
          classification: classification,
          chunkCount: chunkCount,
        ),
        temperature: 0.35,
        modelName: modelName,
        promptTrace: traceRecorder.config(label: 'build_skeleton'),
      );
    }
    return _buildSkeletonHierarchically(
      provider: provider,
      modelName: modelName,
      sketchPayload: sketchPayload,
      classification: classification,
      chunkCount: chunkCount,
      traceRecorder: traceRecorder,
    );
  }

  Future<String> _buildSkeletonHierarchically({
    required ProviderConfig provider,
    required String modelName,
    required List<Map<String, Object?>> sketchPayload,
    required PlotInputClassification classification,
    required int chunkCount,
    required PromptTraceRecorder traceRecorder,
  }) async {
    final groups = <List<Map<String, Object?>>>[];
    for (
      var index = 0;
      index < sketchPayload.length;
      index += skeletonGroupSize
    ) {
      groups.add(
        sketchPayload.sublist(
          index,
          (index + skeletonGroupSize).clamp(0, sketchPayload.length),
        ),
      );
    }
    final subSkeletons = <Map<String, Object?>>[];
    for (var index = 0; index < groups.length; index += 1) {
      final markdown = await _completionService.completeMarkdown(
        provider: provider,
        prompt: _promptBuilder.buildSkeletonGroupPrompt(
          groupSketches: groups[index],
          groupIndex: index,
          groupCount: groups.length,
          classification: classification,
        ),
        temperature: 0.35,
        modelName: modelName,
        promptTrace: traceRecorder.config(
          label: 'build_skeleton_group_${index + 1}',
        ),
      );
      subSkeletons.add({
        'group_index': index,
        'group_count': groups.length,
        'markdown': markdown,
      });
    }
    return _completionService.completeMarkdown(
      provider: provider,
      prompt: _promptBuilder.buildSkeletonPrompt(
        sketches: subSkeletons,
        classification: classification,
        chunkCount: chunkCount,
      ),
      temperature: 0.35,
      modelName: modelName,
      promptTrace: traceRecorder.config(label: 'build_skeleton'),
    );
  }

  String _stripMarkdownFence(String raw) {
    final trimmed = raw.trim();
    final match = RegExp(
      r'^```(?:markdown|md)?\s*([\s\S]*?)\s*```$',
      caseSensitive: false,
    ).firstMatch(trimmed);
    return match?.group(1)?.trim() ?? trimmed;
  }

  void _appendLog(StringBuffer buffer, String message) {
    final timestamp = DateTime.now().toIso8601String();
    buffer.writeln('[$timestamp] $message');
  }
}
