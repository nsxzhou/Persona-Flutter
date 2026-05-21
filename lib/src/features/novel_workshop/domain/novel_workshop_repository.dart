import 'novel_workshop.dart';
import 'writing_context.dart';

abstract interface class NovelWorkshopRepository {
  Stream<ProjectBible> watchProjectBible(String projectId);

  Stream<List<ChapterVolume>> watchChapterVolumes(String projectId);

  Stream<List<ChapterPlan>> watchChapterPlans(String projectId);

  Stream<List<ProjectChapter>> watchChapters(String projectId);

  Stream<List<NovelCharacter>> watchCharacters(String projectId);

  Stream<List<NovelRelationship>> watchRelationships(String projectId);

  Stream<List<ChapterGenerationRun>> watchChapterGenerationRuns(
    String projectId,
  );

  Stream<List<AssetGenerationRun>> watchAssetGenerationRuns(String projectId);

  Stream<List<ChapterEnrichmentBatch>> watchChapterEnrichmentBatches(
    String projectId,
  );

  Stream<List<ChapterEnrichmentItem>> watchChapterEnrichmentItems(
    String batchId,
  );

  Stream<ChapterGenerationRun?> watchChapterGenerationRunByWorkflowTask(
    String workflowTaskId,
  );

  Stream<AssetGenerationRun?> watchAssetGenerationRunByWorkflowTask(
    String workflowTaskId,
  );

  Future<ProjectBible?> findProjectBible(String projectId);

  Future<ProjectBible> ensureProjectBible(String projectId);

  Future<ProjectBible> saveProjectBible(ProjectBibleInput input);

  Future<List<ChapterVolume>> watchChapterVolumesOnce(String projectId);

  Future<ChapterPlan?> findChapterPlan(String id);

  Future<ProjectChapter?> findChapter(String id);

  Future<ProjectChapter?> findChapterByPlan(String chapterPlanId);

  Future<NovelCharacter?> findCharacter(String id);

  Future<NovelRelationship?> findRelationship(String id);

  Future<ChapterGenerationRun?> findChapterGenerationRun(String id);

  Future<AssetGenerationRun?> findAssetGenerationRun(String id);

  Future<ChapterEnrichmentBatch?> findChapterEnrichmentBatch(String id);

  Future<ChapterEnrichmentItem?> findChapterEnrichmentItem(String id);

  Future<bool> hasRunningChapterGeneration(String chapterPlanId);

  Future<ProjectRuntimeMemory?> findRuntimeMemory(String projectId);

  Future<ProjectRuntimeMemory> ensureRuntimeMemory(String projectId);

  Future<ProjectRuntimeMemory> saveRuntimeMemory({
    required String projectId,
    required RuntimeMemoryState state,
  });

  Future<void> clearRuntimeMemory(String projectId);

  Future<ChapterVolume> saveChapterVolume({
    String? id,
    required ChapterVolumeInput input,
  });

  Future<NovelCharacter> saveCharacter({
    String? id,
    required NovelCharacterInput input,
  });

  Future<NovelRelationship> saveRelationship({
    String? id,
    required NovelRelationshipInput input,
  });

  Future<ChapterPlan> saveChapterPlan({
    String? id,
    required ChapterPlanInput input,
  });

  Future<ProjectBible> saveOutlineDetailYaml({
    required String projectId,
    required String outlineDetailYaml,
  });

  Future<void> applyCharactersYaml({
    required String projectId,
    required String charactersYaml,
  });

  Future<ProjectChapter> saveChapter({
    String? id,
    required ProjectChapterInput input,
  });

  Future<ProjectChapter> saveMemorySyncProposal(MemorySyncProposalInput input);

  Future<ProjectChapter> applyMemorySyncPatch(String chapterId);

  Future<AssetGenerationRun> createAssetGenerationRun(
    AssetGenerationRunInput input,
  );

  Future<AssetGenerationRun> createVolumeDetailGenerationRun({
    required String projectId,
    required String volumeId,
  });

  Future<AssetGenerationRun> updateAssetGenerationRunState({
    required String id,
    required AssetGenerationStatus status,
    AssetGenerationStage? stage,
    String? providerId,
    String? modelName,
    String? errorMessage,
    String? logs,
    String? draftMarkdown,
    DateTime? startedAt,
    DateTime? completedAt,
  });

  Future<ProjectBible> applyAssetGenerationDraft(String runId);

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

  Future<ChapterEnrichmentBatch> createChapterEnrichmentBatch(
    ChapterEnrichmentBatchInput input,
  );

  Future<ChapterEnrichmentBatch> updateChapterEnrichmentBatchState({
    required String id,
    required ChapterEnrichmentBatchStatus status,
    String? providerId,
    String? modelName,
    String? errorMessage,
    String? logs,
    DateTime? startedAt,
    DateTime? completedAt,
  });

  Future<ChapterEnrichmentItem> updateChapterEnrichmentItemState({
    required String id,
    required ChapterEnrichmentItemStatus status,
    String? errorMessage,
    String? originalContentMarkdown,
    String? generatedContentMarkdown,
    String? providerId,
    String? modelName,
    String? logs,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? appliedAt,
    bool clearStartedAt = false,
    bool clearCompletedAt = false,
    bool clearAppliedAt = false,
  });

  Future<ProjectChapter> applyChapterEnrichmentItem(String itemId);

  Future<void> deleteChapterEnrichmentItem(String itemId);
}
