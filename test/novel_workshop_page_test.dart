import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/novel_workshop_providers.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/accepted_chapter.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/chapter_draft_run.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/chapter_plan.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/memory_projection.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_workshop_repository.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/story_bible.dart';
import 'package:persona_flutter/src/features/novel_workshop/presentation/novel_workshop_page.dart';
import 'package:persona_flutter/src/features/plot_lab/application/plot_lab_providers.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_profile.dart';
import 'package:persona_flutter/src/features/projects/application/project_providers.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';
import 'package:persona_flutter/src/features/settings/application/provider_config_providers.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:persona_flutter/src/features/style_lab/application/style_lab_providers.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_profile.dart';

void main() {
  testWidgets('workshop empty state creates a chapter plan', (tester) async {
    final repository = _FakeNovelWorkshopRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(_WorkshopTestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('还没有章节计划'), findsOneWidget);

    await tester.tap(find.text('创建第 1 章'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, '标题'), '雨夜来信');
    await tester.enterText(
      find.widgetWithText(TextFormField, '本章目标'),
      '主角收到第一封匿名信。',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, '核心剧情拍点'),
      '港口停电后发现旧案线索。',
    );
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();

    expect(find.text('雨夜来信'), findsWidgets);
    expect(find.text('主角收到第一封匿名信。'), findsOneWidget);
    expect(repository.plans, hasLength(1));
  });

  testWidgets('workshop edits and deletes a chapter plan', (tester) async {
    final repository = _FakeNovelWorkshopRepository([
      _chapterPlan(id: 'plan-1', title: '第一章', goal: '旧目标'),
    ]);
    addTearDown(repository.dispose);

    await tester.pumpWidget(_WorkshopTestApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('编辑计划'));
    await tester.tap(find.text('编辑计划'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, '标题'), '第一章 修订');
    await tester.enterText(
      find.widgetWithText(TextFormField, '本章目标'),
      '修订后的目标',
    );
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();

    expect(find.textContaining('第一章 修订'), findsWidgets);
    expect(find.text('修订后的目标'), findsOneWidget);
    expect(repository.plans.single.title, '第一章 修订');

    await tester.tap(find.widgetWithText(OutlinedButton, '删除'));
    await tester.pumpAndSettle();
    expect(find.text('删除章节计划'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();

    expect(repository.plans, isEmpty);
    expect(find.text('还没有章节计划'), findsOneWidget);
  });

  testWidgets('workshop renders missing project state', (tester) async {
    final repository = _FakeNovelWorkshopRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(repository: repository, missingProject: true),
    );
    await tester.pumpAndSettle();

    expect(find.text('项目不存在'), findsOneWidget);
    expect(find.text('没有找到对应的项目记录。'), findsOneWidget);
  });
}

class _WorkshopTestApp extends StatelessWidget {
  const _WorkshopTestApp({
    required this.repository,
    this.missingProject = false,
  });

  final _FakeNovelWorkshopRepository repository;
  final bool missingProject;

  @override
  Widget build(BuildContext context) {
    final effectiveProject = missingProject ? null : _testProject;
    return ProviderScope(
      overrides: [
        writingProjectProvider.overrideWith(
          (ref, id) => Stream<WritingProject?>.value(effectiveProject),
        ),
        novelWorkshopRepositoryProvider.overrideWithValue(repository),
        providerConfigsProvider.overrideWith(
          (ref) => Stream<List<ProviderConfig>>.value([_provider()]),
        ),
        styleProfilesProvider.overrideWith(
          (ref) => Stream<List<StyleProfile>>.value([_styleProfile()]),
        ),
        plotProfilesProvider.overrideWith(
          (ref) => Stream<List<PlotProfile>>.value([_plotProfile()]),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(body: NovelWorkshopPage(projectId: 'project-1')),
      ),
    );
  }
}

class _FakeNovelWorkshopRepository implements NovelWorkshopRepository {
  _FakeNovelWorkshopRepository([List<ChapterPlan>? initialPlans])
    : plans = [...?initialPlans];

  final List<ChapterPlan> plans;
  final _changes = StreamController<void>.broadcast();

  void dispose() {
    _changes.close();
  }

  void _notify() {
    _changes.add(null);
  }

  @override
  Stream<List<ChapterPlan>> watchChapterPlans(String projectId) async* {
    List<ChapterPlan> snapshot() {
      final filtered = plans
          .where((plan) => plan.projectId == projectId)
          .toList(growable: false);
      filtered.sort((a, b) => a.chapterIndex.compareTo(b.chapterIndex));
      return filtered;
    }

    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }

  @override
  Future<List<ChapterPlan>> findChapterPlans(String projectId) async {
    return plans.where((plan) => plan.projectId == projectId).toList();
  }

  @override
  Stream<ChapterPlan?> watchChapterPlan(String id) {
    return Stream<ChapterPlan?>.value(
      plans.where((plan) => plan.id == id).firstOrNull,
    );
  }

  @override
  Future<ChapterPlan?> findChapterPlan(String id) async {
    return plans.where((plan) => plan.id == id).firstOrNull;
  }

  @override
  Future<ChapterPlan> saveChapterPlan({
    String? id,
    required ChapterPlanInput input,
  }) async {
    final existingIndex = id == null
        ? -1
        : plans.indexWhere((plan) => plan.id == id);
    final now = DateTime(2026, 5, 17, 12);
    final plan = ChapterPlan(
      id: id ?? 'plan-${plans.length + 1}',
      projectId: input.projectId,
      chapterIndex: input.chapterIndex,
      title: input.title,
      goal: input.goal,
      targetBeat: input.targetBeat,
      mustInclude: input.mustInclude,
      mustAvoid: input.mustAvoid,
      hook: input.hook,
      payoff: input.payoff,
      status: input.status,
      createdAt: existingIndex == -1 ? now : plans[existingIndex].createdAt,
      updatedAt: now,
    );

    if (existingIndex == -1) {
      plans.add(plan);
    } else {
      plans[existingIndex] = plan;
    }
    _notify();
    return plan;
  }

  @override
  Future<void> deleteChapterPlan(String id) async {
    plans.removeWhere((plan) => plan.id == id);
    _notify();
  }

  @override
  Stream<List<AcceptedChapter>> watchAcceptedChapters(String projectId) {
    return Stream<List<AcceptedChapter>>.value(const []);
  }

  @override
  Stream<StoryBible?> watchStoryBible(String projectId) {
    return Stream<StoryBible?>.value(null);
  }

  @override
  Stream<MemoryProjection?> watchMemoryProjection(String projectId) {
    return Stream<MemoryProjection?>.value(null);
  }

  @override
  Future<int> markInterruptedRunsFailed() async => 0;

  @override
  Future<StoryBible?> findStoryBible(String projectId) async => null;

  @override
  Future<StoryBible> upsertStoryBible(StoryBibleInput input) {
    throw UnimplementedError();
  }

  @override
  Stream<List<ChapterDraftRun>> watchChapterDraftRuns(String chapterPlanId) {
    return Stream<List<ChapterDraftRun>>.value(const []);
  }

  @override
  Stream<ChapterDraftRun?> watchChapterDraftRun(String id) {
    return Stream<ChapterDraftRun?>.value(null);
  }

  @override
  Future<ChapterDraftRun?> findChapterDraftRun(String id) async => null;

  @override
  Future<ChapterDraftRun> createChapterDraftRun(ChapterDraftRunInput input) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateChapterDraftRunState({
    required String id,
    required ChapterDraftRunStatus status,
    ChapterDraftRunStage? stage,
    String? errorMessage,
    String? logs,
    String? contractMarkdown,
    String? draftMarkdown,
    String? auditMarkdown,
    String? revisedMarkdown,
  }) async {}

  @override
  Stream<AcceptedChapter?> watchAcceptedChapterForPlan(String chapterPlanId) {
    return Stream<AcceptedChapter?>.value(null);
  }

  @override
  Future<AcceptedChapter?> findAcceptedChapterForPlan(
    String chapterPlanId,
  ) async {
    return null;
  }

  @override
  Future<AcceptedChapter> upsertAcceptedChapter(AcceptedChapterInput input) {
    throw UnimplementedError();
  }

  @override
  Future<MemoryProjection?> findMemoryProjection(String projectId) async =>
      null;

  @override
  Future<MemoryProjection> upsertMemoryProjection(MemoryProjectionInput input) {
    throw UnimplementedError();
  }
}

ChapterPlan _chapterPlan({
  required String id,
  required String title,
  required String goal,
}) {
  return ChapterPlan(
    id: id,
    projectId: 'project-1',
    chapterIndex: 1,
    title: title,
    goal: goal,
    targetBeat: '核心拍点',
    mustInclude: '必须包含',
    mustAvoid: '必须避免',
    hook: '章末钩子',
    payoff: '伏笔回收',
    status: ChapterPlanStatus.planned,
    createdAt: DateTime(2026, 5, 17, 9),
    updatedAt: DateTime(2026, 5, 17, 10),
  );
}

final _testProject = WritingProject(
  id: 'project-1',
  title: '雾港纪事',
  description: '潮湿港城里的长篇悬疑。',
  status: ProjectStatus.active,
  defaultProviderId: 'provider-1',
  defaultModelName: 'gpt-4.1-mini',
  styleProfileId: 'style-profile-1',
  plotProfileId: 'plot-profile-1',
  createdAt: DateTime(2026, 5, 17, 9),
  updatedAt: DateTime(2026, 5, 17, 10),
);

ProviderConfig _provider() {
  return ProviderConfig(
    id: 'provider-1',
    name: 'OpenAI',
    baseUrl: 'https://api.example.com/v1',
    apiKey: 'sk-test',
    defaultModel: 'gpt-4.1-mini',
    modelNames: const ['gpt-4.1-mini'],
    systemPrompt: '',
    isEnabled: true,
    testStatus: ProviderTestStatus.untested,
    createdAt: DateTime(2026, 5, 17, 9),
    updatedAt: DateTime(2026, 5, 17, 10),
  );
}

StyleProfile _styleProfile() {
  return StyleProfile(
    id: 'style-profile-1',
    sourceRunId: 'style-run-1',
    providerId: 'provider-1',
    modelName: 'gpt-4.1-mini',
    styleName: '冷峻悬疑风格',
    profileMarkdown: '# Voice Profile',
    analysisReportMarkdown: '# Report',
    createdAt: DateTime(2026, 5, 17, 9),
    updatedAt: DateTime(2026, 5, 17, 10),
  );
}

PlotProfile _plotProfile() {
  return PlotProfile(
    id: 'plot-profile-1',
    sourceRunId: 'plot-run-1',
    providerId: 'provider-1',
    modelName: 'gpt-4.1-mini',
    plotName: '港城悬疑引擎',
    storyEngineMarkdown: '# Plot Writing Guide',
    analysisReportMarkdown: '# Report',
    plotSkeletonMarkdown: '# Skeleton',
    createdAt: DateTime(2026, 5, 17, 9),
    updatedAt: DateTime(2026, 5, 17, 10),
  );
}
