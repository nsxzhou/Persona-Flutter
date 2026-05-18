import 'novel_workshop.dart';
import 'writing_context.dart';

abstract interface class NovelWorkshopRepository {
  Stream<List<ChapterPlan>> watchChapterPlans(String projectId);

  Stream<List<ProjectChapter>> watchChapters(String projectId);

  Future<ChapterPlan?> findChapterPlan(String id);

  Future<ProjectChapter?> findChapter(String id);

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
}
