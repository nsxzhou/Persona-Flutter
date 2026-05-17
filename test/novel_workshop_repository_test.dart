import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/database/app_database.dart';
import 'package:persona_flutter/src/core/tasks/data/drift_workflow_task_repository.dart';
import 'package:persona_flutter/src/core/tasks/domain/workflow_task.dart';
import 'package:persona_flutter/src/features/novel_workshop/data/drift_novel_workshop_repository.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/accepted_chapter.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/chapter_draft_run.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/chapter_plan.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/memory_projection.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/story_bible.dart';
import 'package:persona_flutter/src/features/projects/data/drift_project_repository.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';
import 'package:persona_flutter/src/features/settings/data/drift_provider_config_repository.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('novel workshop repository round-trips project documents', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final context = await _novelTestContext(database);
    final repository = context.repository;

    final bible = await repository.upsertStoryBible(
      StoryBibleInput(
        projectId: context.projectId,
        authorIntent: '写一部雾港悬疑。',
        currentFocus: '第一幕铺设疑点。',
        worldMarkdown: '# World\n\n潮湿港城。',
        charactersMarkdown: '# Characters\n\n- 林澈',
        rulesMarkdown: '# Rules\n\n不可提前揭露凶手。',
      ),
    );

    expect(bible.projectId, context.projectId);
    expect(bible.worldMarkdown, '# World\n\n潮湿港城。');
    expect(await repository.watchStoryBible(context.projectId).first, bible);

    final updatedBible = await repository.upsertStoryBible(
      StoryBibleInput(
        projectId: context.projectId,
        authorIntent: '写一部雾港群像悬疑。',
        currentFocus: '第二幕扩大冲突。',
        worldMarkdown: '# World\n\n潮湿港城和旧码头。',
        charactersMarkdown: '# Characters\n\n- 林澈\n- 许岚',
        rulesMarkdown: '# Rules\n\n禁止超自然解释。',
      ),
    );

    expect(updatedBible.id, bible.id);
    expect(updatedBible.authorIntent, '写一部雾港群像悬疑。');
    expect(updatedBible.createdAt, bible.createdAt);

    final projection = await repository.upsertMemoryProjection(
      MemoryProjectionInput(
        projectId: context.projectId,
        recentSummary: '最近章节摘要',
        globalSummary: '全局摘要',
        factLedgerMarkdown: '# Facts\n\n- 港口停电。',
        characterStatesMarkdown: '# States\n\n- 林澈开始怀疑旧友。',
        unresolvedHooksMarkdown: '# Hooks\n\n- 黑伞人身份未知。',
      ),
    );

    expect(projection.factLedgerMarkdown, '# Facts\n\n- 港口停电。');
    expect(
      await repository.watchMemoryProjection(context.projectId).first,
      projection,
    );

    final updatedProjection = await repository.upsertMemoryProjection(
      MemoryProjectionInput(
        projectId: context.projectId,
        recentSummary: '新的近期摘要',
        globalSummary: '新的全局摘要',
      ),
    );

    expect(updatedProjection.id, projection.id);
    expect(updatedProjection.recentSummary, '新的近期摘要');
  });

  test('chapter plans are ordered and unique per project index', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final context = await _novelTestContext(database);
    final repository = context.repository;

    final third = await repository.saveChapterPlan(
      input: ChapterPlanInput(
        projectId: context.projectId,
        chapterIndex: 3,
        title: '第三章',
        goal: '揭示假线索',
      ),
    );
    final first = await repository.saveChapterPlan(
      input: ChapterPlanInput(
        projectId: context.projectId,
        chapterIndex: 1,
        title: '第一章',
        targetBeat: '港口停电',
      ),
    );

    final plans = await repository.watchChapterPlans(context.projectId).first;
    expect(plans.map((plan) => plan.id), [first.id, third.id]);
    expect(plans.map((plan) => plan.chapterIndex), [1, 3]);

    await expectLater(
      repository.saveChapterPlan(
        input: ChapterPlanInput(
          projectId: context.projectId,
          chapterIndex: 1,
          title: '重复第一章',
        ),
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('chapter draft runs synchronize workflow tasks', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final context = await _novelTestContext(database);
    final repository = context.repository;
    final plan = await _savePlan(repository, context.projectId);

    final run = await repository.createChapterDraftRun(
      ChapterDraftRunInput(
        projectId: context.projectId,
        chapterPlanId: plan.id,
        providerId: context.provider.id,
        modelName: context.provider.defaultModel,
      ),
    );

    expect(run.status, ChapterDraftRunStatus.pending);
    expect(run.stage, isNull);
    final taskRepository = DriftWorkflowTaskRepository(database);
    final task = await taskRepository.findTask(run.workflowTaskId);
    expect(task, isNotNull);
    expect(task!.kind, chapterDraftWorkflowTaskKind);
    expect(task.status, WorkflowTaskStatus.pending);
    expect(task.stage, 'queued');

    await repository.updateChapterDraftRunState(
      id: run.id,
      status: ChapterDraftRunStatus.running,
      stage: ChapterDraftRunStage.buildContract,
      contractMarkdown: '# Chapter Contract\n\n## Goal',
      logs: '开始生成章节契约。',
    );

    final running = await repository.findChapterDraftRun(run.id);
    expect(running!.status, ChapterDraftRunStatus.running);
    expect(running.stage, ChapterDraftRunStage.buildContract);
    expect(running.contractMarkdown, '# Chapter Contract\n\n## Goal');

    final runningTask = await taskRepository.findTask(run.workflowTaskId);
    expect(runningTask!.status, WorkflowTaskStatus.running);
    expect(runningTask.stage, ChapterDraftRunStage.buildContract.name);

    await repository.updateChapterDraftRunState(
      id: run.id,
      status: ChapterDraftRunStatus.succeeded,
      stage: ChapterDraftRunStage.awaitAcceptance,
      draftMarkdown: '# Draft\n\n正文草稿。',
      auditMarkdown: '# Audit\n\n通过。',
      revisedMarkdown: '# Revised\n\n修订正文。',
    );

    final succeededTask = await taskRepository.findTask(run.workflowTaskId);
    expect(succeededTask!.status, WorkflowTaskStatus.succeeded);
    final reviewedPlan = await repository.findChapterPlan(plan.id);
    expect(reviewedPlan!.status, ChapterPlanStatus.reviewed);
  });

  test('accepted chapter overwrites one official chapter per plan', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final context = await _novelTestContext(database);
    final repository = context.repository;
    final plan = await _savePlan(repository, context.projectId);
    final firstRun = await _createRun(repository, context, plan.id);
    final secondRun = await _createRun(repository, context, plan.id);

    final firstAccepted = await repository.upsertAcceptedChapter(
      AcceptedChapterInput(
        projectId: context.projectId,
        chapterPlanId: plan.id,
        sourceRunId: firstRun.id,
        chapterIndex: plan.chapterIndex,
        title: '第一章 旧稿',
        contentMarkdown: '# 第一章\n\n旧正文。',
      ),
    );

    final acceptedPlan = await repository.findChapterPlan(plan.id);
    expect(acceptedPlan!.status, ChapterPlanStatus.accepted);

    final secondAccepted = await repository.upsertAcceptedChapter(
      AcceptedChapterInput(
        projectId: context.projectId,
        chapterPlanId: plan.id,
        sourceRunId: secondRun.id,
        chapterIndex: plan.chapterIndex,
        title: '第一章 新稿',
        contentMarkdown: '# 第一章\n\n新正文。',
      ),
    );

    expect(secondAccepted.id, firstAccepted.id);
    expect(secondAccepted.sourceRunId, secondRun.id);
    expect(secondAccepted.contentMarkdown, '# 第一章\n\n新正文。');
    final acceptedChapters = await repository
        .watchAcceptedChapters(context.projectId)
        .first;
    expect(acceptedChapters, hasLength(1));
  });

  test(
    'project deletion removes novel data prompt traces and workflow tasks',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final context = await _novelTestContext(database);
      final repository = context.repository;
      final plan = await _savePlan(repository, context.projectId);
      final run = await _createRun(repository, context, plan.id);
      final accepted = await repository.upsertAcceptedChapter(
        AcceptedChapterInput(
          projectId: context.projectId,
          chapterPlanId: plan.id,
          sourceRunId: run.id,
          chapterIndex: plan.chapterIndex,
          title: plan.title,
          contentMarkdown: '正式正文。',
        ),
      );
      await repository.upsertStoryBible(
        StoryBibleInput(projectId: context.projectId, worldMarkdown: '# World'),
      );
      await repository.upsertMemoryProjection(
        MemoryProjectionInput(
          projectId: context.projectId,
          globalSummary: '摘要',
          updatedFromChapterId: accepted.id,
        ),
      );
      await DriftWorkflowTaskRepository(database).upsertPromptTrace(
        workflowTaskId: run.workflowTaskId,
        traceMarkdown: '# Prompt Trace',
      );

      await context.projectRepository.deleteProject(context.projectId);

      expect(
        await context.projectRepository.findProject(context.projectId),
        isNull,
      );
      expect(await repository.findStoryBible(context.projectId), isNull);
      expect(await repository.findChapterPlan(plan.id), isNull);
      expect(await repository.findChapterDraftRun(run.id), isNull);
      expect(await repository.findMemoryProjection(context.projectId), isNull);
      expect(await repository.findAcceptedChapterForPlan(plan.id), isNull);
      final taskRepository = DriftWorkflowTaskRepository(database);
      expect(await taskRepository.findTask(run.workflowTaskId), isNull);
      expect(
        await taskRepository.watchPromptTrace(run.workflowTaskId).first,
        isNull,
      );
    },
  );

  test(
    'interrupted draft runs are marked failed with workflow tasks',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final context = await _novelTestContext(database);
      final repository = context.repository;
      final plan = await _savePlan(repository, context.projectId);
      final firstRun = await _createRun(repository, context, plan.id);
      final secondRun = await _createRun(repository, context, plan.id);

      await repository.updateChapterDraftRunState(
        id: firstRun.id,
        status: ChapterDraftRunStatus.running,
        stage: ChapterDraftRunStage.draft,
      );
      await repository.updateChapterDraftRunState(
        id: secondRun.id,
        status: ChapterDraftRunStatus.abandoned,
        errorMessage: '用户放弃本次 run。',
      );

      final count = await repository.markInterruptedRunsFailed();

      expect(count, 1);
      final failedRun = await repository.findChapterDraftRun(firstRun.id);
      expect(failedRun!.status, ChapterDraftRunStatus.failed);
      expect(failedRun.stage, isNull);
      expect(failedRun.errorMessage, '应用重启，任务已中断，可重跑。');

      final taskRepository = DriftWorkflowTaskRepository(database);
      final failedTask = await taskRepository.findTask(firstRun.workflowTaskId);
      expect(failedTask!.status, WorkflowTaskStatus.failed);
      final abandonedRun = await repository.findChapterDraftRun(secondRun.id);
      expect(abandonedRun!.status, ChapterDraftRunStatus.abandoned);
    },
  );

  test(
    'migration creates novel workshop tables at schema version 10',
    () async {
      final sqlite = sqlite3.openInMemory();
      addTearDown(sqlite.dispose);
      final createdAt = DateTime.utc(2026, 5, 16, 9).millisecondsSinceEpoch;
      final updatedAt = DateTime.utc(2026, 5, 16, 10).millisecondsSinceEpoch;

      _createSchemaVersion9(sqlite);
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
        id, title, description, status, default_provider_id,
        default_model_name, language, target_length, narrative_perspective,
        created_at, updated_at
      ) VALUES (
        'project-1', '旧项目', '', 'active', 'provider-1',
        'gpt-4.1-mini', '简体中文', 3000, '第三人称有限视角', ?, ?
      );
    ''',
        [createdAt, updatedAt],
      );
      sqlite.execute('PRAGMA user_version = 9;');

      final database = AppDatabase(
        NativeDatabase.opened(sqlite, closeUnderlyingOnClose: false),
      );
      addTearDown(database.close);
      final repository = DriftNovelWorkshopRepository(database);

      final bible = await repository.upsertStoryBible(
        const StoryBibleInput(
          projectId: 'project-1',
          worldMarkdown: '# World\n\n迁移后可写入。',
        ),
      );

      expect(bible.projectId, 'project-1');
      expect(bible.worldMarkdown, '# World\n\n迁移后可写入。');
    },
  );
}

Future<_NovelTestContext> _novelTestContext(AppDatabase database) async {
  final providerRepository = DriftProviderConfigRepository(database);
  await providerRepository.saveProvider(input: _providerInput());
  final provider = (await providerRepository.watchProviders().first).single;

  final projectRepository = DriftProjectRepository(database);
  await projectRepository.saveProject(
    input: WritingProjectInput(
      title: '雾港纪事',
      description: '潮湿港城里的长篇悬疑。',
      status: ProjectStatus.active,
      defaultProviderId: provider.id,
      defaultModelName: provider.defaultModel,
      language: '简体中文',
      targetLength: 3200,
      narrativePerspective: '第三人称有限视角',
    ),
  );
  final project =
      (await projectRepository.watchProjects(ProjectStatus.active).first)
          .single;

  return _NovelTestContext(
    provider: provider,
    projectId: project.id,
    projectRepository: projectRepository,
    repository: DriftNovelWorkshopRepository(database),
  );
}

Future<ChapterPlan> _savePlan(
  DriftNovelWorkshopRepository repository,
  String projectId,
) {
  return repository.saveChapterPlan(
    input: ChapterPlanInput(
      projectId: projectId,
      chapterIndex: 1,
      title: '第一章',
      goal: '引出港口停电事件',
      targetBeat: '主角发现第一条线索',
      mustInclude: '黑伞人',
      mustAvoid: '揭露真凶',
      hook: '章末出现失踪者短信',
      payoff: '回收开场的钟声',
    ),
  );
}

Future<ChapterDraftRun> _createRun(
  DriftNovelWorkshopRepository repository,
  _NovelTestContext context,
  String chapterPlanId,
) {
  return repository.createChapterDraftRun(
    ChapterDraftRunInput(
      projectId: context.projectId,
      chapterPlanId: chapterPlanId,
      providerId: context.provider.id,
      modelName: context.provider.defaultModel,
    ),
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

class _NovelTestContext {
  const _NovelTestContext({
    required this.provider,
    required this.projectId,
    required this.projectRepository,
    required this.repository,
  });

  final ProviderConfig provider;
  final String projectId;
  final DriftProjectRepository projectRepository;
  final DriftNovelWorkshopRepository repository;
}

void _createSchemaVersion9(Database sqlite) {
  sqlite.execute('''
    CREATE TABLE workflow_task_records (
      id TEXT NOT NULL PRIMARY KEY,
      kind TEXT NOT NULL,
      status TEXT NOT NULL,
      title TEXT NOT NULL,
      stage TEXT,
      error_message TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  ''');
  sqlite.execute('''
    CREATE TABLE workflow_prompt_trace_records (
      workflow_task_id TEXT NOT NULL PRIMARY KEY REFERENCES workflow_task_records(id),
      trace_markdown TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
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
      default_provider_id TEXT,
      default_model_name TEXT,
      style_profile_id TEXT,
      plot_profile_id TEXT,
      language TEXT NOT NULL DEFAULT '简体中文',
      target_length INTEGER NOT NULL DEFAULT 3000,
      narrative_perspective TEXT NOT NULL DEFAULT '第三人称有限视角',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  ''');
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
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
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
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      started_at TEXT,
      completed_at TEXT
    );
  ''');
  sqlite.execute('''
    CREATE TABLE style_profile_records (
      id TEXT NOT NULL PRIMARY KEY,
      source_run_id TEXT NOT NULL UNIQUE REFERENCES style_analysis_run_records(id),
      provider_id TEXT NOT NULL REFERENCES provider_config_records(id),
      model_name TEXT NOT NULL,
      style_name TEXT NOT NULL,
      profile_markdown TEXT NOT NULL,
      analysis_report_markdown TEXT NOT NULL,
      project_id TEXT REFERENCES project_records(id),
      source_sample_id TEXT REFERENCES style_sample_records(id),
      source_title TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
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
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
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
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      started_at TEXT,
      completed_at TEXT
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
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  ''');
}
