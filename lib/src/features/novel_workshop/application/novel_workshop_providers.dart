import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart' as flutter_riverpod;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/tasks/application/workflow_task_cancellation_registry.dart';
import '../../../core/tasks/application/workflow_task_providers.dart';
import '../../plot_lab/application/plot_lab_providers.dart';
import '../../projects/application/project_providers.dart';
import '../../projects/domain/writing_project.dart';
import '../../settings/application/image_provider_config_providers.dart';
import '../../settings/application/provider_config_providers.dart';
import '../../settings/domain/image_provider_config.dart';
import '../../style_lab/application/style_lab_providers.dart';
import '../data/drift_novel_workshop_repository.dart';
import '../domain/novel_workshop.dart';
import '../domain/novel_workshop_repository.dart';
import '../domain/writing_context.dart';
import 'asset_generation_pipeline.dart';
import 'chapter_enrichment_pipeline.dart';
import 'chapter_generation_pipeline.dart';
import 'chapter_illustration_generation_pipeline.dart';
import 'chapter_illustration_prompt_service.dart';
import 'chapter_illustration_service.dart';
import 'novel_export_service.dart';
import 'novel_import_parser.dart';
import 'novel_import_service.dart';
import 'outline_detail_parser.dart';
import 'project_prompt_asset_resolver.dart';
import 'writing_context_assembler.dart';
import 'writing_context_retriever.dart';

part 'novel_workshop_providers.g.dart';

@Riverpod(keepAlive: true)
NovelWorkshopRepository novelWorkshopRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftNovelWorkshopRepository(database);
}

@Riverpod(keepAlive: true)
WritingContextAssembler writingContextAssembler(Ref ref) {
  return const WritingContextAssembler();
}

@Riverpod(keepAlive: true)
WritingContextRetriever writingContextRetriever(Ref ref) {
  return WritingContextRetriever(
    completionService: ref.watch(markdownCompletionServiceProvider),
  );
}

@Riverpod(keepAlive: true)
OutlineDetailParser outlineDetailParser(Ref ref) {
  return const OutlineDetailParser();
}

@Riverpod(keepAlive: true)
ProjectPromptAssetResolver projectPromptAssetResolver(Ref ref) {
  return ProjectPromptAssetResolver(
    projectRepository: ref.watch(projectRepositoryProvider),
    styleLabRepository: ref.watch(styleLabRepositoryProvider),
    plotLabRepository: ref.watch(plotLabRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
AssetGenerationPipeline assetGenerationPipeline(Ref ref) {
  return AssetGenerationPipeline(
    repository: ref.watch(novelWorkshopRepositoryProvider),
    projectRepository: ref.watch(projectRepositoryProvider),
    providerRepository: ref.watch(providerConfigRepositoryProvider),
    promptAssetResolver: ref.watch(projectPromptAssetResolverProvider),
    completionService: ref.watch(markdownCompletionServiceProvider),
    workflowTaskRepository: ref.watch(workflowTaskRepositoryProvider),
    cancellationRegistry: ref.watch(workflowTaskCancellationRegistryProvider),
  );
}

@Riverpod(keepAlive: true)
ChapterGenerationPipeline chapterGenerationPipeline(Ref ref) {
  return ChapterGenerationPipeline(
    repository: ref.watch(novelWorkshopRepositoryProvider),
    projectRepository: ref.watch(projectRepositoryProvider),
    providerRepository: ref.watch(providerConfigRepositoryProvider),
    promptAssetResolver: ref.watch(projectPromptAssetResolverProvider),
    contextAssembler: ref.watch(writingContextAssemblerProvider),
    contextRetriever: ref.watch(writingContextRetrieverProvider),
    completionService: ref.watch(markdownCompletionServiceProvider),
    workflowTaskRepository: ref.watch(workflowTaskRepositoryProvider),
    cancellationRegistry: ref.watch(workflowTaskCancellationRegistryProvider),
  );
}

@Riverpod(keepAlive: true)
ChapterEnrichmentPipeline chapterEnrichmentPipeline(Ref ref) {
  return ChapterEnrichmentPipeline(
    repository: ref.watch(novelWorkshopRepositoryProvider),
    projectRepository: ref.watch(projectRepositoryProvider),
    providerRepository: ref.watch(providerConfigRepositoryProvider),
    promptAssetResolver: ref.watch(projectPromptAssetResolverProvider),
    completionService: ref.watch(markdownCompletionServiceProvider),
    workflowTaskRepository: ref.watch(workflowTaskRepositoryProvider),
    cancellationRegistry: ref.watch(workflowTaskCancellationRegistryProvider),
  );
}

@Riverpod(keepAlive: true)
NovelImportParser novelImportParser(Ref ref) {
  return const NovelImportParser();
}

@Riverpod(keepAlive: true)
NovelImportService novelImportService(Ref ref) {
  return NovelImportService(
    projectRepository: ref.watch(projectRepositoryProvider),
    workshopRepository: ref.watch(novelWorkshopRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
NovelExportService novelExportService(Ref ref) {
  return const NovelExportService();
}

final chapterIllustrationServiceProvider =
    flutter_riverpod.Provider<ChapterIllustrationService>((ref) {
      return ChapterIllustrationService(
        repository: ref.watch(novelWorkshopRepositoryProvider),
        imageGenerationService: ref.watch(imageGenerationServiceProvider),
        httpClient: ref.watch(imageProviderHttpClientProvider),
      );
    });

final chapterIllustrationPromptServiceProvider =
    flutter_riverpod.Provider<ChapterIllustrationPromptService>((ref) {
      return ChapterIllustrationPromptService(
        completionService: ref.watch(markdownCompletionServiceProvider),
      );
    });

final chapterIllustrationGenerationPipelineProvider =
    flutter_riverpod.Provider<ChapterIllustrationGenerationPipeline>((ref) {
      return ChapterIllustrationGenerationPipeline(
        repository: ref.watch(novelWorkshopRepositoryProvider),
        imageProviderRepository: ref.watch(
          imageProviderConfigRepositoryProvider,
        ),
        illustrationService: ref.watch(chapterIllustrationServiceProvider),
      );
    });

@riverpod
Stream<ProjectBible> projectBible(Ref ref, String projectId) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .watchProjectBible(projectId);
}

@riverpod
Stream<List<ChapterVolume>> chapterVolumes(Ref ref, String projectId) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .watchChapterVolumes(projectId);
}

@riverpod
Stream<List<ChapterPlan>> chapterPlans(Ref ref, String projectId) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .watchChapterPlans(projectId);
}

@riverpod
Stream<List<ProjectChapter>> projectChapters(Ref ref, String projectId) {
  return ref.watch(novelWorkshopRepositoryProvider).watchChapters(projectId);
}

final chapterIllustrationsProvider =
    flutter_riverpod.StreamProvider.family<List<ChapterIllustration>, String>((
      ref,
      projectId,
    ) {
      return ref
          .watch(novelWorkshopRepositoryProvider)
          .watchChapterIllustrations(projectId);
    });

final chapterIllustrationGenerationRunsProvider =
    flutter_riverpod.StreamProvider.family<
      List<ChapterIllustrationGenerationRun>,
      String
    >((ref, projectId) {
      return ref
          .watch(novelWorkshopRepositoryProvider)
          .watchChapterIllustrationGenerationRuns(projectId);
    });

@riverpod
Stream<ChapterIllustrationGenerationRun?>
chapterIllustrationGenerationRunByWorkflowTask(Ref ref, String workflowTaskId) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .watchChapterIllustrationGenerationRunByWorkflowTask(workflowTaskId);
}

@riverpod
Stream<List<NovelCharacter>> novelCharacters(Ref ref, String projectId) {
  return ref.watch(novelWorkshopRepositoryProvider).watchCharacters(projectId);
}

@riverpod
Stream<List<NovelRelationship>> novelRelationships(Ref ref, String projectId) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .watchRelationships(projectId);
}

@riverpod
Stream<List<ChapterGenerationRun>> chapterGenerationRuns(
  Ref ref,
  String projectId,
) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .watchChapterGenerationRuns(projectId);
}

@riverpod
Stream<List<ChapterGenerationBatch>> chapterGenerationBatches(
  Ref ref,
  String projectId,
) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .watchChapterGenerationBatches(projectId);
}

@Riverpod(keepAlive: true)
class DismissedChapterGenerationBatches
    extends _$DismissedChapterGenerationBatches {
  @override
  Set<String> build(String projectId) => const {};

  void dismiss(String batchId) {
    state = {...state, batchId};
  }
}

@riverpod
Stream<List<ChapterGenerationBatchItem>> chapterGenerationBatchItems(
  Ref ref,
  String batchId,
) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .watchChapterGenerationBatchItems(batchId);
}

@riverpod
Stream<List<AssetGenerationRun>> assetGenerationRuns(
  Ref ref,
  String projectId,
) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .watchAssetGenerationRuns(projectId);
}

@riverpod
Stream<List<ChapterEnrichmentBatch>> chapterEnrichmentBatches(
  Ref ref,
  String projectId,
) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .watchChapterEnrichmentBatches(projectId);
}

@riverpod
Stream<List<ChapterEnrichmentItem>> chapterEnrichmentItems(
  Ref ref,
  String batchId,
) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .watchChapterEnrichmentItems(batchId);
}

@riverpod
Stream<ChapterGenerationRun?> chapterGenerationRunByWorkflowTask(
  Ref ref,
  String workflowTaskId,
) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .watchChapterGenerationRunByWorkflowTask(workflowTaskId);
}

@riverpod
Stream<ChapterGenerationBatch?> chapterGenerationBatchByWorkflowTask(
  Ref ref,
  String workflowTaskId,
) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .watchChapterGenerationBatchByWorkflowTask(workflowTaskId);
}

@riverpod
Stream<AssetGenerationRun?> assetGenerationRunByWorkflowTask(
  Ref ref,
  String workflowTaskId,
) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .watchAssetGenerationRunByWorkflowTask(workflowTaskId);
}

@riverpod
Stream<ChapterEnrichmentBatch?> chapterEnrichmentBatchByWorkflowTask(
  Ref ref,
  String workflowTaskId,
) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .watchChapterEnrichmentBatchByWorkflowTask(workflowTaskId);
}

@riverpod
Future<ProjectRuntimeMemory> projectRuntimeMemory(Ref ref, String projectId) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .ensureRuntimeMemory(projectId);
}

@riverpod
Future<ProjectPromptAssets> projectPromptAssets(Ref ref, String projectId) {
  return ref.watch(projectPromptAssetResolverProvider).resolve(projectId);
}

@Riverpod(keepAlive: true)
class NovelWorkshopController extends _$NovelWorkshopController {
  @override
  FutureOr<void> build() async {
    await ref
        .read(novelWorkshopRepositoryProvider)
        .markInterruptedChapterIllustrationGenerationRunsFailed();
  }

  Future<ChapterPlan> saveChapterPlan({
    String? id,
    required ChapterPlanInput input,
  }) async {
    state = const AsyncLoading();
    late ChapterPlan saved;
    state = await AsyncValue.guard(() async {
      saved = await ref
          .read(novelWorkshopRepositoryProvider)
          .saveChapterPlan(id: id, input: input);
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    return saved;
  }

  Future<ChapterVolume> saveChapterVolume({
    String? id,
    required ChapterVolumeInput input,
  }) async {
    state = const AsyncLoading();
    late ChapterVolume saved;
    state = await AsyncValue.guard(() async {
      saved = await ref
          .read(novelWorkshopRepositoryProvider)
          .saveChapterVolume(id: id, input: input);
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    return saved;
  }

  Future<ProjectBible> saveProjectBible(ProjectBibleInput input) async {
    state = const AsyncLoading();
    late ProjectBible saved;
    state = await AsyncValue.guard(() async {
      saved = await ref
          .read(novelWorkshopRepositoryProvider)
          .saveProjectBible(input);
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    return saved;
  }

  Future<ProjectBible> saveOutlineDetailYaml({
    required String projectId,
    required String outlineDetailYaml,
  }) async {
    state = const AsyncLoading();
    late ProjectBible saved;
    state = await AsyncValue.guard(() async {
      saved = await ref
          .read(novelWorkshopRepositoryProvider)
          .saveOutlineDetailYaml(
            projectId: projectId,
            outlineDetailYaml: outlineDetailYaml,
          );
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    return saved;
  }

  Future<ProjectChapter> saveChapter({
    String? id,
    required ProjectChapterInput input,
  }) async {
    state = const AsyncLoading();
    late ProjectChapter saved;
    state = await AsyncValue.guard(() async {
      saved = await ref
          .read(novelWorkshopRepositoryProvider)
          .saveChapter(id: id, input: input);
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    return saved;
  }

  Future<String?> exportTxt({
    required WritingProject project,
    required List<ChapterVolume> volumes,
    required List<ChapterPlan> plans,
    required List<ProjectChapter> chapters,
  }) async {
    state = const AsyncLoading();
    String? path;
    state = await AsyncValue.guard(() async {
      path = await ref
          .read(novelExportServiceProvider)
          .exportTxt(
            project: project,
            volumes: volumes,
            plans: plans,
            chapters: chapters,
          );
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    return path;
  }

  Future<String?> exportEpub({
    required WritingProject project,
    required List<ChapterVolume> volumes,
    required List<ChapterPlan> plans,
    required List<ProjectChapter> chapters,
    required List<ChapterIllustration> illustrations,
  }) async {
    state = const AsyncLoading();
    String? path;
    state = await AsyncValue.guard(() async {
      path = await ref
          .read(novelExportServiceProvider)
          .exportEpub(
            project: project,
            volumes: volumes,
            plans: plans,
            chapters: chapters,
            illustrations: illustrations,
          );
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    return path;
  }

  Future<ChapterIllustrationGenerationRun> createAndRunChapterIllustration({
    required ProjectChapter chapter,
    required int paragraphIndex,
    required String selectedText,
    required String prompt,
    required ImageProviderConfig provider,
    required String modelName,
    required ImageAspectRatioPreset aspectRatio,
    required ImageSizePreset size,
    required ImageQualityPreset quality,
    required ImageResponseFormat responseFormat,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final effectiveResponseFormat =
          provider.providerKind == ImageProviderKind.grok
          ? ImageResponseFormat.url
          : responseFormat;
      final run = await ref
          .read(novelWorkshopRepositoryProvider)
          .createChapterIllustrationGenerationRun(
            ChapterIllustrationGenerationRunInput(
              projectId: chapter.projectId,
              chapterId: chapter.id,
              chapterPlanId: chapter.chapterPlanId,
              paragraphIndex: paragraphIndex,
              anchorTextHash: anchorTextHash(selectedText),
              selectedText: selectedText,
              prompt: prompt,
              providerId: provider.id,
              modelName: modelName.trim().isEmpty
                  ? provider.defaultModel
                  : modelName.trim(),
              aspectRatio: aspectRatio.ratio,
              size: size.tier,
              quality: provider.providerKind == ImageProviderKind.grok
                  ? ImageQualityPreset.auto.quality
                  : quality.quality,
              responseFormat: effectiveResponseFormat.name,
            ),
          );
      unawaited(
        ref
            .read(chapterIllustrationGenerationPipelineProvider)
            .run(run.id)
            .then((_) {
              ref.invalidate(chapterIllustrationsProvider(chapter.projectId));
              ref.invalidate(
                chapterIllustrationGenerationRunsProvider(chapter.projectId),
              );
            })
            .catchError((Object _) {}),
      );
      return run;
    });
    state = result.whenData((_) {});
    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }
    return result.requireValue;
  }

  Future<ChapterIllustrationGenerationRun> retryChapterIllustrationGeneration(
    String runId,
  ) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final run = await ref
          .read(novelWorkshopRepositoryProvider)
          .createChapterIllustrationGenerationRunFromExisting(runId);
      unawaited(
        ref
            .read(chapterIllustrationGenerationPipelineProvider)
            .run(run.id)
            .then((_) {
              ref.invalidate(chapterIllustrationsProvider(run.projectId));
              ref.invalidate(
                chapterIllustrationGenerationRunsProvider(run.projectId),
              );
            })
            .catchError((Object _) {}),
      );
      return run;
    });
    state = result.whenData((_) {});
    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }
    return result.requireValue;
  }

  Future<String> generateChapterIllustrationPrompt({
    required ProjectChapter chapter,
    required int paragraphIndex,
    required String selectedText,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final project = await ref
          .read(projectRepositoryProvider)
          .findProject(chapter.projectId);
      if (project == null) {
        throw StateError('项目不存在。');
      }
      final providerId = project.defaultProviderId?.trim() ?? '';
      if (providerId.isEmpty) {
        throw StateError('请先在项目设置中配置默认文本 Provider。');
      }
      final provider = await ref
          .read(providerConfigRepositoryProvider)
          .findProvider(providerId);
      if (provider == null) {
        throw StateError('默认文本 Provider 不存在。');
      }
      if (!provider.isEnabled) {
        throw StateError('默认文本 Provider 已停用。');
      }
      final contextChapters = _illustrationPromptContextChapters(
        chapter: chapter,
        chapters: await ref
            .read(novelWorkshopRepositoryProvider)
            .watchChapters(chapter.projectId)
            .first,
      );
      final configuredModelName = project.defaultModelName?.trim();
      return ref
          .read(chapterIllustrationPromptServiceProvider)
          .generatePrompt(
            chapter: chapter,
            paragraphIndex: paragraphIndex,
            selectedText: selectedText,
            contextChapters: contextChapters,
            provider: provider,
            modelName:
                configuredModelName == null || configuredModelName.isEmpty
                ? provider.defaultModel
                : configuredModelName,
          );
    });
    state = result.whenData((_) {});
    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }
    return result.requireValue;
  }

  List<ProjectChapter> _illustrationPromptContextChapters({
    required ProjectChapter chapter,
    required List<ProjectChapter> chapters,
  }) {
    const chapterRadius = 1;
    final minIndex = chapter.chapterIndex - chapterRadius;
    final maxIndex = chapter.chapterIndex + chapterRadius;
    final selected =
        chapters
            .where(
              (candidate) =>
                  candidate.projectId == chapter.projectId &&
                  candidate.chapterIndex >= minIndex &&
                  candidate.chapterIndex <= maxIndex &&
                  candidate.contentMarkdown.trim().isNotEmpty,
            )
            .toList()
          ..sort((a, b) => a.chapterIndex.compareTo(b.chapterIndex));
    if (selected.any((candidate) => candidate.id == chapter.id)) {
      return selected;
    }
    if (chapter.contentMarkdown.trim().isEmpty) {
      return selected;
    }
    return [...selected, chapter]
      ..sort((a, b) => a.chapterIndex.compareTo(b.chapterIndex));
  }

  Future<void> deleteChapterIllustrationGenerationRun(String runId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(novelWorkshopRepositoryProvider)
          .deleteChapterIllustrationGenerationRun(runId);
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
  }

  Future<ChapterIllustration> insertChapterIllustration(String id) async {
    state = const AsyncLoading();
    late ChapterIllustration saved;
    state = await AsyncValue.guard(() async {
      saved = await ref
          .read(novelWorkshopRepositoryProvider)
          .insertChapterIllustration(id);
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    ref.invalidate(chapterIllustrationsProvider(saved.projectId));
    return saved;
  }

  Future<ChapterIllustration> removeChapterIllustrationFromText(
    String id,
  ) async {
    state = const AsyncLoading();
    late ChapterIllustration saved;
    state = await AsyncValue.guard(() async {
      saved = await ref
          .read(novelWorkshopRepositoryProvider)
          .removeChapterIllustrationFromText(id);
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    ref.invalidate(chapterIllustrationsProvider(saved.projectId));
    return saved;
  }

  Future<void> deleteChapterIllustration({
    required String id,
    required String projectId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(novelWorkshopRepositoryProvider)
          .deleteChapterIllustration(id);
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    ref.invalidate(chapterIllustrationsProvider(projectId));
  }

  Future<ProjectChapter> proposeMemoryPatchForChapter({
    required String projectId,
    required String chapterId,
  }) async {
    state = const AsyncLoading();
    late ProjectChapter saved;
    state = await AsyncValue.guard(() async {
      saved = await ref
          .read(chapterGenerationPipelineProvider)
          .proposeMemoryPatchForChapter(
            projectId: projectId,
            chapterId: chapterId,
          );
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    ref.invalidate(projectChaptersProvider(projectId));
    ref.invalidate(projectRuntimeMemoryProvider(projectId));
    return saved;
  }

  Future<ProjectRuntimeMemory> saveRuntimeMemory({
    required String projectId,
    required RuntimeMemoryState memoryState,
  }) async {
    state = const AsyncLoading();
    late ProjectRuntimeMemory saved;
    state = await AsyncValue.guard(() async {
      saved = await ref
          .read(novelWorkshopRepositoryProvider)
          .saveRuntimeMemory(projectId: projectId, state: memoryState);
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    ref.invalidate(projectRuntimeMemoryProvider(projectId));
    return saved;
  }

  Future<AssetGenerationResult> generateAsset({
    required String projectId,
    required AssetGenerationKind kind,
    String? targetVolumeId,
  }) async {
    state = const AsyncLoading();
    late AssetGenerationResult result;
    state = await AsyncValue.guard(() async {
      result = await ref
          .read(assetGenerationPipelineProvider)
          .generateAsset(
            projectId: projectId,
            kind: kind,
            targetVolumeId: targetVolumeId,
          );
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    return result;
  }

  Future<AssetGenerationResult> regenerateAssetWithFeedback({
    required String projectId,
    required AssetGenerationKind kind,
    required String previousRunId,
    required String previousDraft,
    required String validationErrors,
    String userFeedback = '',
    String? targetVolumeId,
  }) async {
    state = const AsyncLoading();
    late AssetGenerationResult result;
    state = await AsyncValue.guard(() async {
      result = await ref
          .read(assetGenerationPipelineProvider)
          .regenerateAssetWithFeedback(
            projectId: projectId,
            kind: kind,
            previousRunId: previousRunId,
            previousDraft: previousDraft,
            validationErrors: validationErrors,
            userFeedback: userFeedback,
            targetVolumeId: targetVolumeId,
          );
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    return result;
  }

  Future<ProjectBible> applyAssetDraft(String runId) async {
    state = const AsyncLoading();
    late ProjectBible saved;
    state = await AsyncValue.guard(() async {
      saved = await ref
          .read(novelWorkshopRepositoryProvider)
          .applyAssetGenerationDraft(runId);
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    return saved;
  }

  Future<ProjectChapter> applyMemorySyncPatch(String chapterId) async {
    state = const AsyncLoading();
    late ProjectChapter saved;
    state = await AsyncValue.guard(() async {
      saved = await ref
          .read(novelWorkshopRepositoryProvider)
          .applyMemorySyncPatch(chapterId);
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    ref.invalidate(projectRuntimeMemoryProvider(saved.projectId));
    return saved;
  }

  Future<ProjectChapter> discardMemorySyncPatch(String chapterId) async {
    state = const AsyncLoading();
    late ProjectChapter saved;
    state = await AsyncValue.guard(() async {
      saved = await ref
          .read(novelWorkshopRepositoryProvider)
          .discardMemorySyncPatch(chapterId);
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    ref.invalidate(projectRuntimeMemoryProvider(saved.projectId));
    return saved;
  }

  Future<ChapterGenerationResult> generateChapter({
    required String projectId,
    required String chapterPlanId,
    bool replaceExisting = false,
  }) async {
    state = const AsyncLoading();
    late ChapterGenerationResult result;
    state = await AsyncValue.guard(() async {
      result = await ref
          .read(chapterGenerationPipelineProvider)
          .generateChapter(
            projectId: projectId,
            chapterPlanId: chapterPlanId,
            replaceExisting: replaceExisting,
          );
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    return result;
  }

  Future<ChapterGenerationBatchResult> startChapterGenerationBatch({
    required String projectId,
    required List<String> chapterPlanIds,
  }) async {
    state = const AsyncLoading();
    late ChapterGenerationBatchResult result;
    state = await AsyncValue.guard(() async {
      result = await ref
          .read(chapterGenerationPipelineProvider)
          .startChapterGenerationBatch(
            projectId: projectId,
            chapterPlanIds: chapterPlanIds,
          );
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    ref.invalidate(projectRuntimeMemoryProvider(projectId));
    return result;
  }

  Future<ChapterGenerationBatchResult> stopChapterGenerationBatch(
    String batchId,
  ) async {
    state = const AsyncLoading();
    late ChapterGenerationBatchResult result;
    state = await AsyncValue.guard(() async {
      result = await ref
          .read(chapterGenerationPipelineProvider)
          .stopChapterGenerationBatch(batchId);
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    ref.invalidate(projectRuntimeMemoryProvider(result.batch.projectId));
    return result;
  }

  Future<ChapterGenerationContextPreview> previewGenerationContext({
    required String projectId,
    required String chapterPlanId,
  }) async {
    state = const AsyncLoading();
    late ChapterGenerationContextPreview preview;
    state = await AsyncValue.guard(() async {
      preview = await ref
          .read(chapterGenerationPipelineProvider)
          .previewGenerationContext(
            projectId: projectId,
            chapterPlanId: chapterPlanId,
          );
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    return preview;
  }

  Future<ChapterEnrichmentResult> enrichChapters({
    required String projectId,
    required List<String> chapterIds,
    required String instruction,
    int expansionRatioPercent = 20,
  }) async {
    state = const AsyncLoading();
    late ChapterEnrichmentResult result;
    state = await AsyncValue.guard(() async {
      result = await ref
          .read(chapterEnrichmentPipelineProvider)
          .enrichChapters(
            projectId: projectId,
            chapterIds: chapterIds,
            instruction: instruction,
            expansionRatioPercent: expansionRatioPercent,
          );
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    return result;
  }

  Future<ProjectChapter> applyChapterEnrichmentItem(String itemId) async {
    state = const AsyncLoading();
    late ProjectChapter saved;
    state = await AsyncValue.guard(() async {
      saved = await ref
          .read(novelWorkshopRepositoryProvider)
          .applyChapterEnrichmentItem(itemId);
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    return saved;
  }

  Future<void> deleteChapterEnrichmentItem(String itemId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(novelWorkshopRepositoryProvider)
          .deleteChapterEnrichmentItem(itemId);
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
  }

  Future<ChapterEnrichmentResult> retryChapterEnrichmentItem(
    String itemId,
  ) async {
    state = const AsyncLoading();
    late ChapterEnrichmentResult result;
    state = await AsyncValue.guard(() async {
      result = await ref
          .read(chapterEnrichmentPipelineProvider)
          .retryItem(itemId);
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    return result;
  }

  Future<List<ProjectChapter>> applyChapterEnrichmentItems(
    List<String> itemIds,
  ) async {
    state = const AsyncLoading();
    late List<ProjectChapter> saved;
    state = await AsyncValue.guard(() async {
      saved = <ProjectChapter>[];
      for (final itemId in itemIds) {
        saved.add(
          await ref
              .read(novelWorkshopRepositoryProvider)
              .applyChapterEnrichmentItem(itemId),
        );
      }
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    return saved;
  }
}
