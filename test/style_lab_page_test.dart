import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_flutter/src/features/projects/application/project_providers.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';
import 'package:persona_flutter/src/features/settings/application/provider_config_providers.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:persona_flutter/src/features/style_lab/application/style_lab_providers.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_analysis_run.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_lab_repository.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_profile.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_sample.dart';
import 'package:persona_flutter/src/features/style_lab/presentation/style_lab_page.dart';

void main() {
  testWidgets('style lab shows profile library empty state', (tester) async {
    await tester.pumpWidget(
      _StyleLabTestApp(samples: const [], runs: const [], profiles: const []),
    );
    await _pumpStyleLab(tester);

    expect(find.text('Profile 档案库'), findsOneWidget);
    expect(find.text('尚无 Profile 资产'), findsOneWidget);
    expect(find.text('新建 Profile'), findsOneWidget);
    expect(find.text('Voice Profile'), findsNothing);

    await tester.tap(find.text('新建 Profile'));
    await _pumpStyleLab(tester);

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('导入 TXT / EPUB'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('style lab renders saved profiles and draft profiles', (
    tester,
  ) async {
    final sample = _sample(id: 'sample-1', title: '冷雨样本');
    final profile = _profile(id: 'profile-1', sourceSampleId: sample.id);
    final draft = _run(
      id: 'run-draft',
      sampleId: sample.id,
      status: StyleAnalysisStatus.succeeded,
      voiceProfileMarkdown: _validProfile('雾线草稿'),
    );
    final failed = _run(
      id: 'run-failed',
      sampleId: sample.id,
      status: StyleAnalysisStatus.failed,
      errorMessage: '模型返回为空。',
    );

    await tester.pumpWidget(
      _StyleLabTestApp(
        samples: [sample],
        runs: [draft, failed],
        profiles: [profile],
      ),
    );
    await _pumpStyleLab(tester);

    expect(find.text('冷雨风格'), findsWidgets);
    expect(find.text('雾线草稿'), findsWidgets);
    expect(find.text('已保存 (1)'), findsOneWidget);
    expect(find.text('待保存 (1)'), findsOneWidget);
    expect(find.text('任务 (1)'), findsOneWidget);
    expect(find.text('任务活动'), findsOneWidget);
    expect(find.text('模型返回为空。'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('style lab shows running analysis progress and logs', (
    tester,
  ) async {
    final sample = _sample(id: 'sample-1', title: '冷雨样本');
    final running = _run(
      id: 'run-running',
      sampleId: sample.id,
      status: StyleAnalysisStatus.running,
      stage: StyleAnalysisStage.analyzingChunks,
      chunkCount: 3,
      logs:
          '[2026-05-16T11:00:00] 阶段: 分块分析。开始分块分析：3 个 chunk。\n'
          '[2026-05-16T11:01:00] 完成 chunk 1/3。',
    );

    await tester.pumpWidget(
      _StyleLabTestApp(samples: [sample], runs: [running], profiles: const []),
    );
    await _pumpStyleLab(tester);

    expect(find.text('任务活动'), findsOneWidget);
    expect(find.text('分块分析'), findsWidgets);
    expect(find.text('1/3 chunks'), findsWidgets);
    expect(find.text('32%'), findsOneWidget);
    expect(find.textContaining('完成 chunk 1/3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('style lab activity shows failed progress and error logs', (
    tester,
  ) async {
    final sample = _sample(id: 'sample-1', title: '雾线样本');
    final failed = _run(
      id: 'run-failed',
      sampleId: sample.id,
      status: StyleAnalysisStatus.failed,
      stage: StyleAnalysisStage.reporting,
      errorMessage: '模型返回为空。',
      chunkCount: 2,
      logs:
          '[2026-05-16T11:00:00] 完成 chunk 1/2。\n'
          '[2026-05-16T11:02:00] 阶段: 生成报告。生成最终分析报告。\n'
          '[2026-05-16T11:03:00] 分析失败。',
    );

    await tester.pumpWidget(
      _StyleLabTestApp(samples: [sample], runs: [failed], profiles: const []),
    );
    await _pumpStyleLab(tester);

    expect(find.text('生成报告'), findsWidgets);
    expect(find.text('1/2 chunks'), findsWidgets);
    expect(find.text('失败'), findsWidgets);
    expect(find.text('模型返回为空。'), findsOneWidget);
    expect(find.text('打开详情'), findsOneWidget);
    expect(find.textContaining('分析失败。'), findsNothing);
    final progressIndicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator).last,
    );
    expect(progressIndicator.value, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('style lab failed detail shows static error progress', (
    tester,
  ) async {
    final sample = _sample(id: 'sample-1', title: '雾线样本');
    final failed = _run(
      id: 'run-failed',
      sampleId: sample.id,
      status: StyleAnalysisStatus.failed,
      errorMessage: '应用重启，任务已中断，可重跑。',
      chunkCount: 5,
      logs:
          '[2026-05-16T11:00:00] 完成 chunk 1/5。\n'
          '[2026-05-16T11:02:00] 完成 chunk 2/5。',
    );

    await tester.pumpWidget(
      _StyleLabTestApp(
        samples: [sample],
        runs: [failed],
        profiles: const [],
        initialLocation: '/style-lab/tasks/${failed.id}',
      ),
    );
    await _pumpStyleLab(tester);

    await tester.tap(find.text('任务日志'));
    await _pumpStyleLab(tester);

    final progressIndicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator).last,
    );
    expect(progressIndicator.value, 1);
    expect(find.text('失败'), findsOneWidget);
    expect(find.text('应用重启，任务已中断，可重跑。'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('style lab draft detail shows progress and run logs', (
    tester,
  ) async {
    final sample = _sample(id: 'sample-1', title: '雾线样本');
    final draft = _run(
      id: 'run-draft',
      sampleId: sample.id,
      status: StyleAnalysisStatus.succeeded,
      analysisReportMarkdown: '# 分析报告\n节奏克制。',
      voiceProfileMarkdown: _validProfile('雾线草稿'),
      chunkCount: 2,
      logs:
          '[2026-05-16T11:00:00] 完成 chunk 1/2。\n'
          '[2026-05-16T11:02:00] 完成 chunk 2/2。\n'
          '[2026-05-16T11:03:00] 分析完成。',
    );

    await tester.pumpWidget(
      _StyleLabTestApp(samples: [sample], runs: [draft], profiles: const []),
    );
    await _pumpStyleLab(tester);

    await tester.ensureVisible(find.text('雾线草稿').first);
    await tester.tap(find.text('雾线草稿').first);
    await _pumpStyleLab(tester);
    expect(find.text('TASK DETAIL'), findsOneWidget);
    await tester.tap(find.text('任务日志'));
    await _pumpStyleLab(tester);

    expect(find.text('100%'), findsOneWidget);
    expect(find.text('2/2 chunks'), findsWidgets);
    expect(find.text('完整日志'), findsOneWidget);
    expect(find.textContaining('分析完成。'), findsOneWidget);
    final logBlock = find.byKey(const ValueKey('style-lab-run-log-code-block'));
    expect(logBlock, findsOneWidget);
    final logBlockSize = tester.getSize(logBlock);
    final tabViewSize = tester.getSize(find.byType(TabBarView));
    expect(logBlockSize.width, closeTo(tabViewSize.width - 36, 0.1));
    expect(logBlockSize.height, greaterThan(420));
    expect(tester.takeException(), isNull);
  });

  testWidgets('style lab routes to saved profile detail', (tester) async {
    final sample = _sample(id: 'sample-1', title: '冷雨样本');
    final run = _run(
      id: 'run-1',
      sampleId: sample.id,
      profileId: 'profile-1',
      status: StyleAnalysisStatus.succeeded,
      analysisReportMarkdown: '# 分析报告\n冷感短句。',
      voiceProfileMarkdown: _validProfile('冷雨风格'),
    );
    final profile = _profile(
      id: 'profile-1',
      sourceRunId: run.id,
      sourceSampleId: sample.id,
    );

    await tester.pumpWidget(
      _StyleLabTestApp(samples: [sample], runs: [run], profiles: [profile]),
    );
    await _pumpStyleLab(tester);

    await tester.tap(find.text('冷雨风格').first);
    await _pumpStyleLab(tester);

    expect(find.text('PROFILE DETAIL'), findsOneWidget);
    expect(find.text('更新 Profile'), findsOneWidget);
    expect(find.text('分析报告'), findsWidgets);
    expect(find.text('来源样本'), findsOneWidget);
    expect(find.text('返回档案库'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('style lab routes to draft detail with save action', (
    tester,
  ) async {
    final sample = _sample(id: 'sample-1', title: '雾线样本');
    final draft = _run(
      id: 'run-draft',
      sampleId: sample.id,
      status: StyleAnalysisStatus.succeeded,
      analysisReportMarkdown: '# 分析报告\n节奏克制。',
      voiceProfileMarkdown: _validProfile('雾线草稿'),
    );

    await tester.pumpWidget(
      _StyleLabTestApp(samples: [sample], runs: [draft], profiles: const []),
    );
    await _pumpStyleLab(tester);

    await tester.tap(find.text('雾线草稿').first);
    await _pumpStyleLab(tester);

    expect(find.text('TASK DETAIL'), findsOneWidget);
    expect(find.text('保存为 Profile'), findsOneWidget);
    expect(find.text('YAML 契约有效'), findsOneWidget);
    expect(find.text('源码'), findsOneWidget);
    expect(find.text('预览'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('style lab library fits narrow viewport', (tester) async {
    tester.view.physicalSize = const Size(760, 980);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final sample = _sample(id: 'sample-1', title: '窄屏样本');
    final profile = _profile(id: 'profile-1', sourceSampleId: sample.id);

    await tester.pumpWidget(
      _StyleLabTestApp(samples: [sample], runs: const [], profiles: [profile]),
    );
    await _pumpStyleLab(tester);

    expect(find.text('Profile 档案库'), findsOneWidget);
    expect(find.text('冷雨风格'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

class _StyleLabTestApp extends StatelessWidget {
  const _StyleLabTestApp({
    required this.samples,
    required this.runs,
    required this.profiles,
    this.initialLocation = '/style-lab',
  });

  final List<StyleSample> samples;
  final List<StyleAnalysisRun> runs;
  final List<StyleProfile> profiles;
  final String initialLocation;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        styleSamplesProvider.overrideWith(
          (ref) => Stream<List<StyleSample>>.value(samples),
        ),
        recentStyleAnalysisRunsProvider.overrideWith(
          (ref) => Stream<List<StyleAnalysisRun>>.value(runs),
        ),
        styleProfilesProvider.overrideWith(
          (ref) => Stream<List<StyleProfile>>.value(profiles),
        ),
        styleSampleProvider.overrideWith(
          (ref, id) => Stream<StyleSample?>.value(
            samples.where((sample) => sample.id == id).firstOrNull,
          ),
        ),
        styleAnalysisRunProvider.overrideWith(
          (ref, id) => Stream<StyleAnalysisRun?>.value(
            runs.where((run) => run.id == id).firstOrNull,
          ),
        ),
        styleProfileProvider.overrideWith(
          (ref, id) => Stream<StyleProfile?>.value(
            profiles.where((profile) => profile.id == id).firstOrNull,
          ),
        ),
        providerConfigsProvider.overrideWith(
          (ref) => Stream<List<ProviderConfig>>.value([_provider()]),
        ),
        writingProjectsProvider.overrideWith(
          (ref, status) => Stream<List<WritingProject>>.value(const []),
        ),
        styleLabRepositoryProvider.overrideWithValue(
          _FakeStyleLabRepository(
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

Future<void> _pumpStyleLab(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump();
}

GoRouter _router([String initialLocation = '/style-lab']) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/style-lab',
        builder: (context, state) => const StyleLabPage(),
        routes: [
          GoRoute(
            path: 'profiles/:profileId',
            builder: (context, state) => StyleLabProfileDetailPage(
              profileId: state.pathParameters['profileId']!,
            ),
          ),
          GoRoute(
            path: 'drafts/:runId',
            builder: (context, state) =>
                StyleLabDraftDetailPage(runId: state.pathParameters['runId']!),
          ),
          GoRoute(
            path: 'tasks/:runId',
            builder: (context, state) =>
                StyleLabTaskDetailPage(runId: state.pathParameters['runId']!),
          ),
        ],
      ),
    ],
  );
}

StyleSample _sample({required String id, required String title}) {
  return StyleSample(
    id: id,
    sourceType: StyleSampleSourceType.txt,
    title: title,
    content: '雨落在玻璃上。\n\n他没有回头。',
    characterCount: 15,
    sourceFilename: 'sample.txt',
    createdAt: DateTime(2026, 5, 16, 9),
    updatedAt: DateTime(2026, 5, 16, 10),
  );
}

StyleAnalysisRun _run({
  required String id,
  required String sampleId,
  required StyleAnalysisStatus status,
  String styleName = '雾线草稿',
  StyleAnalysisStage? stage,
  String? profileId,
  String? analysisReportMarkdown,
  String? voiceProfileMarkdown,
  String? errorMessage,
  String logs = 'prepare_input\nbuild_voice_profile',
  int chunkCount = 1,
}) {
  return StyleAnalysisRun(
    id: id,
    workflowTaskId: 'task-$id',
    sampleId: sampleId,
    providerId: 'provider-1',
    modelName: 'deepseek-chat',
    styleName: styleName,
    status: status,
    stage: stage,
    errorMessage: errorMessage,
    logs: logs,
    analysisReportMarkdown: analysisReportMarkdown,
    voiceProfileMarkdown: voiceProfileMarkdown,
    profileId: profileId,
    chunkCount: chunkCount,
    characterCount: 15,
    createdAt: DateTime(2026, 5, 16, 11),
    updatedAt: DateTime(2026, 5, 16, 12),
    completedAt: status == StyleAnalysisStatus.succeeded
        ? DateTime(2026, 5, 16, 12)
        : null,
  );
}

StyleProfile _profile({
  required String id,
  String sourceRunId = 'run-1',
  String? sourceSampleId,
}) {
  return StyleProfile(
    id: id,
    sourceRunId: sourceRunId,
    providerId: 'provider-1',
    modelName: 'deepseek-chat',
    styleName: '冷雨风格',
    profileMarkdown: _validProfile('冷雨风格'),
    analysisReportMarkdown: '# 分析报告\n冷感短句。',
    sourceSampleId: sourceSampleId,
    sourceTitle: '冷雨样本',
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

String _validProfile(String name) {
  return '''---
name: "$name"
tags: ["冷感", "短句"]
voice_summary: "低温、克制、短句推进。"
tone: "冷静"
pacing: "短句推进"
diction: "冷色词汇"
syntax: "短句和停顿"
do: ["压迫场景用短句"]
avoid: ["过度解释"]
intensity: 0.7
---

# Voice Profile

## 3.1 口头禅与常用表达
- 执行规则：短句推进。
''';
}

class _FakeStyleLabRepository implements StyleLabRepository {
  const _FakeStyleLabRepository({
    required this.samples,
    required this.runs,
    required this.profiles,
  });

  final List<StyleSample> samples;
  final List<StyleAnalysisRun> runs;
  final List<StyleProfile> profiles;

  @override
  Stream<List<StyleSample>> watchSamples() {
    return Stream<List<StyleSample>>.value(samples);
  }

  @override
  Stream<StyleSample?> watchSample(String id) {
    return Stream<StyleSample?>.value(
      samples.where((sample) => sample.id == id).firstOrNull,
    );
  }

  @override
  Future<StyleSample?> findSample(String id) async {
    return samples.where((sample) => sample.id == id).firstOrNull;
  }

  @override
  Future<StyleSample> saveSample(StyleSampleInput input) {
    throw UnimplementedError();
  }

  @override
  Stream<List<StyleAnalysisRun>> watchRecentRuns() {
    return Stream<List<StyleAnalysisRun>>.value(runs);
  }

  @override
  Stream<StyleAnalysisRun?> watchRun(String id) {
    return Stream<StyleAnalysisRun?>.value(
      runs.where((run) => run.id == id).firstOrNull,
    );
  }

  @override
  Stream<StyleAnalysisRun?> watchRunByWorkflowTask(String workflowTaskId) {
    return Stream<StyleAnalysisRun?>.value(
      runs.where((run) => run.workflowTaskId == workflowTaskId).firstOrNull,
    );
  }

  @override
  Future<StyleAnalysisRun?> findRun(String id) async {
    return runs.where((run) => run.id == id).firstOrNull;
  }

  @override
  Future<StyleAnalysisRun> createRun(StyleAnalysisRunInput input) {
    throw UnimplementedError();
  }

  @override
  Future<StyleAnalysisRun> createRunFromExisting(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteRun(String id) async {}

  @override
  Future<void> updateRunState({
    required String id,
    required StyleAnalysisStatus status,
    StyleAnalysisStage? stage,
    String? errorMessage,
    String? logs,
    String? analysisReportMarkdown,
    String? voiceProfileMarkdown,
    String? profileId,
    int? chunkCount,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {}

  @override
  Future<int> markInterruptedRunsFailed() async {
    return 0;
  }

  @override
  Stream<List<StyleProfile>> watchProfiles() {
    return Stream<List<StyleProfile>>.value(profiles);
  }

  @override
  Stream<StyleProfile?> watchProfile(String id) {
    return Stream<StyleProfile?>.value(
      profiles.where((profile) => profile.id == id).firstOrNull,
    );
  }

  @override
  Future<StyleProfile?> findProfile(String id) async {
    return profiles.where((profile) => profile.id == id).firstOrNull;
  }

  @override
  Future<StyleProfile> saveProfileFromRun(StyleProfileInput input) {
    throw UnimplementedError();
  }

  @override
  Future<StyleProfile> updateProfile({
    required String id,
    required StyleProfileUpdateInput input,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteProfile(String id) async {}
}
