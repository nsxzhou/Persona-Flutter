import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../llm/domain/llm_cancellation.dart';

part 'workflow_task_cancellation_registry.g.dart';

class WorkflowTaskCancellationRegistry {
  final _tokens = <String, LlmCancellationToken>{};

  LlmCancellationToken register(String workflowTaskId) {
    final token = LlmCancellationToken();
    _tokens[workflowTaskId]?.cancel();
    _tokens[workflowTaskId] = token;
    return token;
  }

  void unregister(String workflowTaskId, LlmCancellationToken token) {
    if (identical(_tokens[workflowTaskId], token)) {
      _tokens.remove(workflowTaskId);
    }
  }

  void cancel(String workflowTaskId) {
    _tokens[workflowTaskId]?.cancel();
  }
}

@Riverpod(keepAlive: true)
WorkflowTaskCancellationRegistry workflowTaskCancellationRegistry(Ref ref) {
  return WorkflowTaskCancellationRegistry();
}
