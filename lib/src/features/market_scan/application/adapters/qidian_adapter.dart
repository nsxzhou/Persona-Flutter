import '../../domain/data_source_adapter.dart';
import '../../domain/market_book.dart';
import '../../domain/scraped_book.dart';
import '../scraper_process_runner.dart';

class QidianAdapter extends DataSourceAdapter {
  QidianAdapter(this._runner);

  final ScraperProcessRunner _runner;

  @override
  MarketPlatform get platform => MarketPlatform.qidian;

  @override
  String get displayName => '起点中文网';

  @override
  Future<List<ScrapedBook>> scrapeCoreCharts() {
    return _runner.run('qidian_scraper.js');
  }
}
