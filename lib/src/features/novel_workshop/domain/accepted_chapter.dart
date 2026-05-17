import 'package:freezed_annotation/freezed_annotation.dart';

part 'accepted_chapter.freezed.dart';
part 'accepted_chapter.g.dart';

@freezed
abstract class AcceptedChapter with _$AcceptedChapter {
  const factory AcceptedChapter({
    required String id,
    required String projectId,
    required String chapterPlanId,
    required String sourceRunId,
    required int chapterIndex,
    required String title,
    required String contentMarkdown,
    required DateTime acceptedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AcceptedChapter;

  factory AcceptedChapter.fromJson(Map<String, Object?> json) =>
      _$AcceptedChapterFromJson(json);
}

class AcceptedChapterInput {
  const AcceptedChapterInput({
    required this.projectId,
    required this.chapterPlanId,
    required this.sourceRunId,
    required this.chapterIndex,
    required this.title,
    required this.contentMarkdown,
    this.acceptedAt,
  });

  final String projectId;
  final String chapterPlanId;
  final String sourceRunId;
  final int chapterIndex;
  final String title;
  final String contentMarkdown;
  final DateTime? acceptedAt;
}
