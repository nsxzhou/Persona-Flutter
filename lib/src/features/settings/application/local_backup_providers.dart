import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/database/local_backup_service.dart';

part 'local_backup_providers.g.dart';

class LocalBackupState {
  const LocalBackupState({this.result});

  final LocalBackupResult? result;
}

@Riverpod(keepAlive: true)
LocalBackupService localBackupService(Ref ref) {
  return LocalBackupService(database: ref.watch(appDatabaseProvider));
}

@riverpod
class LocalBackupController extends _$LocalBackupController {
  @override
  FutureOr<LocalBackupState> build() => const LocalBackupState();

  Future<void> exportBackup() async {
    final destination = await FilePicker.saveFile(
      fileName: _backupFilename(),
      type: FileType.custom,
      allowedExtensions: const ['sqlite'],
    );
    if (destination == null) {
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(localBackupServiceProvider)
          .writeBackup(File(destination));
      return LocalBackupState(result: result);
    });
  }

  Future<void> restoreBackup() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['sqlite', 'db'],
    );
    final path = result?.files.single.path;
    if (path == null) {
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final restoreResult = await ref
          .read(localBackupServiceProvider)
          .restoreFrom(File(path));
      invalidateAppDatabase(ref);
      return LocalBackupState(result: restoreResult);
    });
  }
}

String _backupFilename() {
  final now = DateTime.now().toLocal();
  String two(int input) => input.toString().padLeft(2, '0');
  return 'persona-backup-${now.year}${two(now.month)}${two(now.day)}-'
      '${two(now.hour)}${two(now.minute)}${two(now.second)}.sqlite';
}
