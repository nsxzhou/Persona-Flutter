import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_database.dart';

part 'database_providers.g.dart';

@Riverpod(keepAlive: true)
int appDatabaseGeneration(Ref ref) => 0;

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  ref.watch(appDatabaseGenerationProvider);
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
}

Future<void> reloadAppDatabase(Ref ref) async {
  final database = ref.read(appDatabaseProvider);
  await database.close();
  invalidateAppDatabase(ref);
}

void invalidateAppDatabase(Ref ref) {
  ref.invalidate(appDatabaseProvider);
  ref.invalidate(appDatabaseGenerationProvider);
}
