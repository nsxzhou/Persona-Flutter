import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/database/app_database.dart';
import 'package:persona_flutter/src/core/tasks/data/drift_workflow_task_repository.dart';
import 'package:persona_flutter/src/core/tasks/domain/workflow_task.dart';
import 'package:persona_flutter/src/features/novel_workshop/data/drift_novel_workshop_repository.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/outline_detail_parser.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_workshop.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/writing_context.dart';
import 'package:persona_flutter/src/features/projects/data/drift_project_repository.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';
import 'package:persona_flutter/src/features/settings/data/drift_provider_config_repository.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('project bible initializes from project description', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final project = await _saveProject(database);
    final repository = DriftNovelWorkshopRepository(database);

    final bible = await repository.ensureProjectBible(project.id);

    expect(bible.projectId, project.id);
    expect(bible.descriptionMarkdown, project.description);
    expect(bible.outlineDetailYaml, isEmpty);
  });

  test('outline detail yaml projects volumes and chapter plans', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final project = await _saveProject(database);
    final repository = DriftNovelWorkshopRepository(database);

    final bible = await repository.saveOutlineDetailYaml(
      projectId: project.id,
      outlineDetailYaml: '''
volumes:
  - index: 1
    title: 第一卷
    chapters:
      - index: 1
        title: 第一章
        objective: 主角进入雾港。
        pressureSource: 追兵逼近。
        payoffTarget: 找到第一条线索。
        relationshipShift: 主角与向导临时合作。
        hookType: 信息差钩子。
        coreEvent: 抵达雾港。
        emotionArc: 警惕到被迫合作。
        chapterHook: 港务处灯灭。
        outlineMarkdown: |
          - 雾气压住码头。
          - 向导提出交易。
''',
    );

    final volumes = await repository.watchChapterVolumes(project.id).first;
    final plans = await repository.watchChapterPlans(project.id).first;

    expect(bible.outlineDetailYaml, contains('volumes:'));
    expect(volumes.single.title, '第一卷');
    expect(plans.single.volumeId, volumes.single.id);
    expect(plans.single.chapterLocalIndex, 1);
    expect(plans.single.objectiveCard.chapterTitle, '第一章');
    expect(plans.single.coreEvent, '抵达雾港。');
    expect(plans.single.outlineMarkdown, contains('雾气压住码头'));
  });

  test('outline parser reports missing required fields', () {
    expect(
      () => const OutlineDetailParser().parse('volumes: []'),
      throwsA(isA<OutlineDetailValidationException>()),
    );
    expect(
      () => const OutlineDetailParser().parse('''
volumes:
  - index: 1
    title: 第一卷
    chapters:
      - index: 1
'''),
      throwsA(isA<OutlineDetailValidationException>()),
    );
  });

  test('runtime memory initializes updates and clears per project', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final project = await _saveProject(database);
    final repository = DriftNovelWorkshopRepository(database);

    final initial = await repository.ensureRuntimeMemory(project.id);
    expect(initial.state.isEmpty, isTrue);

    final updated = await repository.saveRuntimeMemory(
      projectId: project.id,
      state: const RuntimeMemoryState(
        charactersStatus: '- 林岚：抵达雾港。',
        runtimeState: '- 潮汐封城。',
        runtimeThreads: '- 港务处线索未解。',
        storySummary: '林岚追查失踪案。',
      ),
    );
    expect(updated.state.charactersStatus, contains('林岚'));
    expect(updated.state.runtimeState, contains('潮汐'));

    await repository.clearRuntimeMemory(project.id);
    final cleared = await repository.findRuntimeMemory(project.id);
    expect(cleared, isNotNull);
    expect(cleared!.state.isEmpty, isTrue);
  });

  test('chapter plan and single chapter record round-trip', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final project = await _saveProject(database);
    final repository = DriftNovelWorkshopRepository(database);
    final volume = await repository.saveChapterVolume(
      input: ChapterVolumeInput(
        projectId: project.id,
        volumeIndex: 1,
        title: '第一卷',
      ),
    );

    final plan = await repository.saveChapterPlan(
      input: ChapterPlanInput(
        projectId: project.id,
        volumeId: volume.id,
        volumeIndex: volume.volumeIndex,
        volumeTitle: volume.title,
        chapterLocalIndex: 1,
        chapterIndex: 1,
        objectiveCard: const ChapterObjectiveCard(
          chapterTitle: '第一章',
          objective: '主角进入雾港。',
          pressureSource: '追兵逼近。',
          payoffTarget: '找到第一条线索。',
          relationshipShift: '主角与向导临时合作。',
          hookType: '信息差钩子。',
        ),
      ),
    );
    final chapter = await repository.saveChapter(
      input: ProjectChapterInput(
        projectId: project.id,
        chapterPlanId: plan.id,
        chapterIndex: plan.chapterIndex,
        title: plan.objectiveCard.chapterTitle,
        contentMarkdown: '雾气贴着码头爬上来。',
        continuityVerdict: ContinuityVerdict.warning,
        continuityReportMarkdown: '# 审校报告\n\n- 章末推动偏弱。',
      ),
    );

    expect(chapter.title, '第一章');
    expect(chapter.contentMarkdown, '雾气贴着码头爬上来。');
    expect(chapter.contentHash, isNotEmpty);
    expect(chapter.continuityVerdict, ContinuityVerdict.warning);
    expect(chapter.memorySyncStatus, MemorySyncStatus.idle);

    final plans = await repository.watchChapterPlans(project.id).first;
    final chapters = await repository.watchChapters(project.id).first;
    expect(plans.single.id, plan.id);
    expect(chapters.single.id, chapter.id);
  });

  test(
    'editing chapter content clears previous memory sync proposal',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final project = await _saveProject(database);
      final repository = DriftNovelWorkshopRepository(database);
      final volume = await repository.saveChapterVolume(
        input: ChapterVolumeInput(
          projectId: project.id,
          volumeIndex: 1,
          title: '第一卷',
        ),
      );
      final plan = await repository.saveChapterPlan(
        input: ChapterPlanInput(
          projectId: project.id,
          volumeId: volume.id,
          volumeIndex: volume.volumeIndex,
          volumeTitle: volume.title,
          chapterLocalIndex: 1,
          chapterIndex: 1,
          objectiveCard: const ChapterObjectiveCard(objective: '推进调查。'),
        ),
      );
      final chapter = await repository.saveChapter(
        input: ProjectChapterInput(
          projectId: project.id,
          chapterPlanId: plan.id,
          chapterIndex: 1,
          title: '第一章',
          contentMarkdown: '旧正文。',
        ),
      );
      final proposal = await repository.saveMemorySyncProposal(
        MemorySyncProposalInput(
          chapterId: chapter.id,
          contentHash: chapter.contentHash,
          proposedMemory: const RuntimeMemoryState(
            charactersStatus: '- 林岚：发现旧线索。',
            runtimeState: '- 旧正文状态。',
            runtimeThreads: '- 旧伏笔。',
            storySummary: '旧摘要。',
          ),
        ),
      );
      expect(proposal.memorySyncStatus, MemorySyncStatus.pendingReview);
      expect(proposal.memorySyncProposedStorySummary, '旧摘要。');

      final edited = await repository.saveChapter(
        id: chapter.id,
        input: ProjectChapterInput(
          projectId: project.id,
          chapterPlanId: plan.id,
          chapterIndex: 1,
          title: '第一章',
          contentMarkdown: '新正文。',
        ),
      );

      expect(edited.contentMarkdown, '新正文。');
      expect(edited.contentHash, isNot(chapter.contentHash));
      expect(edited.memorySyncStatus, MemorySyncStatus.idle);
      expect(edited.memorySyncContentHash, isEmpty);
      expect(edited.memorySyncProposedCharactersStatus, isEmpty);
      expect(edited.memorySyncProposedRuntimeState, isEmpty);
      expect(edited.memorySyncProposedRuntimeThreads, isEmpty);
      expect(edited.memorySyncProposedStorySummary, isEmpty);
    },
  );

  test('chapter generation run syncs workflow task and prompt trace', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final project = await _saveProject(database);
    final repository = DriftNovelWorkshopRepository(database);
    final volume = await repository.saveChapterVolume(
      input: ChapterVolumeInput(
        projectId: project.id,
        volumeIndex: 1,
        title: '第一卷',
      ),
    );
    final workflowRepository = DriftWorkflowTaskRepository(database);
    final plan = await repository.saveChapterPlan(
      input: ChapterPlanInput(
        projectId: project.id,
        volumeId: volume.id,
        volumeIndex: volume.volumeIndex,
        volumeTitle: volume.title,
        chapterLocalIndex: 1,
        chapterIndex: 1,
        objectiveCard: const ChapterObjectiveCard(
          chapterTitle: '第一章',
          objective: '主角进入雾港。',
        ),
      ),
    );

    final run = await repository.createChapterGenerationRun(
      ChapterGenerationRunInput(
        projectId: project.id,
        chapterPlanId: plan.id,
        providerId: project.defaultProviderId!,
        modelName: project.defaultModelName!,
      ),
    );

    expect(run.status, ChapterGenerationStatus.pending);
    expect(await repository.hasRunningChapterGeneration(plan.id), isTrue);

    final running = await repository.updateChapterGenerationRunState(
      id: run.id,
      status: ChapterGenerationStatus.running,
      stage: ChapterGenerationStage.generatingDraft,
      contextWarningsMarkdown: '- 运行时记忆为空。',
      startedAt: DateTime.now(),
    );
    final task = await workflowRepository.findTask(run.workflowTaskId);
    expect(running.stage, ChapterGenerationStage.generatingDraft);
    expect(running.contextWarningsMarkdown, contains('运行时记忆'));
    expect(task!.kind, chapterGenerationWorkflowTaskKind);
    expect(task.status, WorkflowTaskStatus.running);
    expect(task.stage, ChapterGenerationStage.generatingDraft.name);

    await workflowRepository.upsertPromptTrace(
      workflowTaskId: run.workflowTaskId,
      traceMarkdown: '# Prompt Trace',
    );
    final trace = await workflowRepository
        .watchPromptTrace(run.workflowTaskId)
        .first;
    expect(trace!.traceMarkdown, '# Prompt Trace');

    final succeeded = await repository.updateChapterGenerationRunState(
      id: run.id,
      status: ChapterGenerationStatus.succeeded,
      stage: null,
      completedAt: DateTime.now(),
    );
    final completedTask = await workflowRepository.findTask(run.workflowTaskId);
    expect(succeeded.status, ChapterGenerationStatus.succeeded);
    expect(completedTask!.status, WorkflowTaskStatus.succeeded);
    expect(await repository.hasRunningChapterGeneration(plan.id), isFalse);
  });

  test('migration creates novel workshop persistence tables', () async {
    final sqlite = sqlite3.openInMemory();
    addTearDown(sqlite.dispose);
    final now = DateTime.utc(2026, 5, 18).millisecondsSinceEpoch;
    _createSchema11Database(sqlite, now: now);
    sqlite.execute('PRAGMA user_version = 11;');

    final database = AppDatabase(
      NativeDatabase.opened(sqlite, closeUnderlyingOnClose: false),
    );
    addTearDown(database.close);
    await database.customSelect('SELECT 1').get();

    expect(
      await _tableExists(sqlite, 'project_runtime_memory_records'),
      isTrue,
    );
    expect(await _tableExists(sqlite, 'chapter_plan_records'), isTrue);
    expect(await _tableExists(sqlite, 'project_chapter_records'), isTrue);
    expect(
      await _tableExists(sqlite, 'chapter_generation_run_records'),
      isTrue,
    );
  });
}

Future<WritingProject> _saveProject(AppDatabase database) async {
  final providerRepository = DriftProviderConfigRepository(database);
  await providerRepository.saveProvider(
    input: const ProviderConfigInput(
      name: 'OpenAI',
      baseUrl: 'https://api.example.com/v1',
      apiKey: 'sk-test',
      defaultModel: 'gpt-4.1-mini',
      systemPrompt: '',
      isEnabled: true,
    ),
  );
  final provider = (await providerRepository.watchProviders().first).single;
  final projectRepository = DriftProjectRepository(database);
  await projectRepository.saveProject(
    input: WritingProjectInput(
      title: '雾港纪事',
      description: '',
      status: ProjectStatus.active,
      defaultProviderId: provider.id,
      defaultModelName: provider.defaultModel,
    ),
  );
  return (await projectRepository.watchProjects(ProjectStatus.active).first)
      .single;
}

void _createSchema11Database(Database sqlite, {required int now}) {
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
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
  sqlite.execute('''
    CREATE TABLE provider_model_records (
      provider_id TEXT NOT NULL REFERENCES provider_config_records(id),
      model_name TEXT NOT NULL,
      sort_order INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      PRIMARY KEY (provider_id, model_name)
    );
  ''');
  sqlite.execute('''
    CREATE TABLE project_records (
      id TEXT NOT NULL PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT NOT NULL DEFAULT '',
      status TEXT NOT NULL,
      default_provider_id TEXT,
      default_model_name TEXT,
      style_profile_id TEXT,
      plot_profile_id TEXT,
      language TEXT NOT NULL DEFAULT '简体中文',
      target_length INTEGER NOT NULL DEFAULT 3000,
      narrative_perspective TEXT NOT NULL DEFAULT '第三人称有限视角',
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
  sqlite.execute(
    '''
    INSERT INTO project_records (
      id, title, description, status, created_at, updated_at
    ) VALUES ('project-1', '旧项目', '', 'active', ?, ?);
  ''',
    [now, now],
  );
  sqlite.execute('''
    CREATE TABLE style_sample_records (
      id TEXT NOT NULL PRIMARY KEY,
      source_type TEXT NOT NULL,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      character_count INTEGER NOT NULL,
      project_id TEXT REFERENCES project_records(id),
      source_filename TEXT,
      epub_book_title TEXT,
      epub_author TEXT,
      epub_chapter_title TEXT,
      epub_chapter_index INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
  sqlite.execute('''
    CREATE TABLE style_analysis_run_records (
      id TEXT NOT NULL PRIMARY KEY,
      workflow_task_id TEXT NOT NULL REFERENCES workflow_task_records(id),
      sample_id TEXT NOT NULL REFERENCES style_sample_records(id),
      provider_id TEXT NOT NULL REFERENCES provider_config_records(id),
      model_name TEXT NOT NULL,
      style_name TEXT NOT NULL,
      project_id TEXT REFERENCES project_records(id),
      status TEXT NOT NULL,
      stage TEXT,
      error_message TEXT,
      logs TEXT NOT NULL DEFAULT '',
      analysis_report_markdown TEXT,
      voice_profile_markdown TEXT,
      profile_id TEXT,
      chunk_count INTEGER NOT NULL DEFAULT 0,
      character_count INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      started_at INTEGER,
      completed_at INTEGER
    );
  ''');
  sqlite.execute('''
    CREATE TABLE style_profile_records (
      id TEXT NOT NULL PRIMARY KEY,
      source_run_id TEXT NOT NULL UNIQUE
        REFERENCES style_analysis_run_records(id),
      provider_id TEXT NOT NULL REFERENCES provider_config_records(id),
      model_name TEXT NOT NULL,
      style_name TEXT NOT NULL,
      profile_markdown TEXT NOT NULL,
      analysis_report_markdown TEXT NOT NULL,
      project_id TEXT REFERENCES project_records(id),
      source_sample_id TEXT REFERENCES style_sample_records(id),
      source_title TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
  sqlite.execute('''
    CREATE TABLE plot_sample_records (
      id TEXT NOT NULL PRIMARY KEY,
      source_type TEXT NOT NULL,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      character_count INTEGER NOT NULL,
      project_id TEXT REFERENCES project_records(id),
      source_filename TEXT,
      epub_book_title TEXT,
      epub_author TEXT,
      epub_chapter_count INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
  sqlite.execute('''
    CREATE TABLE plot_analysis_run_records (
      id TEXT NOT NULL PRIMARY KEY,
      workflow_task_id TEXT NOT NULL REFERENCES workflow_task_records(id),
      sample_id TEXT NOT NULL REFERENCES plot_sample_records(id),
      provider_id TEXT NOT NULL REFERENCES provider_config_records(id),
      model_name TEXT NOT NULL,
      plot_name TEXT NOT NULL,
      project_id TEXT REFERENCES project_records(id),
      status TEXT NOT NULL,
      stage TEXT,
      error_message TEXT,
      logs TEXT NOT NULL DEFAULT '',
      analysis_report_markdown TEXT,
      plot_skeleton_markdown TEXT,
      story_engine_markdown TEXT,
      profile_id TEXT,
      chunk_count INTEGER NOT NULL DEFAULT 0,
      character_count INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      started_at INTEGER,
      completed_at INTEGER
    );
  ''');
  sqlite.execute('''
    CREATE TABLE plot_profile_records (
      id TEXT NOT NULL PRIMARY KEY,
      source_run_id TEXT NOT NULL UNIQUE REFERENCES plot_analysis_run_records(id),
      provider_id TEXT NOT NULL REFERENCES provider_config_records(id),
      model_name TEXT NOT NULL,
      plot_name TEXT NOT NULL,
      story_engine_markdown TEXT NOT NULL,
      analysis_report_markdown TEXT NOT NULL,
      plot_skeleton_markdown TEXT NOT NULL,
      project_id TEXT REFERENCES project_records(id),
      source_sample_id TEXT REFERENCES plot_sample_records(id),
      source_title TEXT,
      created_at INTEGER NOT NULL,
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
