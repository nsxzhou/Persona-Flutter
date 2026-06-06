import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:persona_flutter/src/core/image_generation/application/image_generation_service.dart';
import 'package:persona_flutter/src/core/image_generation/domain/image_generation_client.dart';
import 'package:persona_flutter/src/core/image_generation/domain/image_generation_request.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/chapter_illustration_service.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_workshop.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_workshop_repository.dart';
import 'package:persona_flutter/src/features/settings/domain/image_provider_config.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';

void main() {
  test(
    'generateIllustration persists base64 images as local PNG drafts',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'illustration-b64',
      );
      addTearDown(() => directory.delete(recursive: true));
      final repository = _RecordingRepository();
      final service = ChapterIllustrationService(
        repository: repository,
        imageGenerationService: ImageGenerationService(
          client: _StaticImageClient(
            GeneratedImage(b64Json: base64Encode(<int>[1, 2, 3, 4])),
          ),
        ),
        supportDirectory: () async => directory,
      );

      final illustration = await service.generateIllustration(
        chapter: _chapter(),
        paragraphIndex: 2,
        selectedText: '  corridor light  ',
        prompt: '  dim corridor  ',
        provider: _provider(),
        modelName: 'image-v1',
      );

      expect(illustration.status, ChapterIllustrationStatus.draft);
      expect(illustration.mimeType, 'image/png');
      expect(illustration.localPath, endsWith('.png'));
      expect(await File(illustration.localPath).readAsBytes(), <int>[
        1,
        2,
        3,
        4,
      ]);
      expect(repository.lastInput!.prompt, 'dim corridor');
      expect(
        repository.lastInput!.anchorTextHash,
        anchorTextHash('corridor light'),
      );
    },
  );

  test(
    'generateIllustration downloads URL images with response MIME type',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'illustration-url',
      );
      addTearDown(() => directory.delete(recursive: true));
      final repository = _RecordingRepository();
      final service = ChapterIllustrationService(
        repository: repository,
        imageGenerationService: ImageGenerationService(
          client: _StaticImageClient(
            const GeneratedImage(
              url: 'https://images.example.test/generated.jpg',
            ),
          ),
        ),
        httpClient: MockClient(
          (_) async => http.Response.bytes(
            <int>[9, 8, 7],
            200,
            headers: <String, String>{
              'content-type': 'image/jpeg; charset=binary',
            },
          ),
        ),
        supportDirectory: () async => directory,
      );

      final illustration = await service.generateIllustration(
        chapter: _chapter(),
        paragraphIndex: 0,
        selectedText: 'rain',
        prompt: 'rain',
        provider: _provider(),
        modelName: 'image-v1',
      );

      expect(illustration.mimeType, 'image/jpeg');
      expect(illustration.localPath, endsWith('.jpg'));
      expect(await File(illustration.localPath).readAsBytes(), <int>[9, 8, 7]);
    },
  );

  test('generateIllustration forwards image generation parameters', () async {
    final directory = await Directory.systemTemp.createTemp(
      'illustration-params',
    );
    addTearDown(() => directory.delete(recursive: true));
    final client = _StaticImageClient(
      GeneratedImage(b64Json: base64Encode(<int>[5, 6, 7])),
    );
    final service = ChapterIllustrationService(
      repository: _RecordingRepository(),
      imageGenerationService: ImageGenerationService(client: client),
      supportDirectory: () async => directory,
    );

    await service.generateIllustration(
      chapter: _chapter(),
      paragraphIndex: 1,
      selectedText: 'blue door',
      prompt: '  blue door at dusk  ',
      provider: _provider(),
      modelName: 'custom-image-model',
      aspectRatio: ImageAspectRatioPreset.wide,
      size: ImageSizePreset.twoK,
      quality: ImageQualityPreset.high,
      responseFormat: ImageResponseFormat.b64Json,
    );

    expect(client.lastRequest, isNotNull);
    expect(client.lastRequest!.model, 'custom-image-model');
    expect(client.lastRequest!.prompt, 'blue door at dusk');
    expect(client.lastRequest!.size, '2736x1536');
    expect(client.lastRequest!.quality, 'high');
    expect(client.lastRequest!.responseFormat, ImageResponseFormat.b64Json);
  });
}

class _StaticImageClient implements ImageGenerationClient {
  _StaticImageClient(this.image);

  final GeneratedImage image;
  ImageGenerationRequest? lastRequest;

  @override
  Future<ImageGenerationResult> generateImage({
    required ImageProviderConfig provider,
    required ImageGenerationRequest request,
  }) async {
    lastRequest = request;
    return ImageGenerationResult(created: 1, images: <GeneratedImage>[image]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RecordingRepository implements NovelWorkshopRepository {
  ChapterIllustrationInput? lastInput;

  @override
  Future<ChapterIllustration> createChapterIllustration(
    ChapterIllustrationInput input,
  ) async {
    lastInput = input;
    final now = DateTime(2026, 5, 25);
    return ChapterIllustration(
      id: 'illustration-1',
      projectId: input.projectId,
      chapterId: input.chapterId,
      chapterPlanId: input.chapterPlanId,
      paragraphIndex: input.paragraphIndex,
      anchorTextHash: input.anchorTextHash,
      selectedText: input.selectedText,
      prompt: input.prompt,
      providerId: input.providerId,
      modelName: input.modelName,
      localPath: input.localPath,
      mimeType: input.mimeType,
      status: ChapterIllustrationStatus.draft,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProjectChapter _chapter() {
  return ProjectChapter(
    id: 'chapter-1',
    projectId: 'project-1',
    chapterPlanId: 'plan-1',
    chapterIndex: 1,
    title: 'Chapter 1',
    contentMarkdown: 'A corridor.',
    contentHash: 'hash',
    continuityVerdict: ContinuityVerdict.pass,
    continuityReportMarkdown: '',
    memorySyncStatus: MemorySyncStatus.idle,
    memorySyncContentHash: '',
    memorySyncProposedRuntimeState: '',
    memorySyncProposedRuntimeThreads: '',
    memorySyncProposedStorySummary: '',
    createdAt: DateTime(2026, 5, 25),
    updatedAt: DateTime(2026, 5, 25),
  );
}

ImageProviderConfig _provider() {
  final now = DateTime(2026, 5, 25);
  return ImageProviderConfig(
    id: 'provider-1',
    name: 'Images',
    baseUrl: 'https://images.example.test',
    apiKey: 'secret',
    defaultModel: 'image-v1',
    isEnabled: true,
    testStatus: ProviderTestStatus.untested,
    createdAt: now,
    updatedAt: now,
  );
}
