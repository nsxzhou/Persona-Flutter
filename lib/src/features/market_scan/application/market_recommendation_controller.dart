import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/llm/domain/llm_cancellation.dart';
import '../../../core/tasks/application/prompt_trace_recorder.dart';
import '../../../core/tasks/application/workflow_task_cancellation_registry.dart';
import '../../../core/tasks/application/workflow_task_providers.dart';
import '../../../core/tasks/application/workflow_task_repository.dart';
import '../../../core/tasks/domain/workflow_task.dart';
import '../domain/market_book.dart';
import '../domain/market_scan_workflow.dart';
import '../domain/recommendation_direction.dart';
import '../domain/recommendation_generation_request.dart';
import 'market_scan_providers.dart';

part 'market_recommendation_controller.g.dart';

class MarketRecommendationState {
  const MarketRecommendationState({
    this.isGenerating = false,
    this.workflowTaskId,
    this.directionsByPlatform = const {},
    this.errorMessage,
    this.generatedAt,
    this.currentGeneratingPlatform,
    this.completedPlatformCount = 0,
    this.totalPlatformCount = 0,
  });

  final bool isGenerating;
  final String? workflowTaskId;
  final Map<MarketPlatform, List<RecommendationDirection>> directionsByPlatform;
  final String? errorMessage;
  final DateTime? generatedAt;
  final MarketPlatform? currentGeneratingPlatform;
  final int completedPlatformCount;
  final int totalPlatformCount;

  bool get hasDirections => directionsByPlatform.isNotEmpty;

  List<RecommendationDirection> get directions {
    return directionsByPlatform.values.expand((items) => items).toList();
  }

  MarketRecommendationState copyWith({
    bool? isGenerating,
    String? workflowTaskId,
    bool clearWorkflowTaskId = false,
    Map<MarketPlatform, List<RecommendationDirection>>? directionsByPlatform,
    String? errorMessage,
    bool clearErrorMessage = false,
    DateTime? generatedAt,
    bool clearGeneratedAt = false,
    MarketPlatform? currentGeneratingPlatform,
    bool clearCurrentGeneratingPlatform = false,
    int? completedPlatformCount,
    int? totalPlatformCount,
  }) {
    return MarketRecommendationState(
      isGenerating: isGenerating ?? this.isGenerating,
      workflowTaskId: clearWorkflowTaskId
          ? null
          : workflowTaskId ?? this.workflowTaskId,
      directionsByPlatform: directionsByPlatform ?? this.directionsByPlatform,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      generatedAt: clearGeneratedAt ? null : generatedAt ?? this.generatedAt,
      currentGeneratingPlatform: clearCurrentGeneratingPlatform
          ? null
          : currentGeneratingPlatform ?? this.currentGeneratingPlatform,
      completedPlatformCount:
          completedPlatformCount ?? this.completedPlatformCount,
      totalPlatformCount: totalPlatformCount ?? this.totalPlatformCount,
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
    if (!request.isValid) {
      throw StateError('请至少选择一个目标平台和一个参考榜单。');
    }

    final targetPlatforms = request.targetPlatforms;
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
      directionsByPlatform: const {},
      clearErrorMessage: true,
      clearGeneratedAt: true,
      clearCurrentGeneratingPlatform: true,
      completedPlatformCount: 0,
      totalPlatformCount: targetPlatforms.length,
    );

    final directionsByPlatform =
        <MarketPlatform, List<RecommendationDirection>>{};
    String? failureMessage;

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

      for (var index = 0; index < targetPlatforms.length; index += 1) {
        final platform = targetPlatforms[index];
        state = state.copyWith(
          currentGeneratingPlatform: platform,
          completedPlatformCount: index,
        );
        await updateTask(
          WorkflowTaskStatus.running,
          stage: 'analyzing_patterns_${platform.name}',
        );
        try {
          final directions = await service.generate(
            request: request.forSinglePlatform(platform),
            provider: provider,
            cancellationToken: cancellationToken,
            promptTrace: traceRecorder.config(
              label: 'market_recommendation_${platform.name}',
            ),
            onStageChanged: (stage) async {
              await updateTask(
                WorkflowTaskStatus.running,
                stage: stage,
              );
            },
          );
          cancellationToken.throwIfCancelled();
          directionsByPlatform[platform] = directions;
          state = state.copyWith(
            directionsByPlatform: Map.unmodifiable(directionsByPlatform),
            completedPlatformCount: index + 1,
          );
        } on Object catch (error) {
          failureMessage = '${_platformLabel(platform)} 生成失败: $error';
          break;
        }
      }

      if (failureMessage != null && directionsByPlatform.isEmpty) {
        await updateTask(
          WorkflowTaskStatus.failed,
          clearStage: true,
          errorMessage: failureMessage,
        );
        state = state.copyWith(
          isGenerating: false,
          errorMessage: failureMessage,
          clearCurrentGeneratingPlatform: true,
        );
        return;
      }

      await updateTask(
        failureMessage == null
            ? WorkflowTaskStatus.succeeded
            : WorkflowTaskStatus.failed,
        clearStage: true,
        errorMessage: failureMessage,
        clearErrorMessage: failureMessage == null,
      );
      state = state.copyWith(
        isGenerating: false,
        directionsByPlatform: Map.unmodifiable(directionsByPlatform),
        generatedAt: DateTime.now(),
        errorMessage: failureMessage,
        clearErrorMessage: failureMessage == null,
        clearCurrentGeneratingPlatform: true,
        completedPlatformCount: directionsByPlatform.length,
      );
    } on LlmCancellationException {
      await taskRepository.abandonTask(task.id);
      state = state.copyWith(
        isGenerating: false,
        clearCurrentGeneratingPlatform: true,
        clearErrorMessage: true,
      );
    } on Object catch (error) {
      final message = error.toString();
      await updateTask(
        WorkflowTaskStatus.failed,
        clearStage: true,
        errorMessage: message,
      );
      state = state.copyWith(
        isGenerating: false,
        errorMessage: message,
        clearCurrentGeneratingPlatform: true,
      );
    } finally {
      cancellationRegistry.unregister(task.id, cancellationToken);
      await cancellationToken.dispose();
    }
  }

  void clearResults() {
    if (state.isGenerating) {
      return;
    }
    if (!state.hasDirections && state.errorMessage == null) {
      return;
    }
    state = state.copyWith(
      directionsByPlatform: const {},
      clearErrorMessage: true,
      clearGeneratedAt: true,
      clearCurrentGeneratingPlatform: true,
      completedPlatformCount: 0,
      totalPlatformCount: 0,
    );
  }

  void clear() {
    if (state.isGenerating) {
      throw StateError('推荐生成任务运行中，无法清空推荐结果。');
    }
    state = const MarketRecommendationState();
  }

  String _platformLabel(MarketPlatform platform) {
    return switch (platform) {
      MarketPlatform.qidian => '起点中文网',
      MarketPlatform.fanqie => '番茄小说',
    };
  }
}
