import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/database/app_database.dart';
import 'package:persona_flutter/src/features/projects/data/drift_project_repository.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';
import 'package:persona_flutter/src/features/settings/data/drift_provider_config_repository.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('project repository round-trips and filters project records', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final providerRepository = DriftProviderConfigRepository(database);
    await providerRepository.saveProvider(input: _providerInput());
    final provider = (await providerRepository.watchProviders().first).single;

    final repository = DriftProjectRepository(database);
    final input = WritingProjectInput(
      title: '雾港纪事',
      description: '潮湿港城里的长篇悬疑。',
      status: ProjectStatus.active,
      defaultProviderId: provider.id,
      defaultModelName: provider.defaultModel,
      language: '简体中文',
      targetLength: 3200,
      narrativePerspective: '第三人称有限视角',
    );

    await repository.saveProject(input: input);

    final active = await repository.watchProjects(ProjectStatus.active).first;
    expect(active, hasLength(1));
    expect(active.single.title, input.title);
    expect(active.single.description, input.description);
    expect(active.single.status, ProjectStatus.active);
    expect(active.single.defaultProviderId, provider.id);
    expect(active.single.defaultModelName, provider.defaultModel);
    expect(active.single.styleProfileId, isNull);
    expect(active.single.plotProfileId, isNull);
    expect(active.single.language, '简体中文');
    expect(active.single.targetLength, 3200);
    expect(active.single.origin, ProjectOrigin.standard);
    expect(active.single.narrativePerspective, '第三人称有限视角');

    final saved = active.single;
    await repository.saveProject(
      id: saved.id,
      input: WritingProjectInput(
        title: '雾港纪事：修订',
        description: '新的项目简介。',
        status: ProjectStatus.archived,
        defaultProviderId: provider.id,
        defaultModelName: 'gpt-4.1',
        origin: ProjectOrigin.importedEnrichment,
        language: 'English',
        targetLength: 1800,
        narrativePerspective: '第一人称',
      ),
    );

    final archived = await repository
        .watchProjects(ProjectStatus.archived)
        .first;
    expect(archived, hasLength(1));
    expect(archived.single.id, saved.id);
    expect(archived.single.title, '雾港纪事：修订');
    expect(archived.single.defaultModelName, 'gpt-4.1');
    expect(archived.single.origin, ProjectOrigin.importedEnrichment);
    expect(archived.single.language, 'English');
    expect(archived.single.targetLength, 1800);
    expect(archived.single.narrativePerspective, '第一人称');
    expect(archived.single.createdAt, saved.createdAt);
    expect(archived.single.updatedAt.isAfter(saved.updatedAt), isTrue);

    final activeAfterArchive = await repository
        .watchProjects(ProjectStatus.active)
        .first;
    expect(activeAfterArchive, isEmpty);

    await repository.updateStatus(id: saved.id, status: ProjectStatus.active);
    expect(
      await repository.watchProjects(ProjectStatus.active).first,
      hasLength(1),
    );

    await repository.deleteProject(saved.id);
    expect(await repository.findProject(saved.id), isNull);
  });

  test('project repository requires provider and valid model', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = DriftProjectRepository(database);

    await expectLater(
      repository.saveProject(
        input: const WritingProjectInput(
          title: '雾港纪事',
          description: '',
          status: ProjectStatus.active,
          defaultProviderId: 'missing-provider',
          defaultModelName: 'gpt-4.1-mini',
        ),
      ),
      throwsStateError,
    );

    final providerRepository = DriftProviderConfigRepository(database);
    await providerRepository.saveProvider(input: _providerInput());
    final provider = (await providerRepository.watchProviders().first).single;

    await expectLater(
      repository.saveProject(
        input: WritingProjectInput(
          title: '雾港纪事',
          description: '',
          status: ProjectStatus.active,
          defaultProviderId: provider.id,
          defaultModelName: 'not-owned',
        ),
      ),
      throwsStateError,
    );
  });

  test('project repository rejects invalid profile references', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final providerRepository = DriftProviderConfigRepository(database);
    await providerRepository.saveProvider(input: _providerInput());
    final provider = (await providerRepository.watchProviders().first).single;
    final repository = DriftProjectRepository(database);

    await expectLater(
      repository.saveProject(
        input: WritingProjectInput(
          title: '雾港纪事',
          description: '',
          status: ProjectStatus.active,
          defaultProviderId: provider.id,
          defaultModelName: provider.defaultModel,
          styleProfileId: 'missing-style-profile',
        ),
      ),
      throwsStateError,
    );

    await expectLater(
      repository.saveProject(
        input: WritingProjectInput(
          title: '雾港纪事',
          description: '',
          status: ProjectStatus.active,
          defaultProviderId: provider.id,
          defaultModelName: provider.defaultModel,
          plotProfileId: 'missing-plot-profile',
        ),
      ),
      throwsStateError,
    );
  });

  test(
    'migration backfills legacy projects with enabled provider defaults',
    () async {
      final sqlite = sqlite3.openInMemory();
      addTearDown(sqlite.dispose);
      final createdAt = DateTime.utc(2026, 5, 16, 9).millisecondsSinceEpoch;
      final updatedAt = DateTime.utc(2026, 5, 16, 10).millisecondsSinceEpoch;

      sqlite.execute('''
      CREATE TABLE provider_config_records (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        base_url TEXT NOT NULL,
        api_key TEXT NOT NULL,
        default_model TEXT NOT NULL,
        system_prompt TEXT NOT NULL DEFAULT '',
        is_enabled INTEGER NOT NULL DEFAULT 1,
        test_status TEXT NOT NULL,
        last_tested_at INTEGER,
        last_test_message TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');
      sqlite.execute('''
      CREATE TABLE provider_model_records (
        provider_id TEXT NOT NULL REFERENCES provider_config_records(id),
        model_name TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        PRIMARY KEY (provider_id, model_name)
      );
    ''');
      sqlite.execute('''
      CREATE TABLE project_records (
        id TEXT NOT NULL PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');
      sqlite.execute(
        '''
      INSERT INTO provider_config_records (
        id, name, base_url, api_key, default_model, system_prompt, is_enabled,
        test_status, created_at, updated_at
      ) VALUES (
        'provider-1', 'OpenAI', 'https://api.example.com/v1', 'sk-test',
        'gpt-4.1-mini', '', 1, 'untested', ?, ?
      );
    ''',
        [createdAt, updatedAt],
      );
      sqlite.execute(
        '''
      INSERT INTO project_records (
        id, title, description, status, created_at, updated_at
      ) VALUES (
        'project-1', '旧项目', '', 'active', ?, ?
      );
    ''',
        [createdAt, updatedAt],
      );
      sqlite.execute('PRAGMA user_version = 8;');

      final database = AppDatabase(
        NativeDatabase.opened(sqlite, closeUnderlyingOnClose: false),
      );
      addTearDown(database.close);
      final repository = DriftProjectRepository(database);

      final project = await repository.findProject('project-1');

      expect(project, isNotNull);
      expect(project!.defaultProviderId, 'provider-1');
      expect(project.defaultModelName, 'gpt-4.1-mini');
      expect(project.origin, ProjectOrigin.standard);
      expect(project.language, defaultProjectLanguage);
      expect(project.targetLength, defaultProjectTargetLength);
      expect(project.narrativePerspective, defaultProjectNarrativePerspective);
    },
  );

  test(
    'migration drops legacy novel workshop tables and workflow traces',
    () async {
      final sqlite = sqlite3.openInMemory();
      addTearDown(sqlite.dispose);
      final now = DateTime.utc(2026, 5, 18).millisecondsSinceEpoch;

      _createSchema10NovelWorkshopTables(sqlite);
      sqlite.execute(
        '''
      INSERT INTO workflow_task_records (
        id, kind, status, title, created_at, updated_at
      ) VALUES (
        'task-novel', 'novel_chapter_draft', 'running', '章节草稿', ?, ?
      );
    ''',
        [now, now],
      );
      sqlite.execute(
        '''
      INSERT INTO workflow_task_records (
        id, kind, status, title, created_at, updated_at
      ) VALUES (
        'task-style', 'style_analysis', 'succeeded', '风格分析', ?, ?
      );
    ''',
        [now, now],
      );
      sqlite.execute(
        '''
      INSERT INTO workflow_prompt_trace_records (
        workflow_task_id, trace_markdown, created_at, updated_at
      ) VALUES (
        'task-novel', '# Novel Trace', ?, ?
      );
    ''',
        [now, now],
      );
      sqlite.execute(
        '''
      INSERT INTO workflow_prompt_trace_records (
        workflow_task_id, trace_markdown, created_at, updated_at
      ) VALUES (
        'task-style', '# Style Trace', ?, ?
      );
    ''',
        [now, now],
      );
      sqlite.execute(
        '''
      INSERT INTO story_bible_records (
        id, project_id, world_markdown, created_at, updated_at
      ) VALUES (
        'bible-1', 'project-1', '# World', ?, ?
      );
    ''',
        [now, now],
      );
      sqlite.execute(
        '''
      INSERT INTO chapter_plan_records (
        id, project_id, chapter_index, title, status, created_at, updated_at
      ) VALUES (
        'plan-1', 'project-1', 1, '第一章', 'drafting', ?, ?
      );
    ''',
        [now, now],
      );
      sqlite.execute(
        '''
      INSERT INTO chapter_draft_run_records (
        id, workflow_task_id, project_id, chapter_plan_id, provider_id,
        model_name, status, created_at, updated_at
      ) VALUES (
        'run-1', 'task-novel', 'project-1', 'plan-1', 'provider-1',
        'gpt-4.1-mini', 'running', ?, ?
      );
    ''',
        [now, now],
      );
      sqlite.execute(
        '''
      INSERT INTO accepted_chapter_records (
        id, project_id, chapter_plan_id, source_run_id, chapter_index, title,
        content_markdown, accepted_at, created_at, updated_at
      ) VALUES (
        'chapter-1', 'project-1', 'plan-1', 'run-1', 1, '第一章',
        '正文', ?, ?, ?
      );
    ''',
        [now, now, now],
      );
      sqlite.execute(
        '''
      INSERT INTO memory_projection_records (
        id, project_id, global_summary, updated_from_chapter_id, updated_at
      ) VALUES (
        'memory-1', 'project-1', '摘要', 'chapter-1', ?
      );
    ''',
        [now],
      );
      sqlite.execute('PRAGMA user_version = 10;');

      final database = AppDatabase(
        NativeDatabase.opened(sqlite, closeUnderlyingOnClose: false),
      );
      addTearDown(database.close);

      final remainingTasks = await database
          .customSelect('SELECT id FROM workflow_task_records ORDER BY id')
          .get();
      final remainingTraces = await database
          .customSelect(
            'SELECT workflow_task_id FROM workflow_prompt_trace_records '
            'ORDER BY workflow_task_id',
          )
          .get();

      expect(remainingTasks.map((row) => row.read<String>('id')), [
        'task-style',
      ]);
      expect(
        remainingTraces.map((row) => row.read<String>('workflow_task_id')),
        ['task-style'],
      );
      expect(await _tableExists(sqlite, 'story_bible_records'), isFalse);
      expect(await _tableExists(sqlite, 'chapter_draft_run_records'), isFalse);
      expect(await _tableExists(sqlite, 'accepted_chapter_records'), isFalse);
      expect(await _tableExists(sqlite, 'memory_projection_records'), isFalse);
      expect(
        await _tableExists(sqlite, 'project_runtime_memory_records'),
        isTrue,
      );
      expect(await _tableExists(sqlite, 'chapter_plan_records'), isTrue);
      expect(await _tableExists(sqlite, 'project_chapter_records'), isTrue);
    },
  );
}

ProviderConfigInput _providerInput() {
  return const ProviderConfigInput(
    name: 'OpenAI',
    baseUrl: 'https://api.example.com/v1',
    apiKey: 'sk-test',
    defaultModel: 'gpt-4.1-mini',
    modelNames: ['gpt-4.1'],
    systemPrompt: '',
    isEnabled: true,
  );
}

void _createSchema10NovelWorkshopTables(Database sqlite) {
  sqlite.execute('''
    CREATE TABLE workflow_task_records (
      id TEXT NOT NULL PRIMARY KEY,
      kind TEXT NOT NULL,
      status TEXT NOT NULL,
      title TEXT NOT NULL,
      stage TEXT,
      error_message TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
  sqlite.execute('''
    CREATE TABLE workflow_prompt_trace_records (
      workflow_task_id TEXT NOT NULL
        REFERENCES workflow_task_records (id)
        PRIMARY KEY,
      trace_markdown TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
  sqlite.execute('''
    CREATE TABLE story_bible_records (
      id TEXT NOT NULL PRIMARY KEY,
      project_id TEXT NOT NULL UNIQUE,
      author_intent TEXT NOT NULL DEFAULT '',
      current_focus TEXT NOT NULL DEFAULT '',
      world_markdown TEXT NOT NULL DEFAULT '',
      characters_markdown TEXT NOT NULL DEFAULT '',
      rules_markdown TEXT NOT NULL DEFAULT '',
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
  sqlite.execute('''
    CREATE TABLE chapter_plan_records (
      id TEXT NOT NULL PRIMARY KEY,
      project_id TEXT NOT NULL,
      chapter_index INTEGER NOT NULL,
      title TEXT NOT NULL,
      goal TEXT NOT NULL DEFAULT '',
      target_beat TEXT NOT NULL DEFAULT '',
      must_include TEXT NOT NULL DEFAULT '',
      must_avoid TEXT NOT NULL DEFAULT '',
      hook TEXT NOT NULL DEFAULT '',
      payoff TEXT NOT NULL DEFAULT '',
      status TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      UNIQUE(project_id, chapter_index)
    );
  ''');
  sqlite.execute('''
    CREATE TABLE chapter_draft_run_records (
      id TEXT NOT NULL PRIMARY KEY,
      workflow_task_id TEXT NOT NULL REFERENCES workflow_task_records (id),
      project_id TEXT NOT NULL,
      chapter_plan_id TEXT NOT NULL REFERENCES chapter_plan_records (id),
      provider_id TEXT NOT NULL,
      model_name TEXT NOT NULL,
      status TEXT NOT NULL,
      stage TEXT,
      contract_markdown TEXT NOT NULL DEFAULT '',
      draft_markdown TEXT NOT NULL DEFAULT '',
      audit_markdown TEXT NOT NULL DEFAULT '',
      revised_markdown TEXT NOT NULL DEFAULT '',
      error_message TEXT,
      logs TEXT NOT NULL DEFAULT '',
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
  sqlite.execute('''
    CREATE TABLE accepted_chapter_records (
      id TEXT NOT NULL PRIMARY KEY,
      project_id TEXT NOT NULL,
      chapter_plan_id TEXT NOT NULL UNIQUE REFERENCES chapter_plan_records (id),
      source_run_id TEXT NOT NULL REFERENCES chapter_draft_run_records (id),
      chapter_index INTEGER NOT NULL,
      title TEXT NOT NULL,
      content_markdown TEXT NOT NULL,
      accepted_at INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
  sqlite.execute('''
    CREATE TABLE memory_projection_records (
      id TEXT NOT NULL PRIMARY KEY,
      project_id TEXT NOT NULL UNIQUE,
      recent_summary TEXT NOT NULL DEFAULT '',
      global_summary TEXT NOT NULL DEFAULT '',
      fact_ledger_markdown TEXT NOT NULL DEFAULT '',
      character_states_markdown TEXT NOT NULL DEFAULT '',
      unresolved_hooks_markdown TEXT NOT NULL DEFAULT '',
      updated_from_chapter_id TEXT REFERENCES accepted_chapter_records (id),
      updated_at INTEGER NOT NULL
    );
  ''');
}

Future<bool> _tableExists(Database sqlite, String tableName) async {
  final result = sqlite.select(
    '''
    SELECT name
    FROM sqlite_master
    WHERE type = 'table' AND name = ?
    LIMIT 1
    ''',
    [tableName],
  );
  return result.isNotEmpty;
}
