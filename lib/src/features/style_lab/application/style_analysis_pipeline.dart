import '../../../core/llm/application/markdown_completion_service.dart';
import '../../settings/domain/provider_config.dart';
import '../domain/style_analysis_run.dart';
import '../domain/style_lab_repository.dart';
import 'style_lab_prompts.dart';

class StyleAnalysisPipeline {
  const StyleAnalysisPipeline({
    required StyleLabRepository repository,
    required MarkdownCompletionService completionService,
    StyleLabPromptBuilder promptBuilder = const StyleLabPromptBuilder(),
  }) : _repository = repository,
       _completionService = completionService,
       _promptBuilder = promptBuilder;

  final StyleLabRepository _repository;
  final MarkdownCompletionService _completionService;
  final StyleLabPromptBuilder _promptBuilder;

  static const chunkSize = 12000;

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
        message: '准备样本文本。',
        startedAt: DateTime.now(),
      );
      final chunks = splitIntoChunks(sample.content);
      await transition(
        StyleAnalysisStatus.running,
        StyleAnalysisStage.analyzingChunks,
        message: '开始分块分析：${chunks.length} 个 chunk。',
        chunkCount: chunks.length,
      );

      final chunkAnalyses = <String>[];
      for (var index = 0; index < chunks.length; index += 1) {
        final prompt = _promptBuilder.buildChunkAnalysisPrompt(
          chunk: chunks[index],
          chunkIndex: index,
          chunkCount: chunks.length,
        );
        final analysis = await _completionService.completeMarkdown(
          provider: provider,
          prompt: prompt,
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
        message: '聚合分块分析。',
      );
      final merged = chunkAnalyses.length == 1
          ? chunkAnalyses.single
          : await _completionService.completeMarkdown(
              provider: provider,
              prompt: _promptBuilder.buildMergePrompt(
                chunkAnalyses: chunkAnalyses,
              ),
            );

      await transition(
        StyleAnalysisStatus.running,
        StyleAnalysisStage.reporting,
        message: '生成最终分析报告。',
      );
      final report = await _completionService.completeMarkdown(
        provider: provider,
        prompt: _promptBuilder.buildReportPrompt(
          mergedAnalysisMarkdown: merged,
        ),
      );

      await transition(
        StyleAnalysisStatus.running,
        StyleAnalysisStage.buildingVoiceProfile,
        message: '生成 YAML+MD Voice Profile。',
        analysisReportMarkdown: report,
      );
      final profile = await _completionService.completeMarkdown(
        provider: provider,
        prompt: _promptBuilder.buildVoiceProfilePrompt(
          reportMarkdown: report,
          styleName: run.styleName,
        ),
        temperature: 0.35,
      );

      await transition(
        StyleAnalysisStatus.succeeded,
        null,
        message: '分析完成。',
        analysisReportMarkdown: report,
        voiceProfileMarkdown: profile,
        completedAt: DateTime.now(),
      );
    } on Object catch (error) {
      await transition(
        StyleAnalysisStatus.failed,
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
