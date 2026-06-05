// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_scan_run.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MarketScanRun _$MarketScanRunFromJson(Map<String, dynamic> json) =>
    _MarketScanRun(
      id: json['id'] as String,
      platform: json['platform'] as String,
      status: $enumDecode(_$MarketScanRunStatusEnumMap, json['status']),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      errorMessage: json['errorMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MarketScanRunToJson(_MarketScanRun instance) =>
    <String, dynamic>{
      'id': instance.id,
      'platform': instance.platform,
      'status': _$MarketScanRunStatusEnumMap[instance.status]!,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'itemCount': instance.itemCount,
      'errorMessage': instance.errorMessage,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$MarketScanRunStatusEnumMap = {
  MarketScanRunStatus.running: 'running',
  MarketScanRunStatus.completed: 'completed',
  MarketScanRunStatus.failed: 'failed',
};
