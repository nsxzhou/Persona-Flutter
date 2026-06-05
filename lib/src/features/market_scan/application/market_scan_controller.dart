import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/data_source_adapter.dart';
import 'market_scan_providers.dart';
import 'market_scan_service.dart';

part 'market_scan_controller.g.dart';

/// Per-platform scan status during a scan operation.
enum PlatformScanStatus {
  pending,
  scanning,
  completed,
  failed,

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
    this.platforms = const [],
    this.error,
  });

  final bool isScanning;
  final List<PlatformScanEntry> platforms;
  final String? error;

  bool get hasAnyData =>
      platforms.any((p) => p.status == PlatformScanStatus.completed && p.itemCount > 0);

  int get completedCount =>
      platforms.where((p) => p.status == PlatformScanStatus.completed).length;

  int get failedCount =>
      platforms.where((p) => p.status == PlatformScanStatus.failed).length;

  MarketScanState copyWith({
    bool? isScanning,
    List<PlatformScanEntry>? platforms,
    String? error,
  }) {
    return MarketScanState(
      isScanning: isScanning ?? this.isScanning,
      platforms: platforms ?? this.platforms,
      error: error,
    );
  }
}

/// Controller that manages manual scan operations with real-time progress.
@riverpod
class MarketScanController extends _$MarketScanController {
  @override
  MarketScanState build() => const MarketScanState();

  /// Trigger a full scan across all platforms in parallel,
  /// reporting per-platform progress.
  Future<void> scanNow() async {
    debugPrint('[ScanController] scanNow() called');
    final service = ref.read(marketScanServiceProvider);
    final adapters = service.adapters;
    debugPrint('[ScanController] ${adapters.length} adapters loaded');

    // Initialize all platforms as pending.
    state = MarketScanState(
      isScanning: true,
      platforms: [
        for (final a in adapters)
          PlatformScanEntry(
            platform: a.platform.name,
            displayName: a.displayName,
            status: PlatformScanStatus.pending,
          ),
      ],
    );

    // Run all platforms in parallel. Each updates its own slot.
    final futures = <Future<void>>[];
    for (var i = 0; i < adapters.length; i++) {
      final index = i;
      final adapter = adapters[index];

      futures.add(_runPlatform(index, adapter, service));
    }

    await Future.wait(futures);
    state = state.copyWith(isScanning: false);
  }

  Future<void> _runPlatform(
    int index,
    DataSourceAdapter adapter,
    MarketScanService service,
  ) async {
    // Mark as scanning.
    state = state.copyWith(
      platforms: _updatePlatform(index, (e) => e.copyWith(
        status: PlatformScanStatus.scanning,
      )),
    );

    try {
      // Auto-launch Chrome for adapters that need CDP.
      if (adapter.requiresCdp) {
        debugPrint('[ScanController] ${adapter.displayName} requires CDP, ensuring Chrome is ready...');
        final runner = ref.read(scraperProcessRunnerProvider);
        final cdpReady = await runner.ensureCdpReady();
        debugPrint('[ScanController] CDP ready: $cdpReady');
        if (!cdpReady) {
          state = state.copyWith(
            platforms: _updatePlatform(index, (e) => e.copyWith(
              status: PlatformScanStatus.cdpRequired,
              errorMessage: 'Chrome 未找到或无法启动。请手动以调试模式启动 Chrome:\n'
                  'Google Chrome --remote-debugging-port=9222',
            )),
          );
          return;
        }
      }

      final result = await service.scanPlatform(adapter);

      if (result.cdpRequired) {
        state = state.copyWith(
          platforms: _updatePlatform(index, (e) => e.copyWith(
            status: PlatformScanStatus.cdpRequired,
            errorMessage: result.errorMessage,
          )),
        );
      } else if (result.success) {
        state = state.copyWith(
          platforms: _updatePlatform(index, (e) => e.copyWith(
            status: PlatformScanStatus.completed,
            itemCount: result.itemCount,
          )),
        );
      } else {
        state = state.copyWith(
          platforms: _updatePlatform(index, (e) => e.copyWith(
            status: PlatformScanStatus.failed,
            errorMessage: result.errorMessage,
          )),
        );
      }
    } catch (e) {
      debugPrint('[ScanController] Platform ${adapter.displayName} threw: $e');
      state = state.copyWith(
        platforms: _updatePlatform(index, (e) => e.copyWith(
          status: PlatformScanStatus.failed,
          errorMessage: e.toString(),
        )),
      );
    }
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
