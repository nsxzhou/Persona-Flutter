// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProviderConfig _$ProviderConfigFromJson(Map<String, dynamic> json) =>
    _ProviderConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      baseUrl: json['baseUrl'] as String,
      apiKey: json['apiKey'] as String,
      defaultModel: json['defaultModel'] as String,
      modelNames:
          (json['modelNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      systemPrompt: json['systemPrompt'] as String? ?? '',
      isEnabled: json['isEnabled'] as bool,
      testStatus: $enumDecode(_$ProviderTestStatusEnumMap, json['testStatus']),
      lastTestedAt: json['lastTestedAt'] == null
          ? null
          : DateTime.parse(json['lastTestedAt'] as String),
      lastTestMessage: json['lastTestMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProviderConfigToJson(_ProviderConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'baseUrl': instance.baseUrl,
      'apiKey': instance.apiKey,
      'defaultModel': instance.defaultModel,
      'modelNames': instance.modelNames,
      'systemPrompt': instance.systemPrompt,
      'isEnabled': instance.isEnabled,
      'testStatus': _$ProviderTestStatusEnumMap[instance.testStatus]!,
      'lastTestedAt': instance.lastTestedAt?.toIso8601String(),
      'lastTestMessage': instance.lastTestMessage,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ProviderTestStatusEnumMap = {
  ProviderTestStatus.untested: 'untested',
  ProviderTestStatus.testing: 'testing',
  ProviderTestStatus.succeeded: 'succeeded',
  ProviderTestStatus.failed: 'failed',
};
