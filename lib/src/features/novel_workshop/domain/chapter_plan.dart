import 'package:freezed_annotation/freezed_annotation.dart';

part 'chapter_plan.freezed.dart';
part 'chapter_plan.g.dart';

enum ChapterPlanStatus { planned, drafting, reviewed, accepted }

@freezed
abstract class ChapterPlan with _$ChapterPlan {
  const factory ChapterPlan({
    required String id,
    required String projectId,
    required int chapterIndex,
    required String title,
    @Default('') String goal,
    @Default('') String targetBeat,
    @Default('') String mustInclude,
    @Default('') String mustAvoid,
    @Default('') String hook,
    @Default('') String payoff,
    required ChapterPlanStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ChapterPlan;

  factory ChapterPlan.fromJson(Map<String, Object?> json) =>
      _$ChapterPlanFromJson(json);
}

class ChapterPlanInput {
  const ChapterPlanInput({
    required this.projectId,
    required this.chapterIndex,
    required this.title,
    this.goal = '',
    this.targetBeat = '',
    this.mustInclude = '',
    this.mustAvoid = '',
    this.hook = '',
    this.payoff = '',
    this.status = ChapterPlanStatus.planned,
  });

  final String projectId;
  final int chapterIndex;
  final String title;
  final String goal;
  final String targetBeat;
  final String mustInclude;
  final String mustAvoid;
  final String hook;
  final String payoff;
  final ChapterPlanStatus status;
}
