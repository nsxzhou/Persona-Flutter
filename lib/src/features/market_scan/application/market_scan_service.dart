import '../domain/data_source_adapter.dart';
import '../domain/market_book.dart';
import '../domain/market_ranking.dart';
import '../domain/market_scan_repository.dart';
import '../domain/scraped_book.dart';

/// Orchestrates scraping across all platform adapters.
///
/// For each adapter: creates a run record, scrapes, upserts books,
/// inserts rankings, and marks the run as completed or failed.
class MarketScanService {
  const MarketScanService({
    required this.repository,
    required this.adapters,
  });

  final MarketScanRepository repository;
  final List<DataSourceAdapter> adapters;

  /// Run scraping for all platforms. Returns total items scraped.
  /// Each platform runs independently — one failure doesn't block others.
  Future<ScanAllResult> scanAll() async {
    final results = <String, PlatformScanResult>{};
    var totalItems = 0;

    for (final adapter in adapters) {
      final result = await scanPlatform(adapter);
      results[adapter.platform.name] = result;
      totalItems += result.itemCount;
    }

    return ScanAllResult(
      totalItems: totalItems,
      platformResults: results,
    );
  }

  /// Run scraping for a single platform.
  Future<PlatformScanResult> scanPlatform(DataSourceAdapter adapter) async {
    final run = await repository.createRun(adapter.platform.name);
    try {
      final scrapedBooks = await adapter.scrapeCoreCharts();
      if (scrapedBooks.isEmpty) {
        await repository.completeRun(runId: run.id, itemCount: 0);
        return PlatformScanResult(
          platform: adapter.displayName,
          itemCount: 0,
          success: true,
        );
      }

      // Group by book identity and upsert.
      final bookInputMap = <String, MarketBookInput>{};
      for (final scraped in scrapedBooks) {
        final key = '${scraped.platform.name}:${scraped.platformBookId}';
        bookInputMap.putIfAbsent(key, () => _toBookInput(scraped));
      }
      await repository.upsertBooks(bookInputMap.values.toList());

      // Resolve book IDs for ranking insertion.
      final rankingInputs = <_PendingRanking>[];
      for (final scraped in scrapedBooks) {
        final books = await repository.findBooks(platform: scraped.platform);
        final book = books.firstWhere(
          (b) => b.platformBookId == scraped.platformBookId,
          orElse: () => throw StateError(
            'Book not found after upsert: ${scraped.platformBookId}',
          ),
        );
        rankingInputs.add(_PendingRanking(bookId: book.id, scraped: scraped));
      }

      await repository.insertRankings(
        rankingInputs
            .map(
              (p) => MarketRankingInput(
                bookId: p.bookId,
                chartName: p.scraped.chartName,
                rank: p.scraped.rank,
                runId: run.id,
                favorites: p.scraped.favorites,
                recommendVotes: p.scraped.recommendVotes,
                monthlyTickets: p.scraped.monthlyTickets,
                commentCount: p.scraped.commentCount,
                scrapedAt: p.scraped.scrapedAt,
              ),
            )
            .toList(),
      );

      await repository.completeRun(runId: run.id, itemCount: scrapedBooks.length);
      return PlatformScanResult(
        platform: adapter.displayName,
        itemCount: scrapedBooks.length,
        success: true,
      );
    } catch (e) {
      await repository.failRun(
        runId: run.id,
        errorMessage: e.toString(),
      );
      return PlatformScanResult(
        platform: adapter.displayName,
        itemCount: 0,
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  MarketBookInput _toBookInput(ScrapedBook s) {
    return MarketBookInput(
      platform: s.platform,
      platformBookId: s.platformBookId,
      title: s.title,
      author: s.author,
      description: s.description,
      categories: s.categories,
      tags: s.tags,
      totalWordCount: s.totalWordCount,
      status: s.status,
      firstPublishDate: s.firstPublishDate,
    );
  }
}

class ScanAllResult {
  const ScanAllResult({
    required this.totalItems,
    required this.platformResults,
  });

  final int totalItems;
  final Map<String, PlatformScanResult> platformResults;

  bool get allSucceeded =>
      platformResults.values.every((r) => r.success);
}

class PlatformScanResult {
  const PlatformScanResult({
    required this.platform,
    required this.itemCount,
    required this.success,
    this.errorMessage,
  });

  final String platform;
  final int itemCount;
  final bool success;
  final String? errorMessage;
}

class _PendingRanking {
  const _PendingRanking({required this.bookId, required this.scraped});
  final String bookId;
  final ScrapedBook scraped;
}
