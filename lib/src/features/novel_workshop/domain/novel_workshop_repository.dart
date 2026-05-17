import 'accepted_chapter.dart';
import 'chapter_draft_run.dart';
import 'chapter_plan.dart';
import 'memory_projection.dart';
import 'story_bible.dart';

abstract interface class NovelWorkshopRepository {
  Stream<StoryBible?> watchStoryBible(String projectId);

  Future<StoryBible?> findStoryBible(String projectId);

  Future<StoryBible> upsertStoryBible(StoryBibleInput input);

  Stream<List<ChapterPlan>> watchChapterPlans(String projectId);

  Future<List<ChapterPlan>> findChapterPlans(String projectId);

  Stream<ChapterPlan?> watchChapterPlan(String id);

  Future<ChapterPlan?> findChapterPlan(String id);

  Future<ChapterPlan> saveChapterPlan({
    String? id,
    required ChapterPlanInput input,
  });

  Future<void> deleteChapterPlan(String id);

  Stream<List<ChapterDraftRun>> watchChapterDraftRuns(String chapterPlanId);

  Stream<ChapterDraftRun?> watchChapterDraftRun(String id);

  Future<ChapterDraftRun?> findChapterDraftRun(String id);

  Future<ChapterDraftRun> createChapterDraftRun(ChapterDraftRunInput input);

  Future<void> updateChapterDraftRunState({
    required String id,
    required ChapterDraftRunStatus status,
    ChapterDraftRunStage? stage,
    String? errorMessage,
    String? logs,
    String? contractMarkdown,
    String? draftMarkdown,
    String? auditMarkdown,
    String? revisedMarkdown,
  });

  Future<int> markInterruptedRunsFailed();

  Stream<List<AcceptedChapter>> watchAcceptedChapters(String projectId);

  Stream<AcceptedChapter?> watchAcceptedChapterForPlan(String chapterPlanId);

  Future<AcceptedChapter?> findAcceptedChapterForPlan(String chapterPlanId);

  Future<AcceptedChapter> upsertAcceptedChapter(AcceptedChapterInput input);

  Stream<MemoryProjection?> watchMemoryProjection(String projectId);

  Future<MemoryProjection?> findMemoryProjection(String projectId);

  Future<MemoryProjection> upsertMemoryProjection(MemoryProjectionInput input);
}
