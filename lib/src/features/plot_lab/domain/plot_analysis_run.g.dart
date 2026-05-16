// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plot_analysis_run.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlotAnalysisRun _$PlotAnalysisRunFromJson(Map<String, dynamic> json) =>
    _PlotAnalysisRun(
      id: json['id'] as String,
      workflowTaskId: json['workflowTaskId'] as String,
      sampleId: json['sampleId'] as String,
      providerId: json['providerId'] as String,
      modelName: json['modelName'] as String,
      plotName: json['plotName'] as String,
      status: $enumDecode(_$PlotAnalysisStatusEnumMap, json['status']),
      stage: $enumDecodeNullable(_$PlotAnalysisStageEnumMap, json['stage']),
      errorMessage: json['errorMessage'] as String?,
      logs: json['logs'] as String? ?? '',
      analysisReportMarkdown: json['analysisReportMarkdown'] as String?,
      plotSkeletonMarkdown: json['plotSkeletonMarkdown'] as String?,
      storyEngineMarkdown: json['storyEngineMarkdown'] as String?,
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

Map<String, dynamic> _$PlotAnalysisRunToJson(_PlotAnalysisRun instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workflowTaskId': instance.workflowTaskId,
      'sampleId': instance.sampleId,
      'providerId': instance.providerId,
      'modelName': instance.modelName,
      'plotName': instance.plotName,
      'status': _$PlotAnalysisStatusEnumMap[instance.status]!,
      'stage': _$PlotAnalysisStageEnumMap[instance.stage],
      'errorMessage': instance.errorMessage,
      'logs': instance.logs,
      'analysisReportMarkdown': instance.analysisReportMarkdown,
      'plotSkeletonMarkdown': instance.plotSkeletonMarkdown,
      'storyEngineMarkdown': instance.storyEngineMarkdown,
      'profileId': instance.profileId,
      'chunkCount': instance.chunkCount,
      'characterCount': instance.characterCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };

const _$PlotAnalysisStatusEnumMap = {
  PlotAnalysisStatus.pending: 'pending',
  PlotAnalysisStatus.running: 'running',
  PlotAnalysisStatus.succeeded: 'succeeded',
  PlotAnalysisStatus.failed: 'failed',
};

const _$PlotAnalysisStageEnumMap = {
  PlotAnalysisStage.preparingInput: 'preparingInput',
  PlotAnalysisStage.sketchingChunks: 'sketchingChunks',
  PlotAnalysisStage.buildingSkeleton: 'buildingSkeleton',
  PlotAnalysisStage.reporting: 'reporting',
  PlotAnalysisStage.postprocessing: 'postprocessing',
};
