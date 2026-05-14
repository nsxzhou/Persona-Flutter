import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../database/database_providers.dart';
import '../data/drift_workflow_task_repository.dart';
import '../domain/workflow_task.dart';
import 'workflow_task_repository.dart';

part 'workflow_task_providers.g.dart';

@Riverpod(keepAlive: true)
WorkflowTaskRepository workflowTaskRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftWorkflowTaskRepository(database);
}

@riverpod
Stream<List<WorkflowTask>> recentWorkflowTasks(Ref ref) {
  final repository = ref.watch(workflowTaskRepositoryProvider);
  return repository.watchRecentTasks();
}
