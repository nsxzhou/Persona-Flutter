import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/llm/domain/llm_cancellation.dart';
import '../../../core/tasks/application/workflow_task_cancellation_registry.dart';
import '../../../core/tasks/application/workflow_task_providers.dart';
import '../../../core/tasks/application/workflow_task_repository.dart';
import '../../../core/tasks/domain/workflow_task.dart';
import '../domain/data_source_adapter.dart';
import '../domain/market_scan_workflow.dart';
import 'market_recommendation_controller.dart';
import 'market_scan_providers.dart';
import 'market_scan_service.dart';

part 'market_scan_controller.g.dart';

/// Per-platform scan status during a scan operation.
enum PlatformScanStatus {
  pending,
  scanning,
  completed,
  failed,
  abandoned,

  /// Chrome DevTools Protocol not available — user needs to start Chrome
  /// in debug mode for this platform to work.
  cdpRequired,
}

class PlatformScanEntry {
  const PlatformScanEntry({
    required this.platform,
    required this.displayName,
    required this.status,
    this.itemCount = 0,
    this.errorMessage,
  });

  final String platform;
  final String displayName;
  final PlatformScanStatus status;
  final int itemCount;
  final String? errorMessage;

  PlatformScanEntry copyWith({
    PlatformScanStatus? status,
    int? itemCount,
    String? errorMessage,
  }) {
    return PlatformScanEntry(
      platform: platform,
      displayName: displayName,
      status: status ?? this.status,
      itemCount: itemCount ?? this.itemCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class MarketScanState {
  const MarketScanState({
    this.isScanning = false,
    this.isClearing = false,
    this.workflowTaskId,
    this.platforms = const [],
    this.error,
    this.startedAt,
  });

  final bool isScanning;
  final bool isClearing;
  final String? workflowTaskId;
  final List<PlatformScanEntry> platforms;
  final String? error;
  final DateTime? startedAt;

  bool get hasAnyData => platforms.any(
    (p) => p.status == PlatformScanStatus.completed && p.itemCount > 0,
  );

  int get completedCount =>
      platforms.where((p) => p.status == PlatformScanStatus.completed).length;

  int get failedCount =>
      platforms.where((p) => p.status == PlatformScanStatus.failed).length;

  int get blockedCount =>
      platforms.where((p) => p.status == PlatformScanStatus.cdpRequired).length;

  int get abandonedCount =>
      platforms.where((p) => p.status == PlatformScanStatus.abandoned).length;

  MarketScanState copyWith({
    bool? isScanning,
    bool? isClearing,
    String? workflowTaskId,
    bool clearWorkflowTaskId = false,
    List<PlatformScanEntry>? platforms,
    String? error,
    bool clearError = false,
    DateTime? startedAt,
    bool clearStartedAt = false,
  }) {
    return MarketScanState(
      isScanning: isScanning ?? this.isScanning,
      isClearing: isClearing ?? this.isClearing,
      workflowTaskId: clearWorkflowTaskId
          ? null
          : workflowTaskId ?? this.workflowTaskId,
      platforms: platforms ?? this.platforms,
      error: clearError ? null : error ?? this.error,
      startedAt: clearStartedAt ? null : startedAt ?? this.startedAt,
    );
  }
}

/// Controller that manages manual scan operations with real-time progress.
@Riverpod(keepAlive: true)
class MarketScanController extends _$MarketScanController {
  @override
  MarketScanState build() => const MarketScanState();

  /// Trigger a full scan across all platforms in parallel,
  /// reporting per-platform progress.
  Future<void> scanNow() async {
    if (state.isScanning) {
      return;
    }
    final service = ref.read(marketScanServiceProvider);
    final adapters = service.adapters;
    final taskRepository = ref.read(workflowTaskRepositoryProvider);
    final cancellationRegistry = ref.read(
      workflowTaskCancellationRegistryProvider,
    );
    final task = await taskRepository.createTask(
      const WorkflowTaskInput(
        kind: marketScanWorkflowTaskKind,
        title: '市场扫描',
        stage: 'queued',
      ),
    );
    final cancellationToken = cancellationRegistry.register(task.id);

    // Initialize all platforms as pending.
    state = MarketScanState(
      isScanning: true,
      workflowTaskId: task.id,
      startedAt: DateTime.now(),
      platforms: [
        for (final a in adapters)
          PlatformScanEntry(
            platform: a.platform.name,
            displayName: a.displayName,
            status: PlatformScanStatus.pending,
          ),
      ],
    );

    try {
      await taskRepository.updateTaskState(
        id: task.id,
        status: WorkflowTaskStatus.running,
        stage: 'scanning_platforms',
        clearErrorMessage: true,
      );
      cancellationToken.throwIfCancelled();

      // Run all platforms in parallel. Each updates its own slot.
      final futures = <Future<void>>[];
      for (var i = 0; i < adapters.length; i++) {
        final index = i;
        final adapter = adapters[index];

        futures.add(_runPlatform(index, adapter, service, cancellationToken));
      }

      await Future.wait(futures);
      cancellationToken.throwIfCancelled();
      await _finishWorkflowTask(taskRepository, task.id);
      state = state.copyWith(isScanning: false);
    } on LlmCancellationException {
      await taskRepository.abandonTask(task.id);
      state = state.copyWith(
        isScanning: false,
        platforms: [
          for (final entry in state.platforms)
            if (entry.status == PlatformScanStatus.scanning ||
                entry.status == PlatformScanStatus.pending)
              entry.copyWith(status: PlatformScanStatus.abandoned)
            else
              entry,
        ],
        clearError: true,
      );
    } on Object catch (error) {
      final message = error.toString();
      await taskRepository.updateTaskState(
        id: task.id,
        status: WorkflowTaskStatus.failed,
        clearStage: true,
        errorMessage: message,
      );
      state = state.copyWith(isScanning: false, error: message);
    } finally {
      cancellationRegistry.unregister(task.id, cancellationToken);
      await cancellationToken.dispose();
      ref.invalidate(marketScanHasDataProvider);
      ref.invalidate(scanDataBundleProvider);
    }
  }

  Future<void> clearAllData() async {
    if (state.isScanning) {
      throw StateError('市场扫描任务运行中，无法清空扫描数据。');
    }
    final recommendationState = ref.read(
      marketRecommendationControllerProvider,
    );
    if (recommendationState.isGenerating) {
      throw StateError('创作推荐任务运行中，无法清空扫描数据。');
    }

    state = state.copyWith(isClearing: true, clearError: true);
    try {
      await ref.read(marketScanRepositoryProvider).clearAllData();
      ref.read(marketRecommendationControllerProvider.notifier).clear();
      ref.invalidate(marketScanHasDataProvider);
      ref.invalidate(scanDataBundleProvider);
      state = const MarketScanState();
    } on Object catch (error) {
      state = state.copyWith(isClearing: false, error: error.toString());
      rethrow;
    }
  }

  Future<void> _runPlatform(
    int index,
    DataSourceAdapter adapter,
    MarketScanService service,
    LlmCancellationToken cancellationToken,
  ) async {
    cancellationToken.throwIfCancelled();
    // Mark as scanning.
    state = state.copyWith(
      platforms: _updatePlatform(
        index,
        (e) => e.copyWith(status: PlatformScanStatus.scanning),
      ),
    );

    try {
      // Auto-launch Chrome for adapters that need CDP.
      if (adapter.requiresCdp) {
        final runner = ref.read(scraperProcessRunnerProvider);
        final cdpReady = await runner.ensureCdpReady(
          cancellationToken: cancellationToken,
        );
        if (!cdpReady) {
          state = state.copyWith(
            platforms: _updatePlatform(
              index,
              (e) => e.copyWith(
                status: PlatformScanStatus.cdpRequired,
                errorMessage:
                    'Chrome 未找到或无法启动。请手动以调试模式启动 Chrome:\n'
                    'Google Chrome --remote-debugging-port=9222',
              ),
            ),
          );
          return;
        }
      }

      final result = await service.scanPlatform(
        adapter,
        cancellationToken: cancellationToken,
      );

      if (result.cdpRequired) {
        state = state.copyWith(
          platforms: _updatePlatform(
            index,
            (e) => e.copyWith(
              status: PlatformScanStatus.cdpRequired,
              errorMessage: result.errorMessage,
            ),
          ),
        );
      } else if (result.success) {
        state = state.copyWith(
          platforms: _updatePlatform(
            index,
            (e) => e.copyWith(
              status: PlatformScanStatus.completed,
              itemCount: result.itemCount,
            ),
          ),
        );
      } else {
        state = state.copyWith(
          platforms: _updatePlatform(
            index,
            (e) => e.copyWith(
              status: PlatformScanStatus.failed,
              errorMessage: result.errorMessage,
            ),
          ),
        );
      }
    } on LlmCancellationException {
      state = state.copyWith(
        platforms: _updatePlatform(
          index,
          (e) => e.copyWith(status: PlatformScanStatus.abandoned),
        ),
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        platforms: _updatePlatform(
          index,
          (e) => e.copyWith(
            status: PlatformScanStatus.failed,
            errorMessage: e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> _finishWorkflowTask(
    WorkflowTaskRepository taskRepository,
    String taskId,
  ) async {
    final completed = state.completedCount;
    final failures = [
      ...state.platforms.where((entry) {
        return entry.status == PlatformScanStatus.failed ||
            entry.status == PlatformScanStatus.cdpRequired;
      }),
    ];
    final status = completed > 0
        ? WorkflowTaskStatus.succeeded
        : WorkflowTaskStatus.failed;
    final errorMessage = failures.isEmpty
        ? null
        : failures
              .map((entry) {
                final reason = entry.errorMessage?.trim();
                return reason == null || reason.isEmpty
                    ? '${entry.displayName} 未完成'
                    : '${entry.displayName}: $reason';
              })
              .join('\n');
    await taskRepository.updateTaskState(
      id: taskId,
      status: status,
      clearStage: true,
      errorMessage: errorMessage,
      clearErrorMessage: errorMessage == null,
    );
  }

  List<PlatformScanEntry> _updatePlatform(
    int index,
    PlatformScanEntry Function(PlatformScanEntry) updater,
  ) {
    final updated = [...state.platforms];
    updated[index] = updater(updated[index]);
    return updated;
  }
}
