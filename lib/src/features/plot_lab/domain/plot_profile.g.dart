// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plot_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlotProfile _$PlotProfileFromJson(Map<String, dynamic> json) => _PlotProfile(
  id: json['id'] as String,
  sourceRunId: json['sourceRunId'] as String,
  providerId: json['providerId'] as String,
  modelName: json['modelName'] as String,
  plotName: json['plotName'] as String,
  storyEngineMarkdown: json['storyEngineMarkdown'] as String,
  analysisReportMarkdown: json['analysisReportMarkdown'] as String,
  plotSkeletonMarkdown: json['plotSkeletonMarkdown'] as String,
  sourceSampleId: json['sourceSampleId'] as String?,
  sourceTitle: json['sourceTitle'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PlotProfileToJson(_PlotProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceRunId': instance.sourceRunId,
      'providerId': instance.providerId,
      'modelName': instance.modelName,
      'plotName': instance.plotName,
      'storyEngineMarkdown': instance.storyEngineMarkdown,
      'analysisReportMarkdown': instance.analysisReportMarkdown,
      'plotSkeletonMarkdown': instance.plotSkeletonMarkdown,
      'sourceSampleId': instance.sourceSampleId,
      'sourceTitle': instance.sourceTitle,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
