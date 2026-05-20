import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_flutter/src/features/projects/application/project_providers.dart';
import 'package:persona_flutter/src/features/projects/domain/project_repository.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';
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

  testWidgets(
    'active project menu exposes workshop entry only for active rows',
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
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/projects',
              routes: [
                GoRoute(
                  path: '/projects',
                  builder: (context, state) => const ProjectsPage(),
                  routes: [
                    GoRoute(
                      path: ':projectId/workshop',
                      builder: (context, state) =>
                          Text('workshop:${state.pathParameters['projectId']}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('项目操作'));
      await tester.pumpAndSettle();

      expect(find.text('打开工作台'), findsOneWidget);

      await tester.tap(find.text('打开工作台'));
      await tester.pumpAndSettle();

      expect(find.text('workshop:active-project'), findsOneWidget);

      GoRouter.of(
        tester.element(find.text('workshop:active-project')),
      ).go('/projects');
      await tester.pumpAndSettle();
      await tester.tap(find.text('归档').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('项目操作'));
      await tester.pumpAndSettle();

      expect(find.text('打开工作台'), findsNothing);
    },
  );

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
  Future<WritingProject> createProject(WritingProjectInput input) async {
    await saveProject(id: 'created-project', input: input);
    final project = await findProject('created-project');
    if (project == null) {
      throw StateError('Project was not saved.');
    }
    return project;
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
      origin: input.origin,
      language: input.language,
      targetLength: input.targetLength,
      totalTargetLength: input.totalTargetLength,
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
