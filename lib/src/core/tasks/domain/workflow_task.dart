import 'package:freezed_annotation/freezed_annotation.dart';

part 'workflow_task.freezed.dart';
part 'workflow_task.g.dart';

enum WorkflowTaskStatus { pending, running, succeeded, failed, abandoned }

@freezed
abstract class WorkflowTask with _$WorkflowTask {
  const factory WorkflowTask({
    required String id,
    required String kind,
    required WorkflowTaskStatus status,
    required String title,
    String? stage,
    String? errorMessage,
    DateTime? previewDismissedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _WorkflowTask;

  factory WorkflowTask.fromJson(Map<String, Object?> json) =>
      _$WorkflowTaskFromJson(json);
}
