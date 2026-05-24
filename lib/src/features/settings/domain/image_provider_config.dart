import 'package:freezed_annotation/freezed_annotation.dart';

import 'provider_config.dart';

part 'image_provider_config.freezed.dart';
part 'image_provider_config.g.dart';

enum ImageResponseFormat { url, b64Json }

enum ImageProviderKind {
  gpt(label: 'GPT', storageValue: 'gpt'),
  grok(label: 'Grok', storageValue: 'grok');

  const ImageProviderKind({required this.label, required this.storageValue});

  final String label;
  final String storageValue;

  static ImageProviderKind fromStorage(String value) {
    final normalized = value.trim().toLowerCase();
    for (final kind in values) {
      if (kind.storageValue == normalized || kind.name == normalized) {
        return kind;
      }
    }
    return ImageProviderKind.gpt;
  }
}

enum ImageAspectRatioPreset {
  square(label: '方形 1:1', ratio: '1:1'),
  portrait(label: '竖版 3:4', ratio: '3:4'),
  story(label: '故事版 9:16', ratio: '9:16'),
  landscape(label: '横版 4:3', ratio: '4:3'),
  wide(label: '宽屏 16:9', ratio: '16:9');

  const ImageAspectRatioPreset({required this.label, required this.ratio});

  final String label;
  final String ratio;

  static ImageAspectRatioPreset fromRatio(String value) {
    final normalized = value.trim();
    for (final preset in values) {
      if (preset.ratio == normalized || preset.label == normalized) {
        return preset;
      }
    }
    return ImageAspectRatioPreset.square;
  }
}

enum ImageSizePreset {
  oneK(label: '1K', tier: '1K', squareSize: '1024x1024'),
  twoK(label: '2K', tier: '2K', squareSize: '2048x2048'),
  fourK(label: '4K', tier: '4K', squareSize: '2880x2880');

  const ImageSizePreset({
    required this.label,
    required this.tier,
    required this.squareSize,
  });

  final String label;
  final String tier;
  final String squareSize;

  static ImageSizePreset fromTier(String value) {
    final normalized = value.trim();
    for (final preset in values) {
      if (preset.tier.toLowerCase() == normalized.toLowerCase() ||
          preset.label.toLowerCase() == normalized.toLowerCase()) {
        return preset;
      }
    }
    return ImageSizePreset.oneK;
  }
}

enum ImageQualityPreset {
  auto(label: 'auto', quality: 'auto'),
  low(label: 'low', quality: 'low'),
  medium(label: 'medium', quality: 'medium'),
  high(label: 'high', quality: 'high');

  const ImageQualityPreset({required this.label, required this.quality});

  final String label;
  final String quality;

  static ImageQualityPreset fromQuality(String value) {
    final normalized = value.trim();
    for (final preset in values) {
      if (preset.quality == normalized || preset.label == normalized) {
        return preset;
      }
    }
    return ImageQualityPreset.auto;
  }
}

String resolveImageRequestSize({
  required ImageAspectRatioPreset aspectRatio,
  required ImageSizePreset size,
}) {
  final ratio = aspectRatio.ratio;
  return switch ((size, ratio)) {
    (ImageSizePreset.oneK, '1:1') => '1024x1024',
    (ImageSizePreset.oneK, '3:4') => '896x1184',
    (ImageSizePreset.oneK, '9:16') => '768x1344',
    (ImageSizePreset.oneK, '4:3') => '1184x896',
    (ImageSizePreset.oneK, '16:9') => '1344x768',
    (ImageSizePreset.twoK, '1:1') => '2048x2048',
    (ImageSizePreset.twoK, '3:4') => '1776x2368',
    (ImageSizePreset.twoK, '9:16') => '1536x2736',
    (ImageSizePreset.twoK, '4:3') => '2368x1776',
    (ImageSizePreset.twoK, '16:9') => '2736x1536',
    (ImageSizePreset.fourK, '1:1') => '2880x2880',
    (ImageSizePreset.fourK, '3:4') => '2496x3328',
    (ImageSizePreset.fourK, '9:16') => '2160x3840',
    (ImageSizePreset.fourK, '4:3') => '3328x2496',
    (ImageSizePreset.fourK, '16:9') => '3840x2160',
    _ => size.squareSize,
  };
}

@freezed
abstract class ImageProviderConfig with _$ImageProviderConfig {
  const factory ImageProviderConfig({
    required String id,
    required String name,
    required String baseUrl,
    required String apiKey,
    required String defaultModel,
    @Default(ImageProviderKind.gpt) ImageProviderKind providerKind,
    @Default(<String>[]) List<String> modelNames,
    @Default(ImageAspectRatioPreset.square)
    ImageAspectRatioPreset defaultAspectRatio,
    @Default(ImageSizePreset.oneK) ImageSizePreset defaultSize,
    @Default(ImageQualityPreset.auto) ImageQualityPreset defaultQuality,
    @Default(ImageResponseFormat.url) ImageResponseFormat defaultResponseFormat,
    required bool isEnabled,
    required ProviderTestStatus testStatus,
    DateTime? lastTestedAt,
    String? lastTestMessage,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ImageProviderConfig;

  factory ImageProviderConfig.fromJson(Map<String, Object?> json) =>
      _$ImageProviderConfigFromJson(json);
}

class ImageProviderConfigInput {
  const ImageProviderConfigInput({
    required this.name,
    required this.baseUrl,
    required this.apiKey,
    required this.defaultModel,
    this.providerKind = ImageProviderKind.gpt,
    this.modelNames = const <String>[],
    this.defaultAspectRatio = ImageAspectRatioPreset.square,
    this.defaultSize = ImageSizePreset.oneK,
    this.defaultQuality = ImageQualityPreset.auto,
    this.defaultResponseFormat = ImageResponseFormat.url,
    required this.isEnabled,
  });

  final String name;
  final String baseUrl;
  final String apiKey;
  final String defaultModel;
  final ImageProviderKind providerKind;
  final List<String> modelNames;
  final ImageAspectRatioPreset defaultAspectRatio;
  final ImageSizePreset defaultSize;
  final ImageQualityPreset defaultQuality;
  final ImageResponseFormat defaultResponseFormat;
  final bool isEnabled;
}
