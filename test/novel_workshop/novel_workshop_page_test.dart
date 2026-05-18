import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/chapter_generation_pipeline.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/novel_workshop_providers.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_workshop.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_workshop_repository.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/writing_context.dart';
import 'package:persona_flutter/src/features/novel_workshop/presentation/novel_workshop_page.dart';
import 'package:persona_flutter/src/features/plot_lab/application/plot_lab_providers.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_lab_repository.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_profile.dart';
import 'package:persona_flutter/src/features/projects/application/project_providers.dart';
import 'package:persona_flutter/src/features/projects/domain/project_repository.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';
import 'package:persona_flutter/src/features/settings/application/provider_config_providers.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config_repository.dart';
import 'package:persona_flutter/src/features/style_lab/application/style_lab_providers.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_lab_repository.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_profile.dart';

const _workshopLocation = '/projects/project-1/workshop';
const _editorLocation = '/projects/project-1/workshop/editor';

void main() {
  testWidgets('workshop shows tabbed workbench with asset tabs', (tester) async {
    final fixture = _WorkshopFixture();
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    expect(find.text('项目工作台'), findsOneWidget);
    expect(find.text('项目概览'), findsWidgets);
    expect(find.text('Voice Profile'), findsWidgets);
    expect(find.text('Story Engine'), findsWidgets);
    expect(find.text('骨架大纲'), findsWidgets);
    expect(find.text('章节计划'), findsWidgets);
    expect(find.text('进入编辑器'), findsOneWidget);
    expect(find.byKey(const ValueKey('novel-workshop-editor')), findsNothing);
  });

  testWidgets('workshop creates chapter plan from chapter planning tab', (
    tester,
  ) async {
    final fixture = _WorkshopFixture();
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    // Switch to the chapter planning tab first.
    await tester.tap(find.text('章节计划').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('新建章节').first);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('新建章节目标卡'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, '章节标题'), '第一章');
    await tester.enterText(
      find.widgetWithText(TextFormField, '章节目标'),
      '主角进入雾港。',
    );
    await tester.ensureVisible(find.widgetWithText(FilledButton, '保存'));
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('第一章'), findsWidgets);
    expect(fixture.repository.plans.single.chapterIndex, 1);
  });

  testWidgets('editor loads from workshop sub-route', (tester) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    await tester.tap(find.text('进入编辑器'));
    await tester.pumpAndSettle();

    expect(find.text('创作导航'), findsOneWidget);
    expect(find.byKey(const ValueKey('novel-workshop-editor')), findsOneWidget);
  });

  testWidgets('editor back button navigates to workshop', (tester) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
    );
    await tester.pumpAndSettle();

    expect(find.text('创作导航'), findsOneWidget);

    await tester.tap(find.byTooltip('返回工作台'));
    await tester.pumpAndSettle();

    expect(find.text('项目工作台'), findsOneWidget);
  });

  testWidgets('editing chapter plan keeps chapter index readonly', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('编辑目标'));
    await tester.pumpAndSettle();

    final indexField = tester.widget<TextField>(
      find.descendant(
        of: find.widgetWithText(TextFormField, '第 1 章').first,
        matching: find.byType(TextField),
      ),
    );
    expect(indexField.readOnly, isTrue);
  });

  testWidgets('existing chapter generation asks for overwrite confirmation', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
      chapters: [_chapter(planId: 'plan-1', index: 1, content: '旧正文。')],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('生成章节'));
    await tester.pumpAndSettle();

    expect(find.text('覆盖已有正文'), findsOneWidget);

    await tester.tap(find.text('确认覆盖'));
    await tester.pumpAndSettle();

    expect(fixture.pipeline.replaceExisting, isTrue);
    expect(fixture.pipeline.generateCalls, 1);
  });

  testWidgets('dirty editor asks before switching chapters and can save', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
        _plan(id: 'plan-2', index: 2, title: '第二章', objective: '主角追查线索。'),
      ],
      chapters: [_chapter(planId: 'plan-1', index: 1, content: '旧正文。')],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('novel-workshop-editor')),
      '修改后的正文。',
    );
    await tester.tap(find.textContaining('第二章').first);
    await tester.pumpAndSettle();

    expect(find.text('正文尚未保存'), findsOneWidget);

    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(
      fixture.repository.chapters
          .singleWhere((chapter) => chapter.chapterPlanId == 'plan-1')
          .contentMarkdown,
      '修改后的正文。',
    );
    expect(find.text('第二章'), findsWidgets);
  });

  testWidgets(
    'running generation disables selected chapter save and generate',
    (tester) async {
      final fixture = _WorkshopFixture(
        plans: [
          _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
        ],
        runs: [_run(planId: 'plan-1', status: ChapterGenerationStatus.running)],
      );
      addTearDown(fixture.dispose);

      await tester.pumpWidget(
        _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
      );
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, '保存正文'))
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, '生成章节'))
            .onPressed,
        isNull,
      );
      expect(find.text('生成中'), findsOneWidget);
    },
  );

  testWidgets('run summary links to workflow detail route', (tester) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
      runs: [
        _run(
          id: 'run-1',
          workflowTaskId: 'task-1',
          planId: 'plan-1',
          status: ChapterGenerationStatus.succeeded,
        ),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('查看 Prompt Trace'));
    await tester.tap(find.text('查看 Prompt Trace'));
    await tester.pumpAndSettle();

    expect(find.text('workflow:task-1'), findsOneWidget);
  });

  testWidgets(
    'compact editor stacks inspector below editor without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fixture = _WorkshopFixture(
        plans: [
          _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
        ],
      );
      addTearDown(fixture.dispose);

      await tester.pumpWidget(
        _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
      );
      await tester.pumpAndSettle();

      expect(find.text('创作导航'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('novel-workshop-editor')),
        findsOneWidget,
      );
      expect(find.text('工作流诊断'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

class _WorkshopTestApp extends StatelessWidget {
  const _WorkshopTestApp({
    required this.fixture,
    this.initialLocation = _workshopLocation,
  });

  final _WorkshopFixture fixture;
  final String initialLocation;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        projectRepositoryProvider.overrideWithValue(fixture.projectRepository),
        providerConfigRepositoryProvider.overrideWithValue(
          fixture.providerRepository,
        ),
        novelWorkshopRepositoryProvider.overrideWithValue(fixture.repository),
        chapterGenerationPipelineProvider.overrideWithValue(fixture.pipeline),
        styleLabRepositoryProvider.overrideWithValue(fixture.styleRepository),
        plotLabRepositoryProvider.overrideWithValue(fixture.plotRepository),
      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: initialLocation,
          routes: [
            GoRoute(
              path: '/projects/:projectId/workshop',
              builder: (context, state) => NovelWorkshopPage(
                projectId: state.pathParameters['projectId']!,
              ),
              routes: [
                GoRoute(
                  path: 'editor',
                  builder: (context, state) => NovelEditorPage(
                    projectId: state.pathParameters['projectId']!,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: '/projects',
              builder: (context, state) => const Text('projects'),
            ),
            GoRoute(
              path: '/workflow-runs/:taskId',
              builder: (context, state) =>
                  Text('workflow:${state.pathParameters['taskId']}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkshopFixture {
  _WorkshopFixture({
    ProjectStatus projectStatus = ProjectStatus.active,
    List<ChapterPlan> plans = const [],
    List<ProjectChapter> chapters = const [],
    List<ChapterGenerationRun> runs = const [],
  }) : projectRepository = _FakeProjectRepository(status: projectStatus),
       repository = _FakeNovelWorkshopRepository(
         plans: plans,
         chapters: chapters,
         runs: runs,
       ),
       styleRepository = _FakeStyleLabRepository(),
       plotRepository = _FakePlotLabRepository() {
    pipeline = _FakeChapterGenerationPipeline(repository);
  }

  final _FakeProjectRepository projectRepository;
  final _FakeProviderConfigRepository providerRepository =
      _FakeProviderConfigRepository();
  final _FakeNovelWorkshopRepository repository;
  final _FakeStyleLabRepository styleRepository;
  final _FakePlotLabRepository plotRepository;
  late final _FakeChapterGenerationPipeline pipeline;

  void dispose() {
    projectRepository.dispose();
    providerRepository.dispose();
    repository.dispose();
  }
}

class _FakeChapterGenerationPipeline implements ChapterGenerationPipeline {
  _FakeChapterGenerationPipeline(this.repository);

  final _FakeNovelWorkshopRepository repository;
  int generateCalls = 0;
  bool? replaceExisting;

  @override
  Future<ChapterGenerationResult> generateChapter({
    required String projectId,
    required String chapterPlanId,
    bool replaceExisting = false,
  }) async {
    generateCalls += 1;
    this.replaceExisting = replaceExisting;
    final plan = repository.plans.singleWhere(
      (item) => item.id == chapterPlanId,
    );
    final existing = await repository.findChapterByPlan(chapterPlanId);
    final chapter = await repository.saveChapter(
      id: existing?.id,
      input: ProjectChapterInput(
        projectId: projectId,
        chapterPlanId: chapterPlanId,
        chapterIndex: plan.chapterIndex,
        title: plan.objectiveCard.chapterTitle,
        contentMarkdown: '生成正文。',
      ),
    );
    final run = _run(
      id: 'run-generated',
      workflowTaskId: 'task-generated',
      planId: chapterPlanId,
      status: ChapterGenerationStatus.succeeded,
      chapterId: chapter.id,
    );
    repository.runs.add(run);
    repository.emit();
    return ChapterGenerationResult(
      run: run,
      chapter: chapter,
      contextWarnings: const [],
      workflowTaskId: run.workflowTaskId,
    );
  }
}

class _FakeProjectRepository implements ProjectRepository {
  _FakeProjectRepository({ProjectStatus status = ProjectStatus.active}) {
    _project = WritingProject(
      id: 'project-1',
      title: '雾港纪事',
      description: '项目简介',
      status: status,
      defaultProviderId: 'provider-1',
      defaultModelName: 'gpt-4.1-mini',
      styleProfileId: 'style-1',
      plotProfileId: 'plot-1',
      createdAt: DateTime(2026, 5, 18, 9),
      updatedAt: DateTime(2026, 5, 18, 10),
    );
  }

  final _changes = StreamController<void>.broadcast();
  late WritingProject _project;

  WritingProject get project => _project;

  void dispose() {
    _changes.close();
  }

  @override
  Future<void> deleteProject(String id) async {}

  @override
  Future<WritingProject?> findProject(String id) async {
    return id == _project.id ? _project : null;
  }

  @override
  Future<void> saveProject({
    String? id,
    required WritingProjectInput input,
  }) async {
    _project = WritingProject(
      id: id ?? _project.id,
      title: input.title,
      description: input.description,
      status: input.status,
      defaultProviderId: input.defaultProviderId,
      defaultModelName: input.defaultModelName,
      styleProfileId: input.styleProfileId,
      plotProfileId: input.plotProfileId,
      language: input.language,
      targetLength: input.targetLength,
      narrativePerspective: input.narrativePerspective,
      createdAt: _project.createdAt,
      updatedAt: DateTime(2026, 5, 18, 12),
    );
    _changes.add(null);
  }

  @override
  Future<void> updateStatus({
    required String id,
    required ProjectStatus status,
  }) async {}

  @override
  Stream<WritingProject?> watchProject(String id) async* {
    yield id == _project.id ? _project : null;
    yield* _changes.stream.map((_) => id == _project.id ? _project : null);
  }

  @override
  Stream<List<WritingProject>> watchProjects(ProjectStatus status) async* {
    yield status == _project.status ? [_project] : const [];
  }
}

class _FakeProviderConfigRepository implements ProviderConfigRepository {
  _FakeProviderConfigRepository() {
    _providers = [
      ProviderConfig(
        id: 'provider-1',
        name: 'OpenAI',
        baseUrl: 'https://api.example.com/v1',
        apiKey: 'sk-test',
        defaultModel: 'gpt-4.1-mini',
        modelNames: const ['gpt-4.1-mini', 'gpt-4.1'],
        systemPrompt: '',
        isEnabled: true,
        testStatus: ProviderTestStatus.untested,
        createdAt: DateTime(2026, 5, 18, 9),
        updatedAt: DateTime(2026, 5, 18, 10),
      ),
    ];
  }

  final _changes = StreamController<void>.broadcast();
  late final List<ProviderConfig> _providers;

  void dispose() {
    _changes.close();
  }

  @override
  Future<void> deleteProvider(String id) async {}

  @override
  Future<ProviderConfig?> findProvider(String id) async {
    return _providers.where((provider) => provider.id == id).firstOrNull;
  }

  @override
  Future<void> saveProvider({
    String? id,
    required ProviderConfigInput input,
  }) async {}

  @override
  Future<void> updateSystemPrompt({
    required String id,
    required String systemPrompt,
  }) async {}

  @override
  Future<void> updateTestResult({
    required String id,
    required ProviderTestStatus status,
    required DateTime testedAt,
    String? message,
  }) async {}

  @override
  Stream<List<ProviderConfig>> watchProviders() async* {
    yield _providers;
    yield* _changes.stream.map((_) => _providers);
  }

  @override
  Stream<ProviderConfig?> watchProvider(String id) async* {
    yield _providers.where((provider) => provider.id == id).firstOrNull;
    yield* _changes.stream.map(
      (_) => _providers.where((provider) => provider.id == id).firstOrNull,
    );
  }
}

class _FakeNovelWorkshopRepository implements NovelWorkshopRepository {
  _FakeNovelWorkshopRepository({
    required List<ChapterPlan> plans,
    required List<ProjectChapter> chapters,
    required List<ChapterGenerationRun> runs,
  }) : plans = [...plans],
       chapters = [...chapters],
       runs = [...runs];

  final List<ChapterPlan> plans;
  final List<ProjectChapter> chapters;
  final List<ChapterGenerationRun> runs;
  final _changes = StreamController<void>.broadcast();

  void emit() {
    _changes.add(null);
  }

  void dispose() {
    _changes.close();
  }

  @override
  Future<void> clearRuntimeMemory(String projectId) async {}

  @override
  Future<ChapterGenerationRun> createChapterGenerationRun(
    ChapterGenerationRunInput input,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<ChapterPlan?> findChapterPlan(String id) async {
    return plans.where((plan) => plan.id == id).firstOrNull;
  }

  @override
  Future<ProjectChapter?> findChapter(String id) async {
    return chapters.where((chapter) => chapter.id == id).firstOrNull;
  }

  @override
  Future<ProjectChapter?> findChapterByPlan(String chapterPlanId) async {
    return chapters
        .where((chapter) => chapter.chapterPlanId == chapterPlanId)
        .firstOrNull;
  }

  @override
  Future<ChapterGenerationRun?> findChapterGenerationRun(String id) async {
    return runs.where((run) => run.id == id).firstOrNull;
  }

  @override
  Future<ProjectRuntimeMemory?> findRuntimeMemory(String projectId) async {
    return await ensureRuntimeMemory(projectId);
  }

  @override
  Future<ProjectRuntimeMemory> ensureRuntimeMemory(String projectId) async {
    return ProjectRuntimeMemory(
      projectId: projectId,
      state: const RuntimeMemoryState(storySummary: '林岚追查失踪案。'),
      createdAt: DateTime(2026, 5, 18, 9),
      updatedAt: DateTime(2026, 5, 18, 10),
    );
  }

  @override
  Future<bool> hasRunningChapterGeneration(String chapterPlanId) async {
    return runs.any(
      (run) =>
          run.chapterPlanId == chapterPlanId &&
          (run.status == ChapterGenerationStatus.pending ||
              run.status == ChapterGenerationStatus.running),
    );
  }

  @override
  Future<ProjectChapter> saveChapter({
    String? id,
    required ProjectChapterInput input,
  }) async {
    final existingIndex = id == null
        ? -1
        : chapters.indexWhere((chapter) => chapter.id == id);
    final saved = _chapter(
      id: id ?? 'chapter-${input.chapterPlanId}',
      planId: input.chapterPlanId,
      index: input.chapterIndex,
      title: input.title,
      content: input.contentMarkdown,
    );
    if (existingIndex == -1) {
      chapters.add(saved);
    } else {
      chapters[existingIndex] = saved;
    }
    emit();
    return saved;
  }

  @override
  Future<ChapterPlan> saveChapterPlan({
    String? id,
    required ChapterPlanInput input,
  }) async {
    if (input.chapterIndex <= 0 || input.objectiveCard.isEmpty) {
      throw StateError('章节目标卡不能为空。');
    }
    final existingIndex = id == null
        ? -1
        : plans.indexWhere((plan) => plan.id == id);
    final saved = ChapterPlan(
      id: id ?? 'plan-${plans.length + 1}',
      projectId: input.projectId,
      chapterIndex: input.chapterIndex,
      objectiveCard: input.objectiveCard,
      createdAt: existingIndex == -1
          ? DateTime(2026, 5, 18, 9)
          : plans[existingIndex].createdAt,
      updatedAt: DateTime(2026, 5, 18, 10),
    );
    if (existingIndex == -1) {
      plans.add(saved);
    } else {
      plans[existingIndex] = saved;
    }
    plans.sort((a, b) => a.chapterIndex.compareTo(b.chapterIndex));
    emit();
    return saved;
  }

  @override
  Future<ProjectChapter> saveMemorySyncProposal(
    MemorySyncProposalInput input,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<ProjectRuntimeMemory> saveRuntimeMemory({
    required String projectId,
    required RuntimeMemoryState state,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ChapterGenerationRun> updateChapterGenerationRunState({
    required String id,
    required ChapterGenerationStatus status,
    ChapterGenerationStage? stage,
    String? chapterId,
    String? providerId,
    String? modelName,
    String? errorMessage,
    String? logs,
    String? contextWarningsMarkdown,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    throw UnimplementedError();
  }

  @override
  Stream<List<ChapterGenerationRun>> watchChapterGenerationRuns(
    String projectId,
  ) async* {
    List<ChapterGenerationRun> snapshot() =>
        runs.where((run) => run.projectId == projectId).toList(growable: false);
    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }

  @override
  Stream<ChapterGenerationRun?> watchChapterGenerationRunByWorkflowTask(
    String workflowTaskId,
  ) async* {
    yield runs.where((run) => run.workflowTaskId == workflowTaskId).firstOrNull;
  }

  @override
  Stream<List<ChapterPlan>> watchChapterPlans(String projectId) async* {
    List<ChapterPlan> snapshot() => plans
        .where((plan) => plan.projectId == projectId)
        .toList(growable: false);
    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }

  @override
  Stream<List<ProjectChapter>> watchChapters(String projectId) async* {
    List<ProjectChapter> snapshot() => chapters
        .where((chapter) => chapter.projectId == projectId)
        .toList(growable: false);
    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }
}

class _FakeStyleLabRepository implements StyleLabRepository {
  @override
  Future<StyleProfile?> findProfile(String id) async {
    if (id != 'style-1') return null;
    return StyleProfile(
      id: id,
      sourceRunId: 'style-run',
      providerId: 'provider-1',
      modelName: 'gpt-4.1-mini',
      styleName: '冷峻悬疑风格',
      profileMarkdown: '# Voice Profile',
      analysisReportMarkdown: '# Report',
      createdAt: DateTime(2026, 5, 18, 9),
      updatedAt: DateTime(2026, 5, 18, 10),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlotLabRepository implements PlotLabRepository {
  @override
  Future<PlotProfile?> findProfile(String id) async {
    if (id != 'plot-1') return null;
    return PlotProfile(
      id: id,
      sourceRunId: 'plot-run',
      providerId: 'provider-1',
      modelName: 'gpt-4.1-mini',
      plotName: '港城悬疑引擎',
      storyEngineMarkdown: '# Plot Writing Guide',
      analysisReportMarkdown: '# Report',
      plotSkeletonMarkdown: '# Skeleton',
      createdAt: DateTime(2026, 5, 18, 9),
      updatedAt: DateTime(2026, 5, 18, 10),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ChapterPlan _plan({
  required String id,
  required int index,
  required String title,
  required String objective,
}) {
  return ChapterPlan(
    id: id,
    projectId: 'project-1',
    chapterIndex: index,
    objectiveCard: ChapterObjectiveCard(
      chapterTitle: title,
      objective: objective,
      pressureSource: '追兵逼近。',
      payoffTarget: '找到线索。',
      relationshipShift: '主角与向导合作。',
      hookType: '信息差钩子。',
    ),
    createdAt: DateTime(2026, 5, 18, 9),
    updatedAt: DateTime(2026, 5, 18, 10),
  );
}

ProjectChapter _chapter({
  String id = 'chapter-1',
  required String planId,
  required int index,
  String title = '第一章',
  required String content,
}) {
  return ProjectChapter(
    id: id,
    projectId: 'project-1',
    chapterPlanId: planId,
    chapterIndex: index,
    title: title,
    contentMarkdown: content,
    contentHash: content.hashCode.toString(),
    continuityVerdict: ContinuityVerdict.pass,
    continuityReportMarkdown: '',
    memorySyncStatus: MemorySyncStatus.idle,
    memorySyncContentHash: '',
    memorySyncProposedCharactersStatus: '',
    memorySyncProposedRuntimeState: '',
    memorySyncProposedRuntimeThreads: '',
    memorySyncProposedStorySummary: '',
    createdAt: DateTime(2026, 5, 18, 9),
    updatedAt: DateTime(2026, 5, 18, 10),
  );
}

ChapterGenerationRun _run({
  String id = 'run-1',
  String workflowTaskId = 'task-1',
  required String planId,
  required ChapterGenerationStatus status,
  String? chapterId,
}) {
  return ChapterGenerationRun(
    id: id,
    workflowTaskId: workflowTaskId,
    projectId: 'project-1',
    chapterPlanId: planId,
    chapterId: chapterId,
    providerId: 'provider-1',
    modelName: 'gpt-4.1-mini',
    status: status,
    stage: status == ChapterGenerationStatus.running
        ? ChapterGenerationStage.generatingDraft
        : null,
    errorMessage: null,
    logs: '章节生成完成。',
    contextWarningsMarkdown: '',
    createdAt: DateTime(2026, 5, 18, 9),
    updatedAt: DateTime(2026, 5, 18, 10),
    startedAt: DateTime(2026, 5, 18, 9),
    completedAt: status == ChapterGenerationStatus.running
        ? null
        : DateTime(2026, 5, 18, 10),
  );
}
