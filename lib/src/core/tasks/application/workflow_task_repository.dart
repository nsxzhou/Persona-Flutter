import '../domain/workflow_task.dart';

abstract interface class WorkflowTaskRepository {
  Stream<List<WorkflowTask>> watchRecentTasks();

  Future<void> upsertTask(WorkflowTask task);

  Future<void> updateTask({
    required String id,
    required WorkflowTaskStatus status,
    String? stage,
    String? errorMessage,
  });
}
