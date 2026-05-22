import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:persona_flutter/src/core/database/app_database.dart';
import 'package:persona_flutter/src/core/database/local_backup_service.dart';
import 'package:persona_flutter/src/features/settings/data/drift_provider_config_repository.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';

void main() {
  late Directory tempDir;
  late File liveFile;
  late AppDatabase database;
  late LocalBackupService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('persona-backup-test-');
    liveFile = File(p.join(tempDir.path, 'persona.sqlite'));
    database = AppDatabase(NativeDatabase(liveFile));
    service = LocalBackupService(
      database: database,
      databaseFileResolver: () async => liveFile,
      temporaryDirectoryResolver: () => tempDir,
      clock: () => DateTime.utc(2026, 5, 22, 12),
    );
  });

  tearDown(() async {
    await database.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('exports an openable SQLite backup with current user version', () async {
    await _saveProvider(database, name: 'deepseek');
    final destination = File(p.join(tempDir.path, 'backup.sqlite'));

    final result = await service.writeBackup(destination);

    expect(destination.existsSync(), isTrue);
    expect(result.operation, LocalBackupOperation.export);
    expect(result.message, contains('schema v${database.schemaVersion}'));

    await database.close();

    final backupDatabase = AppDatabase(NativeDatabase(destination));
    final providers = await DriftProviderConfigRepository(
      backupDatabase,
    ).watchProviders().first;
    addTearDown(backupDatabase.close);
    expect(providers.single.name, 'deepseek');
  });

  test('rejects corrupt restore files', () async {
    final corrupt = File(p.join(tempDir.path, 'corrupt.sqlite'));
    await corrupt.writeAsString('not sqlite');

    expect(() => service.restoreFrom(corrupt), throwsStateError);
  });

  test('rejects backups from a future schema version', () async {
    final futureBackup = File(p.join(tempDir.path, 'future.sqlite'));
    await database.close();
    final futureDatabase = AppDatabase(NativeDatabase(futureBackup));
    await futureDatabase.customStatement('PRAGMA user_version = 999');
    await futureDatabase.close();

    database = AppDatabase(NativeDatabase(liveFile));
    service = LocalBackupService(
      database: database,
      databaseFileResolver: () async => liveFile,
      temporaryDirectoryResolver: () => tempDir,
      clock: () => DateTime.utc(2026, 5, 22, 12),
    );

    expect(() => service.restoreFrom(futureBackup), throwsStateError);
  });

  test('restores backup and keeps a pre-restore rollback copy', () async {
    await _saveProvider(database, name: 'before');
    final backup = File(p.join(tempDir.path, 'backup.sqlite'));
    await service.writeBackup(backup);

    await database.close();
    database = AppDatabase(NativeDatabase(liveFile));
    service = LocalBackupService(
      database: database,
      databaseFileResolver: () async => liveFile,
      temporaryDirectoryResolver: () => tempDir,
      clock: () => DateTime.utc(2026, 5, 22, 12, 1),
    );
    await _saveProvider(database, name: 'after');

    final result = await service.restoreFrom(backup);

    expect(result.operation, LocalBackupOperation.restore);
    expect(result.rollbackPath, isNotNull);
    expect(File(result.rollbackPath!).existsSync(), isTrue);

    await database.close();
    final restored = AppDatabase(NativeDatabase(liveFile));
    final providers = await DriftProviderConfigRepository(
      restored,
    ).watchProviders().first;
    addTearDown(restored.close);
    expect(providers.single.name, 'before');
  });
}

Future<void> _saveProvider(AppDatabase database, {required String name}) {
  return DriftProviderConfigRepository(database).saveProvider(
    input: ProviderConfigInput(
      name: name,
      baseUrl: 'https://api.example.com/v1',
      apiKey: 'sk-secret-$name',
      defaultModel: 'model-$name',
      systemPrompt: '',
      isEnabled: true,
    ),
  );
}
