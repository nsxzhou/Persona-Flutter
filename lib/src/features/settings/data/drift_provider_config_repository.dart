import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/provider_config.dart';
import '../domain/provider_config_repository.dart';

class DriftProviderConfigRepository implements ProviderConfigRepository {
  const DriftProviderConfigRepository(this._database);

  final AppDatabase _database;

  static const _uuid = Uuid();

  @override
  Stream<List<ProviderConfig>> watchProviders() {
    final query = _database.select(_database.providerConfigRecords)
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
    required ProviderConfigInput input,
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
          .into(_database.providerConfigRecords)
          .insertOnConflictUpdate(
            ProviderConfigRecordsCompanion(
              id: Value(normalizedId),
              name: Value(input.name.trim()),
              baseUrl: Value(input.baseUrl.trim()),
              apiKey: Value(input.apiKey.trim()),
              defaultModel: Value(modelNames.first),
              systemPrompt: Value(input.systemPrompt.trim()),
              isEnabled: Value(input.isEnabled),
              testStatus: Value(ProviderTestStatus.untested.name),
              lastTestedAt: const Value(null),
              lastTestMessage: const Value(null),
              createdAt: Value(existing?.createdAt ?? now),
              updatedAt: Value(now),
            ),
          );
      await (_database.delete(
        _database.providerModelRecords,
      )..where((model) => model.providerId.equals(normalizedId))).go();
      for (var index = 0; index < modelNames.length; index += 1) {
        await _database
            .into(_database.providerModelRecords)
            .insert(
              ProviderModelRecordsCompanion.insert(
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
        _database.providerModelRecords,
      )..where((model) => model.providerId.equals(id))).go();
      await (_database.delete(
        _database.providerConfigRecords,
      )..where((provider) => provider.id.equals(id))).go();
    });
  }

  @override
  Future<ProviderConfig?> findProvider(String id) async {
    final query = _database.select(_database.providerConfigRecords)
      ..where((provider) => provider.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapRecord(row, await _modelsForProvider(id));
  }

  @override
  Stream<ProviderConfig?> watchProvider(String id) {
    final query = _database.select(_database.providerConfigRecords)
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
      _database.providerConfigRecords,
    )..where((provider) => provider.id.equals(id))).write(
      ProviderConfigRecordsCompanion(
        testStatus: Value(status.name),
        lastTestedAt: Value(testedAt),
        lastTestMessage: Value(message),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> updateSystemPrompt({
    required String id,
    required String systemPrompt,
  }) {
    return (_database.update(
      _database.providerConfigRecords,
    )..where((provider) => provider.id.equals(id))).write(
      ProviderConfigRecordsCompanion(
        systemPrompt: Value(systemPrompt.trim()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<ProviderConfig>> _mapRecords(List<ProviderConfigRecord> rows) {
    return Future.wait(
      rows.map(
        (row) async => _mapRecord(row, await _modelsForProvider(row.id)),
      ),
    );
  }

  Future<List<String>> _modelsForProvider(String providerId) async {
    final query = _database.select(_database.providerModelRecords)
      ..where((model) => model.providerId.equals(providerId))
      ..orderBy([
        (model) => OrderingTerm(expression: model.sortOrder),
        (model) => OrderingTerm(expression: model.modelName),
      ]);
    final rows = await query.get();
    final names = rows
        .map((row) => row.modelName.trim())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
    return names;
  }

  ProviderConfig _mapRecord(ProviderConfigRecord row, List<String> modelNames) {
    final normalizedModels = _normalizeModelNames(row.defaultModel, modelNames);
    return ProviderConfig(
      id: row.id,
      name: row.name,
      baseUrl: row.baseUrl,
      apiKey: row.apiKey,
      defaultModel: row.defaultModel,
      modelNames: normalizedModels,
      systemPrompt: row.systemPrompt,
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
      throw StateError('Provider 至少需要一个模型。');
    }
    return normalized;
  }
}
