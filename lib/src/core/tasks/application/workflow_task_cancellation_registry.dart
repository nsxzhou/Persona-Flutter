import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../llm/domain/llm_cancellation.dart';

part 'workflow_task_cancellation_registry.g.dart';

class WorkflowTaskCancellationRegistry {
  final _tokens = <String, LlmCancellationToken>{};
  final _callbacks = <String, FutureOr<void> Function()>{};

  LlmCancellationToken register(String workflowTaskId) {
    final token = LlmCancellationToken();
    _tokens[workflowTaskId]?.cancel();
    _tokens[workflowTaskId] = token;
    return token;
  }

  void registerCallback(
    String workflowTaskId,
    FutureOr<void> Function() onCancel,
  ) {
    _callbacks[workflowTaskId] = onCancel;
  }

  void unregister(String workflowTaskId, LlmCancellationToken token) {
    if (identical(_tokens[workflowTaskId], token)) {
      _tokens.remove(workflowTaskId);
    }
  }

  void unregisterCallback(
    String workflowTaskId,
    FutureOr<void> Function() onCancel,
  ) {
    if (identical(_callbacks[workflowTaskId], onCancel)) {
      _callbacks.remove(workflowTaskId);
    }
  }

  Future<void> cancel(String workflowTaskId) async {
    _tokens[workflowTaskId]?.cancel();
    final callback = _callbacks[workflowTaskId];
    if (callback != null) {
      await callback();
    }
  }
}

@Riverpod(keepAlive: true)
WorkflowTaskCancellationRegistry workflowTaskCancellationRegistry(Ref ref) {
  return WorkflowTaskCancellationRegistry();
}
