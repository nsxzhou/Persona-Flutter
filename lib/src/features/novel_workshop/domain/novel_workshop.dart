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
