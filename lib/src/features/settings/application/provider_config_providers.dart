import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/llm/application/llm_invocation_service.dart';
import '../../../core/llm/data/langchain_llm_client.dart';
import '../../../core/llm/domain/llm_client.dart';
import '../data/drift_provider_config_repository.dart';
import '../domain/provider_config.dart';
import '../domain/provider_config_repository.dart';
import 'provider_connectivity_tester.dart';

part 'provider_config_providers.g.dart';

@Riverpod(keepAlive: true)
http.Client providerHttpClient(Ref ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
}

@Riverpod(keepAlive: true)
ProviderConfigRepository providerConfigRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftProviderConfigRepository(database);
}

@Riverpod(keepAlive: true)
ProviderConnectivityTester providerConnectivityTester(Ref ref) {
  return ProviderConnectivityTester(
    client: ref.watch(providerHttpClientProvider),
  );
}

@Riverpod(keepAlive: true)
LlmClient llmClient(Ref ref) {
  return LangChainLlmClient(client: ref.watch(providerHttpClientProvider));
}

@Riverpod(keepAlive: true)
LlmInvocationService llmInvocationService(Ref ref) {
  return LlmInvocationService(client: ref.watch(llmClientProvider));
}

@riverpod
Stream<List<ProviderConfig>> providerConfigs(Ref ref) {
  final repository = ref.watch(providerConfigRepositoryProvider);
  return repository.watchProviders();
}

@riverpod
Stream<ProviderConfig?> providerConfig(Ref ref, String id) {
  final repository = ref.watch(providerConfigRepositoryProvider);
  return repository.watchProvider(id);
}

@riverpod
class ProviderConfigController extends _$ProviderConfigController {
  @override
  FutureOr<void> build() {}

  Future<void> save({String? id, required ProviderConfigInput input}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(providerConfigRepositoryProvider)
          .saveProvider(id: id, input: input);
    });
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(providerConfigRepositoryProvider).deleteProvider(id);
    });
  }

  Future<void> updateSystemPrompt({
    required String id,
    required String systemPrompt,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(providerConfigRepositoryProvider)
          .updateSystemPrompt(id: id, systemPrompt: systemPrompt);
    });
  }

  Future<void> test(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(providerConfigRepositoryProvider);
      final provider = await repository.findProvider(id);
      if (provider == null) {
        throw StateError('Provider 不存在。');
      }

      final now = DateTime.now();
      await repository.updateTestResult(
        id: id,
        status: ProviderTestStatus.testing,
        testedAt: now,
      );

      final result = await ref
          .read(providerConnectivityTesterProvider)
          .test(provider);

      await repository.updateTestResult(
        id: id,
        status: result.isSuccess
            ? ProviderTestStatus.succeeded
            : ProviderTestStatus.failed,
        testedAt: DateTime.now(),
        message: result.message,
      );
    });
  }
}
