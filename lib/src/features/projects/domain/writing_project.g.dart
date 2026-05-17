// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'writing_project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WritingProject _$WritingProjectFromJson(Map<String, dynamic> json) =>
    _WritingProject(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: $enumDecode(_$ProjectStatusEnumMap, json['status']),
      defaultProviderId: json['defaultProviderId'] as String?,
      defaultModelName: json['defaultModelName'] as String?,
      styleProfileId: json['styleProfileId'] as String?,
      plotProfileId: json['plotProfileId'] as String?,
      language: json['language'] as String? ?? defaultProjectLanguage,
      targetLength:
          (json['targetLength'] as num?)?.toInt() ?? defaultProjectTargetLength,
      narrativePerspective:
          json['narrativePerspective'] as String? ??
          defaultProjectNarrativePerspective,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$WritingProjectToJson(_WritingProject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': _$ProjectStatusEnumMap[instance.status]!,
      'defaultProviderId': instance.defaultProviderId,
      'defaultModelName': instance.defaultModelName,
      'styleProfileId': instance.styleProfileId,
      'plotProfileId': instance.plotProfileId,
      'language': instance.language,
      'targetLength': instance.targetLength,
      'narrativePerspective': instance.narrativePerspective,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ProjectStatusEnumMap = {
  ProjectStatus.active: 'active',
  ProjectStatus.archived: 'archived',
};
