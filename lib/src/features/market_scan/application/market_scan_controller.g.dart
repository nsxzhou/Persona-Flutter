// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_scan_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller that manages manual scan operations with real-time progress.

@ProviderFor(MarketScanController)
final marketScanControllerProvider = MarketScanControllerProvider._();

/// Controller that manages manual scan operations with real-time progress.
final class MarketScanControllerProvider
    extends $NotifierProvider<MarketScanController, MarketScanState> {
  /// Controller that manages manual scan operations with real-time progress.
  MarketScanControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'marketScanControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$marketScanControllerHash();

  @$internal
  @override
  MarketScanController create() => MarketScanController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarketScanState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarketScanState>(value),
    );
  }
}

String _$marketScanControllerHash() =>
    r'e870db5fade13b008db28bf3c4e488b7286e3054';

/// Controller that manages manual scan operations with real-time progress.

abstract class _$MarketScanController extends $Notifier<MarketScanState> {
  MarketScanState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MarketScanState, MarketScanState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MarketScanState, MarketScanState>,
              MarketScanState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
