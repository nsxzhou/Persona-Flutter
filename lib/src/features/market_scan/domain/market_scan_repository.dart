import 'market_book.dart';
import 'market_ranking.dart';
import 'market_scan_run.dart';

abstract interface class MarketScanRepository {
  /// All books, optionally filtered by platform.
  Future<List<MarketBook>> findBooks({MarketPlatform? platform});

  /// Upsert a book by (platform, platformBookId). Returns the persisted book.
  Future<MarketBook> upsertBook(MarketBookInput input);

  /// Bulk upsert books. Returns the count of upserted books.
  Future<int> upsertBooks(List<MarketBookInput> inputs);

  /// Rankings for a given run, optionally filtered by chart name.
  Future<List<MarketRanking>> findRankings({
    required String runId,
    String? chartName,
  });

  /// Latest rankings across all runs, grouped by chart.
  Future<List<MarketRanking>> findLatestRankings({MarketPlatform? platform});

  /// Insert rankings in bulk.
  Future<void> insertRankings(List<MarketRankingInput> inputs);

  /// All scan runs, newest first.
  Future<List<MarketScanRun>> findRuns({int? limit});

  /// Latest completed run per platform.
  Future<Map<String, MarketScanRun>> findLatestCompletedRuns();

  /// Create a new run record with status=running.
  Future<MarketScanRun> createRun(String platform);

  /// Mark a run as completed.
  Future<void> completeRun({required String runId, required int itemCount});

  /// Mark a run as failed.
  Future<void> failRun({required String runId, required String errorMessage});

  /// Whether any market data exists (at least one completed run).
  Future<bool> hasData();
}
