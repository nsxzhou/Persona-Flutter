import '../../../core/llm/domain/llm_cancellation.dart';
import '../domain/market_book.dart';
import '../domain/scraped_book.dart';

/// Platform-specific scraper implementation.
/// Each adapter wraps a Node.js script via [ScraperProcessRunner].
abstract class DataSourceAdapter {
  /// Platform identifier.
  MarketPlatform get platform;

  /// Human-readable platform name for logging.
  String get displayName;

  /// Whether this adapter requires Chrome DevTools Protocol.
  /// When true, the scraper connects to an existing Chrome instance
  /// rather than launching its own browser.
  bool get requiresCdp => false;

  /// Scrape core charts from this platform.
  /// Returns raw scraped books; the caller is responsible for persistence.
  Future<List<ScrapedBook>> scrapeCoreCharts({
    LlmCancellationToken? cancellationToken,
  });
}
