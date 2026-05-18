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

const chapterGenerationWorkflowTaskKind = 'novel_chapter_generation';

class ChapterPlan {
  const ChapterPlan({
    required this.id,
    required this.projectId,
    required this.chapterIndex,
    required this.objectiveCard,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String projectId;
  final int chapterIndex;
  final ChapterObjectiveCard objectiveCard;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ChapterPlanInput {
  const ChapterPlanInput({
    required this.projectId,
    required this.chapterIndex,
    required this.objectiveCard,
  });

  final String projectId;
  final int chapterIndex;
  final ChapterObjectiveCard objectiveCard;
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
