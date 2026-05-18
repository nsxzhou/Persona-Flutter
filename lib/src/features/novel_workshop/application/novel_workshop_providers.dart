import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/tasks/application/workflow_task_providers.dart';
import '../../plot_lab/application/plot_lab_providers.dart';
import '../../projects/application/project_providers.dart';
import '../../settings/application/provider_config_providers.dart';
import '../../style_lab/application/style_lab_providers.dart';
import '../data/drift_novel_workshop_repository.dart';
import '../domain/novel_workshop.dart';
import '../domain/novel_workshop_repository.dart';
import '../domain/writing_context.dart';
import 'chapter_generation_pipeline.dart';
import 'project_prompt_asset_resolver.dart';
import 'writing_context_assembler.dart';

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
ProjectPromptAssetResolver projectPromptAssetResolver(Ref ref) {
  return ProjectPromptAssetResolver(
    projectRepository: ref.watch(projectRepositoryProvider),
    styleLabRepository: ref.watch(styleLabRepositoryProvider),
    plotLabRepository: ref.watch(plotLabRepositoryProvider),
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
    completionService: ref.watch(markdownCompletionServiceProvider),
    workflowTaskRepository: ref.watch(workflowTaskRepositoryProvider),
  );
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
Stream<List<ChapterGenerationRun>> chapterGenerationRuns(
  Ref ref,
  String projectId,
) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .watchChapterGenerationRuns(projectId);
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
Future<ProjectRuntimeMemory> projectRuntimeMemory(Ref ref, String projectId) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .ensureRuntimeMemory(projectId);
}

@riverpod
Future<ProjectPromptAssets> projectPromptAssets(Ref ref, String projectId) {
  return ref.watch(projectPromptAssetResolverProvider).resolve(projectId);
}
