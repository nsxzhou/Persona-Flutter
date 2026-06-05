import 'dart:async';

import '../domain/market_scan_repository.dart';
import 'market_scan_service.dart';

/// Background scheduler that checks whether market data needs refreshing
/// and triggers scraping when the last completed run is older than 24 hours.
///
/// Uses in-process [Timer] — does not survive app termination.
/// Periodic check runs every 6 hours while the app is open.
class MarketScanScheduler {
  MarketScanScheduler({
    required this.repository,
    required this.service,
    this.staleThreshold = const Duration(hours: 24),
    this.checkInterval = const Duration(hours: 6),
  });

  final MarketScanRepository repository;
  final MarketScanService service;
  final Duration staleThreshold;
  final Duration checkInterval;

  Timer? _periodicTimer;
  bool _isRunning = false;

  /// Whether a scan is currently in progress.
  bool get isRunning => _isRunning;

  /// Called once on app startup. Checks staleness and kicks off a scan if
  /// needed, then starts the periodic timer for subsequent checks.
  Future<void> init() async {
    await _checkAndScanIfNeeded();
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(checkInterval, (_) {
      _checkAndScanIfNeeded();
    });
  }

  /// Stop the periodic timer. Call from AppShell.dispose().
  void dispose() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  /// Manually trigger a full scan regardless of staleness.
  /// Returns the scan result. Guards against concurrent execution.
  Future<ScanAllResult?> scanNow() async {
    if (_isRunning) return null;
    _isRunning = true;
    try {
      return await service.scanAll();
    } finally {
      _isRunning = false;
    }
  }

  Future<void> _checkAndScanIfNeeded() async {
    if (_isRunning) return;

    try {
      if (await _isDataStale()) {
        await scanNow();
      }
    } catch (_) {
      // Silently absorb failures — they are persisted in run records
      // and surfaced via the UI when the user opens the recommendation page.
    }
  }

  Future<bool> _isDataStale() async {
    final latestRuns = await repository.findLatestCompletedRuns();
    if (latestRuns.isEmpty) {
      // No data at all — definitely stale.
      return true;
    }

    // Find the oldest "latest completed" timestamp across all platforms.
    // If any platform's data is stale, trigger a full re-scan.
    final now = DateTime.now();
    for (final run in latestRuns.values) {
      if (run.completedAt == null) return true;
      if (now.difference(run.completedAt!) > staleThreshold) {
        return true;
      }
    }
    return false;
  }
}
