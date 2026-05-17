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
      expect(project.language, defaultProjectLanguage);
      expect(project.targetLength, defaultProjectTargetLength);
      expect(project.narrativePerspective, defaultProjectNarrativePerspective);
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
