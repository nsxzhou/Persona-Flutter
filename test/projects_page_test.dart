import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/novel_workshop_providers.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/accepted_chapter.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/chapter_plan.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/memory_projection.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/story_bible.dart';
import 'package:persona_flutter/src/features/novel_workshop/presentation/novel_workshop_page.dart';
import 'package:persona_flutter/src/features/projects/application/project_providers.dart';
import 'package:persona_flutter/src/features/projects/domain/project_repository.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';
import 'package:persona_flutter/src/features/projects/presentation/project_detail_page.dart';
import 'package:persona_flutter/src/features/projects/presentation/projects_page.dart';
import 'package:persona_flutter/src/features/settings/application/provider_config_providers.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:persona_flutter/src/features/style_lab/application/style_lab_providers.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_profile.dart';
import 'package:persona_flutter/src/features/plot_lab/application/plot_lab_providers.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_profile.dart';

void main() {
  testWidgets('projects page shows empty active state with create entry', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          writingProjectsProvider.overrideWith(
            (ref, status) => Stream<List<WritingProject>>.value(const []),
          ),
          providerConfigsProvider.overrideWith(
            (ref) => Stream<List<ProviderConfig>>.value(const []),
          ),
          styleProfilesProvider.overrideWith(
            (ref) => Stream<List<StyleProfile>>.value(const []),
          ),
          plotProfilesProvider.overrideWith(
            (ref) => Stream<List<PlotProfile>>.value(const []),
          ),
        ],
        child: const MaterialApp(home: ProjectsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('尚未创建项目'), findsOneWidget);
    expect(find.text('新建项目'), findsWidgets);
    expect(find.text('活动'), findsWidgets);
    expect(find.text('本地状态'), findsNothing);
    expect(find.text('SQLite'), findsNothing);
    expect(find.text('筛选'), findsNothing);
  });

  testWidgets(
    'projects page hides archived projects until archived view is selected',
    (tester) async {
      final active = _project(
        id: 'active-project',
        title: '活动长篇',
        status: ProjectStatus.active,
      );
      final archived = _project(
        id: 'archived-project',
        title: '归档长篇',
        status: ProjectStatus.archived,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            writingProjectsProvider.overrideWith(
              (ref, status) => Stream<List<WritingProject>>.value([
                if (status == ProjectStatus.active) active,
                if (status == ProjectStatus.archived) archived,
              ]),
            ),
            providerConfigsProvider.overrideWith(
              (ref) => Stream<List<ProviderConfig>>.value([_provider()]),
            ),
            styleProfilesProvider.overrideWith(
              (ref) => Stream<List<StyleProfile>>.value(const []),
            ),
            plotProfilesProvider.overrideWith(
              (ref) => Stream<List<PlotProfile>>.value(const []),
            ),
          ],
          child: const MaterialApp(home: ProjectsPage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('活动长篇'), findsOneWidget);
      expect(find.text('归档长篇'), findsNothing);

      await tester.tap(find.text('归档').last);
      await tester.pumpAndSettle();

      expect(find.text('活动长篇'), findsNothing);
      expect(find.text('归档长篇'), findsOneWidget);
      expect(find.text('1 个档案'), findsOneWidget);
      expect(find.text('本地状态'), findsNothing);
      expect(find.text('SQLite'), findsNothing);
      expect(find.text('筛选'), findsNothing);
    },
  );

  testWidgets(
    'project archive action survives row removal after status change',
    (tester) async {
      final repository = _MutableProjectRepository([
        _project(
          id: 'active-project',
          title: '活动长篇',
          status: ProjectStatus.active,
        ),
      ]);
      addTearDown(repository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectRepositoryProvider.overrideWithValue(repository),
            providerConfigsProvider.overrideWith(
              (ref) => Stream<List<ProviderConfig>>.value([_provider()]),
            ),
            styleProfilesProvider.overrideWith(
              (ref) => Stream<List<StyleProfile>>.value(const []),
            ),
            plotProfilesProvider.overrideWith(
              (ref) => Stream<List<PlotProfile>>.value(const []),
            ),
          ],
          child: const MaterialApp(home: ProjectsPage()),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('活动长篇'), findsOneWidget);

      await tester.tap(find.byTooltip('项目操作'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('归档项目'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('活动长篇'), findsNothing);
      expect(find.text('尚未创建项目'), findsOneWidget);
    },
  );

  testWidgets('project detail page renders loaded project dossier', (
    tester,
  ) async {
    final project = _project(
      id: 'project-1',
      title: '雾港纪事',
      description: '潮湿港城里的长篇悬疑。',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          writingProjectProvider.overrideWith(
            (ref, id) => Stream<WritingProject?>.value(project),
          ),
          chapterPlansProvider.overrideWith(
            (ref, projectId) => Stream<List<ChapterPlan>>.value(const []),
          ),
          acceptedChaptersProvider.overrideWith(
            (ref, projectId) => Stream<List<AcceptedChapter>>.value(const []),
          ),
          storyBibleProvider.overrideWith(
            (ref, projectId) => Stream<StoryBible?>.value(null),
          ),
          memoryProjectionProvider.overrideWith(
            (ref, projectId) => Stream<MemoryProjection?>.value(null),
          ),
          providerConfigsProvider.overrideWith(
            (ref) => Stream<List<ProviderConfig>>.value([_provider()]),
          ),
          styleProfilesProvider.overrideWith(
            (ref) => Stream<List<StyleProfile>>.value(const []),
          ),
          plotProfilesProvider.overrideWith(
            (ref) => Stream<List<PlotProfile>>.value(const []),
          ),
        ],
        child: const MaterialApp(
          home: ProjectDetailPage(projectId: 'project-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('雾港纪事'), findsOneWidget);
    expect(find.text('潮湿港城里的长篇悬疑。'), findsWidgets);
    expect(find.text('项目控制台'), findsOneWidget);
    expect(find.text('进入章节工作台'), findsWidgets);
    expect(find.text('项目概要'), findsOneWidget);
    expect(find.text('OpenAI · gpt-4.1-mini'), findsWidgets);
    expect(find.text('未挂载 Style Profile。'), findsWidgets);
    expect(find.text('未挂载 Plot Profile。'), findsWidgets);
    expect(find.text('简体中文'), findsOneWidget);
    expect(find.text('3000 字'), findsOneWidget);
    expect(find.text('创作工作台'), findsOneWidget);
    expect(find.text('后续工作台入口'), findsNothing);
  });

  testWidgets('project detail routes to novel workshop', (tester) async {
    final project = _project(
      id: 'project-1',
      title: '雾港纪事',
      description: '潮湿港城里的长篇悬疑。',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          writingProjectProvider.overrideWith(
            (ref, id) => Stream<WritingProject?>.value(project),
          ),
          chapterPlansProvider.overrideWith(
            (ref, projectId) => Stream<List<ChapterPlan>>.value(const []),
          ),
          acceptedChaptersProvider.overrideWith(
            (ref, projectId) => Stream<List<AcceptedChapter>>.value(const []),
          ),
          storyBibleProvider.overrideWith(
            (ref, projectId) => Stream<StoryBible?>.value(null),
          ),
          memoryProjectionProvider.overrideWith(
            (ref, projectId) => Stream<MemoryProjection?>.value(null),
          ),
          providerConfigsProvider.overrideWith(
            (ref) => Stream<List<ProviderConfig>>.value([_provider()]),
          ),
          styleProfilesProvider.overrideWith(
            (ref) => Stream<List<StyleProfile>>.value(const []),
          ),
          plotProfilesProvider.overrideWith(
            (ref) => Stream<List<PlotProfile>>.value(const []),
          ),
        ],
        child: MaterialApp.router(routerConfig: _projectRouter()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '进入章节工作台').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();

    expect(find.text('章节工作台'), findsOneWidget);
    expect(find.text('还没有章节计划'), findsOneWidget);
  });

  testWidgets('project detail page renders invalid creative references', (
    tester,
  ) async {
    final project = _project(
      id: 'project-1',
      title: '雾港纪事',
      defaultProviderId: 'deleted-provider',
      defaultModelName: 'deleted-model',
      styleProfileId: 'deleted-style',
      plotProfileId: 'deleted-plot',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          writingProjectProvider.overrideWith(
            (ref, id) => Stream<WritingProject?>.value(project),
          ),
          chapterPlansProvider.overrideWith(
            (ref, projectId) => Stream<List<ChapterPlan>>.value(const []),
          ),
          acceptedChaptersProvider.overrideWith(
            (ref, projectId) => Stream<List<AcceptedChapter>>.value(const []),
          ),
          storyBibleProvider.overrideWith(
            (ref, projectId) => Stream<StoryBible?>.value(null),
          ),
          memoryProjectionProvider.overrideWith(
            (ref, projectId) => Stream<MemoryProjection?>.value(null),
          ),
          providerConfigsProvider.overrideWith(
            (ref) => Stream<List<ProviderConfig>>.value(const []),
          ),
          styleProfilesProvider.overrideWith(
            (ref) => Stream<List<StyleProfile>>.value(const []),
          ),
          plotProfilesProvider.overrideWith(
            (ref) => Stream<List<PlotProfile>>.value(const []),
          ),
        ],
        child: const MaterialApp(
          home: ProjectDetailPage(projectId: 'project-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Provider 已失效 · deleted-model'), findsWidgets);
    expect(find.text('Style Profile 已失效。'), findsWidgets);
    expect(find.text('Plot Profile 已失效。'), findsWidgets);
  });

  testWidgets('project dialog renders creative configuration fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          writingProjectsProvider.overrideWith(
            (ref, status) => Stream<List<WritingProject>>.value(const []),
          ),
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
        child: const MaterialApp(home: ProjectsPage()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('新建项目').first);
    await tester.pumpAndSettle();

    expect(find.text('创作配置'), findsOneWidget);
    expect(find.text('写作参数'), findsOneWidget);
    expect(find.text('默认 Provider'), findsOneWidget);
    expect(find.text('默认模型'), findsOneWidget);
    expect(find.text('Style Profile（可选）'), findsOneWidget);
    expect(find.text('Plot Profile（可选）'), findsOneWidget);
  });

  testWidgets('project dialog blocks save without provider configuration', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          writingProjectsProvider.overrideWith(
            (ref, status) => Stream<List<WritingProject>>.value(const []),
          ),
          providerConfigsProvider.overrideWith(
            (ref) => Stream<List<ProviderConfig>>.value(const []),
          ),
          styleProfilesProvider.overrideWith(
            (ref) => Stream<List<StyleProfile>>.value(const []),
          ),
          plotProfilesProvider.overrideWith(
            (ref) => Stream<List<PlotProfile>>.value(const []),
          ),
        ],
        child: const MaterialApp(home: ProjectsPage()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('新建项目').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('请先在 Settings 配置 Provider'), findsWidgets);
    final saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '保存').last,
    );
    expect(saveButton.onPressed, isNull);
  });

  testWidgets('project detail page handles missing project', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          writingProjectProvider.overrideWith(
            (ref, id) => Stream<WritingProject?>.value(null),
          ),
        ],
        child: const MaterialApp(
          home: ProjectDetailPage(projectId: 'missing-project'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('项目不存在'), findsOneWidget);
    expect(find.text('没有找到对应的项目记录。'), findsOneWidget);
  });
}

GoRouter _projectRouter() {
  return GoRouter(
    initialLocation: '/projects/project-1',
    routes: [
      GoRoute(
        path: '/projects/:projectId',
        builder: (context, state) =>
            ProjectDetailPage(projectId: state.pathParameters['projectId']!),
        routes: [
          GoRoute(
            path: 'workshop',
            builder: (context, state) => NovelWorkshopPage(
              projectId: state.pathParameters['projectId']!,
            ),
          ),
        ],
      ),
    ],
  );
}

WritingProject _project({
  required String id,
  required String title,
  String description = '项目简介',
  ProjectStatus status = ProjectStatus.active,
  String? defaultProviderId = 'provider-1',
  String? defaultModelName = 'gpt-4.1-mini',
  String? styleProfileId,
  String? plotProfileId,
}) {
  return WritingProject(
    id: id,
    title: title,
    description: description,
    status: status,
    defaultProviderId: defaultProviderId,
    defaultModelName: defaultModelName,
    styleProfileId: styleProfileId,
    plotProfileId: plotProfileId,
    createdAt: DateTime(2026, 5, 16, 9),
    updatedAt: DateTime(2026, 5, 16, 10),
  );
}

ProviderConfig _provider() {
  return ProviderConfig(
    id: 'provider-1',
    name: 'OpenAI',
    baseUrl: 'https://api.example.com/v1',
    apiKey: 'sk-test',
    defaultModel: 'gpt-4.1-mini',
    modelNames: const ['gpt-4.1-mini', 'gpt-4.1'],
    systemPrompt: '',
    isEnabled: true,
    testStatus: ProviderTestStatus.untested,
    createdAt: DateTime(2026, 5, 16, 9),
    updatedAt: DateTime(2026, 5, 16, 10),
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
    createdAt: DateTime(2026, 5, 16, 9),
    updatedAt: DateTime(2026, 5, 16, 10),
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
    createdAt: DateTime(2026, 5, 16, 9),
    updatedAt: DateTime(2026, 5, 16, 10),
  );
}

class _MutableProjectRepository implements ProjectRepository {
  _MutableProjectRepository(List<WritingProject> initialProjects)
    : _projects = [...initialProjects];

  final List<WritingProject> _projects;
  final _changes = StreamController<void>.broadcast();

  void dispose() {
    _changes.close();
  }

  @override
  Stream<List<WritingProject>> watchProjects(ProjectStatus status) async* {
    List<WritingProject> snapshot() => _projects
        .where((project) => project.status == status)
        .toList(growable: false);

    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }

  @override
  Stream<WritingProject?> watchProject(String id) async* {
    WritingProject? snapshot() =>
        _projects.where((project) => project.id == id).firstOrNull;

    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }

  @override
  Future<WritingProject?> findProject(String id) async {
    return _projects.where((project) => project.id == id).firstOrNull;
  }

  @override
  Future<void> saveProject({
    String? id,
    required WritingProjectInput input,
  }) async {
    final existingIndex = id == null
        ? -1
        : _projects.indexWhere((project) => project.id == id);
    final now = DateTime(2026, 5, 16, 12);
    final project = WritingProject(
      id: id ?? 'created-project',
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
      createdAt: existingIndex == -1 ? now : _projects[existingIndex].createdAt,
      updatedAt: now,
    );

    if (existingIndex == -1) {
      _projects.add(project);
    } else {
      _projects[existingIndex] = project;
    }
    _changes.add(null);
  }

  @override
  Future<void> updateStatus({
    required String id,
    required ProjectStatus status,
  }) async {
    final index = _projects.indexWhere((project) => project.id == id);
    if (index == -1) {
      return;
    }

    _projects[index] = _projects[index].copyWith(
      status: status,
      updatedAt: DateTime(2026, 5, 16, 12),
    );
    _changes.add(null);
    await Future<void>.delayed(Duration.zero);
  }

  @override
  Future<void> deleteProject(String id) async {
    _projects.removeWhere((project) => project.id == id);
    _changes.add(null);
  }
}
