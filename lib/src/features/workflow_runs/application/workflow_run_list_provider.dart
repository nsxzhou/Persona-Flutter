import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/tasks/application/workflow_task_providers.dart';
import '../../../core/tasks/domain/workflow_task.dart';
import '../../novel_workshop/application/novel_workshop_providers.dart';
import '../../novel_workshop/domain/novel_workshop.dart';
import '../../plot_lab/application/plot_lab_providers.dart';
import '../../plot_lab/domain/plot_analysis_run.dart';
import '../../style_lab/application/style_lab_providers.dart';
import '../../style_lab/domain/style_analysis_run.dart';

part 'workflow_run_list_provider.g.dart';

class WorkflowRunItem {
  const WorkflowRunItem({
    required this.task,
    this.styleRun,
    this.plotRun,
    this.assetRun,
    this.chapterRun,
    this.chapterBatch,
    this.enrichmentBatch,
  });

  final WorkflowTask task;
  final StyleAnalysisRun? styleRun;
  final PlotAnalysisRun? plotRun;
  final AssetGenerationRun? assetRun;
  final ChapterGenerationRun? chapterRun;
  final ChapterGenerationBatch? chapterBatch;
  final ChapterEnrichmentBatch? enrichmentBatch;
}

@riverpod
Future<List<WorkflowRunItem>> workflowRunItems(Ref ref) async {
  final tasks = await ref.watch(workflowTasksProvider.future);

  if (tasks.isEmpty) return const <WorkflowRunItem>[];

  final items = await Future.wait(tasks.map((task) async {
    StyleAnalysisRun? styleRun;
    PlotAnalysisRun? plotRun;
    AssetGenerationRun? assetRun;
    ChapterGenerationRun? chapterRun;
    ChapterGenerationBatch? chapterBatch;
    ChapterEnrichmentBatch? enrichmentBatch;

    if (task.kind == styleAnalysisWorkflowTaskKind) {
      styleRun = await ref.read(
        styleAnalysisRunByWorkflowTaskProvider(task.id).future,
      );
    }
    if (task.kind == plotAnalysisWorkflowTaskKind) {
      plotRun = await ref.read(
        plotAnalysisRunByWorkflowTaskProvider(task.id).future,
      );
    }
    if (task.kind == assetGenerationWorkflowTaskKind) {
      assetRun = await ref.read(
        assetGenerationRunByWorkflowTaskProvider(task.id).future,
      );
    }
    if (task.kind == chapterGenerationWorkflowTaskKind) {
      chapterRun = await ref.read(
        chapterGenerationRunByWorkflowTaskProvider(task.id).future,
      );
    }
    if (task.kind == chapterGenerationBatchWorkflowTaskKind) {
      chapterBatch = await ref.read(
        chapterGenerationBatchByWorkflowTaskProvider(task.id).future,
      );
    }
    if (task.kind == chapterEnrichmentWorkflowTaskKind) {
      enrichmentBatch = await ref.read(
        chapterEnrichmentBatchByWorkflowTaskProvider(task.id).future,
      );
    }

    return WorkflowRunItem(
      task: task,
      styleRun: styleRun,
      plotRun: plotRun,
      assetRun: assetRun,
      chapterRun: chapterRun,
      chapterBatch: chapterBatch,
      enrichmentBatch: enrichmentBatch,
    );
  }));

  return items;
}
