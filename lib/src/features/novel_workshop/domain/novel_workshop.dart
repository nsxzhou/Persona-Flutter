import 'writing_context.dart';

enum ContinuityVerdict { pass, warning, fail }

enum MemorySyncStatus {
  idle,
  checking,
  pendingReview,
  synced,
  noChange,
  failed,
  stale,
}

enum ChapterGenerationStatus { pending, running, succeeded, failed }

enum ChapterGenerationStage { preparingContext, generatingDraft, savingChapter }

enum AssetGenerationKind {
  worldBuilding,
  charactersBlueprint,
  outlineMaster,
  outlineDetailYaml,
}

enum AssetGenerationStatus { pending, running, succeeded, failed, applied }

enum AssetGenerationStage { preparingContext, generatingDraft, savingDraft }

const chapterGenerationWorkflowTaskKind = 'novel_chapter_generation';
const assetGenerationWorkflowTaskKind = 'novel_asset_generation';

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
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String projectId;
  final int volumeIndex;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ChapterVolumeInput {
  const ChapterVolumeInput({
    required this.projectId,
    required this.volumeIndex,
    required this.title,
  });

  final String projectId;
  final int volumeIndex;
  final String title;
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
    required this.memorySyncProposedCharactersStatus,
    required this.memorySyncProposedRuntimeState,
    required this.memorySyncProposedRuntimeThreads,
    required this.memorySyncProposedStorySummary,
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
  final String memorySyncProposedCharactersStatus;
  final String memorySyncProposedRuntimeState;
  final String memorySyncProposedRuntimeThreads;
  final String memorySyncProposedStorySummary;
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
    required this.proposedMemory,
  });

  final String chapterId;
  final String contentHash;
  final RuntimeMemoryState proposedMemory;
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

class AssetGenerationRun {
  const AssetGenerationRun({
    required this.id,
    required this.workflowTaskId,
    required this.projectId,
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
