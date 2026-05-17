import '../domain/workflow_task.dart';

abstract interface class WorkflowTaskRepository {
  Stream<List<WorkflowTask>> watchRecentTasks();
}
