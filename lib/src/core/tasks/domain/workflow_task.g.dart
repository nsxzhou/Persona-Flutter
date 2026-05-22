// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkflowTask _$WorkflowTaskFromJson(Map<String, dynamic> json) =>
    _WorkflowTask(
      id: json['id'] as String,
      kind: json['kind'] as String,
      status: $enumDecode(_$WorkflowTaskStatusEnumMap, json['status']),
      title: json['title'] as String,
      stage: json['stage'] as String?,
      errorMessage: json['errorMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$WorkflowTaskToJson(_WorkflowTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': instance.kind,
      'status': _$WorkflowTaskStatusEnumMap[instance.status]!,
      'title': instance.title,
      'stage': instance.stage,
      'errorMessage': instance.errorMessage,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$WorkflowTaskStatusEnumMap = {
  WorkflowTaskStatus.pending: 'pending',
  WorkflowTaskStatus.running: 'running',
  WorkflowTaskStatus.succeeded: 'succeeded',
  WorkflowTaskStatus.failed: 'failed',
  WorkflowTaskStatus.abandoned: 'abandoned',
};
