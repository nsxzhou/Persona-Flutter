import 'package:freezed_annotation/freezed_annotation.dart';

part 'chapter_draft_run.freezed.dart';
part 'chapter_draft_run.g.dart';

enum ChapterDraftRunStatus { pending, running, succeeded, failed, abandoned }

enum ChapterDraftRunStage {
  prepareContext,
  buildContract,
  draft,
  audit,
  revise,
  awaitAcceptance,
  projectMemory,
}

const chapterDraftWorkflowTaskKind = 'novel_chapter_draft';

@freezed
abstract class ChapterDraftRun with _$ChapterDraftRun {
  const factory ChapterDraftRun({
    required String id,
    required String workflowTaskId,
    required String projectId,
    required String chapterPlanId,
    required String providerId,
    required String modelName,
    required ChapterDraftRunStatus status,
    ChapterDraftRunStage? stage,
    @Default('') String contractMarkdown,
    @Default('') String draftMarkdown,
    @Default('') String auditMarkdown,
    @Default('') String revisedMarkdown,
    String? errorMessage,
    @Default('') String logs,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ChapterDraftRun;

  factory ChapterDraftRun.fromJson(Map<String, Object?> json) =>
      _$ChapterDraftRunFromJson(json);
}

class ChapterDraftRunInput {
  const ChapterDraftRunInput({
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
