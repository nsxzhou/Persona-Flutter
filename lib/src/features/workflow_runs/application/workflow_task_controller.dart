import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/tasks/application/workflow_task_cancellation_registry.dart';
import '../../../core/tasks/application/workflow_task_providers.dart';
import '../../novel_workshop/application/novel_workshop_providers.dart';
import '../../novel_workshop/domain/novel_workshop.dart';

part 'workflow_task_controller.g.dart';

@Riverpod(keepAlive: true)
class WorkflowTaskController extends _$WorkflowTaskController {
  @override
  FutureOr<void> build() {}

  Future<void> abandon(String taskId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(workflowTaskCancellationRegistryProvider).cancel(taskId);
      final repository = ref.read(workflowTaskRepositoryProvider);
      final task = await repository.findTask(taskId);
      if (task == null) {
        return;
      }
      switch (task.kind) {
        case chapterGenerationWorkflowTaskKind:
        case chapterGenerationBatchWorkflowTaskKind:
        case assetGenerationWorkflowTaskKind:
        case chapterEnrichmentWorkflowTaskKind:
          await ref
              .read(novelWorkshopRepositoryProvider)
              .abandonWorkflowTask(taskId);
        default:
          await repository.abandonTask(taskId);
      }
    });
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
  }
}
