import 'novel_workshop.dart';
import 'writing_context.dart';

abstract interface class NovelWorkshopRepository {
  Stream<List<ChapterPlan>> watchChapterPlans(String projectId);

  Stream<List<ProjectChapter>> watchChapters(String projectId);

  Stream<List<ChapterGenerationRun>> watchChapterGenerationRuns(
    String projectId,
  );

  Stream<ChapterGenerationRun?> watchChapterGenerationRunByWorkflowTask(
    String workflowTaskId,
  );

  Future<ChapterPlan?> findChapterPlan(String id);

  Future<ProjectChapter?> findChapter(String id);

  Future<ProjectChapter?> findChapterByPlan(String chapterPlanId);

  Future<ChapterGenerationRun?> findChapterGenerationRun(String id);

  Future<bool> hasRunningChapterGeneration(String chapterPlanId);

  Future<ProjectRuntimeMemory?> findRuntimeMemory(String projectId);

  Future<ProjectRuntimeMemory> ensureRuntimeMemory(String projectId);

  Future<ProjectRuntimeMemory> saveRuntimeMemory({
    required String projectId,
    required RuntimeMemoryState state,
  });

  Future<void> clearRuntimeMemory(String projectId);

  Future<ChapterPlan> saveChapterPlan({
    String? id,
    required ChapterPlanInput input,
  });

  Future<ProjectChapter> saveChapter({
    String? id,
    required ProjectChapterInput input,
  });

  Future<ProjectChapter> saveMemorySyncProposal(MemorySyncProposalInput input);

  Future<ChapterGenerationRun> createChapterGenerationRun(
    ChapterGenerationRunInput input,
  );

  Future<ChapterGenerationRun> updateChapterGenerationRunState({
    required String id,
    required ChapterGenerationStatus status,
    ChapterGenerationStage? stage,
    String? chapterId,
    String? providerId,
    String? modelName,
    String? errorMessage,
    String? logs,
    String? contextWarningsMarkdown,
    DateTime? startedAt,
    DateTime? completedAt,
  });
}
