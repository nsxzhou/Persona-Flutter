// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'style_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StyleProfile _$StyleProfileFromJson(Map<String, dynamic> json) =>
    _StyleProfile(
      id: json['id'] as String,
      sourceRunId: json['sourceRunId'] as String,
      providerId: json['providerId'] as String,
      modelName: json['modelName'] as String,
      styleName: json['styleName'] as String,
      profileMarkdown: json['profileMarkdown'] as String,
      analysisReportMarkdown: json['analysisReportMarkdown'] as String,
      projectId: json['projectId'] as String?,
      sourceSampleId: json['sourceSampleId'] as String?,
      sourceTitle: json['sourceTitle'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$StyleProfileToJson(_StyleProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceRunId': instance.sourceRunId,
      'providerId': instance.providerId,
      'modelName': instance.modelName,
      'styleName': instance.styleName,
      'profileMarkdown': instance.profileMarkdown,
      'analysisReportMarkdown': instance.analysisReportMarkdown,
      'projectId': instance.projectId,
      'sourceSampleId': instance.sourceSampleId,
      'sourceTitle': instance.sourceTitle,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
