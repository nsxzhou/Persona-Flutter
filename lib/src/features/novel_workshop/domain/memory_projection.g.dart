// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_projection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MemoryProjection _$MemoryProjectionFromJson(Map<String, dynamic> json) =>
    _MemoryProjection(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      recentSummary: json['recentSummary'] as String? ?? '',
      globalSummary: json['globalSummary'] as String? ?? '',
      factLedgerMarkdown: json['factLedgerMarkdown'] as String? ?? '',
      characterStatesMarkdown: json['characterStatesMarkdown'] as String? ?? '',
      unresolvedHooksMarkdown: json['unresolvedHooksMarkdown'] as String? ?? '',
      updatedFromChapterId: json['updatedFromChapterId'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MemoryProjectionToJson(_MemoryProjection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'recentSummary': instance.recentSummary,
      'globalSummary': instance.globalSummary,
      'factLedgerMarkdown': instance.factLedgerMarkdown,
      'characterStatesMarkdown': instance.characterStatesMarkdown,
      'unresolvedHooksMarkdown': instance.unresolvedHooksMarkdown,
      'updatedFromChapterId': instance.updatedFromChapterId,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
