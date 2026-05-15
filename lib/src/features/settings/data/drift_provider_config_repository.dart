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

    return query.watch().map(
      (rows) => rows.map(_mapRecord).toList(growable: false),
    );
  }

  @override
  Future<void> saveProvider({
    String? id,
    required ProviderConfigInput input,
  }) async {
    final now = DateTime.now();
    final normalizedId = id ?? _uuid.v4();
    final existing = id == null ? null : await findProvider(id);

    await _database
        .into(_database.providerConfigRecords)
        .insertOnConflictUpdate(
          ProviderConfigRecordsCompanion(
            id: Value(normalizedId),
            name: Value(input.name.trim()),
            baseUrl: Value(input.baseUrl.trim()),
            apiKey: Value(input.apiKey.trim()),
            defaultModel: Value(input.defaultModel.trim()),
            isEnabled: Value(input.isEnabled),
            testStatus: Value(ProviderTestStatus.untested.name),
            lastTestedAt: const Value(null),
            lastTestMessage: const Value(null),
            createdAt: Value(existing?.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );
  }

  @override
  Future<void> deleteProvider(String id) {
    return (_database.delete(
      _database.providerConfigRecords,
    )..where((provider) => provider.id.equals(id))).go();
  }

  @override
  Future<ProviderConfig?> findProvider(String id) async {
    final query = _database.select(_database.providerConfigRecords)
      ..where((provider) => provider.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapRecord(row);
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

  ProviderConfig _mapRecord(ProviderConfigRecord row) {
    return ProviderConfig(
      id: row.id,
      name: row.name,
      baseUrl: row.baseUrl,
      apiKey: row.apiKey,
      defaultModel: row.defaultModel,
      isEnabled: row.isEnabled,
      testStatus: ProviderTestStatus.values.byName(row.testStatus),
      lastTestedAt: row.lastTestedAt,
      lastTestMessage: row.lastTestMessage,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
