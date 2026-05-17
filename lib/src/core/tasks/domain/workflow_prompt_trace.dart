class WorkflowPromptTrace {
  const WorkflowPromptTrace({
    required this.workflowTaskId,
    required this.traceMarkdown,
    required this.createdAt,
    required this.updatedAt,
  });

  final String workflowTaskId;
  final String traceMarkdown;
  final DateTime createdAt;
  final DateTime updatedAt;
}
