import '../../../core/analysis/analysis_text_tools.dart';
import '../../../core/llm/application/markdown_completion_service.dart';
import '../../../core/tasks/application/prompt_trace_recorder.dart';
import '../../../core/tasks/application/workflow_task_repository.dart';
import '../../settings/domain/provider_config.dart';
import '../domain/style_analysis_run.dart';
import '../domain/style_lab_repository.dart';
import 'style_input_classification.dart';
import 'style_lab_prompts.dart';
import 'voice_profile_front_matter.dart';

class StyleAnalysisPipeline {
  const StyleAnalysisPipeline({
    required StyleLabRepository repository,
    required MarkdownCompletionService completionService,
    required WorkflowTaskRepository workflowTaskRepository,
    StyleLabPromptBuilder promptBuilder = const StyleLabPromptBuilder(),
    VoiceProfileFrontMatterParser frontMatterParser =
        const VoiceProfileFrontMatterParser(),
  }) : _repository = repository,
       _completionService = completionService,
       _workflowTaskRepository = workflowTaskRepository,
       _promptBuilder = promptBuilder,
       _frontMatterParser = frontMatterParser;

  final StyleLabRepository _repository;
  final MarkdownCompletionService _completionService;
  final WorkflowTaskRepository _workflowTaskRepository;
  final StyleLabPromptBuilder _promptBuilder;
  final VoiceProfileFrontMatterParser _frontMatterParser;

  Future<void> run({
    required String runId,
    required ProviderConfig provider,
  }) async {
    final run = await _repository.findRun(runId);
    if (run == null) {
      throw StateError('Style analysis run does not exist: $runId');
    }
    final sample = await _repository.findSample(run.sampleId);
    if (sample == null) {
      throw StateError('Style sample does not exist: ${run.sampleId}');
    }

    var currentStage = run.stage;
    final traceRecorder = PromptTraceRecorder(
      repository: _workflowTaskRepository,
      workflowTaskId: run.workflowTaskId,
      workflowKind: styleAnalysisWorkflowTaskKind,
      runId: run.id,
      providerId: provider.id,
      providerApiKey: provider.apiKey,
      modelName: run.modelName,
      stageLabel: () => currentStage?.name,
    );
    final log = StringBuffer(run.logs);
    Future<void> transition(
      StyleAnalysisStatus status,
      StyleAnalysisStage? stage, {
      String? message,
      String? errorMessage,
      String? analysisReportMarkdown,
      String? voiceProfileMarkdown,
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
        voiceProfileMarkdown: voiceProfileMarkdown,
        chunkCount: chunkCount,
        startedAt: startedAt,
        completedAt: completedAt,
      );
    }

    try {
      await transition(
        StyleAnalysisStatus.running,
        StyleAnalysisStage.preparingInput,
        message: '阶段: 准备输入。准备样本文本。',
        startedAt: DateTime.now(),
      );
      final chunks = splitAnalysisTextIntoChunks(sample.content);
      if (chunks.isEmpty) {
        throw StateError('样本文本没有可分析的有效内容。');
      }
      final classification = StyleInputClassification.detect(
        text: sample.content,
        chunkCount: chunks.length,
      );
      await transition(
        StyleAnalysisStatus.running,
        StyleAnalysisStage.analyzingChunks,
        message: '阶段: 分块分析。开始分块分析：${chunks.length} 个 chunk。',
        chunkCount: chunks.length,
      );

      final chunkAnalyses = <String>[];
      for (var index = 0; index < chunks.length; index += 1) {
        final prompt = _promptBuilder.buildChunkAnalysisPrompt(
          chunk: chunks[index],
          chunkIndex: index,
          chunkCount: chunks.length,
          classification: classification,
        );
        final analysis = await _completionService.completeMarkdown(
          provider: provider,
          prompt: prompt,
          modelName: run.modelName,
          promptTrace: traceRecorder.config(
            label: 'chunk_analysis_${index + 1}',
          ),
        );
        chunkAnalyses.add(analysis);
        await transition(
          StyleAnalysisStatus.running,
          StyleAnalysisStage.analyzingChunks,
          message: '完成 chunk ${index + 1}/${chunks.length}。',
        );
      }

      await transition(
        StyleAnalysisStatus.running,
        StyleAnalysisStage.aggregating,
        message: '阶段: 聚合分析。聚合分块分析。',
      );
      final merged = chunkAnalyses.length == 1
          ? chunkAnalyses.single
          : await _completionService.completeMarkdown(
              provider: provider,
              prompt: _promptBuilder.buildMergePrompt(
                chunkAnalyses: chunkAnalyses,
                classification: classification,
              ),
              modelName: run.modelName,
              promptTrace: traceRecorder.config(label: 'merge_chunks'),
            );

      await transition(
        StyleAnalysisStatus.running,
        StyleAnalysisStage.reporting,
        message: '阶段: 生成报告。生成最终分析报告。',
      );
      final report = await _completionService.completeMarkdown(
        provider: provider,
        prompt: _promptBuilder.buildReportPrompt(
          mergedAnalysisMarkdown: merged,
          classification: classification,
        ),
        modelName: run.modelName,
        promptTrace: traceRecorder.config(label: 'build_report'),
      );

      await transition(
        StyleAnalysisStatus.running,
        StyleAnalysisStage.buildingVoiceProfile,
        message: '阶段: 生成 Voice Profile。生成 YAML+MD Voice Profile。',
        analysisReportMarkdown: report,
      );
      final profile = await _completionService.completeMarkdown(
        provider: provider,
        prompt: _promptBuilder.buildVoiceProfilePrompt(
          reportMarkdown: report,
          styleName: run.styleName,
        ),
        temperature: 0.35,
        modelName: run.modelName,
        promptTrace: traceRecorder.config(label: 'build_voice_profile'),
      );
      final normalizedProfile = await _validateOrRepairVoiceProfile(
        profile,
        provider: provider,
        traceRecorder: traceRecorder,
      );

      await transition(
        StyleAnalysisStatus.running,
        StyleAnalysisStage.persistingResult,
        message: '阶段: 保存结果。写入分析报告与 Voice Profile。',
      );
      await transition(
        StyleAnalysisStatus.succeeded,
        null,
        message: '分析完成。',
        analysisReportMarkdown: report,
        voiceProfileMarkdown: normalizedProfile,
        completedAt: DateTime.now(),
      );
    } on Object catch (error) {
      await transition(
        StyleAnalysisStatus.failed,
        null,
        message: '分析失败。',
        errorMessage: sanitizeAnalysisError(error, provider),
        completedAt: DateTime.now(),
      );
      rethrow;
    }
  }

  Future<String> _validateOrRepairVoiceProfile(
    String profile, {
    required ProviderConfig provider,
    required PromptTraceRecorder traceRecorder,
  }) async {
    try {
      _frontMatterParser.parse(profile);
      return profile;
    } on Object catch (error) {
      return _repairAndValidateVoiceProfile(
        invalidProfileMarkdown: profile,
        parseError: error,
        provider: provider,
        traceRecorder: traceRecorder,
      );
    }
  }

  Future<String> _repairAndValidateVoiceProfile({
    required String invalidProfileMarkdown,
    required Object parseError,
    required ProviderConfig provider,
    required PromptTraceRecorder traceRecorder,
  }) async {
    try {
      final repaired = await _completionService.completeMarkdown(
        provider: provider,
        prompt: _promptBuilder.buildVoiceProfileRepairPrompt(
          invalidProfileMarkdown: invalidProfileMarkdown,
          parseError: parseError.toString(),
        ),
        temperature: 0,
        maxAttempts: 1,
        modelName: traceRecorder.modelName,
        promptTrace: traceRecorder.config(label: 'repair_voice_profile'),
      );
      _frontMatterParser.parse(repaired);
      return repaired;
    } on Object catch (repairError) {
      throw VoiceProfileValidationException(
        '$parseError; repair failed: $repairError',
      );
    }
  }

  void _appendLog(StringBuffer buffer, String message) {
    final timestamp = DateTime.now().toIso8601String();
    buffer.writeln('[$timestamp] $message');
  }
}
