// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accepted_chapter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AcceptedChapter _$AcceptedChapterFromJson(Map<String, dynamic> json) =>
    _AcceptedChapter(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      chapterPlanId: json['chapterPlanId'] as String,
      sourceRunId: json['sourceRunId'] as String,
      chapterIndex: (json['chapterIndex'] as num).toInt(),
      title: json['title'] as String,
      contentMarkdown: json['contentMarkdown'] as String,
      acceptedAt: DateTime.parse(json['acceptedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AcceptedChapterToJson(_AcceptedChapter instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'chapterPlanId': instance.chapterPlanId,
      'sourceRunId': instance.sourceRunId,
      'chapterIndex': instance.chapterIndex,
      'title': instance.title,
      'contentMarkdown': instance.contentMarkdown,
      'acceptedAt': instance.acceptedAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
