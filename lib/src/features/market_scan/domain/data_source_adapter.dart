import '../domain/market_book.dart';
import '../domain/scraped_book.dart';

/// Platform-specific scraper implementation.
/// Each adapter wraps a Node.js Puppeteer script via [ScraperProcessRunner].
abstract interface class DataSourceAdapter {
  /// Platform identifier.
  MarketPlatform get platform;

  /// Human-readable platform name for logging.
  String get displayName;

  /// Scrape core charts from this platform.
  /// Returns raw scraped books; the caller is responsible for persistence.
  Future<List<ScrapedBook>> scrapeCoreCharts();
}
