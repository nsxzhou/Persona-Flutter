import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/database/app_database.dart';
import 'package:persona_flutter/src/core/image_generation/application/image_generation_service.dart';
import 'package:persona_flutter/src/core/image_generation/domain/image_generation_client.dart';
import 'package:persona_flutter/src/core/image_generation/domain/image_generation_request.dart';
import 'package:persona_flutter/src/core/tasks/data/drift_workflow_task_repository.dart';
import 'package:persona_flutter/src/core/tasks/domain/workflow_task.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/chapter_illustration_generation_pipeline.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/chapter_illustration_service.dart';
import 'package:persona_flutter/src/features/novel_workshop/data/drift_novel_workshop_repository.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_workshop.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/writing_context.dart';
import 'package:persona_flutter/src/features/projects/data/drift_project_repository.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';
import 'package:persona_flutter/src/features/settings/data/drift_image_provider_config_repository.dart';
import 'package:persona_flutter/src/features/settings/data/drift_provider_config_repository.dart';
import 'package:persona_flutter/src/features/settings/domain/image_provider_config.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';

void main() {
  test(
    'pipeline creates draft illustration and completes workflow task',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final directory = await Directory.systemTemp.createTemp(
        'illustration-pipeline-success',
      );
      addTearDown(() => directory.delete(recursive: true));
      final imageClient = _RecordingImageClient(
        GeneratedImage(b64Json: base64Encode(<int>[1, 2, 3])),
      );
      final fixture = await _Fixture.create(
        database,
        directory: directory,
        imageClient: imageClient,
      );
      final run = await fixture.repository
          .createChapterIllustrationGenerationRun(
            ChapterIllustrationGenerationRunInput(
              projectId: fixture.project.id,
              chapterId: fixture.chapter.id,
              chapterPlanId: fixture.plan.id,
              paragraphIndex: 0,
              anchorTextHash: 'hash',
              selectedText: '旧灯塔映着海雾。',
              prompt: '旧灯塔，海雾，冷色调。',
              providerId: fixture.imageProvider.id,
              modelName: 'custom-image-model',
              aspectRatio: ImageAspectRatioPreset.wide.ratio,
              size: ImageSizePreset.twoK.tier,
              quality: ImageQualityPreset.high.quality,
              responseFormat: ImageResponseFormat.b64Json.name,
            ),
          );

      final result = await fixture.pipeline.run(run.id);

      expect(result.run.status, ChapterIllustrationGenerationStatus.succeeded);
      expect(result.illustration, isNotNull);
      expect(result.illustration!.status, ChapterIllustrationStatus.draft);
      final savedRun = await fixture.repository
          .findChapterIllustrationGenerationRun(run.id);
      expect(savedRun!.status, ChapterIllustrationGenerationStatus.succeeded);
      expect(savedRun.illustrationId, result.illustration!.id);
      expect(savedRun.logs, contains('生成图片'));
      expect(savedRun.logs, contains('保存草稿'));
      final illustrations = await fixture.repository
          .watchChapterIllustrations(fixture.project.id)
          .first;
      expect(illustrations, hasLength(1));
      expect(await File(illustrations.single.localPath).readAsBytes(), <int>[
        1,
        2,
        3,
      ]);
      final task = await fixture.workflowRepository.findTask(
        run.workflowTaskId,
      );
      expect(task!.status, WorkflowTaskStatus.succeeded);
      expect(task.stage, isNull);
      expect(imageClient.lastRequest!.model, 'custom-image-model');
      expect(imageClient.lastRequest!.prompt, '旧灯塔，海雾，冷色调。');
      expect(imageClient.lastRequest!.size, '2736x1536');
      expect(imageClient.lastRequest!.quality, 'high');
      expect(
        imageClient.lastRequest!.responseFormat,
        ImageResponseFormat.b64Json,
      );
    },
  );

  test(
    'pipeline records failure without creating empty illustration',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final directory = await Directory.systemTemp.createTemp(
        'illustration-pipeline-failure',
      );
      addTearDown(() => directory.delete(recursive: true));
      final fixture = await _Fixture.create(
        database,
        directory: directory,
        imageClient: _ThrowingImageClient(StateError('sk-image-secret failed')),
      );
      final run = await fixture.repository
          .createChapterIllustrationGenerationRun(
            ChapterIllustrationGenerationRunInput(
              projectId: fixture.project.id,
              chapterId: fixture.chapter.id,
              chapterPlanId: fixture.plan.id,
              paragraphIndex: 0,
              anchorTextHash: 'hash',
              selectedText: '旧灯塔。',
              prompt: '旧灯塔。',
              providerId: fixture.imageProvider.id,
              modelName: fixture.imageProvider.defaultModel,
              aspectRatio: ImageAspectRatioPreset.square.ratio,
              size: ImageSizePreset.oneK.tier,
              quality: ImageQualityPreset.auto.quality,
              responseFormat: ImageResponseFormat.url.name,
            ),
          );

      await expectLater(fixture.pipeline.run(run.id), throwsStateError);

      final failedRun = await fixture.repository
          .findChapterIllustrationGenerationRun(run.id);
      expect(failedRun!.status, ChapterIllustrationGenerationStatus.failed);
      expect(failedRun.errorMessage, contains('[REDACTED]'));
      expect(failedRun.errorMessage, isNot(contains('sk-image-secret')));
      expect(
        await fixture.repository
            .watchChapterIllustrations(fixture.project.id)
            .first,
        isEmpty,
      );
      final task = await fixture.workflowRepository.findTask(
        run.workflowTaskId,
      );
      expect(task!.status, WorkflowTaskStatus.failed);
      expect(task.errorMessage, failedRun.errorMessage);
    },
  );
}

class _Fixture {
  const _Fixture({
    required this.project,
    required this.plan,
    required this.chapter,
    required this.imageProvider,
    required this.repository,
    required this.workflowRepository,
    required this.pipeline,
  });

  final WritingProject project;
  final ChapterPlan plan;
  final ProjectChapter chapter;
  final ImageProviderConfig imageProvider;
  final DriftNovelWorkshopRepository repository;
  final DriftWorkflowTaskRepository workflowRepository;
  final ChapterIllustrationGenerationPipeline pipeline;

  static Future<_Fixture> create(
    AppDatabase database, {
    required Directory directory,
    required ImageGenerationClient imageClient,
  }) async {
    final providerRepository = DriftProviderConfigRepository(database);
    await providerRepository.saveProvider(
      input: const ProviderConfigInput(
        name: 'OpenAI',
        baseUrl: 'https://api.example.com/v1',
        apiKey: 'sk-text-secret',
        defaultModel: 'gpt-4.1-mini',
        systemPrompt: '',
        isEnabled: true,
      ),
    );
    final textProvider =
        (await providerRepository.watchProviders().first).single;
    final projectRepository = DriftProjectRepository(database);
    await projectRepository.saveProject(
      input: WritingProjectInput(
        title: '雾港纪事',
        description: '',
        status: ProjectStatus.active,
        defaultProviderId: textProvider.id,
        defaultModelName: textProvider.defaultModel,
      ),
    );
    final project =
        (await projectRepository.watchProjects(ProjectStatus.active).first)
            .single;

    final imageProviderRepository = DriftImageProviderConfigRepository(
      database,
    );
    await imageProviderRepository.saveProvider(
      input: const ImageProviderConfigInput(
        name: 'OpenAI Images',
        baseUrl: 'https://api.example.com/v1',
        apiKey: 'sk-image-secret',
        defaultModel: 'gpt-image-1',
        modelNames: ['gpt-image-1', 'custom-image-model'],
        defaultResponseFormat: ImageResponseFormat.b64Json,
        isEnabled: true,
      ),
    );
    final imageProvider =
        (await imageProviderRepository.watchProviders().first).single;

    final repository = DriftNovelWorkshopRepository(database);
    final volume = await repository.saveChapterVolume(
      input: ChapterVolumeInput(
        projectId: project.id,
        volumeIndex: 1,
        title: '第一卷',
      ),
    );
    final plan = await repository.saveChapterPlan(
      input: ChapterPlanInput(
        projectId: project.id,
        volumeId: volume.id,
        volumeIndex: volume.volumeIndex,
        volumeTitle: volume.title,
        chapterLocalIndex: 1,
        chapterIndex: 1,
        objectiveCard: const ChapterObjectiveCard(chapterTitle: '第一章'),
      ),
    );
    final chapter = await repository.saveChapter(
      input: ProjectChapterInput(
        projectId: project.id,
        chapterPlanId: plan.id,
        chapterIndex: 1,
        title: '第一章',
        contentMarkdown: '旧灯塔映着海雾。',
      ),
    );

    final service = ChapterIllustrationService(
      repository: repository,
      imageGenerationService: ImageGenerationService(client: imageClient),
      supportDirectory: () async => directory,
    );
    return _Fixture(
      project: project,
      plan: plan,
      chapter: chapter,
      imageProvider: imageProvider,
      repository: repository,
      workflowRepository: DriftWorkflowTaskRepository(database),
      pipeline: ChapterIllustrationGenerationPipeline(
        repository: repository,
        imageProviderRepository: imageProviderRepository,
        illustrationService: service,
      ),
    );
  }
}

class _RecordingImageClient implements ImageGenerationClient {
  _RecordingImageClient(this.image);

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
  Future<ImageGenerationResult> editImage({
    required ImageProviderConfig provider,
    required ImageEditRequest request,
  }) {
    throw UnimplementedError();
  }
}

class _ThrowingImageClient implements ImageGenerationClient {
  const _ThrowingImageClient(this.error);

  final Object error;

  @override
  Future<ImageGenerationResult> generateImage({
    required ImageProviderConfig provider,
    required ImageGenerationRequest request,
  }) async {
    throw error;
  }

  @override
  Future<ImageGenerationResult> editImage({
    required ImageProviderConfig provider,
    required ImageEditRequest request,
  }) {
    throw UnimplementedError();
  }
}
