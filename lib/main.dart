import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/persona_app.dart';
import 'src/core/theme/reader_settings_provider.dart';
import 'src/core/theme/theme_mode_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeModeStore = await SharedPreferencesThemeModeStore.create();
  final readerSettingsStore =
      await SharedPreferencesReaderSettingsStore.create();

  runApp(
    ProviderScope(
      overrides: [
        themeModeStoreProvider.overrideWithValue(themeModeStore),
        readerSettingsStoreProvider.overrideWithValue(readerSettingsStore),
      ],
      child: const PersonaApp(),
    ),
  );
}
