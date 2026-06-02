import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'reader_settings_provider.freezed.dart';

const _readerFontSizeKey = 'persona.reader.fontSize';
const _readerLineHeightKey = 'persona.reader.lineHeight';
const _readerColumnWidthKey = 'persona.reader.columnWidth';
const _readerDarkKey = 'persona.reader.dark';

final readerSettingsStoreProvider = Provider<ReaderSettingsStore>((ref) {
  return InMemoryReaderSettingsStore();
});

final readerSettingsProvider =
    NotifierProvider<ReaderSettingsNotifier, ReaderSettings>(
      ReaderSettingsNotifier.new,
    );

class ReaderSettingsNotifier extends Notifier<ReaderSettings> {
  @override
  ReaderSettings build() => ref.watch(readerSettingsStoreProvider).read();

  Future<void> update(ReaderSettings settings) async {
    state = settings;
    await ref.read(readerSettingsStoreProvider).write(settings);
  }
}

@freezed
abstract class ReaderSettings with _$ReaderSettings {
  const factory ReaderSettings({
    @Default(19) double fontSize,
    @Default(1.9) double lineHeight,
    @Default(760) double columnWidth,
    @Default(false) bool dark,
  }) = _ReaderSettings;
}

abstract interface class ReaderSettingsStore {
  ReaderSettings read();

  Future<void> write(ReaderSettings settings);
}

class SharedPreferencesReaderSettingsStore implements ReaderSettingsStore {
  const SharedPreferencesReaderSettingsStore(this._preferences);

  static Future<SharedPreferencesReaderSettingsStore> create() async {
    final preferences = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: {
          _readerFontSizeKey,
          _readerLineHeightKey,
          _readerColumnWidthKey,
          _readerDarkKey,
        },
      ),
    );

    return SharedPreferencesReaderSettingsStore(preferences);
  }

  final SharedPreferencesWithCache _preferences;

  @override
  ReaderSettings read() {
    return ReaderSettings(
      fontSize: _preferences.getDouble(_readerFontSizeKey) ?? 19,
      lineHeight: _preferences.getDouble(_readerLineHeightKey) ?? 1.9,
      columnWidth: _preferences.getDouble(_readerColumnWidthKey) ?? 760,
      dark: _preferences.getBool(_readerDarkKey) ?? false,
    );
  }

  @override
  Future<void> write(ReaderSettings settings) async {
    await _preferences.setDouble(_readerFontSizeKey, settings.fontSize);
    await _preferences.setDouble(_readerLineHeightKey, settings.lineHeight);
    await _preferences.setDouble(_readerColumnWidthKey, settings.columnWidth);
    await _preferences.setBool(_readerDarkKey, settings.dark);
  }
}

class InMemoryReaderSettingsStore implements ReaderSettingsStore {
  InMemoryReaderSettingsStore([this._settings = const ReaderSettings()]);

  ReaderSettings _settings;

  @override
  ReaderSettings read() => _settings;

  @override
  Future<void> write(ReaderSettings settings) async {
    _settings = settings;
  }
}
