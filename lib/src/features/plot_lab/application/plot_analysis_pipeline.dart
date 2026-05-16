import '../../../core/llm/application/markdown_completion_service.dart';
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
    PlotLabPromptBuilder promptBuilder = const PlotLabPromptBuilder(),
    StoryEngineNormalizer storyEngineNormalizer = const StoryEngineNormalizer(),
    PlotChunkSketchDocumentParser sketchDocumentParser =
        const PlotChunkSketchDocumentParser(),
  }) : _repository = repository,
       _completionService = completionService,
       _promptBuilder = promptBuilder,
       _storyEngineNormalizer = storyEngineNormalizer,
       _sketchDocumentParser = sketchDocumentParser;

  final PlotLabRepository _repository;
  final MarkdownCompletionService _completionService;
  final PlotLabPromptBuilder _promptBuilder;
  final StoryEngineNormalizer _storyEngineNormalizer;
  final PlotChunkSketchDocumentParser _sketchDocumentParser;

  static const chunkSize = 12000;

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
      final chunks = splitIntoChunks(sample.content);
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
          prompt: _promptBuilder.buildSketchPrompt(
            chunk: chunks[index],
            chunkIndex: index,
            chunkCount: chunks.length,
            classification: classification,
          ),
          temperature: 0.25,
        );
        final sketch = _parseSketch(raw, index, chunks.length);
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
      final skeleton = await _completionService.completeMarkdown(
        provider: provider,
        prompt: _promptBuilder.buildSkeletonPrompt(
          sketches: sketches.map((item) => item.toJson()).toList(),
          classification: classification,
          chunkCount: chunks.length,
        ),
        temperature: 0.35,
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
        errorMessage: _sanitizeError(error, provider),
        completedAt: DateTime.now(),
      );
      rethrow;
    }
  }

  List<String> splitIntoChunks(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return const [];
    }
    if (normalized.length <= chunkSize) {
      return [normalized];
    }

    final paragraphs = normalized.split(RegExp(r'\n{2,}'));
    final chunks = <String>[];
    final buffer = StringBuffer();
    for (final paragraph in paragraphs) {
      if (buffer.isNotEmpty &&
          buffer.length + paragraph.length + 2 > chunkSize) {
        chunks.add(buffer.toString().trim());
        buffer.clear();
      }
      if (paragraph.length > chunkSize) {
        var start = 0;
        while (start < paragraph.length) {
          final end = (start + chunkSize).clamp(0, paragraph.length);
          chunks.add(paragraph.substring(start, end).trim());
          start = end;
        }
        continue;
      }
      if (buffer.isNotEmpty) {
        buffer.write('\n\n');
      }
      buffer.write(paragraph);
    }
    if (buffer.isNotEmpty) {
      chunks.add(buffer.toString().trim());
    }
    return chunks.where((chunk) => chunk.isNotEmpty).toList(growable: false);
  }

  PlotChunkSketch _parseSketch(String raw, int chunkIndex, int chunkCount) {
    try {
      return _sketchDocumentParser.parse(
        markdown: _stripMarkdownFence(raw),
        chunkIndex: chunkIndex,
        chunkCount: chunkCount,
      );
    } on Object catch (error) {
      throw FormatException(
        'Sketch chunk $chunkIndex produced invalid YAML+MD: $error',
      );
    }
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

  String _sanitizeError(Object error, ProviderConfig provider) {
    var message = error.toString();
    final apiKey = provider.apiKey.trim();
    if (apiKey.isNotEmpty) {
      message = message.replaceAll(apiKey, '[REDACTED]');
    }
    if (message.length <= 220) {
      return message;
    }
    return '${message.substring(0, 217)}...';
  }
}
