import '../../domain/data_source_adapter.dart';
import '../../domain/market_book.dart';
import '../../domain/scraped_book.dart';
import '../scraper_process_runner.dart';

class JinjiangAdapter implements DataSourceAdapter {
  const JinjiangAdapter(this._runner);

  final ScraperProcessRunner _runner;

  @override
  MarketPlatform get platform => MarketPlatform.jinjiang;

  @override
  String get displayName => '晋江文学城';

  @override
  Future<List<ScrapedBook>> scrapeCoreCharts() {
    return _runner.run('jinjiang_scraper.js');
  }
}
