import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:persona_flutter/src/features/settings/presentation/settings_page.dart';
import 'package:persona_flutter/src/features/settings/application/provider_config_providers.dart';

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
    'settings page highlights provider testing as the main card action',
    (tester) async {
      final provider = ProviderConfig(
        id: 'deepseek',
        name: 'deepseek',
        baseUrl: 'https://api.deepseek.com/v1',
        apiKey: 'sk-2••••fc7c',
        defaultModel: 'deepseek-v4-flash',
        isEnabled: true,
        testStatus: ProviderTestStatus.succeeded,
        lastTestedAt: DateTime(2026, 5, 15),
        lastTestMessage: '连接成功，已读取模型列表。',
        createdAt: DateTime(2026, 5, 15),
        updatedAt: DateTime(2026, 5, 15),
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

      expect(find.text('Provider 控制台'), findsOneWidget);
      expect(find.text('测试连接'), findsWidgets);
      expect(find.text('可用'), findsWidgets);
    },
  );
}
