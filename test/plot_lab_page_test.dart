import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_flutter/src/features/projects/application/project_providers.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';
import 'package:persona_flutter/src/features/plot_lab/application/plot_lab_providers.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_analysis_run.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_lab_repository.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_profile.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_sample.dart';
import 'package:persona_flutter/src/features/plot_lab/presentation/plot_lab_page.dart';
import 'package:persona_flutter/src/features/settings/application/provider_config_providers.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';

void main() {
  testWidgets('plot lab shows profile library empty state', (tester) async {
    await tester.pumpWidget(
      _PlotLabTestApp(samples: const [], runs: const [], profiles: const []),
    );
    await _pumpPlotLab(tester);

    expect(find.text('Plot Profile 档案库'), findsOneWidget);
    expect(find.text('尚无 Plot Profile 资产'), findsOneWidget);
    expect(find.text('新建 Profile'), findsOneWidget);
    expect(find.text('Story Engine'), findsNothing);

    await tester.tap(find.text('新建 Profile'));
    await _pumpPlotLab(tester);

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('导入 TXT / EPUB'), findsOneWidget);
    expect(find.text('剧情档案名称'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('plot lab renders saved profiles drafts and failed tasks', (
    tester,
  ) async {
    final sample = _sample(id: 'sample-1', title: '裂缝样本');
    final profile = _profile(id: 'profile-1', sourceSampleId: sample.id);
    final draft = _run(
      id: 'run-draft',
      sampleId: sample.id,
      status: PlotAnalysisStatus.succeeded,
      storyEngineMarkdown: _validStoryEngine,
    );
    final failed = _run(
      id: 'run-failed',
      sampleId: sample.id,
      status: PlotAnalysisStatus.failed,
      errorMessage: '模型返回为空。',
    );

    await tester.pumpWidget(
      _PlotLabTestApp(
        samples: [sample],
        runs: [draft, failed],
        profiles: [profile],
      ),
    );
    await _pumpPlotLab(tester);

    expect(find.text('裂缝骨架'), findsWidgets);
    expect(find.text('雾线剧情'), findsWidgets);
    expect(find.text('已保存 (1)'), findsOneWidget);
    expect(find.text('待保存 (1)'), findsOneWidget);
    expect(find.text('任务 (1)'), findsOneWidget);
    expect(find.text('任务活动'), findsOneWidget);
    expect(find.text('模型返回为空。'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('plot lab task detail shows Story Engine and logs', (
    tester,
  ) async {
    final sample = _sample(id: 'sample-1', title: '裂缝样本');
    final draft = _run(
      id: 'run-draft',
      sampleId: sample.id,
      status: PlotAnalysisStatus.succeeded,
      analysisReportMarkdown: '# 执行摘要\n压力推进。',
      plotSkeletonMarkdown: '# 全书骨架\n## 主线推进链\n@chunk0',
      storyEngineMarkdown: _validStoryEngine,
      chunkCount: 2,
      logs:
          '[2026-05-16T11:00:00] 完成 sketch 1/2。\n'
          '[2026-05-16T11:02:00] 完成 sketch 2/2。\n'
          '[2026-05-16T11:03:00] 分析完成。',
    );

    await tester.pumpWidget(
      _PlotLabTestApp(
        samples: [sample],
        runs: [draft],
        profiles: const [],
        initialLocation: '/plot-lab/tasks/${draft.id}',
      ),
    );
    await _pumpPlotLab(tester);

    expect(find.text('保存为 Profile'), findsOneWidget);
    expect(find.text('YAML+MD 有效'), findsOneWidget);
    expect(find.text('全书骨架'), findsWidgets);
    await tester.tap(find.text('预览'));
    await _pumpPlotLab(tester);

    expect(find.text('Plot Writing Guide'), findsOneWidget);
    expect(find.textContaining('plot_summary'), findsNothing);
    expect(find.textContaining('intensity'), findsNothing);

    await tester.tap(find.text('任务日志'));
    await _pumpPlotLab(tester);

    expect(find.text('100%'), findsOneWidget);
    expect(find.text('2/2 chunks'), findsWidgets);
    expect(find.textContaining('分析完成。'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('plot-lab-run-log-code-block')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('plot lab routes to saved profile detail', (tester) async {
    final sample = _sample(id: 'sample-1', title: '裂缝样本');
    final run = _run(
      id: 'run-1',
      sampleId: sample.id,
      profileId: 'profile-1',
      status: PlotAnalysisStatus.succeeded,
    );
    final profile = _profile(
      id: 'profile-1',
      sourceRunId: run.id,
      sourceSampleId: sample.id,
    );

    await tester.pumpWidget(
      _PlotLabTestApp(samples: [sample], runs: [run], profiles: [profile]),
    );
    await _pumpPlotLab(tester);

    await tester.tap(find.text('裂缝骨架').first);
    await _pumpPlotLab(tester);

    expect(find.text('PLOT PROFILE DETAIL'), findsOneWidget);
    expect(find.text('更新 Profile'), findsOneWidget);
    expect(find.text('YAML+MD 有效'), findsOneWidget);
    expect(find.text('来源样本'), findsOneWidget);
    expect(find.text('返回档案库'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _PlotLabTestApp extends StatelessWidget {
  const _PlotLabTestApp({
    required this.samples,
    required this.runs,
    required this.profiles,
    this.initialLocation = '/plot-lab',
  });

  final List<PlotSample> samples;
  final List<PlotAnalysisRun> runs;
  final List<PlotProfile> profiles;
  final String initialLocation;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        plotSamplesProvider.overrideWith(
          (ref) => Stream<List<PlotSample>>.value(samples),
        ),
        recentPlotAnalysisRunsProvider.overrideWith(
          (ref) => Stream<List<PlotAnalysisRun>>.value(runs),
        ),
        plotProfilesProvider.overrideWith(
          (ref) => Stream<List<PlotProfile>>.value(profiles),
        ),
        plotSampleProvider.overrideWith(
          (ref, id) => Stream<PlotSample?>.value(
            samples.where((sample) => sample.id == id).firstOrNull,
          ),
        ),
        plotAnalysisRunProvider.overrideWith(
          (ref, id) => Stream<PlotAnalysisRun?>.value(
            runs.where((run) => run.id == id).firstOrNull,
          ),
        ),
        plotProfileProvider.overrideWith(
          (ref, id) => Stream<PlotProfile?>.value(
            profiles.where((profile) => profile.id == id).firstOrNull,
          ),
        ),
        providerConfigsProvider.overrideWith(
          (ref) => Stream<List<ProviderConfig>>.value([_provider()]),
        ),
        writingProjectsProvider.overrideWith(
          (ref, status) => Stream<List<WritingProject>>.value(const []),
        ),
        plotLabRepositoryProvider.overrideWithValue(
          _FakePlotLabRepository(
            samples: samples,
            runs: runs,
            profiles: profiles,
          ),
        ),
      ],
      child: MaterialApp.router(routerConfig: _router(initialLocation)),
    );
  }
}

Future<void> _pumpPlotLab(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump();
}

GoRouter _router([String initialLocation = '/plot-lab']) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/plot-lab',
        builder: (context, state) => const PlotLabPage(),
        routes: [
          GoRoute(
            path: 'profiles/:profileId',
            builder: (context, state) => PlotLabProfileDetailPage(
              profileId: state.pathParameters['profileId']!,
            ),
          ),
          GoRoute(
            path: 'tasks/:runId',
            builder: (context, state) =>
                PlotLabTaskDetailPage(runId: state.pathParameters['runId']!),
          ),
        ],
      ),
    ],
  );
}

PlotSample _sample({required String id, required String title}) {
  return PlotSample(
    id: id,
    sourceType: PlotSampleSourceType.txt,
    title: title,
    content: '第一章 开端\n\n他被迫做出选择。',
    characterCount: 15,
    sourceFilename: 'sample.txt',
    createdAt: DateTime(2026, 5, 16, 9),
    updatedAt: DateTime(2026, 5, 16, 10),
  );
}

PlotAnalysisRun _run({
  required String id,
  required String sampleId,
  required PlotAnalysisStatus status,
  String plotName = '雾线剧情',
  PlotAnalysisStage? stage,
  String? profileId,
  String? analysisReportMarkdown,
  String? plotSkeletonMarkdown,
  String? storyEngineMarkdown,
  String? errorMessage,
  String logs = 'prepare_input\nbuild_story_engine',
  int chunkCount = 1,
}) {
  return PlotAnalysisRun(
    id: id,
    workflowTaskId: 'task-$id',
    sampleId: sampleId,
    providerId: 'provider-1',
    modelName: 'deepseek-chat',
    plotName: plotName,
    status: status,
    stage: stage,
    errorMessage: errorMessage,
    logs: logs,
    analysisReportMarkdown: analysisReportMarkdown,
    plotSkeletonMarkdown: plotSkeletonMarkdown,
    storyEngineMarkdown: storyEngineMarkdown,
    profileId: profileId,
    chunkCount: chunkCount,
    characterCount: 15,
    createdAt: DateTime(2026, 5, 16, 11),
    updatedAt: DateTime(2026, 5, 16, 12),
    completedAt: status == PlotAnalysisStatus.succeeded
        ? DateTime(2026, 5, 16, 12)
        : null,
  );
}

PlotProfile _profile({
  required String id,
  String sourceRunId = 'run-1',
  String? sourceSampleId,
}) {
  return PlotProfile(
    id: id,
    sourceRunId: sourceRunId,
    providerId: 'provider-1',
    modelName: 'deepseek-chat',
    plotName: '裂缝骨架',
    storyEngineMarkdown: _validStoryEngine,
    analysisReportMarkdown: '# 执行摘要\n压力推进。',
    plotSkeletonMarkdown: '# 全书骨架\n## 主线推进链\n@chunk0',
    sourceSampleId: sourceSampleId,
    sourceTitle: '裂缝样本',
    createdAt: DateTime(2026, 5, 16, 12),
    updatedAt: DateTime(2026, 5, 16, 13),
  );
}

ProviderConfig _provider() {
  return ProviderConfig(
    id: 'provider-1',
    name: 'deepseek',
    baseUrl: 'https://api.example.com/v1',
    apiKey: 'sk-secret',
    defaultModel: 'deepseek-chat',
    isEnabled: true,
    testStatus: ProviderTestStatus.succeeded,
    createdAt: DateTime(2026, 5, 16),
    updatedAt: DateTime(2026, 5, 16),
  );
}

const _validStoryEngine = '''---
name: "裂缝骨架"
tags:
  - 身份压力
  - 半兑现
plot_summary: "主角在身份压力下被迫行动，用半兑现维持追读。"
core_formula: "当主角遭遇身份压力，必须采取行动，否则失去关键关系。"
progression_loop: "目标 -> 阻碍 -> 行动 -> 半兑现 -> 新压力。"
tension_rhythm: "半兑现后追加代价。"
hook_strategy: "用信息差或资源诱惑制造下一步选择。"
anti_drift:
  - 不要把输出写成世界观说明。
intensity: 0.7
---

# Plot Writing Guide

## Core Plot Formula
- 当主角遭遇身份压力，必须采取行动，否则失去关键关系。

## Chapter Progression Loop
- 目标 -> 阻碍 -> 行动 -> 半兑现 -> 新压力。

## Scene Construction Rules
- 每场从欲望和压力开始，并以筹码变化结束。

## Setup and Payoff Rules
- 伏笔必须经历埋设 -> 强化 -> 回收。

## Payoff and Tension Rhythm
- 半兑现后追加代价。

## Side Plot Usage
- 支线必须回流主线。

## Hook Recipes
- 章末用信息差或资源诱惑制造下一步选择。

## Anti-Drift Rules
- 不要把输出写成世界观说明。
''';

class _FakePlotLabRepository implements PlotLabRepository {
  const _FakePlotLabRepository({
    required this.samples,
    required this.runs,
    required this.profiles,
  });

  final List<PlotSample> samples;
  final List<PlotAnalysisRun> runs;
  final List<PlotProfile> profiles;

  @override
  Stream<List<PlotSample>> watchSamples() => Stream.value(samples);

  @override
  Stream<PlotSample?> watchSample(String id) {
    return Stream.value(samples.where((sample) => sample.id == id).firstOrNull);
  }

  @override
  Future<PlotSample?> findSample(String id) async {
    return samples.where((sample) => sample.id == id).firstOrNull;
  }

  @override
  Future<PlotSample> saveSample(PlotSampleInput input) {
    throw UnimplementedError();
  }

  @override
  Stream<List<PlotAnalysisRun>> watchRecentRuns() => Stream.value(runs);

  @override
  Stream<PlotAnalysisRun?> watchRun(String id) {
    return Stream.value(runs.where((run) => run.id == id).firstOrNull);
  }

  @override
  Stream<PlotAnalysisRun?> watchRunByWorkflowTask(String workflowTaskId) {
    return Stream.value(
      runs.where((run) => run.workflowTaskId == workflowTaskId).firstOrNull,
    );
  }

  @override
  Future<PlotAnalysisRun?> findRun(String id) async {
    return runs.where((run) => run.id == id).firstOrNull;
  }

  @override
  Future<PlotAnalysisRun> createRun(PlotAnalysisRunInput input) {
    throw UnimplementedError();
  }

  @override
  Future<PlotAnalysisRun> createRunFromExisting(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteRun(String id) async {}

  @override
  Future<void> updateRunState({
    required String id,
    required PlotAnalysisStatus status,
    PlotAnalysisStage? stage,
    String? errorMessage,
    String? logs,
    String? analysisReportMarkdown,
    String? plotSkeletonMarkdown,
    String? storyEngineMarkdown,
    String? profileId,
    int? chunkCount,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {}

  @override
  Future<int> markInterruptedRunsFailed() async => 0;

  @override
  Stream<List<PlotProfile>> watchProfiles() => Stream.value(profiles);

  @override
  Stream<PlotProfile?> watchProfile(String id) {
    return Stream.value(
      profiles.where((profile) => profile.id == id).firstOrNull,
    );
  }

  @override
  Future<PlotProfile?> findProfile(String id) async {
    return profiles.where((profile) => profile.id == id).firstOrNull;
  }

  @override
  Future<PlotProfile> saveProfileFromRun(PlotProfileInput input) {
    throw UnimplementedError();
  }

  @override
  Future<PlotProfile> updateProfile({
    required String id,
    required PlotProfileUpdateInput input,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteProfile(String id) async {}
}
