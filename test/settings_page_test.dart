import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_client.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_request.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_stream_event.dart';
import 'package:persona_flutter/src/features/settings/application/provider_config_providers.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:persona_flutter/src/features/settings/presentation/provider_detail_page.dart';
import 'package:persona_flutter/src/features/settings/presentation/settings_page.dart';

void main() {
  testWidgets('settings page shows the local console empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerConfigsProvider.overrideWith(
            (ref) => Stream<List<ProviderConfig>>.value(const []),
          ),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Provider 控制台'), findsOneWidget);
    expect(find.text('尚未配置 Provider'), findsOneWidget);
    expect(find.text('待开发'), findsWidgets);
    expect(find.text('新增 Provider'), findsWidgets);
  });

  testWidgets(
    'settings page renders compact provider rows with primary test action',
    (tester) async {
      final providers = [
        _provider(
          id: 'deepseek',
          name: 'deepseek',
          apiKey: 'sk-secret-deepseek',
          systemPrompt: 'Provider writing rules',
          testStatus: ProviderTestStatus.succeeded,
          lastTestMessage: '连接成功，已读取模型列表。',
        ),
        _provider(
          id: 'openai',
          name: 'openai',
          apiKey: 'sk-secret-openai',
          systemPrompt: '',
          testStatus: ProviderTestStatus.untested,
          isEnabled: false,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            providerConfigsProvider.overrideWith(
              (ref) => Stream<List<ProviderConfig>>.value(providers),
            ),
          ],
          child: const MaterialApp(home: SettingsPage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Provider 控制台'), findsOneWidget);
      expect(find.text('测试连接'), findsWidgets);
      expect(find.text('打开详情'), findsWidgets);
      expect(find.text('可用'), findsWidgets);
      expect(find.text('已配置'), findsWidgets);
      expect(find.text('未配置'), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsNWidgets(2));
      expect(find.text('sk-secret-deepseek'), findsNothing);
      expect(find.text('sk-secret-openai'), findsNothing);
    },
  );

  testWidgets('provider dialogs are constrained and expose safe actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final provider = _provider(
      id: 'deepseek',
      name: 'deepseek',
      apiKey: 'sk-secret-deepseek',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerConfigsProvider.overrideWith(
            (ref) => Stream<List<ProviderConfig>>.value([provider]),
          ),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('新增 Provider').first);
    await tester.pumpAndSettle();

    expect(find.text('新增 Provider'), findsWidgets);
    expect(find.textContaining('API Key 只保存在本地 SQLite'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('取消').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除 Provider'));
    await tester.pumpAndSettle();

    expect(find.text('删除 Provider'), findsWidgets);
    expect(find.textContaining('API Key 会从 SQLite 中删除'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('provider detail page edits prompt and streams assistant reply', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final provider = ProviderConfig(
      id: 'deepseek',
      name: 'deepseek',
      baseUrl: 'https://api.deepseek.com/v1',
      apiKey: 'sk-secret',
      defaultModel: 'deepseek-v4-flash',
      systemPrompt: 'Provider writing rules',
      isEnabled: false,
      testStatus: ProviderTestStatus.succeeded,
      lastTestedAt: DateTime(2026, 5, 15),
      lastTestMessage: '连接成功，已读取模型列表。',
      createdAt: DateTime(2026, 5, 15),
      updatedAt: DateTime(2026, 5, 15),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerConfigProvider.overrideWith(
            (ref, id) => Stream<ProviderConfig?>.value(provider),
          ),
          llmClientProvider.overrideWithValue(_FakeLlmClient()),
        ],
        child: const MaterialApp(
          home: ProviderDetailPage(providerId: 'deepseek'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('已停用 · 仍可测试'), findsOneWidget);
    expect(find.text('Provider writing rules'), findsOneWidget);
    expect(find.text('Inspector'), findsOneWidget);
    expect(find.text('Prompt'), findsOneWidget);
    expect(find.text('Request'), findsOneWidget);
    expect(find.text('sk-secret'), findsNothing);

    await tester.enterText(find.byType(TextField).last, '继续写下一段');
    await tester.ensureVisible(find.text('发送测试'));
    await tester.tap(find.text('发送测试'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('模型回复'), findsOneWidget);
    expect(find.textContaining('继续写下一段'), findsWidgets);
    expect(find.text('sk-secret'), findsNothing);

    await tester.tap(find.text('Request'));
    await tester.pumpAndSettle();

    expect(find.text('Actual Request'), findsOneWidget);
    expect(find.text('sk-secret'), findsNothing);
  });

  testWidgets('provider detail page fits narrow viewport', (tester) async {
    tester.view.physicalSize = const Size(760, 980);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final provider = _provider(
      id: 'deepseek',
      name: 'deepseek',
      apiKey: 'sk-secret',
      systemPrompt: 'Provider writing rules',
      isEnabled: false,
      testStatus: ProviderTestStatus.succeeded,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerConfigProvider.overrideWith(
            (ref, id) => Stream<ProviderConfig?>.value(provider),
          ),
          llmClientProvider.overrideWithValue(_FakeLlmClient()),
        ],
        child: const MaterialApp(
          home: ProviderDetailPage(providerId: 'deepseek'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('流式对话测试'), findsOneWidget);
    expect(find.text('Inspector'), findsOneWidget);
    expect(find.text('sk-secret'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

ProviderConfig _provider({
  required String id,
  required String name,
  required String apiKey,
  String baseUrl = 'https://api.deepseek.com/v1',
  String defaultModel = 'deepseek-v4-flash',
  String systemPrompt = 'Provider writing rules',
  bool isEnabled = true,
  ProviderTestStatus testStatus = ProviderTestStatus.succeeded,
  String? lastTestMessage,
}) {
  return ProviderConfig(
    id: id,
    name: name,
    baseUrl: baseUrl,
    apiKey: apiKey,
    defaultModel: defaultModel,
    systemPrompt: systemPrompt,
    isEnabled: isEnabled,
    testStatus: testStatus,
    lastTestedAt: DateTime(2026, 5, 15),
    lastTestMessage: lastTestMessage,
    createdAt: DateTime(2026, 5, 15),
    updatedAt: DateTime(2026, 5, 15),
  );
}

class _FakeLlmClient implements LlmClient {
  @override
  Stream<LlmStreamEvent> streamChat({
    required ProviderConfig provider,
    required LlmRequest request,
  }) async* {
    yield const LlmStreamDelta('模型');
    yield const LlmStreamDelta('回复');
    yield const LlmStreamDone();
  }
}
