import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:persona_flutter/src/core/database/app_database.dart';
import 'package:persona_flutter/src/features/settings/application/provider_connectivity_tester.dart';
import 'package:persona_flutter/src/features/settings/data/drift_provider_config_repository.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';

void main() {
  test('provider connectivity tester requests the models endpoint', () async {
    late http.BaseRequest capturedRequest;

    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response('{"data":[]}', 200);
    });

    final tester = ProviderConnectivityTester(client: client);
    final provider = ProviderConfig(
      id: 'provider-1',
      name: 'OpenAI',
      baseUrl: 'https://api.example.com/v1',
      apiKey: 'sk-test',
      defaultModel: 'gpt-4.1-mini',
      isEnabled: true,
      testStatus: ProviderTestStatus.untested,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    final result = await tester.test(provider);

    expect(result.isSuccess, isTrue);
    expect(result.message, contains('连接成功'));
    expect(capturedRequest.url.toString(), 'https://api.example.com/v1/models');
    expect(capturedRequest.headers['Authorization'], 'Bearer sk-test');
    expect(capturedRequest.headers['Accept'], 'application/json');
  });

  test('provider repository round-trips provider records in sqlite', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = DriftProviderConfigRepository(database);
    const input = ProviderConfigInput(
      name: 'OpenAI',
      baseUrl: 'https://api.example.com/v1',
      apiKey: 'sk-test',
      defaultModel: 'gpt-4.1-mini',
      isEnabled: true,
    );

    await repository.saveProvider(input: input);

    final saved = (await repository.watchProviders().first).single;
    expect(saved.name, input.name);
    expect(saved.baseUrl, input.baseUrl);
    expect(saved.apiKey, input.apiKey);
    expect(saved.defaultModel, input.defaultModel);
    expect(saved.testStatus, ProviderTestStatus.untested);

    await repository.updateTestResult(
      id: saved.id,
      status: ProviderTestStatus.succeeded,
      testedAt: DateTime.utc(2026, 5, 15, 12, 0),
      message: 'ok',
    );

    final updated = await repository.findProvider(saved.id);
    expect(updated, isNotNull);
    expect(updated!.testStatus, ProviderTestStatus.succeeded);
    expect(updated.lastTestMessage, 'ok');

    await repository.deleteProvider(saved.id);
    expect(await repository.findProvider(saved.id), isNull);
  });
}
