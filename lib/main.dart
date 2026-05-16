import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/persona_app.dart';
import 'src/core/theme/theme_mode_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeModeStore = await SharedPreferencesThemeModeStore.create();

  runApp(
    ProviderScope(
      overrides: [themeModeStoreProvider.overrideWithValue(themeModeStore)],
      child: const PersonaApp(),
    ),
  );
}
