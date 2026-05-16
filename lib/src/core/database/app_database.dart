import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class WorkflowTaskRecords extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get status => text()();
  TextColumn get title => text()();
  TextColumn get stage => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ProviderConfigRecords extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get baseUrl => text()();
  TextColumn get apiKey => text()();
  TextColumn get defaultModel => text()();
  TextColumn get systemPrompt => text().withDefault(const Constant(''))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get testStatus => text()();
  DateTimeColumn get lastTestedAt => dateTime().nullable()();
  TextColumn get lastTestMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ProjectRecords extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class StyleSampleRecords extends Table {
  TextColumn get id => text()();
  TextColumn get sourceType => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  IntColumn get characterCount => integer()();
  TextColumn get projectId =>
      text().nullable().references(ProjectRecords, #id)();
  TextColumn get sourceFilename => text().nullable()();
  TextColumn get epubBookTitle => text().nullable()();
  TextColumn get epubAuthor => text().nullable()();
  TextColumn get epubChapterTitle => text().nullable()();
  IntColumn get epubChapterIndex => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class StyleAnalysisRunRecords extends Table {
  TextColumn get id => text()();
  TextColumn get workflowTaskId =>
      text().references(WorkflowTaskRecords, #id)();
  TextColumn get sampleId => text().references(StyleSampleRecords, #id)();
  TextColumn get providerId => text().references(ProviderConfigRecords, #id)();
  TextColumn get modelName => text()();
  TextColumn get styleName => text()();
  TextColumn get projectId =>
      text().nullable().references(ProjectRecords, #id)();
  TextColumn get status => text()();
  TextColumn get stage => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get logs => text().withDefault(const Constant(''))();
  TextColumn get analysisReportMarkdown => text().nullable()();
  TextColumn get voiceProfileMarkdown => text().nullable()();
  TextColumn get profileId => text().nullable()();
  IntColumn get chunkCount => integer().withDefault(const Constant(0))();
  IntColumn get characterCount => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class StyleProfileRecords extends Table {
  TextColumn get id => text()();
  TextColumn get sourceRunId =>
      text().unique().references(StyleAnalysisRunRecords, #id)();
  TextColumn get providerId => text().references(ProviderConfigRecords, #id)();
  TextColumn get modelName => text()();
  TextColumn get styleName => text()();
  TextColumn get profileMarkdown => text()();
  TextColumn get analysisReportMarkdown => text()();
  TextColumn get projectId =>
      text().nullable().references(ProjectRecords, #id)();
  TextColumn get sourceSampleId =>
      text().nullable().references(StyleSampleRecords, #id)();
  TextColumn get sourceTitle => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    WorkflowTaskRecords,
    ProviderConfigRecords,
    ProjectRecords,
    StyleSampleRecords,
    StyleAnalysisRunRecords,
    StyleProfileRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(providerConfigRecords);
        }
        if (from < 3) {
          await migrator.addColumn(
            providerConfigRecords,
            providerConfigRecords.systemPrompt,
          );
        }
        if (from < 4) {
          await migrator.createTable(projectRecords);
        }
        if (from < 5) {
          await migrator.createTable(styleSampleRecords);
          await migrator.createTable(styleAnalysisRunRecords);
          await migrator.createTable(styleProfileRecords);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final supportDir = await getApplicationSupportDirectory();
    final dbDir = Directory(p.join(supportDir.path, 'Persona'));
    if (!dbDir.existsSync()) {
      dbDir.createSync(recursive: true);
    }
    final file = File(p.join(dbDir.path, 'persona.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
