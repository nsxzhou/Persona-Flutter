import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/database_providers.dart';
import '../data/drift_market_scan_repository.dart';
import '../domain/data_source_adapter.dart';
import '../domain/market_scan_repository.dart';
import 'adapters/fanqie_adapter.dart';
import 'adapters/jinjiang_adapter.dart';
import 'adapters/qidian_adapter.dart';
import '../../settings/application/provider_config_providers.dart';
import '../../style_lab/application/style_lab_providers.dart';
import 'market_scan_scheduler.dart';
import 'market_scan_service.dart';
import 'recommendation_generation_service.dart';
import 'rule_engine.dart';
import 'scraper_process_runner.dart';

part 'market_scan_providers.g.dart';

@Riverpod(keepAlive: true)
MarketScanRepository marketScanRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftMarketScanRepository(database);
}

@Riverpod(keepAlive: true)
ScraperProcessRunner scraperProcessRunner(Ref ref) {
  return ScraperProcessRunner();
}

@Riverpod(keepAlive: true)
List<DataSourceAdapter> dataSourceAdapters(Ref ref) {
  final runner = ref.watch(scraperProcessRunnerProvider);
  return [
    QidianAdapter(runner),
    FanqieAdapter(runner),
    JinjiangAdapter(runner),
  ];
}

@Riverpod(keepAlive: true)
MarketScanService marketScanService(Ref ref) {
  final repository = ref.watch(marketScanRepositoryProvider);
  final adapters = ref.watch(dataSourceAdaptersProvider);
  final runner = ref.watch(scraperProcessRunnerProvider);
  return MarketScanService(repository: repository, adapters: adapters, runner: runner);
}

@Riverpod(keepAlive: true)
MarketScanScheduler marketScanScheduler(Ref ref) {
  final repository = ref.watch(marketScanRepositoryProvider);
  final service = ref.watch(marketScanServiceProvider);
  final scheduler = MarketScanScheduler(repository: repository, service: service);
  ref.onDispose(scheduler.dispose);
  return scheduler;
}

@Riverpod(keepAlive: true)
RuleEngine ruleEngine(Ref ref) {
  final repository = ref.watch(marketScanRepositoryProvider);
  return RuleEngine(repository);
}

@Riverpod(keepAlive: true)
RecommendationGenerationService recommendationGenerationService(Ref ref) {
  return RecommendationGenerationService(
    ruleEngine: ref.watch(ruleEngineProvider),
    completionService: ref.watch(markdownCompletionServiceProvider),
    providerRepository: ref.watch(providerConfigRepositoryProvider),
  );
}

@riverpod
Future<bool> marketScanHasData(Ref ref) {
  final repository = ref.watch(marketScanRepositoryProvider);
  return repository.hasData();
}
