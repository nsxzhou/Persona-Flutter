import '../../../../core/llm/domain/llm_cancellation.dart';
import '../../domain/data_source_adapter.dart';
import '../../domain/market_book.dart';
import '../../domain/scraped_book.dart';
import '../scraper_process_runner.dart';

class JinjiangAdapter extends DataSourceAdapter {
  JinjiangAdapter(this._runner);

  final ScraperProcessRunner _runner;

  @override
  MarketPlatform get platform => MarketPlatform.jinjiang;

  @override
  String get displayName => '晋江文学城';

  @override
  Future<List<ScrapedBook>> scrapeCoreCharts({
    LlmCancellationToken? cancellationToken,
  }) {
    return _runner.run(
      'jinjiang_scraper.js',
      cancellationToken: cancellationToken,
    );
  }
}
