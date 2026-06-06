import '../domain/workflow_task.dart';
import '../domain/workflow_prompt_trace.dart';

class WorkflowTaskInput {
  const WorkflowTaskInput({
    this.id,
    required this.kind,
    required this.title,
    this.status = WorkflowTaskStatus.pending,
    this.stage,
    this.errorMessage,
  });

  final String? id;
  final String kind;
  final String title;
  final WorkflowTaskStatus status;
  final String? stage;
  final String? errorMessage;
}

abstract interface class WorkflowTaskRepository {
  Stream<List<WorkflowTask>> watchTasks();

  Stream<WorkflowTask?> watchTask(String id);

  Future<WorkflowTask?> findTask(String id);

  Future<WorkflowTask> createTask(WorkflowTaskInput input);

  Future<WorkflowTask?> updateTaskState({
    required String id,
    WorkflowTaskStatus? status,
    String? stage,
    bool clearStage = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  });

  Future<void> abandonTask(String id);

  Future<void> dismissTaskPreview(String id);

  Stream<WorkflowPromptTrace?> watchPromptTrace(String workflowTaskId);

  Future<void> upsertPromptTrace({
    required String workflowTaskId,
    required String traceMarkdown,
  });
}
