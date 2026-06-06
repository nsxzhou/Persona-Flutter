// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_recommendation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MarketRecommendationController)
final marketRecommendationControllerProvider =
    MarketRecommendationControllerProvider._();

final class MarketRecommendationControllerProvider
    extends
        $NotifierProvider<
          MarketRecommendationController,
          MarketRecommendationState
        > {
  MarketRecommendationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'marketRecommendationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$marketRecommendationControllerHash();

  @$internal
  @override
  MarketRecommendationController create() => MarketRecommendationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarketRecommendationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarketRecommendationState>(value),
    );
  }
}

String _$marketRecommendationControllerHash() =>
    r'bd900b06cb06f49c58236f92655c34aec6135449';

abstract class _$MarketRecommendationController
    extends $Notifier<MarketRecommendationState> {
  MarketRecommendationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<MarketRecommendationState, MarketRecommendationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MarketRecommendationState, MarketRecommendationState>,
              MarketRecommendationState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
