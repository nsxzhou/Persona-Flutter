import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../database/database_providers.dart';
import '../data/drift_workflow_task_repository.dart';
import '../domain/workflow_prompt_trace.dart';
import '../domain/workflow_task.dart';
import 'workflow_task_repository.dart';

part 'workflow_task_providers.g.dart';

@Riverpod(keepAlive: true)
WorkflowTaskRepository workflowTaskRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftWorkflowTaskRepository(database);
}

@riverpod
Stream<List<WorkflowTask>> workflowTasks(Ref ref) {
  final repository = ref.watch(workflowTaskRepositoryProvider);
  return repository.watchTasks();
}

@riverpod
Stream<WorkflowTask?> workflowTask(Ref ref, String id) {
  final repository = ref.watch(workflowTaskRepositoryProvider);
  return repository.watchTask(id);
}

@riverpod
Stream<WorkflowPromptTrace?> workflowPromptTrace(
  Ref ref,
  String workflowTaskId,
) {
  final repository = ref.watch(workflowTaskRepositoryProvider);
  return repository.watchPromptTrace(workflowTaskId);
}
