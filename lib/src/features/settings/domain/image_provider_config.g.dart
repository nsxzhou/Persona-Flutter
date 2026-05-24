// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_provider_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImageProviderConfig _$ImageProviderConfigFromJson(Map<String, dynamic> json) =>
    _ImageProviderConfig(
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
      defaultAspectRatio:
          $enumDecodeNullable(
            _$ImageAspectRatioPresetEnumMap,
            json['defaultAspectRatio'],
          ) ??
          ImageAspectRatioPreset.square,
      defaultSize:
          $enumDecodeNullable(_$ImageSizePresetEnumMap, json['defaultSize']) ??
          ImageSizePreset.oneK,
      defaultQuality:
          $enumDecodeNullable(
            _$ImageQualityPresetEnumMap,
            json['defaultQuality'],
          ) ??
          ImageQualityPreset.auto,
      defaultResponseFormat:
          $enumDecodeNullable(
            _$ImageResponseFormatEnumMap,
            json['defaultResponseFormat'],
          ) ??
          ImageResponseFormat.url,
      isEnabled: json['isEnabled'] as bool,
      testStatus: $enumDecode(_$ProviderTestStatusEnumMap, json['testStatus']),
      lastTestedAt: json['lastTestedAt'] == null
          ? null
          : DateTime.parse(json['lastTestedAt'] as String),
      lastTestMessage: json['lastTestMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ImageProviderConfigToJson(
  _ImageProviderConfig instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'baseUrl': instance.baseUrl,
  'apiKey': instance.apiKey,
  'defaultModel': instance.defaultModel,
  'modelNames': instance.modelNames,
  'defaultAspectRatio':
      _$ImageAspectRatioPresetEnumMap[instance.defaultAspectRatio]!,
  'defaultSize': _$ImageSizePresetEnumMap[instance.defaultSize]!,
  'defaultQuality': _$ImageQualityPresetEnumMap[instance.defaultQuality]!,
  'defaultResponseFormat':
      _$ImageResponseFormatEnumMap[instance.defaultResponseFormat]!,
  'isEnabled': instance.isEnabled,
  'testStatus': _$ProviderTestStatusEnumMap[instance.testStatus]!,
  'lastTestedAt': instance.lastTestedAt?.toIso8601String(),
  'lastTestMessage': instance.lastTestMessage,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$ImageAspectRatioPresetEnumMap = {
  ImageAspectRatioPreset.square: 'square',
  ImageAspectRatioPreset.portrait: 'portrait',
  ImageAspectRatioPreset.story: 'story',
  ImageAspectRatioPreset.landscape: 'landscape',
  ImageAspectRatioPreset.wide: 'wide',
};

const _$ImageSizePresetEnumMap = {
  ImageSizePreset.oneK: 'oneK',
  ImageSizePreset.twoK: 'twoK',
  ImageSizePreset.fourK: 'fourK',
};

const _$ImageQualityPresetEnumMap = {
  ImageQualityPreset.auto: 'auto',
  ImageQualityPreset.low: 'low',
  ImageQualityPreset.medium: 'medium',
  ImageQualityPreset.high: 'high',
};

const _$ImageResponseFormatEnumMap = {
  ImageResponseFormat.url: 'url',
  ImageResponseFormat.b64Json: 'b64Json',
};

const _$ProviderTestStatusEnumMap = {
  ProviderTestStatus.untested: 'untested',
  ProviderTestStatus.testing: 'testing',
  ProviderTestStatus.succeeded: 'succeeded',
  ProviderTestStatus.failed: 'failed',
};
