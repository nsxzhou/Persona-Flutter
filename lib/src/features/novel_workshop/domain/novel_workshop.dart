import 'writing_context.dart';

enum ContinuityVerdict { pass, warning, fail }

enum MemorySyncStatus {
  idle,
  checking,
  pendingReview,
  synced,
  noChange,
  discarded,
  failed,
  stale,
}

enum ChapterGenerationStatus { pending, running, succeeded, failed }

enum ChapterGenerationStage {
  preparingContext,
  generatingDraft,
  savingChapter,
  proposingMemoryPatch,
}

enum AssetGenerationKind {
  worldBuilding,
  charactersBlueprint,
  outlineMaster,
  volumeBlueprintYaml,
  outlineDetailYaml,
}

enum AssetGenerationStatus { pending, running, succeeded, failed, applied }

enum AssetGenerationStage { preparingContext, generatingDraft, savingDraft }

enum ChapterEnrichmentBatchStatus {
  pending,
  running,
  succeeded,
  partialFailed,
  failed,
}

enum ChapterEnrichmentItemStatus {
  waiting,
  running,
  generated,
  failed,
  applied,
}

const chapterGenerationWorkflowTaskKind = 'novel_chapter_generation';
const assetGenerationWorkflowTaskKind = 'novel_asset_generation';
const chapterEnrichmentWorkflowTaskKind = 'novel_chapter_enrichment';

class ProjectBible {
  const ProjectBible({
    required this.projectId,
    required this.descriptionMarkdown,
    required this.worldBuildingMarkdown,
    required this.charactersBlueprintMarkdown,
    required this.outlineMasterMarkdown,
    required this.outlineDetailYaml,
    required this.createdAt,
    required this.updatedAt,
  });

  final String projectId;
  final String descriptionMarkdown;
  final String worldBuildingMarkdown;
  final String charactersBlueprintMarkdown;
  final String outlineMasterMarkdown;
  final String outlineDetailYaml;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ProjectBibleInput {
  const ProjectBibleInput({
    required this.projectId,
    required this.descriptionMarkdown,
    required this.worldBuildingMarkdown,
    required this.charactersBlueprintMarkdown,
    required this.outlineMasterMarkdown,
    required this.outlineDetailYaml,
  });

  final String projectId;
  final String descriptionMarkdown;
  final String worldBuildingMarkdown;
  final String charactersBlueprintMarkdown;
  final String outlineMasterMarkdown;
  final String outlineDetailYaml;
}

class ChapterVolume {
  const ChapterVolume({
    required this.id,
    required this.projectId,
    required this.volumeIndex,
    required this.title,
    this.targetLength = 0,
    this.summary = '',
    this.centralConflict = '',
    this.characterProgression = '',
    this.endingHook = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String projectId;
  final int volumeIndex;
  final String title;
  final int targetLength;
  final String summary;
  final String centralConflict;
  final String characterProgression;
  final String endingHook;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ChapterVolumeInput {
  const ChapterVolumeInput({
    required this.projectId,
    required this.volumeIndex,
    required this.title,
    this.targetLength = 0,
    this.summary = '',
    this.centralConflict = '',
    this.characterProgression = '',
    this.endingHook = '',
  });

  final String projectId;
  final int volumeIndex;
  final String title;
  final int targetLength;
  final String summary;
  final String centralConflict;
  final String characterProgression;
  final String endingHook;
}

class ChapterPlan {
  const ChapterPlan({
    required this.id,
    required this.projectId,
    required this.volumeId,
    required this.volumeIndex,
    required this.volumeTitle,
    required this.chapterLocalIndex,
    required this.chapterIndex,
    required this.objectiveCard,
    required this.coreEvent,
    required this.emotionArc,
    required this.chapterHook,
    required this.outlineMarkdown,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String projectId;
  final String volumeId;
  final int volumeIndex;
  final String volumeTitle;
  final int chapterLocalIndex;
  final int chapterIndex;
  final ChapterObjectiveCard objectiveCard;
  final String coreEvent;
  final String emotionArc;
  final String chapterHook;
  final String outlineMarkdown;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ChapterPlanInput {
  const ChapterPlanInput({
    required this.projectId,
    required this.volumeId,
    required this.volumeIndex,
    required this.volumeTitle,
    required this.chapterLocalIndex,
    required this.chapterIndex,
    required this.objectiveCard,
    this.coreEvent = '',
    this.emotionArc = '',
    this.chapterHook = '',
    this.outlineMarkdown = '',
  });

  final String projectId;
  final String volumeId;
  final int volumeIndex;
  final String volumeTitle;
  final int chapterLocalIndex;
  final int chapterIndex;
  final ChapterObjectiveCard objectiveCard;
  final String coreEvent;
  final String emotionArc;
  final String chapterHook;
  final String outlineMarkdown;
}

class ProjectChapter {
  const ProjectChapter({
    required this.id,
    required this.projectId,
    required this.chapterPlanId,
    required this.chapterIndex,
    required this.title,
    required this.contentMarkdown,
    required this.contentHash,
    required this.continuityVerdict,
    required this.continuityReportMarkdown,
    required this.memorySyncStatus,
    required this.memorySyncContentHash,
    required this.memorySyncProposedRuntimeState,
    required this.memorySyncProposedRuntimeThreads,
    required this.memorySyncProposedStorySummary,
    this.memorySyncProposedContinuityIndex = '',
    this.memorySyncProposedChapterArchiveMarkdown = '',
    this.memorySyncPatchYaml = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String projectId;
  final String chapterPlanId;
  final int chapterIndex;
  final String title;
  final String contentMarkdown;
  final String contentHash;
  final ContinuityVerdict continuityVerdict;
  final String continuityReportMarkdown;
  final MemorySyncStatus memorySyncStatus;
  final String memorySyncContentHash;
  final String memorySyncProposedRuntimeState;
  final String memorySyncProposedRuntimeThreads;
  final String memorySyncProposedStorySummary;
  final String memorySyncProposedContinuityIndex;
  final String memorySyncProposedChapterArchiveMarkdown;
  final String memorySyncPatchYaml;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ProjectChapterInput {
  const ProjectChapterInput({
    required this.projectId,
    required this.chapterPlanId,
    required this.chapterIndex,
    required this.title,
    required this.contentMarkdown,
    this.continuityVerdict = ContinuityVerdict.pass,
    this.continuityReportMarkdown = '',
  });

  final String projectId;
  final String chapterPlanId;
  final int chapterIndex;
  final String title;
  final String contentMarkdown;
  final ContinuityVerdict continuityVerdict;
  final String continuityReportMarkdown;
}

class MemorySyncProposalInput {
  const MemorySyncProposalInput({
    required this.chapterId,
    required this.contentHash,
    this.proposedMemory = const RuntimeMemoryState(),
    this.patchYaml = '',
  });

  final String chapterId;
  final String contentHash;
  final RuntimeMemoryState proposedMemory;
  final String patchYaml;
}

class NovelCharacter {
  const NovelCharacter({
    required this.id,
    required this.projectId,
    required this.name,
    required this.aliases,
    required this.tags,
    required this.faction,
    required this.role,
    required this.longTermGoal,
    required this.currentStatus,
    required this.secrets,
    required this.firstChapterIndex,
    required this.lastChapterIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String projectId;
  final String name;
  final String aliases;
  final String tags;
  final String faction;
  final String role;
  final String longTermGoal;
  final String currentStatus;
  final String secrets;
  final int? firstChapterIndex;
  final int? lastChapterIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class NovelCharacterInput {
  const NovelCharacterInput({
    required this.projectId,
    required this.name,
    this.aliases = '',
    this.tags = '',
    this.faction = '',
    this.role = '',
    this.longTermGoal = '',
    this.currentStatus = '',
    this.secrets = '',
    this.firstChapterIndex,
    this.lastChapterIndex,
  });

  final String projectId;
  final String name;
  final String aliases;
  final String tags;
  final String faction;
  final String role;
  final String longTermGoal;
  final String currentStatus;
  final String secrets;
  final int? firstChapterIndex;
  final int? lastChapterIndex;
}

class NovelRelationship {
  const NovelRelationship({
    required this.id,
    required this.projectId,
    required this.fromCharacterId,
    required this.toCharacterId,
    required this.relationshipType,
    required this.strength,
    required this.status,
    required this.description,
    required this.lastChangedChapterIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String projectId;
  final String fromCharacterId;
  final String toCharacterId;
  final String relationshipType;
  final int strength;
  final String status;
  final String description;
  final int? lastChangedChapterIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class NovelRelationshipInput {
  const NovelRelationshipInput({
    required this.projectId,
    required this.fromCharacterId,
    required this.toCharacterId,
    this.relationshipType = '',
    this.strength = 0,
    this.status = '',
    this.description = '',
    this.lastChangedChapterIndex,
  });

  final String projectId;
  final String fromCharacterId;
  final String toCharacterId;
  final String relationshipType;
  final int strength;
  final String status;
  final String description;
  final int? lastChangedChapterIndex;
}

class ProjectRuntimeMemory {
  const ProjectRuntimeMemory({
    required this.projectId,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
  });

  final String projectId;
  final RuntimeMemoryState state;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ChapterGenerationRun {
  const ChapterGenerationRun({
    required this.id,
    required this.workflowTaskId,
    required this.projectId,
    required this.chapterPlanId,
    required this.chapterId,
    required this.providerId,
    required this.modelName,
    required this.status,
    required this.stage,
    required this.errorMessage,
    required this.logs,
    required this.contextWarningsMarkdown,
    required this.createdAt,
    required this.updatedAt,
    required this.startedAt,
    required this.completedAt,
  });

  final String id;
  final String workflowTaskId;
  final String projectId;
  final String chapterPlanId;
  final String? chapterId;
  final String providerId;
  final String modelName;
  final ChapterGenerationStatus status;
  final ChapterGenerationStage? stage;
  final String? errorMessage;
  final String logs;
  final String contextWarningsMarkdown;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
}

class ChapterGenerationRunInput {
  const ChapterGenerationRunInput({
    required this.projectId,
    required this.chapterPlanId,
    required this.providerId,
    required this.modelName,
  });

  final String projectId;
  final String chapterPlanId;
  final String providerId;
  final String modelName;
}

class ChapterGenerationResult {
  const ChapterGenerationResult({
    required this.run,
    required this.chapter,
    required this.contextWarnings,
    required this.workflowTaskId,
  });

  final ChapterGenerationRun run;
  final ProjectChapter chapter;
  final List<String> contextWarnings;
  final String workflowTaskId;
}

class ChapterEnrichmentBatch {
  const ChapterEnrichmentBatch({
    required this.id,
    required this.workflowTaskId,
    required this.projectId,
    required this.instruction,
    required this.expansionRatioPercent,
    required this.providerId,
    required this.modelName,
    required this.status,
    required this.errorMessage,
    required this.totalCount,
    required this.generatedCount,
    required this.failedCount,
    required this.appliedCount,
    required this.logs,
    required this.createdAt,
    required this.updatedAt,
    required this.startedAt,
    required this.completedAt,
  });

  final String id;
  final String workflowTaskId;
  final String projectId;
  final String instruction;
  final int expansionRatioPercent;
  final String providerId;
  final String modelName;
  final ChapterEnrichmentBatchStatus status;
  final String? errorMessage;
  final int totalCount;
  final int generatedCount;
  final int failedCount;
  final int appliedCount;
  final String logs;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
}

class ChapterEnrichmentItem {
  const ChapterEnrichmentItem({
    required this.id,
    required this.batchId,
    required this.projectId,
    required this.chapterId,
    required this.position,
    required this.status,
    required this.errorMessage,
    required this.originalContentMarkdown,
    required this.generatedContentMarkdown,
    required this.providerId,
    required this.modelName,
    required this.logs,
    required this.createdAt,
    required this.updatedAt,
    required this.startedAt,
    required this.completedAt,
    required this.appliedAt,
  });

  final String id;
  final String batchId;
  final String projectId;
  final String chapterId;
  final int position;
  final ChapterEnrichmentItemStatus status;
  final String? errorMessage;
  final String originalContentMarkdown;
  final String generatedContentMarkdown;
  final String providerId;
  final String modelName;
  final String logs;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? appliedAt;
}

class ChapterEnrichmentBatchInput {
  const ChapterEnrichmentBatchInput({
    required this.projectId,
    required this.chapterIds,
    required this.instruction,
    required this.expansionRatioPercent,
    required this.providerId,
    required this.modelName,
  });

  final String projectId;
  final List<String> chapterIds;
  final String instruction;
  final int expansionRatioPercent;
  final String providerId;
  final String modelName;
}

class ChapterEnrichmentResult {
  const ChapterEnrichmentResult({
    required this.batch,
    required this.items,
    required this.workflowTaskId,
  });

  final ChapterEnrichmentBatch batch;
  final List<ChapterEnrichmentItem> items;
  final String workflowTaskId;
}

class AssetGenerationRun {
  const AssetGenerationRun({
    required this.id,
    required this.workflowTaskId,
    required this.projectId,
    this.targetVolumeId,
    required this.kind,
    required this.providerId,
    required this.modelName,
    required this.status,
    required this.stage,
    required this.errorMessage,
    required this.logs,
    required this.draftMarkdown,
    required this.createdAt,
    required this.updatedAt,
    required this.startedAt,
    required this.completedAt,
  });

  final String id;
  final String workflowTaskId;
  final String projectId;
  final String? targetVolumeId;
  final AssetGenerationKind kind;
  final String providerId;
  final String modelName;
  final AssetGenerationStatus status;
  final AssetGenerationStage? stage;
  final String? errorMessage;
  final String logs;
  final String draftMarkdown;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
}

class AssetGenerationRunInput {
  const AssetGenerationRunInput({
    required this.projectId,
    required this.kind,
    required this.providerId,
    required this.modelName,
  });

  final String projectId;
  final AssetGenerationKind kind;
  final String providerId;
  final String modelName;
}

class AssetGenerationResult {
  const AssetGenerationResult({
    required this.run,
    required this.workflowTaskId,
  });

  final AssetGenerationRun run;
  final String workflowTaskId;
}
