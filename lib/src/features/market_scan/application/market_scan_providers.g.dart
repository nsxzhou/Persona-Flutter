// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_scan_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(marketScanRepository)
final marketScanRepositoryProvider = MarketScanRepositoryProvider._();

final class MarketScanRepositoryProvider
    extends
        $FunctionalProvider<
          MarketScanRepository,
          MarketScanRepository,
          MarketScanRepository
        >
    with $Provider<MarketScanRepository> {
  MarketScanRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'marketScanRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$marketScanRepositoryHash();

  @$internal
  @override
  $ProviderElement<MarketScanRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MarketScanRepository create(Ref ref) {
    return marketScanRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarketScanRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarketScanRepository>(value),
    );
  }
}

String _$marketScanRepositoryHash() =>
    r'94474c3fb1ba5cf24b26a9e4396bfd74f67d0d57';

@ProviderFor(scraperProcessRunner)
final scraperProcessRunnerProvider = ScraperProcessRunnerProvider._();

final class ScraperProcessRunnerProvider
    extends
        $FunctionalProvider<
          ScraperProcessRunner,
          ScraperProcessRunner,
          ScraperProcessRunner
        >
    with $Provider<ScraperProcessRunner> {
  ScraperProcessRunnerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scraperProcessRunnerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scraperProcessRunnerHash();

  @$internal
  @override
  $ProviderElement<ScraperProcessRunner> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ScraperProcessRunner create(Ref ref) {
    return scraperProcessRunner(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScraperProcessRunner value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScraperProcessRunner>(value),
    );
  }
}

String _$scraperProcessRunnerHash() =>
    r'f6d60d30714811f415f95d64d6a4cd099a9e3045';

@ProviderFor(dataSourceAdapters)
final dataSourceAdaptersProvider = DataSourceAdaptersProvider._();

final class DataSourceAdaptersProvider
    extends
        $FunctionalProvider<
          List<DataSourceAdapter>,
          List<DataSourceAdapter>,
          List<DataSourceAdapter>
        >
    with $Provider<List<DataSourceAdapter>> {
  DataSourceAdaptersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataSourceAdaptersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataSourceAdaptersHash();

  @$internal
  @override
  $ProviderElement<List<DataSourceAdapter>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<DataSourceAdapter> create(Ref ref) {
    return dataSourceAdapters(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<DataSourceAdapter> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<DataSourceAdapter>>(value),
    );
  }
}

String _$dataSourceAdaptersHash() =>
    r'87565500bb7149360b12de5302f5a9e50c34c2bc';

@ProviderFor(marketScanService)
final marketScanServiceProvider = MarketScanServiceProvider._();

final class MarketScanServiceProvider
    extends
        $FunctionalProvider<
          MarketScanService,
          MarketScanService,
          MarketScanService
        >
    with $Provider<MarketScanService> {
  MarketScanServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'marketScanServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$marketScanServiceHash();

  @$internal
  @override
  $ProviderElement<MarketScanService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MarketScanService create(Ref ref) {
    return marketScanService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarketScanService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarketScanService>(value),
    );
  }
}

String _$marketScanServiceHash() => r'b76a02764643e87db1517a8f92c3fe9640115afc';

@ProviderFor(ruleEngine)
final ruleEngineProvider = RuleEngineProvider._();

final class RuleEngineProvider
    extends $FunctionalProvider<RuleEngine, RuleEngine, RuleEngine>
    with $Provider<RuleEngine> {
  RuleEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ruleEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ruleEngineHash();

  @$internal
  @override
  $ProviderElement<RuleEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RuleEngine create(Ref ref) {
    return ruleEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RuleEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RuleEngine>(value),
    );
  }
}

String _$ruleEngineHash() => r'7e5bfc963d6f6a514ecc748e39b5283a22abf566';

@ProviderFor(recommendationGenerationService)
final recommendationGenerationServiceProvider =
    RecommendationGenerationServiceProvider._();

final class RecommendationGenerationServiceProvider
    extends
        $FunctionalProvider<
          RecommendationGenerationService,
          RecommendationGenerationService,
          RecommendationGenerationService
        >
    with $Provider<RecommendationGenerationService> {
  RecommendationGenerationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recommendationGenerationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recommendationGenerationServiceHash();

  @$internal
  @override
  $ProviderElement<RecommendationGenerationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecommendationGenerationService create(Ref ref) {
    return recommendationGenerationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecommendationGenerationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecommendationGenerationService>(
        value,
      ),
    );
  }
}

String _$recommendationGenerationServiceHash() =>
    r'2bc9754f622dd0e51a19f3a8539ab0f80b167432';

@ProviderFor(marketScanHasData)
final marketScanHasDataProvider = MarketScanHasDataProvider._();

final class MarketScanHasDataProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  MarketScanHasDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'marketScanHasDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$marketScanHasDataHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return marketScanHasData(ref);
  }
}

String _$marketScanHasDataHash() => r'8e67ab9c4af9d8f1b741be5b10fc494914692924';

@ProviderFor(scanDataBundle)
final scanDataBundleProvider = ScanDataBundleProvider._();

final class ScanDataBundleProvider
    extends
        $FunctionalProvider<
          AsyncValue<ScanDataBundle>,
          ScanDataBundle,
          FutureOr<ScanDataBundle>
        >
    with $FutureModifier<ScanDataBundle>, $FutureProvider<ScanDataBundle> {
  ScanDataBundleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scanDataBundleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scanDataBundleHash();

  @$internal
  @override
  $FutureProviderElement<ScanDataBundle> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ScanDataBundle> create(Ref ref) {
    return scanDataBundle(ref);
  }
}

String _$scanDataBundleHash() => r'2485342e004dbfc14368e71dda5d02a116399587';
