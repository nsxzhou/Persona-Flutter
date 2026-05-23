import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/tasks/application/workflow_task_cancellation_registry.dart';
import '../../../core/tasks/application/workflow_task_providers.dart';
import '../../plot_lab/application/plot_lab_providers.dart';
import '../../projects/application/project_providers.dart';
import '../../settings/application/provider_config_providers.dart';
import '../../style_lab/application/style_lab_providers.dart';
import '../data/drift_novel_workshop_repository.dart';
import '../domain/novel_workshop.dart';
import '../domain/novel_workshop_repository.dart';
import '../domain/writing_context.dart';
import 'asset_generation_pipeline.dart';
import 'chapter_enrichment_pipeline.dart';
import 'chapter_generation_pipeline.dart';
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
  FutureOr<void> build() {}

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
