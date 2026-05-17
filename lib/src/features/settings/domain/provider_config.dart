import 'package:freezed_annotation/freezed_annotation.dart';

part 'provider_config.freezed.dart';
part 'provider_config.g.dart';

enum ProviderTestStatus { untested, testing, succeeded, failed }

@freezed
abstract class ProviderConfig with _$ProviderConfig {
  const factory ProviderConfig({
    required String id,
    required String name,
    required String baseUrl,
    required String apiKey,
    required String defaultModel,
    @Default(<String>[]) List<String> modelNames,
    @Default('') String systemPrompt,
    required bool isEnabled,
    required ProviderTestStatus testStatus,
    DateTime? lastTestedAt,
    String? lastTestMessage,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ProviderConfig;

  factory ProviderConfig.fromJson(Map<String, Object?> json) =>
      _$ProviderConfigFromJson(json);
}

class ProviderConfigInput {
  const ProviderConfigInput({
    required this.name,
    required this.baseUrl,
    required this.apiKey,
    required this.defaultModel,
    this.modelNames = const <String>[],
    required this.systemPrompt,
    required this.isEnabled,
  });

  final String name;
  final String baseUrl;
  final String apiKey;
  final String defaultModel;
  final List<String> modelNames;
  final String systemPrompt;
  final bool isEnabled;
}
