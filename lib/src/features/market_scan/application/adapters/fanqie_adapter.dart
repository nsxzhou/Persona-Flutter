import '../../../../core/llm/domain/llm_cancellation.dart';
import '../../domain/data_source_adapter.dart';
import '../../domain/market_book.dart';
import '../../domain/scraped_book.dart';
import '../scraper_process_runner.dart';

class FanqieAdapter extends DataSourceAdapter {
  FanqieAdapter(this._runner);

  final ScraperProcessRunner _runner;

  @override
  MarketPlatform get platform => MarketPlatform.fanqie;

  @override
  String get displayName => '番茄小说';

  @override
  bool get requiresCdp => true;

  @override
  Future<List<ScrapedBook>> scrapeCoreCharts({
    LlmCancellationToken? cancellationToken,
  }) {
    return _runner.run(
      'fanqie_scraper.js',
      cancellationToken: cancellationToken,
    );
  }
}
