import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_flutter/src/core/tasks/application/workflow_task_providers.dart';
import 'package:persona_flutter/src/core/tasks/domain/workflow_task.dart';
import 'package:persona_flutter/src/features/plot_lab/application/plot_lab_providers.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_analysis_run.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_sample.dart';
import 'package:persona_flutter/src/features/plot_lab/presentation/plot_lab_page.dart';
import 'package:persona_flutter/src/features/settings/application/provider_config_providers.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:persona_flutter/src/features/style_lab/application/style_lab_providers.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_analysis_run.dart';
import 'package:persona_flutter/src/features/workflow_runs/presentation/workflow_runs_page.dart';

void main() {
  testWidgets('workflow runs opens a Plot Lab task detail', (tester) async {
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

    await tester.tap(find.text('剧情分析：雾线剧情'));
    await _pumpWorkflowRuns(tester);

    expect(find.text('保存为 Profile'), findsOneWidget);
    expect(find.text('YAML+MD 有效'), findsOneWidget);
    expect(find.text('返回档案库'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _WorkflowRunsTestApp extends StatelessWidget {
  const _WorkflowRunsTestApp({required this.task, required this.run});

  final WorkflowTask task;
  final PlotAnalysisRun run;

  @override
  Widget build(BuildContext context) {
    final sample = _sample();
    return ProviderScope(
      overrides: [
        recentWorkflowTasksProvider.overrideWith(
          (ref) => Stream<List<WorkflowTask>>.value([task]),
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
      ],
      child: MaterialApp.router(routerConfig: _router()),
    );
  }
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
        builder: (context, state) => const WorkflowRunsPage(),
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
