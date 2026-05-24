import '../domain/workflow_task.dart';
import '../domain/workflow_prompt_trace.dart';

abstract interface class WorkflowTaskRepository {
  Stream<List<WorkflowTask>> watchTasks();

  Stream<WorkflowTask?> watchTask(String id);

  Future<WorkflowTask?> findTask(String id);

  Future<void> abandonTask(String id);

  Future<void> dismissTaskPreview(String id);

  Stream<WorkflowPromptTrace?> watchPromptTrace(String workflowTaskId);

  Future<void> upsertPromptTrace({
    required String workflowTaskId,
    required String traceMarkdown,
  });
}
