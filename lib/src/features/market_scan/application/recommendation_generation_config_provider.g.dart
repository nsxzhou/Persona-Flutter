// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_generation_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecommendationGenerationConfigController)
final recommendationGenerationConfigControllerProvider =
    RecommendationGenerationConfigControllerProvider._();

final class RecommendationGenerationConfigControllerProvider
    extends
        $NotifierProvider<
          RecommendationGenerationConfigController,
          RecommendationGenerationConfig
        > {
  RecommendationGenerationConfigControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recommendationGenerationConfigControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$recommendationGenerationConfigControllerHash();

  @$internal
  @override
  RecommendationGenerationConfigController create() =>
      RecommendationGenerationConfigController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecommendationGenerationConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecommendationGenerationConfig>(
        value,
      ),
    );
  }
}

String _$recommendationGenerationConfigControllerHash() =>
    r'fa1b7e8f809e43a868e7ec7ab27f7c2e0cd951b6';

abstract class _$RecommendationGenerationConfigController
    extends $Notifier<RecommendationGenerationConfig> {
  RecommendationGenerationConfig build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              RecommendationGenerationConfig,
              RecommendationGenerationConfig
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                RecommendationGenerationConfig,
                RecommendationGenerationConfig
              >,
              RecommendationGenerationConfig,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
