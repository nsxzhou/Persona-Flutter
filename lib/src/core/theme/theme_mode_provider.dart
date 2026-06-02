import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const defaultThemeMode = ThemeMode.dark;
const _themeModePreferenceKey = 'persona.themeMode';

final themeModeStoreProvider = Provider<ThemeModeStore>((ref) {
  return InMemoryThemeModeStore();
});

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(themeModeStoreProvider).read();

  Future<void> toggle() async {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = nextMode;

    await ref.read(themeModeStoreProvider).write(nextMode);
  }
}

abstract interface class ThemeModeStore {
  ThemeMode read();

  Future<void> write(ThemeMode mode);
}

class SharedPreferencesThemeModeStore implements ThemeModeStore {
  const SharedPreferencesThemeModeStore(this._preferences);

  static Future<SharedPreferencesThemeModeStore> create() async {
    final preferences = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: {_themeModePreferenceKey},
      ),
    );

    return SharedPreferencesThemeModeStore(preferences);
  }

  final SharedPreferencesWithCache _preferences;

  @override
  ThemeMode read() {
    return ThemeModePreference.decode(
      _preferences.getString(_themeModePreferenceKey),
    );
  }

  @override
  Future<void> write(ThemeMode mode) {
    return _preferences.setString(
      _themeModePreferenceKey,
      ThemeModePreference.encode(mode),
    );
  }
}

class InMemoryThemeModeStore implements ThemeModeStore {
  InMemoryThemeModeStore([this._mode = defaultThemeMode]);

  ThemeMode _mode;

  @override
  ThemeMode read() => _mode;

  @override
  Future<void> write(ThemeMode mode) async {
    _mode = mode;
  }
}

final class ThemeModePreference {
  const ThemeModePreference._();

  static ThemeMode decode(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => defaultThemeMode,
    };
  }

  static String encode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}
