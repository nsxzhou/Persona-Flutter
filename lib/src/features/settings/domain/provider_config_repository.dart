import 'provider_config.dart';

abstract interface class ProviderConfigRepository {
  Stream<List<ProviderConfig>> watchProviders();

  Future<void> saveProvider({String? id, required ProviderConfigInput input});

  Future<void> deleteProvider(String id);

  Future<ProviderConfig?> findProvider(String id);

  Stream<ProviderConfig?> watchProvider(String id);

  Future<void> updateTestResult({
    required String id,
    required ProviderTestStatus status,
    required DateTime testedAt,
    String? message,
  });

  Future<void> updateSystemPrompt({
    required String id,
    required String systemPrompt,
    bool? isSystemPromptEnabled,
  });
}
