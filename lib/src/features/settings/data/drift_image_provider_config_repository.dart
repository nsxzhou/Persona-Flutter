import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/image_provider_config.dart';
import '../domain/image_provider_config_repository.dart';
import '../domain/provider_config.dart';

class DriftImageProviderConfigRepository
    implements ImageProviderConfigRepository {
  const DriftImageProviderConfigRepository(this._database);

  final AppDatabase _database;

  static const _uuid = Uuid();

  @override
  Stream<List<ImageProviderConfig>> watchProviders() {
    final query = _database.select(_database.imageProviderConfigRecords)
      ..orderBy([
        (provider) => OrderingTerm(
          expression: provider.updatedAt,
          mode: OrderingMode.desc,
        ),
      ]);

    return query.watch().asyncMap(_mapRecords);
  }

  @override
  Future<void> saveProvider({
    String? id,
    required ImageProviderConfigInput input,
  }) async {
    final now = DateTime.now();
    final normalizedId = id ?? _uuid.v4();
    final existing = id == null ? null : await findProvider(id);
    final modelNames = _normalizeModelNames(
      input.defaultModel,
      input.modelNames,
    );

    await _database.transaction(() async {
      await _database
          .into(_database.imageProviderConfigRecords)
          .insertOnConflictUpdate(
            ImageProviderConfigRecordsCompanion(
              id: Value(normalizedId),
              name: Value(input.name.trim()),
              baseUrl: Value(input.baseUrl.trim()),
              apiKey: Value(input.apiKey.trim()),
              defaultModel: Value(modelNames.first),
              defaultAspectRatio: Value(input.defaultAspectRatio.ratio),
              defaultSize: Value(input.defaultSize.tier),
              defaultQuality: Value(input.defaultQuality.quality),
              defaultResponseFormat: Value(
                _responseFormatToStorage(input.defaultResponseFormat),
              ),
              isEnabled: Value(input.isEnabled),
              testStatus: Value(ProviderTestStatus.untested.name),
              lastTestedAt: const Value(null),
              lastTestMessage: const Value(null),
              createdAt: Value(existing?.createdAt ?? now),
              updatedAt: Value(now),
            ),
          );
      await (_database.delete(
        _database.imageProviderModelRecords,
      )..where((model) => model.providerId.equals(normalizedId))).go();
      for (var index = 0; index < modelNames.length; index += 1) {
        await _database
            .into(_database.imageProviderModelRecords)
            .insert(
              ImageProviderModelRecordsCompanion.insert(
                providerId: normalizedId,
                modelName: modelNames[index],
                sortOrder: Value(index),
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
    });
  }

  @override
  Future<void> deleteProvider(String id) {
    return _database.transaction(() async {
      await (_database.delete(
        _database.imageProviderModelRecords,
      )..where((model) => model.providerId.equals(id))).go();
      await (_database.delete(
        _database.imageProviderConfigRecords,
      )..where((provider) => provider.id.equals(id))).go();
    });
  }

  @override
  Future<ImageProviderConfig?> findProvider(String id) async {
    final query = _database.select(_database.imageProviderConfigRecords)
      ..where((provider) => provider.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapRecord(row, await _modelsForProvider(id));
  }

  @override
  Stream<ImageProviderConfig?> watchProvider(String id) {
    final query = _database.select(_database.imageProviderConfigRecords)
      ..where((provider) => provider.id.equals(id))
      ..limit(1);
    return query.watchSingleOrNull().asyncMap(
      (row) async => row == null
          ? null
          : _mapRecord(row, await _modelsForProvider(row.id)),
    );
  }

  @override
  Future<void> updateTestResult({
    required String id,
    required ProviderTestStatus status,
    required DateTime testedAt,
    String? message,
  }) {
    return (_database.update(
      _database.imageProviderConfigRecords,
    )..where((provider) => provider.id.equals(id))).write(
      ImageProviderConfigRecordsCompanion(
        testStatus: Value(status.name),
        lastTestedAt: Value(testedAt),
        lastTestMessage: Value(message),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<ImageProviderConfig>> _mapRecords(
    List<ImageProviderConfigRecord> rows,
  ) {
    return Future.wait(
      rows.map(
        (row) async => _mapRecord(row, await _modelsForProvider(row.id)),
      ),
    );
  }

  Future<List<String>> _modelsForProvider(String providerId) async {
    final query = _database.select(_database.imageProviderModelRecords)
      ..where((model) => model.providerId.equals(providerId))
      ..orderBy([
        (model) => OrderingTerm(expression: model.sortOrder),
        (model) => OrderingTerm(expression: model.modelName),
      ]);
    final rows = await query.get();
    return rows
        .map((row) => row.modelName.trim())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
  }

  ImageProviderConfig _mapRecord(
    ImageProviderConfigRecord row,
    List<String> modelNames,
  ) {
    final normalizedModels = _normalizeModelNames(row.defaultModel, modelNames);
    return ImageProviderConfig(
      id: row.id,
      name: row.name,
      baseUrl: row.baseUrl,
      apiKey: row.apiKey,
      defaultModel: row.defaultModel,
      modelNames: normalizedModels,
      defaultAspectRatio: ImageAspectRatioPreset.fromRatio(
        row.defaultAspectRatio,
      ),
      defaultSize: ImageSizePreset.fromTier(row.defaultSize),
      defaultQuality: ImageQualityPreset.fromQuality(row.defaultQuality),
      defaultResponseFormat: _responseFormatFromStorage(
        row.defaultResponseFormat,
      ),
      isEnabled: row.isEnabled,
      testStatus: ProviderTestStatus.values.byName(row.testStatus),
      lastTestedAt: row.lastTestedAt,
      lastTestMessage: row.lastTestMessage,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  List<String> _normalizeModelNames(
    String defaultModel,
    Iterable<String> modelNames,
  ) {
    final seen = <String>{};
    final normalized = <String>[];
    void add(String value) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || !seen.add(trimmed)) {
        return;
      }
      normalized.add(trimmed);
    }

    add(defaultModel);
    for (final modelName in modelNames) {
      add(modelName);
    }
    if (normalized.isEmpty) {
      throw StateError('图像 Provider 至少需要一个模型。');
    }
    return normalized;
  }

  String _responseFormatToStorage(ImageResponseFormat format) {
    return switch (format) {
      ImageResponseFormat.url => 'url',
      ImageResponseFormat.b64Json => 'b64_json',
    };
  }

  ImageResponseFormat _responseFormatFromStorage(String value) {
    return switch (value.trim()) {
      'b64_json' => ImageResponseFormat.b64Json,
      _ => ImageResponseFormat.url,
    };
  }
}
