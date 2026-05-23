import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_flutter/src/core/tasks/application/workflow_task_providers.dart';
import 'package:persona_flutter/src/core/tasks/application/workflow_task_repository.dart';
import 'package:persona_flutter/src/core/tasks/domain/workflow_prompt_trace.dart';
import 'package:persona_flutter/src/core/tasks/domain/workflow_task.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/novel_workshop_providers.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_workshop.dart';
import 'package:persona_flutter/src/features/plot_lab/application/plot_lab_providers.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_analysis_run.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_sample.dart';
import 'package:persona_flutter/src/features/plot_lab/presentation/plot_lab_page.dart';
import 'package:persona_flutter/src/features/settings/application/provider_config_providers.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:persona_flutter/src/features/style_lab/application/style_lab_providers.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_analysis_run.dart';
import 'package:persona_flutter/src/features/workflow_runs/application/workflow_task_controller.dart';
import 'package:persona_flutter/src/features/workflow_runs/presentation/workflow_runs_page.dart';

void main() {
  testWidgets('workflow runs opens generic prompt trace detail', (
    tester,
  ) async {
    final run = _plotRun();
    final task = WorkflowTask(
      id: run.workflowTaskId,
      kind: plotAnalysisWorkflowTaskKind,
      status: WorkflowTaskStatus.succeeded,
      title: '剧情分析：雾线剧情',
      stage: null,
      createdAt: DateTime(2026, 5, 16, 11),
      updatedAt: DateTime(2026, 5, 16, 12),
    );

    await tester.pumpWidget(_WorkflowRunsTestApp(task: task, run: run));
    await _pumpWorkflowRuns(tester);

    expect(find.text('打开详情'), findsOneWidget);

    await tester.tap(find.text('剧情分析：雾线剧情').last);
    await _pumpWorkflowRuns(tester);

    expect(find.text('运行时 Prompt Trace'), findsOneWidget);
    expect(find.text('业务详情'), findsOneWidget);
    expect(find.text('未记录阶段'), findsOneWidget);
    expect(find.text(plotAnalysisWorkflowTaskKind), findsWidgets);
    expect(find.text('任务状态'), findsNothing);
    expect(find.text('结构化'), findsOneWidget);
    expect(find.text('1 calls'), findsOneWidget);
    expect(find.text('0 failed'), findsOneWidget);
    expect(find.text('deepseek-chat'), findsWidgets);
    expect(find.text('12 input chars'), findsOneWidget);
    expect(find.textContaining('Prompt Trace'), findsWidgets);
    expect(find.text('reporting / build_report'), findsOneWidget);
    expect(find.text('PROMPT'), findsNothing);

    await tester.tap(find.text('reporting / build_report'));
    await _pumpWorkflowRuns(tester);

    expect(find.text('User message'), findsOneWidget);
    expect(find.text('Output excerpt'), findsOneWidget);
    expect(find.text('PROMPT'), findsOneWidget);
    expect(find.text('OUTPUT'), findsOneWidget);

    await tester.tap(find.text('Raw'));
    await _pumpWorkflowRuns(tester);

    expect(
      find.textContaining('format: persona.workflow_prompt_trace'),
      findsOneWidget,
    );
    expect(
      find.textContaining('## Call 1 - reporting / build_report'),
      findsOneWidget,
    );

    await tester.tap(find.text('任务日志'));
    await _pumpWorkflowRuns(tester);

    expect(
      find.byKey(const ValueKey('workflow-log-code-block')),
      findsOneWidget,
    );
    expect(find.textContaining('分析完成'), findsOneWidget);

    await tester.tap(find.text('业务详情'));
    await _pumpWorkflowRuns(tester);

    expect(find.text('保存为 Profile'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('workflow detail shows novel asset generation logs', (
    tester,
  ) async {
    final task = WorkflowTask(
      id: 'task-asset-1',
      kind: assetGenerationWorkflowTaskKind,
      status: WorkflowTaskStatus.failed,
      title: '资产生成：角色索引与关系网',
      stage: null,
      errorMessage: 'secrets 必须是字符串。',
      createdAt: DateTime(2026, 5, 21, 16),
      updatedAt: DateTime(2026, 5, 21, 16, 6),
    );
    final assetRun = _assetRun(workflowTaskId: task.id);

    await tester.pumpWidget(
      _WorkflowRunsTestApp(task: task, run: _plotRun(), assetRun: assetRun),
    );
    await _pumpWorkflowRuns(tester);

    await tester.tap(find.text('资产生成：角色索引与关系网'));
    await _pumpWorkflowRuns(tester);

    expect(find.text('业务详情'), findsNothing);

    await tester.tap(find.text('任务日志'));
    await _pumpWorkflowRuns(tester);

    expect(
      find.byKey(const ValueKey('workflow-log-code-block')),
      findsOneWidget,
    );
    expect(find.textContaining('阶段: 生成草稿'), findsOneWidget);
    expect(find.textContaining('资产草稿生成失败'), findsOneWidget);
  });

  testWidgets('workflow runs shows abandon action for running task', (
    tester,
  ) async {
    final task = WorkflowTask(
      id: 'task-running-1',
      kind: assetGenerationWorkflowTaskKind,
      status: WorkflowTaskStatus.running,
      title: '资产生成：世界观设定',
      stage: 'generatingDraft',
      createdAt: DateTime(2026, 5, 22, 10),
      updatedAt: DateTime(2026, 5, 22, 10, 1),
    );

    await tester.pumpWidget(_WorkflowRunsTestApp(task: task, run: _plotRun()));
    await _pumpWorkflowRuns(tester);

    expect(find.text('放弃'), findsOneWidget);
    await tester.tap(find.text('放弃'));
    await _pumpWorkflowRuns(tester);

    expect(find.text('放弃任务'), findsWidgets);
  });

  testWidgets('workflow runs list shows inline preview actions', (
    tester,
  ) async {
    final plotRun = _plotRun();
    final plotTask = WorkflowTask(
      id: plotRun.workflowTaskId,
      kind: plotAnalysisWorkflowTaskKind,
      status: WorkflowTaskStatus.succeeded,
      title: '剧情分析：雾线剧情',
      createdAt: DateTime(2026, 5, 16, 11),
      updatedAt: DateTime(2026, 5, 16, 12),
    );
    final assetTask = WorkflowTask(
      id: 'task-asset-preview',
      kind: assetGenerationWorkflowTaskKind,
      status: WorkflowTaskStatus.succeeded,
      title: '资产生成：世界观设定',
      createdAt: DateTime(2026, 5, 22, 9),
      updatedAt: DateTime(2026, 5, 22, 9, 30),
    );
    final chapterTask = WorkflowTask(
      id: 'task-chapter-preview',
      kind: chapterGenerationWorkflowTaskKind,
      status: WorkflowTaskStatus.succeeded,
      title: '章节生成：第 1 章',
      createdAt: DateTime(2026, 5, 22, 10),
      updatedAt: DateTime(2026, 5, 22, 10, 30),
    );
    final abandonedTask = WorkflowTask(
      id: 'task-abandoned',
      kind: assetGenerationWorkflowTaskKind,
      status: WorkflowTaskStatus.abandoned,
      title: '资产生成：已放弃',
      createdAt: DateTime(2026, 5, 22, 8),
      updatedAt: DateTime(2026, 5, 22, 8, 10),
    );
    final dismissedTask = WorkflowTask(
      id: 'task-dismissed-preview',
      kind: assetGenerationWorkflowTaskKind,
      status: WorkflowTaskStatus.succeeded,
      title: '资产生成：已忽略预览',
      previewDismissedAt: DateTime(2026, 5, 22, 11),
      createdAt: DateTime(2026, 5, 22, 11),
      updatedAt: DateTime(2026, 5, 22, 11, 10),
    );
    final appliedTask = WorkflowTask(
      id: 'task-applied-preview',
      kind: assetGenerationWorkflowTaskKind,
      status: WorkflowTaskStatus.succeeded,
      title: '资产生成：已应用资产',
      createdAt: DateTime(2026, 5, 22, 12),
      updatedAt: DateTime(2026, 5, 22, 12, 10),
    );
    final repository = _FakeWorkflowTaskRepository(
      tasks: [
        assetTask,
        plotTask,
        chapterTask,
        abandonedTask,
        dismissedTask,
        appliedTask,
      ],
    );

    await tester.pumpWidget(
      _WorkflowRunsTestApp(
        task: plotTask,
        run: plotRun,
        tasks: repository.tasks,
        workflowRepository: repository,
        assetRuns: [
          _assetRun(
            workflowTaskId: assetTask.id,
            status: AssetGenerationStatus.succeeded,
            draftMarkdown: '# 世界观\n\n雾港。',
          ),
          _assetRun(
            workflowTaskId: dismissedTask.id,
            status: AssetGenerationStatus.succeeded,
            draftMarkdown: '# 已忽略\n\n不再提示。',
          ),
          _assetRun(
            workflowTaskId: appliedTask.id,
            status: AssetGenerationStatus.applied,
            draftMarkdown: '# 已应用\n\n已写入项目。',
          ),
        ],
        chapterRun: _chapterRun(workflowTaskId: chapterTask.id),
      ),
    );
    await _pumpWorkflowRuns(tester);

    expect(find.text('完成预览'), findsNothing);
    expect(find.text('最近工作流活动'), findsOneWidget);
    expect(find.text('打开预览'), findsNWidgets(3));
    expect(find.text('应用'), findsOneWidget);
    expect(find.text('忽略'), findsNWidgets(3));
    expect(find.text('资产生成：已忽略预览'), findsOneWidget);
    expect(find.text('资产生成：已应用资产'), findsOneWidget);
    expect(find.text('已放弃'), findsOneWidget);
    expect(find.textContaining('已放弃', findRichText: true), findsWidgets);

    await tester.tap(find.text('忽略').first);
    await _pumpWorkflowRuns(tester);

    expect(repository.dismissedTaskIds, ['task-asset-preview']);

    await tester.tap(find.text('打开预览').first);
    await _pumpWorkflowRuns(tester);

    expect(find.text('任务产出预览'), findsOneWidget);
  });
}

class _WorkflowRunsTestApp extends StatelessWidget {
  const _WorkflowRunsTestApp({
    required this.task,
    required this.run,
    this.tasks,
    this.assetRun,
    this.assetRuns,
    this.chapterRun,
    this.workflowRepository,
  });

  final WorkflowTask task;
  final PlotAnalysisRun run;
  final List<WorkflowTask>? tasks;
  final AssetGenerationRun? assetRun;
  final List<AssetGenerationRun>? assetRuns;
  final ChapterGenerationRun? chapterRun;
  final WorkflowTaskRepository? workflowRepository;

  @override
  Widget build(BuildContext context) {
    final sample = _sample();
    final assetRunItems = assetRuns ?? [?assetRun];
    return ProviderScope(
      overrides: [
        recentWorkflowTasksProvider.overrideWith(
          (ref) => Stream<List<WorkflowTask>>.value(tasks ?? [task]),
        ),
        if (workflowRepository != null)
          workflowTaskRepositoryProvider.overrideWithValue(workflowRepository!),
        workflowTaskProvider.overrideWith(
          (ref, id) => Stream<WorkflowTask?>.value(
            (tasks ?? [task]).where((item) => item.id == id).firstOrNull,
          ),
        ),
        workflowPromptTraceProvider.overrideWith(
          (ref, workflowTaskId) => Stream<WorkflowPromptTrace?>.value(
            workflowTaskId == task.id ? _trace(task.id) : null,
          ),
        ),
        plotAnalysisRunByWorkflowTaskProvider.overrideWith(
          (ref, workflowTaskId) => Stream<PlotAnalysisRun?>.value(
            workflowTaskId == run.workflowTaskId ? run : null,
          ),
        ),
        plotAnalysisRunProvider.overrideWith(
          (ref, id) =>
              Stream<PlotAnalysisRun?>.value(id == run.id ? run : null),
        ),
        plotSampleProvider.overrideWith(
          (ref, id) =>
              Stream<PlotSample?>.value(id == sample.id ? sample : null),
        ),
        providerConfigsProvider.overrideWith(
          (ref) => Stream<List<ProviderConfig>>.value(const []),
        ),
        styleAnalysisRunByWorkflowTaskProvider.overrideWith(
          (ref, workflowTaskId) => const Stream<StyleAnalysisRun?>.empty(),
        ),
        assetGenerationRunByWorkflowTaskProvider.overrideWith(
          (ref, workflowTaskId) => Stream<AssetGenerationRun?>.value(
            assetRunItems
                .where((item) => item.workflowTaskId == workflowTaskId)
                .firstOrNull,
          ),
        ),
        chapterGenerationRunByWorkflowTaskProvider.overrideWith(
          (ref, workflowTaskId) => Stream<ChapterGenerationRun?>.value(
            workflowTaskId == chapterRun?.workflowTaskId ? chapterRun : null,
          ),
        ),
        chapterEnrichmentBatchByWorkflowTaskProvider.overrideWith(
          (ref, workflowTaskId) =>
              const Stream<ChapterEnrichmentBatch?>.empty(),
        ),
        workflowTaskControllerProvider.overrideWith(
          () => _NoopWorkflowTaskController(),
        ),
      ],
      child: MaterialApp.router(routerConfig: _router()),
    );
  }
}

class _NoopWorkflowTaskController extends WorkflowTaskController {
  @override
  Future<void> abandon(String taskId) async {}
}

class _FakeWorkflowTaskRepository implements WorkflowTaskRepository {
  _FakeWorkflowTaskRepository({required this.tasks});

  final List<WorkflowTask> tasks;
  final List<String> dismissedTaskIds = [];

  @override
  Stream<List<WorkflowTask>> watchRecentTasks() => Stream.value(tasks);

  @override
  Stream<WorkflowTask?> watchTask(String id) =>
      Stream.value(tasks.where((item) => item.id == id).firstOrNull);

  @override
  Future<WorkflowTask?> findTask(String id) async =>
      tasks.where((item) => item.id == id).firstOrNull;

  @override
  Future<void> abandonTask(String id) async {}

  @override
  Future<void> dismissTaskPreview(String id) async {
    dismissedTaskIds.add(id);
  }

  @override
  Stream<WorkflowPromptTrace?> watchPromptTrace(String workflowTaskId) =>
      Stream.value(_trace(workflowTaskId));

  @override
  Future<void> upsertPromptTrace({
    required String workflowTaskId,
    required String traceMarkdown,
  }) async {}
}

Future<void> _pumpWorkflowRuns(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump();
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/workflow-runs',
    routes: [
      GoRoute(
        path: '/workflow-runs',
        builder: (context, state) => const Scaffold(body: WorkflowRunsPage()),
        routes: [
          GoRoute(
            path: ':taskId',
            builder: (context, state) => Scaffold(
              body: WorkflowRunDetailPage(
                taskId: state.pathParameters['taskId']!,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/plot-lab',
        builder: (context, state) => const PlotLabPage(),
        routes: [
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

WorkflowPromptTrace _trace(String workflowTaskId) {
  return WorkflowPromptTrace(
    workflowTaskId: workflowTaskId,
    traceMarkdown:
        '''---
format: persona.workflow_prompt_trace
version: 1
workflow_task_id: "$workflowTaskId"
workflow_kind: "plot_analysis"
run_id: "run-plot-1"
provider_id: "provider-1"
model_name: "deepseek-chat"
calls: 1
failed_calls: 0
total_input_chars: 12
updated_at: "2026-05-16T12:00:00.000Z"
---

# Prompt Trace

## Call summary

| # | Stage | Label | Model | Temperature | Input chars | Output chars | Failed | Error |
| --- | --- | --- | --- | ---: | ---: | ---: | --- | --- |
| 1 | reporting | build_report | deepseek-chat | 0.4 | 12 | 6 | no | - |

## Call 1 - reporting / build_report

### User message

```
PROMPT
```

### Output excerpt

```
OUTPUT
```
''',
    createdAt: DateTime(2026, 5, 16, 12),
    updatedAt: DateTime(2026, 5, 16, 12),
  );
}

PlotAnalysisRun _plotRun() {
  return PlotAnalysisRun(
    id: 'run-plot-1',
    workflowTaskId: 'task-plot-1',
    sampleId: 'sample-1',
    providerId: 'provider-1',
    modelName: 'deepseek-chat',
    plotName: '雾线剧情',
    status: PlotAnalysisStatus.succeeded,
    logs: '[2026-05-16T11:03:00] 分析完成。',
    analysisReportMarkdown: '# 执行摘要\n压力推进。',
    plotSkeletonMarkdown: '# 全书骨架\n## 主线推进链\n@chunk0',
    storyEngineMarkdown: _validStoryEngine,
    chunkCount: 1,
    characterCount: 15,
    createdAt: DateTime(2026, 5, 16, 11),
    updatedAt: DateTime(2026, 5, 16, 12),
    completedAt: DateTime(2026, 5, 16, 12),
  );
}

AssetGenerationRun _assetRun({
  required String workflowTaskId,
  AssetGenerationStatus status = AssetGenerationStatus.failed,
  String draftMarkdown = '',
}) {
  return AssetGenerationRun(
    id: 'run-asset-1',
    workflowTaskId: workflowTaskId,
    projectId: 'project-1',
    kind: AssetGenerationKind.charactersBlueprint,
    providerId: 'provider-1',
    modelName: 'deepseek-chat',
    status: status,
    stage: null,
    errorMessage: 'secrets 必须是字符串。',
    logs:
        '[2026-05-21T16:05:00] 阶段: 生成草稿。调用模型生成角色索引与关系网。\n'
        '[2026-05-21T16:06:00] 资产草稿生成失败。',
    draftMarkdown: draftMarkdown,
    createdAt: DateTime(2026, 5, 21, 16),
    updatedAt: DateTime(2026, 5, 21, 16, 6),
    startedAt: DateTime(2026, 5, 21, 16, 5),
    completedAt: DateTime(2026, 5, 21, 16, 6),
  );
}

ChapterGenerationRun _chapterRun({required String workflowTaskId}) {
  return ChapterGenerationRun(
    id: 'run-chapter-1',
    workflowTaskId: workflowTaskId,
    projectId: 'project-1',
    chapterPlanId: 'plan-1',
    chapterId: 'chapter-1',
    providerId: 'provider-1',
    modelName: 'deepseek-chat',
    status: ChapterGenerationStatus.succeeded,
    stage: null,
    errorMessage: null,
    logs: '[2026-05-22T10:30:00] 章节生成完成。',
    contextWarningsMarkdown: '',
    draftMarkdown: '# 第 1 章\n\n雾港醒来。',
    continuityVerdict: ContinuityVerdict.pass,
    continuityReportMarkdown: '# Continuity Audit\n\n通过。',
    createdAt: DateTime(2026, 5, 22, 10),
    updatedAt: DateTime(2026, 5, 22, 10, 30),
    startedAt: DateTime(2026, 5, 22, 10),
    completedAt: DateTime(2026, 5, 22, 10, 30),
  );
}

PlotSample _sample() {
  return PlotSample(
    id: 'sample-1',
    sourceType: PlotSampleSourceType.txt,
    title: '裂缝样本',
    content: '第一章 开端\n\n他被迫做出选择。',
    characterCount: 15,
    sourceFilename: 'sample.txt',
    createdAt: DateTime(2026, 5, 16, 9),
    updatedAt: DateTime(2026, 5, 16, 10),
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
