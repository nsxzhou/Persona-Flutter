import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:persona_flutter/src/features/settings/presentation/settings_page.dart';
import 'package:persona_flutter/src/features/settings/application/provider_config_providers.dart';

void main() {
  testWidgets('settings page shows the provider management surface', (
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

    expect(find.text('Provider 设置'), findsOneWidget);
    expect(find.text('尚未配置 Provider'), findsOneWidget);
    expect(find.text('新增 Provider'), findsWidgets);
  });
}
