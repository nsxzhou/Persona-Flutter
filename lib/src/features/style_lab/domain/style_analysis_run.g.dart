// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'style_analysis_run.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StyleAnalysisRun _$StyleAnalysisRunFromJson(Map<String, dynamic> json) =>
    _StyleAnalysisRun(
      id: json['id'] as String,
      workflowTaskId: json['workflowTaskId'] as String,
      sampleId: json['sampleId'] as String,
      providerId: json['providerId'] as String,
      modelName: json['modelName'] as String,
      styleName: json['styleName'] as String,
      projectId: json['projectId'] as String?,
      status: $enumDecode(_$StyleAnalysisStatusEnumMap, json['status']),
      stage: $enumDecodeNullable(_$StyleAnalysisStageEnumMap, json['stage']),
      errorMessage: json['errorMessage'] as String?,
      logs: json['logs'] as String? ?? '',
      analysisReportMarkdown: json['analysisReportMarkdown'] as String?,
      voiceProfileMarkdown: json['voiceProfileMarkdown'] as String?,
      profileId: json['profileId'] as String?,
      chunkCount: (json['chunkCount'] as num).toInt(),
      characterCount: (json['characterCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$StyleAnalysisRunToJson(_StyleAnalysisRun instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workflowTaskId': instance.workflowTaskId,
      'sampleId': instance.sampleId,
      'providerId': instance.providerId,
      'modelName': instance.modelName,
      'styleName': instance.styleName,
      'projectId': instance.projectId,
      'status': _$StyleAnalysisStatusEnumMap[instance.status]!,
      'stage': _$StyleAnalysisStageEnumMap[instance.stage],
      'errorMessage': instance.errorMessage,
      'logs': instance.logs,
      'analysisReportMarkdown': instance.analysisReportMarkdown,
      'voiceProfileMarkdown': instance.voiceProfileMarkdown,
      'profileId': instance.profileId,
      'chunkCount': instance.chunkCount,
      'characterCount': instance.characterCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };

const _$StyleAnalysisStatusEnumMap = {
  StyleAnalysisStatus.pending: 'pending',
  StyleAnalysisStatus.running: 'running',
  StyleAnalysisStatus.succeeded: 'succeeded',
  StyleAnalysisStatus.failed: 'failed',
};

const _$StyleAnalysisStageEnumMap = {
  StyleAnalysisStage.preparingInput: 'preparingInput',
  StyleAnalysisStage.analyzingChunks: 'analyzingChunks',
  StyleAnalysisStage.aggregating: 'aggregating',
  StyleAnalysisStage.reporting: 'reporting',
  StyleAnalysisStage.buildingVoiceProfile: 'buildingVoiceProfile',
  StyleAnalysisStage.persistingResult: 'persistingResult',
};
