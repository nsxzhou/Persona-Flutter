import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import 'app_database.dart';

enum LocalBackupOperation { export, restore }

class LocalBackupResult {
  const LocalBackupResult({
    required this.operation,
    required this.targetPath,
    required this.completedAt,
    required this.message,
    this.rollbackPath,
  });

  final LocalBackupOperation operation;
  final String targetPath;
  final DateTime completedAt;
  final String message;
  final String? rollbackPath;
}

class LocalBackupService {
  const LocalBackupService({
    required AppDatabase database,
    Future<File> Function() databaseFileResolver = AppDatabase.databaseFile,
    Directory Function() temporaryDirectoryResolver =
        _defaultTemporaryDirectory,
    DateTime Function() clock = DateTime.now,
  }) : _database = database,
       _databaseFileResolver = databaseFileResolver,
       _temporaryDirectoryResolver = temporaryDirectoryResolver,
       _clock = clock;

  final AppDatabase _database;
  final Future<File> Function() _databaseFileResolver;
  final Directory Function() _temporaryDirectoryResolver;
  final DateTime Function() _clock;

  Future<Uint8List> exportBytes() async {
    final tempFile = _temporarySnapshotFile('persona-backup');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }

    try {
      await _database.exclusively(() async {
        await _database.customStatement('VACUUM INTO ?;', [tempFile.path]);
      });
      return tempFile.readAsBytes();
    } finally {
      if (tempFile.existsSync()) {
        await tempFile.delete();
      }
    }
  }

  Future<LocalBackupResult> writeBackup(File destination) async {
    final bytes = await exportBytes();
    if (!destination.parent.existsSync()) {
      destination.parent.createSync(recursive: true);
    }
    await destination.writeAsBytes(bytes, flush: true);
    final userVersion = await readCurrentUserVersion();
    return LocalBackupResult(
      operation: LocalBackupOperation.export,
      targetPath: destination.path,
      completedAt: _clock(),
      message: '已导出 schema v$userVersion 备份。',
    );
  }

  Future<LocalBackupResult> restoreFrom(File source) async {
    final sourceVersion = await validateRestoreSource(source);
    final databaseFile = await _databaseFileResolver();
    final rollback = await _createRollbackCopy(databaseFile);

    try {
      await _database.close();
      if (!databaseFile.parent.existsSync()) {
        databaseFile.parent.createSync(recursive: true);
      }
      await source.copy(databaseFile.path);
    } catch (_) {
      if (rollback.existsSync()) {
        await rollback.copy(databaseFile.path);
      }
      rethrow;
    }

    return LocalBackupResult(
      operation: LocalBackupOperation.restore,
      targetPath: source.path,
      rollbackPath: rollback.path,
      completedAt: _clock(),
      message: '已恢复 schema v$sourceVersion 备份。',
    );
  }

  Future<int> validateRestoreSource(File source) async {
    if (!source.existsSync()) {
      throw StateError('备份文件不存在。');
    }

    final userVersion = await readUserVersion(source);
    if (userVersion > _database.schemaVersion) {
      throw StateError(
        '备份来自更新版本 schema v$userVersion，当前应用只支持 v${_database.schemaVersion}。',
      );
    }
    return userVersion;
  }

  Future<int> readUserVersion(File source) async {
    AppDatabase? backupDatabase;
    try {
      backupDatabase = AppDatabase(
        NativeDatabase(source, enableMigrations: false),
      );
      final rows = await backupDatabase
          .customSelect('PRAGMA user_version')
          .get();
      final value = rows.single.data['user_version'];
      if (value is int) {
        return value;
      }
      throw StateError('无法读取备份 schema 版本。');
    } on SqliteException catch (error) {
      throw StateError('无法打开备份数据库：${error.message}');
    } finally {
      await backupDatabase?.close();
    }
  }

  Future<int> readCurrentUserVersion() async {
    final rows = await _database.customSelect('PRAGMA user_version').get();
    final value = rows.single.data['user_version'];
    if (value is int) {
      return value;
    }
    throw StateError('无法读取当前数据库 schema 版本。');
  }

  Future<File> _createRollbackCopy(File databaseFile) async {
    final rollback = File(
      p.join(
        databaseFile.parent.path,
        'pre-restore-${_timestampForFile(_clock())}.sqlite',
      ),
    );
    if (databaseFile.existsSync()) {
      await databaseFile.copy(rollback.path);
    } else {
      await rollback.writeAsBytes(const [], flush: true);
    }
    return rollback;
  }

  File _temporarySnapshotFile(String prefix) {
    final directory = _temporaryDirectoryResolver();
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return File(
      p.join(directory.path, '$prefix-${_timestampForFile(_clock())}.sqlite'),
    );
  }
}

Directory _defaultTemporaryDirectory() => Directory.systemTemp;

String _timestampForFile(DateTime value) {
  String two(int input) => input.toString().padLeft(2, '0');
  final utc = value.toUtc();
  return '${utc.year}${two(utc.month)}${two(utc.day)}-'
      '${two(utc.hour)}${two(utc.minute)}${two(utc.second)}-'
      '${utc.millisecond.toString().padLeft(3, '0')}';
}
