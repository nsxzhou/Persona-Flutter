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

class WorkflowPromptTraceRecords extends Table {
  TextColumn get workflowTaskId =>
      text().references(WorkflowTaskRecords, #id)();
  TextColumn get traceMarkdown => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {workflowTaskId};
}

class ProviderConfigRecords extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get baseUrl => text()();
  TextColumn get apiKey => text()();
  TextColumn get defaultModel => text()();
  TextColumn get systemPrompt => text().withDefault(const Constant(''))();
  BoolColumn get isSystemPromptEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get testStatus => text()();
  DateTimeColumn get lastTestedAt => dateTime().nullable()();
  TextColumn get lastTestMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ProviderModelRecords extends Table {
  TextColumn get providerId => text().references(ProviderConfigRecords, #id)();
  TextColumn get modelName => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {providerId, modelName};
}

class ProjectRecords extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get status => text()();
  TextColumn get defaultProviderId => text().nullable()();
  TextColumn get defaultModelName => text().nullable()();
  TextColumn get styleProfileId => text().nullable()();
  TextColumn get plotProfileId => text().nullable()();
  TextColumn get language => text().withDefault(const Constant('简体中文'))();
  IntColumn get targetLength => integer().withDefault(const Constant(3000))();
  TextColumn get narrativePerspective =>
      text().withDefault(const Constant('第三人称有限视角'))();
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

class PlotSampleRecords extends Table {
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
  IntColumn get epubChapterCount => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PlotAnalysisRunRecords extends Table {
  TextColumn get id => text()();
  TextColumn get workflowTaskId =>
      text().references(WorkflowTaskRecords, #id)();
  TextColumn get sampleId => text().references(PlotSampleRecords, #id)();
  TextColumn get providerId => text().references(ProviderConfigRecords, #id)();
  TextColumn get modelName => text()();
  TextColumn get plotName => text()();
  TextColumn get projectId =>
      text().nullable().references(ProjectRecords, #id)();
  TextColumn get status => text()();
  TextColumn get stage => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get logs => text().withDefault(const Constant(''))();
  TextColumn get analysisReportMarkdown => text().nullable()();
  TextColumn get plotSkeletonMarkdown => text().nullable()();
  TextColumn get storyEngineMarkdown => text().nullable()();
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

class PlotProfileRecords extends Table {
  TextColumn get id => text()();
  TextColumn get sourceRunId =>
      text().unique().references(PlotAnalysisRunRecords, #id)();
  TextColumn get providerId => text().references(ProviderConfigRecords, #id)();
  TextColumn get modelName => text()();
  TextColumn get plotName => text()();
  TextColumn get storyEngineMarkdown => text()();
  TextColumn get analysisReportMarkdown => text()();
  TextColumn get plotSkeletonMarkdown => text()();
  TextColumn get projectId =>
      text().nullable().references(ProjectRecords, #id)();
  TextColumn get sourceSampleId =>
      text().nullable().references(PlotSampleRecords, #id)();
  TextColumn get sourceTitle => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ProjectRuntimeMemoryRecords extends Table {
  TextColumn get projectId => text()();
  TextColumn get charactersStatus => text().withDefault(const Constant(''))();
  TextColumn get runtimeState => text().withDefault(const Constant(''))();
  TextColumn get runtimeThreads => text().withDefault(const Constant(''))();
  TextColumn get storySummary => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {projectId};
}

class ProjectBibleRecords extends Table {
  TextColumn get projectId => text().references(ProjectRecords, #id)();
  TextColumn get descriptionMarkdown =>
      text().withDefault(const Constant(''))();
  TextColumn get worldBuildingMarkdown =>
      text().withDefault(const Constant(''))();
  TextColumn get charactersBlueprintMarkdown =>
      text().withDefault(const Constant(''))();
  TextColumn get outlineMasterMarkdown =>
      text().withDefault(const Constant(''))();
  TextColumn get outlineDetailYaml => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {projectId};
}

class ChapterVolumeRecords extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(ProjectRecords, #id)();
  IntColumn get volumeIndex => integer()();
  TextColumn get title => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {projectId, volumeIndex},
  ];
}

class ChapterPlanRecords extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(ProjectRecords, #id)();
  TextColumn get volumeId => text().withDefault(const Constant(''))();
  IntColumn get volumeIndex => integer().withDefault(const Constant(1))();
  TextColumn get volumeTitle => text().withDefault(const Constant('未分卷章节'))();
  IntColumn get chapterLocalIndex => integer().withDefault(const Constant(1))();
  IntColumn get chapterIndex => integer()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get objective => text().withDefault(const Constant(''))();
  TextColumn get pressureSource => text().withDefault(const Constant(''))();
  TextColumn get payoffTarget => text().withDefault(const Constant(''))();
  TextColumn get relationshipShift => text().withDefault(const Constant(''))();
  TextColumn get hookType => text().withDefault(const Constant(''))();
  TextColumn get coreEvent => text().withDefault(const Constant(''))();
  TextColumn get emotionArc => text().withDefault(const Constant(''))();
  TextColumn get chapterHook => text().withDefault(const Constant(''))();
  TextColumn get outlineMarkdown => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {projectId, chapterIndex},
  ];
}

class ProjectChapterRecords extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(ProjectRecords, #id)();
  TextColumn get chapterPlanId =>
      text().unique().references(ChapterPlanRecords, #id)();
  IntColumn get chapterIndex => integer()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get contentMarkdown => text().withDefault(const Constant(''))();
  TextColumn get contentHash => text().withDefault(const Constant(''))();
  TextColumn get continuityVerdict =>
      text().withDefault(const Constant('pass'))();
  TextColumn get continuityReportMarkdown =>
      text().withDefault(const Constant(''))();
  TextColumn get memorySyncStatus =>
      text().withDefault(const Constant('idle'))();
  TextColumn get memorySyncContentHash =>
      text().withDefault(const Constant(''))();
  TextColumn get memorySyncProposedCharactersStatus =>
      text().withDefault(const Constant(''))();
  TextColumn get memorySyncProposedRuntimeState =>
      text().withDefault(const Constant(''))();
  TextColumn get memorySyncProposedRuntimeThreads =>
      text().withDefault(const Constant(''))();
  TextColumn get memorySyncProposedStorySummary =>
      text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {projectId, chapterIndex},
  ];
}

class ChapterGenerationRunRecords extends Table {
  TextColumn get id => text()();
  TextColumn get workflowTaskId =>
      text().references(WorkflowTaskRecords, #id)();
  TextColumn get projectId => text().references(ProjectRecords, #id)();
  TextColumn get chapterPlanId => text()();
  TextColumn get chapterId =>
      text().nullable().references(ProjectChapterRecords, #id)();
  TextColumn get providerId => text()();
  TextColumn get modelName => text()();
  TextColumn get status => text()();
  TextColumn get stage => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get logs => text().withDefault(const Constant(''))();
  TextColumn get contextWarningsMarkdown =>
      text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    WorkflowTaskRecords,
    WorkflowPromptTraceRecords,
    ProviderConfigRecords,
    ProviderModelRecords,
    ProjectRecords,
    StyleSampleRecords,
    StyleAnalysisRunRecords,
    StyleProfileRecords,
    PlotSampleRecords,
    PlotAnalysisRunRecords,
    PlotProfileRecords,
    ProjectRuntimeMemoryRecords,
    ProjectBibleRecords,
    ChapterVolumeRecords,
    ChapterPlanRecords,
    ProjectChapterRecords,
    ChapterGenerationRunRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 15;

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
        if (from < 6) {
          await migrator.createTable(plotSampleRecords);
          await migrator.createTable(plotAnalysisRunRecords);
          await migrator.createTable(plotProfileRecords);
        }
        if (from < 7) {
          await migrator.createTable(workflowPromptTraceRecords);
        }
        if (from < 8) {
          await migrator.createTable(providerModelRecords);
          await customStatement('''
            INSERT INTO provider_model_records
              (provider_id, model_name, sort_order, created_at, updated_at)
            SELECT id, default_model, 0, created_at, updated_at
            FROM provider_config_records
            WHERE TRIM(default_model) <> ''
          ''');
          await migrator.addColumn(
            plotSampleRecords,
            plotSampleRecords.projectId,
          );
          await migrator.addColumn(
            plotAnalysisRunRecords,
            plotAnalysisRunRecords.projectId,
          );
          await migrator.addColumn(
            plotProfileRecords,
            plotProfileRecords.projectId,
          );
        }
        if (from < 9) {
          await migrator.addColumn(
            projectRecords,
            projectRecords.defaultProviderId,
          );
          await migrator.addColumn(
            projectRecords,
            projectRecords.defaultModelName,
          );
          await migrator.addColumn(
            projectRecords,
            projectRecords.styleProfileId,
          );
          await migrator.addColumn(
            projectRecords,
            projectRecords.plotProfileId,
          );
          await migrator.addColumn(projectRecords, projectRecords.language);
          await migrator.addColumn(projectRecords, projectRecords.targetLength);
          await migrator.addColumn(
            projectRecords,
            projectRecords.narrativePerspective,
          );
          await customStatement('''
            UPDATE project_records
            SET
              default_provider_id = (
                SELECT id
                FROM provider_config_records
                WHERE is_enabled = 1
                ORDER BY created_at ASC
                LIMIT 1
              ),
              default_model_name = (
                SELECT default_model
                FROM provider_config_records
                WHERE is_enabled = 1
                ORDER BY created_at ASC
                LIMIT 1
              )
            WHERE default_provider_id IS NULL
              AND default_model_name IS NULL
          ''');
        }
        if (from < 11) {
          await _dropNovelWorkshopPersistence();
        }
        if (from < 12) {
          await migrator.createTable(projectRuntimeMemoryRecords);
          await migrator.createTable(chapterPlanRecords);
          await migrator.createTable(projectChapterRecords);
        }
        if (from < 13) {
          await migrator.createTable(chapterGenerationRunRecords);
        }
        if (from < 14) {
          await migrator.createTable(projectBibleRecords);
          await migrator.createTable(chapterVolumeRecords);
          await _migrateWorkshopProjectBibleAndVolumes(migrator);
        }
        if (from < 15) {
          if (await _tableExists('provider_config_records')) {
            await migrator.addColumn(
              providerConfigRecords,
              providerConfigRecords.isSystemPromptEnabled,
            );
          }
        }
      },
    );
  }

  Future<void> _migrateWorkshopProjectBibleAndVolumes(Migrator migrator) async {
    if (!await _tableExists('project_records')) {
      await _addWorkshopChapterPlanColumnsIfTableExists(migrator);
      return;
    }
    await customStatement('''
      INSERT INTO project_bible_records (
        project_id,
        description_markdown,
        world_building_markdown,
        characters_blueprint_markdown,
        outline_master_markdown,
        outline_detail_yaml,
        created_at,
        updated_at
      )
      SELECT
        id,
        COALESCE(description, ''),
        '',
        '',
        '',
        '',
        created_at,
        updated_at
      FROM project_records
      WHERE id NOT IN (SELECT project_id FROM project_bible_records)
    ''');

    await customStatement('''
      INSERT INTO chapter_volume_records (
        id,
        project_id,
        volume_index,
        title,
        created_at,
        updated_at
      )
      SELECT
        'legacy-default-volume-' || project_id,
        project_id,
        1,
        '未分卷章节',
        MIN(created_at),
        MAX(updated_at)
      FROM chapter_plan_records
      GROUP BY project_id
      HAVING project_id NOT IN (
        SELECT project_id FROM chapter_volume_records WHERE volume_index = 1
      )
    ''');

    await _addWorkshopChapterPlanColumnsIfTableExists(migrator);
  }

  Future<void> _addWorkshopChapterPlanColumnsIfTableExists(
    Migrator migrator,
  ) async {
    if (!await _tableExists('chapter_plan_records')) {
      return;
    }
    await _addChapterPlanColumnIfMissing(
      migrator,
      'volume_id',
      chapterPlanRecords.volumeId,
    );
    await _addChapterPlanColumnIfMissing(
      migrator,
      'volume_index',
      chapterPlanRecords.volumeIndex,
    );
    await _addChapterPlanColumnIfMissing(
      migrator,
      'volume_title',
      chapterPlanRecords.volumeTitle,
    );
    await _addChapterPlanColumnIfMissing(
      migrator,
      'chapter_local_index',
      chapterPlanRecords.chapterLocalIndex,
    );
    await _addChapterPlanColumnIfMissing(
      migrator,
      'core_event',
      chapterPlanRecords.coreEvent,
    );
    await _addChapterPlanColumnIfMissing(
      migrator,
      'emotion_arc',
      chapterPlanRecords.emotionArc,
    );
    await _addChapterPlanColumnIfMissing(
      migrator,
      'chapter_hook',
      chapterPlanRecords.chapterHook,
    );
    await _addChapterPlanColumnIfMissing(
      migrator,
      'outline_markdown',
      chapterPlanRecords.outlineMarkdown,
    );

    final nowExpression = _sqliteNowMillisecondsExpression;
    await customStatement('''
      UPDATE chapter_plan_records
      SET
        volume_id = 'legacy-default-volume-' || project_id,
        volume_index = 1,
        volume_title = '未分卷章节',
        chapter_local_index = chapter_index,
        updated_at = CASE
          WHEN updated_at > $nowExpression THEN updated_at
          ELSE $nowExpression
        END
      WHERE TRIM(volume_id) = ''
    ''');
  }

  String get _sqliteNowMillisecondsExpression =>
      "(CAST(strftime('%s', 'now') AS INTEGER) * 1000)";

  Future<void> _addChapterPlanColumnIfMissing(
    Migrator migrator,
    String columnName,
    GeneratedColumn column,
  ) async {
    if (!await _columnExists('chapter_plan_records', columnName)) {
      await migrator.addColumn(chapterPlanRecords, column);
    }
  }

  Future<void> _dropNovelWorkshopPersistence() async {
    final hasWorkflowTasks = await _tableExists('workflow_task_records');
    if (hasWorkflowTasks) {
      final hasPromptTraces = await _tableExists(
        'workflow_prompt_trace_records',
      );
      if (hasPromptTraces) {
        await customStatement('''
          DELETE FROM workflow_prompt_trace_records
          WHERE workflow_task_id IN (
            SELECT id FROM workflow_task_records
            WHERE kind = 'novel_chapter_draft'
          )
        ''');
      }
    }
    await customStatement('DROP TABLE IF EXISTS memory_projection_records');
    await customStatement('DROP TABLE IF EXISTS accepted_chapter_records');
    await customStatement('DROP TABLE IF EXISTS chapter_draft_run_records');
    await customStatement('DROP TABLE IF EXISTS chapter_plan_records');
    await customStatement('DROP TABLE IF EXISTS story_bible_records');
    if (hasWorkflowTasks) {
      await customStatement('''
        DELETE FROM workflow_task_records
        WHERE kind = 'novel_chapter_draft'
      ''');
    }
  }

  Future<bool> _tableExists(String tableName) async {
    final rows = await customSelect(
      '''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table' AND name = ?
      LIMIT 1
      ''',
      variables: [Variable.withString(tableName)],
    ).get();
    return rows.isNotEmpty;
  }

  Future<bool> _columnExists(String tableName, String columnName) async {
    final rows = await customSelect('PRAGMA table_info($tableName)').get();
    return rows.any((row) => row.data['name'] == columnName);
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
