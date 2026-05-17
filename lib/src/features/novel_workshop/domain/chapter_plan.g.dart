// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChapterPlan _$ChapterPlanFromJson(Map<String, dynamic> json) => _ChapterPlan(
  id: json['id'] as String,
  projectId: json['projectId'] as String,
  chapterIndex: (json['chapterIndex'] as num).toInt(),
  title: json['title'] as String,
  goal: json['goal'] as String? ?? '',
  targetBeat: json['targetBeat'] as String? ?? '',
  mustInclude: json['mustInclude'] as String? ?? '',
  mustAvoid: json['mustAvoid'] as String? ?? '',
  hook: json['hook'] as String? ?? '',
  payoff: json['payoff'] as String? ?? '',
  status: $enumDecode(_$ChapterPlanStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ChapterPlanToJson(_ChapterPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'chapterIndex': instance.chapterIndex,
      'title': instance.title,
      'goal': instance.goal,
      'targetBeat': instance.targetBeat,
      'mustInclude': instance.mustInclude,
      'mustAvoid': instance.mustAvoid,
      'hook': instance.hook,
      'payoff': instance.payoff,
      'status': _$ChapterPlanStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ChapterPlanStatusEnumMap = {
  ChapterPlanStatus.planned: 'planned',
  ChapterPlanStatus.drafting: 'drafting',
  ChapterPlanStatus.reviewed: 'reviewed',
  ChapterPlanStatus.accepted: 'accepted',
};
