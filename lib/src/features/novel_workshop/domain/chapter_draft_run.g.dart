// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_draft_run.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChapterDraftRun _$ChapterDraftRunFromJson(Map<String, dynamic> json) =>
    _ChapterDraftRun(
      id: json['id'] as String,
      workflowTaskId: json['workflowTaskId'] as String,
      projectId: json['projectId'] as String,
      chapterPlanId: json['chapterPlanId'] as String,
      providerId: json['providerId'] as String,
      modelName: json['modelName'] as String,
      status: $enumDecode(_$ChapterDraftRunStatusEnumMap, json['status']),
      stage: $enumDecodeNullable(_$ChapterDraftRunStageEnumMap, json['stage']),
      contractMarkdown: json['contractMarkdown'] as String? ?? '',
      draftMarkdown: json['draftMarkdown'] as String? ?? '',
      auditMarkdown: json['auditMarkdown'] as String? ?? '',
      revisedMarkdown: json['revisedMarkdown'] as String? ?? '',
      errorMessage: json['errorMessage'] as String?,
      logs: json['logs'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ChapterDraftRunToJson(_ChapterDraftRun instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workflowTaskId': instance.workflowTaskId,
      'projectId': instance.projectId,
      'chapterPlanId': instance.chapterPlanId,
      'providerId': instance.providerId,
      'modelName': instance.modelName,
      'status': _$ChapterDraftRunStatusEnumMap[instance.status]!,
      'stage': _$ChapterDraftRunStageEnumMap[instance.stage],
      'contractMarkdown': instance.contractMarkdown,
      'draftMarkdown': instance.draftMarkdown,
      'auditMarkdown': instance.auditMarkdown,
      'revisedMarkdown': instance.revisedMarkdown,
      'errorMessage': instance.errorMessage,
      'logs': instance.logs,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ChapterDraftRunStatusEnumMap = {
  ChapterDraftRunStatus.pending: 'pending',
  ChapterDraftRunStatus.running: 'running',
  ChapterDraftRunStatus.succeeded: 'succeeded',
  ChapterDraftRunStatus.failed: 'failed',
  ChapterDraftRunStatus.abandoned: 'abandoned',
};

const _$ChapterDraftRunStageEnumMap = {
  ChapterDraftRunStage.prepareContext: 'prepareContext',
  ChapterDraftRunStage.buildContract: 'buildContract',
  ChapterDraftRunStage.draft: 'draft',
  ChapterDraftRunStage.audit: 'audit',
  ChapterDraftRunStage.revise: 'revise',
  ChapterDraftRunStage.awaitAcceptance: 'awaitAcceptance',
  ChapterDraftRunStage.projectMemory: 'projectMemory',
};
