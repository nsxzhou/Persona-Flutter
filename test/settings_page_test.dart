import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/database/local_backup_service.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_client.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_request.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_stream_event.dart';
import 'package:persona_flutter/src/features/settings/application/local_backup_providers.dart';
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
          localBackupControllerProvider.overrideWith(
            _ReadyBackupController.new,
          ),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Provider 控制台'), findsOneWidget);
    expect(find.text('尚未配置 Provider'), findsOneWidget);
    expect(find.text('待开发'), findsNothing);
    expect(find.text('本地备份'), findsOneWidget);
    expect(find.text('导出备份'), findsOneWidget);
    expect(find.text('恢复备份'), findsOneWidget);
    expect(find.textContaining('Provider API Key'), findsOneWidget);
    expect(find.text('新增 Provider'), findsWidgets);
  });

  testWidgets('settings page confirms restore before dispatching action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = _RecordingBackupController();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerConfigsProvider.overrideWith(
            (ref) => Stream<List<ProviderConfig>>.value(const []),
          ),
          localBackupControllerProvider.overrideWith(() => controller),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('恢复备份'));
    await tester.tap(find.text('恢复备份'));
    await tester.pumpAndSettle();

    expect(find.text('恢复本地备份'), findsOneWidget);
    expect(find.textContaining('覆盖当前全部本地数据'), findsOneWidget);

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(controller.restoreCount, 0);

    await tester.ensureVisible(find.text('恢复备份'));
    await tester.tap(find.text('恢复备份'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('选择备份并恢复'));
    await tester.pumpAndSettle();

    expect(controller.restoreCount, 1);
  });

  testWidgets('settings page disables backup actions while busy', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerConfigsProvider.overrideWith(
            (ref) => Stream<List<ProviderConfig>>.value(const []),
          ),
          localBackupControllerProvider.overrideWithBuild(
            (ref, notifier) => Completer<LocalBackupState>().future,
          ),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );

    await tester.pump();

    final exportButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '导出备份'),
    );
    final restoreButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, '恢复备份'),
    );
    expect(exportButton.onPressed, isNull);
    expect(restoreButton.onPressed, isNull);
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
            localBackupControllerProvider.overrideWith(
              _ReadyBackupController.new,
            ),
          ],
          child: const MaterialApp(home: SettingsPage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Provider 控制台'), findsOneWidget);
      expect(find.byIcon(Icons.network_check), findsNWidgets(2));
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
      expect(find.byIcon(Icons.edit_outlined), findsNWidgets(2));
      expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));
      expect(find.text('deepseek'), findsOneWidget);
      expect(find.text('openai'), findsOneWidget);
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
          localBackupControllerProvider.overrideWith(
            _ReadyBackupController.new,
          ),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('新增'));
    await tester.pumpAndSettle();

    expect(find.text('新增 Provider'), findsOneWidget);
    expect(find.textContaining('API Key 只保存在本地 SQLite'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('取消').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
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

  testWidgets('provider detail page sends selected test model', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final provider = _provider(
      id: 'deepseek',
      name: 'deepseek',
      apiKey: 'sk-secret',
      defaultModel: 'deepseek-chat',
      modelNames: const ['deepseek-chat', 'deepseek-reasoner'],
    );
    final client = _RecordingLlmClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerConfigProvider.overrideWith(
            (ref, id) => Stream<ProviderConfig?>.value(provider),
          ),
          llmClientProvider.overrideWithValue(client),
        ],
        child: const MaterialApp(
          home: ProviderDetailPage(providerId: 'deepseek'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('参数'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('deepseek-chat').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('deepseek-reasoner').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, '继续写下一段');
    await tester.ensureVisible(find.text('发送测试'));
    await tester.tap(find.text('发送测试'));
    await tester.pumpAndSettle();

    expect(client.lastRequest?.model, 'deepseek-reasoner');

    await tester.tap(find.text('Request'));
    await tester.pumpAndSettle();

    expect(find.text('Actual Request'), findsOneWidget);
    expect(find.text('deepseek-reasoner'), findsWidgets);
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
  List<String> modelNames = const <String>[],
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
    modelNames: modelNames,
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

class _RecordingLlmClient implements LlmClient {
  LlmRequest? lastRequest;

  @override
  Stream<LlmStreamEvent> streamChat({
    required ProviderConfig provider,
    required LlmRequest request,
  }) async* {
    lastRequest = request;
    yield const LlmStreamDelta('模型回复');
    yield const LlmStreamDone();
  }
}

class _ReadyBackupController extends LocalBackupController {
  @override
  FutureOr<LocalBackupState> build() => const LocalBackupState();
}

class _RecordingBackupController extends LocalBackupController {
  int restoreCount = 0;

  @override
  FutureOr<LocalBackupState> build() => const LocalBackupState();

  @override
  Future<void> restoreBackup() async {
    restoreCount += 1;
    state = AsyncData(
      LocalBackupState(
        result: LocalBackupResult(
          operation: LocalBackupOperation.restore,
          targetPath: '/tmp/persona-backup.sqlite',
          rollbackPath: '/tmp/pre-restore.sqlite',
          completedAt: DateTime(2026, 5, 22),
          message: '已恢复 schema v22 备份。',
        ),
      ),
    );
  }
}
