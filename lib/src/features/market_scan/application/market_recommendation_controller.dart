import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/llm/domain/llm_cancellation.dart';
import '../../../core/tasks/application/prompt_trace_recorder.dart';
import '../../../core/tasks/application/workflow_task_cancellation_registry.dart';
import '../../../core/tasks/application/workflow_task_providers.dart';
import '../../../core/tasks/application/workflow_task_repository.dart';
import '../../../core/tasks/domain/workflow_task.dart';
import '../domain/market_scan_workflow.dart';
import '../domain/recommendation_direction.dart';
import '../domain/recommendation_generation_request.dart';
import 'market_scan_providers.dart';

part 'market_recommendation_controller.g.dart';

class MarketRecommendationState {
  const MarketRecommendationState({
    this.isGenerating = false,
    this.workflowTaskId,
    this.directions = const [],
    this.errorMessage,
    this.generatedAt,
  });

  final bool isGenerating;
  final String? workflowTaskId;
  final List<RecommendationDirection> directions;
  final String? errorMessage;
  final DateTime? generatedAt;

  bool get hasDirections => directions.isNotEmpty;

  MarketRecommendationState copyWith({
    bool? isGenerating,
    String? workflowTaskId,
    bool clearWorkflowTaskId = false,
    List<RecommendationDirection>? directions,
    String? errorMessage,
    bool clearErrorMessage = false,
    DateTime? generatedAt,
    bool clearGeneratedAt = false,
  }) {
    return MarketRecommendationState(
      isGenerating: isGenerating ?? this.isGenerating,
      workflowTaskId: clearWorkflowTaskId
          ? null
          : workflowTaskId ?? this.workflowTaskId,
      directions: directions ?? this.directions,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      generatedAt: clearGeneratedAt ? null : generatedAt ?? this.generatedAt,
    );
  }
}

@Riverpod(keepAlive: true)
class MarketRecommendationController extends _$MarketRecommendationController {
  @override
  MarketRecommendationState build() => const MarketRecommendationState();

  Future<void> generate(RecommendationGenerationRequest request) async {
    if (state.isGenerating) {
      return;
    }

    final taskRepository = ref.read(workflowTaskRepositoryProvider);
    final cancellationRegistry = ref.read(
      workflowTaskCancellationRegistryProvider,
    );
    final task = await taskRepository.createTask(
      const WorkflowTaskInput(
        kind: marketRecommendationWorkflowTaskKind,
        title: '创作方向推荐',
        stage: 'queued',
      ),
    );
    final cancellationToken = cancellationRegistry.register(task.id);
    var currentStage = 'queued';

    Future<void> updateTask(
      WorkflowTaskStatus status, {
      String? stage,
      bool clearStage = false,
      String? errorMessage,
      bool clearErrorMessage = false,
    }) async {
      currentStage = stage ?? (clearStage ? '' : currentStage);
      await taskRepository.updateTaskState(
        id: task.id,
        status: status,
        stage: stage,
        clearStage: clearStage,
        errorMessage: errorMessage,
        clearErrorMessage: clearErrorMessage,
      );
    }

    state = state.copyWith(
      isGenerating: true,
      workflowTaskId: task.id,
      directions: const [],
      clearErrorMessage: true,
      clearGeneratedAt: true,
    );

    try {
      await updateTask(
        WorkflowTaskStatus.running,
        stage: 'resolving_provider',
        clearErrorMessage: true,
      );
      cancellationToken.throwIfCancelled();

      final service = ref.read(recommendationGenerationServiceProvider);
      final provider = await service.requireEnabledProvider();
      final traceRecorder = PromptTraceRecorder(
        repository: taskRepository,
        workflowTaskId: task.id,
        workflowKind: marketRecommendationWorkflowTaskKind,
        runId: task.id,
        providerId: provider.id,
        providerApiKey: provider.apiKey,
        modelName: provider.defaultModel,
        stageLabel: () => currentStage.isEmpty ? null : currentStage,
      );

      await updateTask(WorkflowTaskStatus.running, stage: 'generating');
      final directions = await service.generate(
        request: request,
        provider: provider,
        cancellationToken: cancellationToken,
        promptTrace: traceRecorder.config(label: 'market_recommendation'),
      );
      cancellationToken.throwIfCancelled();

      await updateTask(
        WorkflowTaskStatus.succeeded,
        clearStage: true,
        clearErrorMessage: true,
      );
      state = state.copyWith(
        isGenerating: false,
        directions: directions,
        generatedAt: DateTime.now(),
        clearErrorMessage: true,
      );
    } on LlmCancellationException {
      await taskRepository.abandonTask(task.id);
      state = state.copyWith(isGenerating: false, clearErrorMessage: true);
    } on Object catch (error) {
      final message = error.toString();
      await updateTask(
        WorkflowTaskStatus.failed,
        clearStage: true,
        errorMessage: message,
      );
      state = state.copyWith(isGenerating: false, errorMessage: message);
    } finally {
      cancellationRegistry.unregister(task.id, cancellationToken);
      await cancellationToken.dispose();
    }
  }

  void clear() {
    if (state.isGenerating) {
      throw StateError('推荐生成任务运行中，无法清空推荐结果。');
    }
    state = const MarketRecommendationState();
  }
}
