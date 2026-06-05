import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'market_scan_providers.dart';

part 'market_scan_controller.g.dart';

/// Per-platform scan status during a scan operation.
enum PlatformScanStatus { pending, scanning, completed, failed }

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

  /// Trigger a full scan across all platforms, reporting per-platform progress.
  Future<void> scanNow() async {
    final service = ref.read(marketScanServiceProvider);
    final adapters = service.adapters;

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

    for (var i = 0; i < adapters.length; i++) {
      final adapter = adapters[i];

      // Mark current platform as scanning.
      state = state.copyWith(
        platforms: _updatePlatform(i, (e) => e.copyWith(
          status: PlatformScanStatus.scanning,
        )),
      );

      try {
        final result = await service.scanPlatform(adapter);
        state = state.copyWith(
          platforms: _updatePlatform(i, (e) => e.copyWith(
            status: PlatformScanStatus.completed,
            itemCount: result.itemCount,
          )),
        );
      } catch (e) {
        state = state.copyWith(
          platforms: _updatePlatform(i, (e) => e.copyWith(
            status: PlatformScanStatus.failed,
            errorMessage: e.toString(),
          )),
        );
      }
    }

    state = state.copyWith(isScanning: false);
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
