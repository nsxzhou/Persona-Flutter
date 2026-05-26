import 'dart:async';

import '../../../core/llm/domain/llm_error_utils.dart';
import '../../settings/domain/image_provider_config.dart';
import '../../settings/domain/image_provider_config_repository.dart';
import '../domain/novel_workshop.dart';
import '../domain/novel_workshop_repository.dart';
import 'chapter_illustration_service.dart';

class ChapterIllustrationGenerationPipeline {
  const ChapterIllustrationGenerationPipeline({
    required NovelWorkshopRepository repository,
    required ImageProviderConfigRepository imageProviderRepository,
    required ChapterIllustrationService illustrationService,
  }) : _repository = repository,
       _imageProviderRepository = imageProviderRepository,
       _illustrationService = illustrationService;

  final NovelWorkshopRepository _repository;
  final ImageProviderConfigRepository _imageProviderRepository;
  final ChapterIllustrationService _illustrationService;

  Future<ChapterIllustrationGenerationResult> run(String runId) async {
    var currentRun = await _requireRun(runId);
    final log = StringBuffer(currentRun.logs);
    ImageProviderConfig? provider;

    Future<void> transition(
      ChapterIllustrationGenerationStatus status,
      ChapterIllustrationGenerationStage? stage, {
      String? message,
      String? errorMessage,
      String? illustrationId,
      DateTime? startedAt,
      DateTime? completedAt,
    }) async {
      if (message != null && message.trim().isNotEmpty) {
        _appendLog(log, message);
      }
      currentRun = await _repository
          .updateChapterIllustrationGenerationRunState(
            id: currentRun.id,
            status: status,
            stage: stage,
            errorMessage: errorMessage,
            logs: log.toString(),
            illustrationId: illustrationId,
            startedAt: startedAt,
            completedAt: completedAt,
          );
    }

    try {
      final chapter = await _requireChapter(currentRun.chapterId);
      provider = await _requireProvider(currentRun.providerId);
      final aspectRatio = ImageAspectRatioPreset.fromRatio(
        currentRun.aspectRatio,
      );
      final size = ImageSizePreset.fromTier(currentRun.size);
      final quality = ImageQualityPreset.fromQuality(currentRun.quality);
      final responseFormat = _responseFormatFromStorage(
        currentRun.responseFormat,
      );

      await transition(
        ChapterIllustrationGenerationStatus.running,
        ChapterIllustrationGenerationStage.generatingImage,
        message: '阶段: 生成图片。调用图像 Provider。',
        startedAt: DateTime.now(),
      );

      final illustration = await _illustrationService.generateIllustration(
        chapter: chapter,
        paragraphIndex: currentRun.paragraphIndex,
        selectedText: currentRun.selectedText,
        prompt: currentRun.prompt,
        provider: provider,
        modelName: currentRun.modelName,
        aspectRatio: aspectRatio,
        size: size,
        quality: provider.providerKind == ImageProviderKind.grok
            ? null
            : quality,
        responseFormat: provider.providerKind == ImageProviderKind.grok
            ? ImageResponseFormat.url
            : responseFormat,
      );

      await transition(
        ChapterIllustrationGenerationStatus.running,
        ChapterIllustrationGenerationStage.persistingDraft,
        message: '阶段: 保存草稿。写入插图库待确认。',
        illustrationId: illustration.id,
      );
      await transition(
        ChapterIllustrationGenerationStatus.succeeded,
        null,
        message: '插图生成完成，等待确认。',
        illustrationId: illustration.id,
        completedAt: DateTime.now(),
      );

      return ChapterIllustrationGenerationResult(
        run: currentRun,
        workflowTaskId: currentRun.workflowTaskId,
        illustration: illustration,
      );
    } on Object catch (error) {
      await transition(
        ChapterIllustrationGenerationStatus.failed,
        null,
        message: '插图生成失败。',
        errorMessage: sanitizeLlmError(error, provider?.apiKey ?? ''),
        completedAt: DateTime.now(),
      );
      rethrow;
    }
  }

  Future<ChapterIllustrationGenerationRun> _requireRun(String runId) async {
    final run = await _repository.findChapterIllustrationGenerationRun(runId);
    if (run == null) {
      throw StateError(
        'Chapter illustration generation run does not exist: $runId',
      );
    }
    return run;
  }

  Future<ProjectChapter> _requireChapter(String chapterId) async {
    final chapter = await _repository.findChapter(chapterId);
    if (chapter == null) {
      throw StateError('插图章节不存在。');
    }
    return chapter;
  }

  Future<ImageProviderConfig> _requireProvider(String providerId) async {
    final provider = await _imageProviderRepository.findProvider(providerId);
    if (provider == null) {
      throw StateError('图像 Provider 不存在。');
    }
    if (!provider.isEnabled) {
      throw StateError('图像 Provider 已停用。');
    }
    return provider;
  }

  ImageResponseFormat _responseFormatFromStorage(String value) {
    final normalized = value.trim();
    for (final format in ImageResponseFormat.values) {
      if (format.name == normalized) {
        return format;
      }
    }
    return ImageResponseFormat.url;
  }
}

void _appendLog(StringBuffer log, String message) {
  final timestamp = DateTime.now().toIso8601String();
  if (log.isNotEmpty && !log.toString().endsWith('\n')) {
    log.writeln();
  }
  log.writeln('[$timestamp] $message');
}
