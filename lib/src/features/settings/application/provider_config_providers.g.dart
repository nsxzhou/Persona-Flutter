// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_config_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(providerHttpClient)
final providerHttpClientProvider = ProviderHttpClientProvider._();

final class ProviderHttpClientProvider
    extends $FunctionalProvider<http.Client, http.Client, http.Client>
    with $Provider<http.Client> {
  ProviderHttpClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerHttpClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerHttpClientHash();

  @$internal
  @override
  $ProviderElement<http.Client> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  http.Client create(Ref ref) {
    return providerHttpClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(http.Client value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<http.Client>(value),
    );
  }
}

String _$providerHttpClientHash() =>
    r'67ab9e8de4c68cd03656df139fa7dba6d2064e8e';

@ProviderFor(providerConfigRepository)
final providerConfigRepositoryProvider = ProviderConfigRepositoryProvider._();

final class ProviderConfigRepositoryProvider
    extends
        $FunctionalProvider<
          ProviderConfigRepository,
          ProviderConfigRepository,
          ProviderConfigRepository
        >
    with $Provider<ProviderConfigRepository> {
  ProviderConfigRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerConfigRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerConfigRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProviderConfigRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProviderConfigRepository create(Ref ref) {
    return providerConfigRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProviderConfigRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProviderConfigRepository>(value),
    );
  }
}

String _$providerConfigRepositoryHash() =>
    r'5b852670662c48878eaf5c0016d655c35b07971c';

@ProviderFor(providerConnectivityTester)
final providerConnectivityTesterProvider =
    ProviderConnectivityTesterProvider._();

final class ProviderConnectivityTesterProvider
    extends
        $FunctionalProvider<
          ProviderConnectivityTester,
          ProviderConnectivityTester,
          ProviderConnectivityTester
        >
    with $Provider<ProviderConnectivityTester> {
  ProviderConnectivityTesterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerConnectivityTesterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerConnectivityTesterHash();

  @$internal
  @override
  $ProviderElement<ProviderConnectivityTester> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProviderConnectivityTester create(Ref ref) {
    return providerConnectivityTester(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProviderConnectivityTester value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProviderConnectivityTester>(value),
    );
  }
}

String _$providerConnectivityTesterHash() =>
    r'8936203422076b12b6df802544940bb8d175c818';

@ProviderFor(providerConfigs)
final providerConfigsProvider = ProviderConfigsProvider._();

final class ProviderConfigsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProviderConfig>>,
          List<ProviderConfig>,
          Stream<List<ProviderConfig>>
        >
    with
        $FutureModifier<List<ProviderConfig>>,
        $StreamProvider<List<ProviderConfig>> {
  ProviderConfigsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerConfigsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerConfigsHash();

  @$internal
  @override
  $StreamProviderElement<List<ProviderConfig>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ProviderConfig>> create(Ref ref) {
    return providerConfigs(ref);
  }
}

String _$providerConfigsHash() => r'a5abbbc643d365f3c3750013b73edd3a430a6502';

@ProviderFor(ProviderConfigController)
final providerConfigControllerProvider = ProviderConfigControllerProvider._();

final class ProviderConfigControllerProvider
    extends $AsyncNotifierProvider<ProviderConfigController, void> {
  ProviderConfigControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerConfigControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerConfigControllerHash();

  @$internal
  @override
  ProviderConfigController create() => ProviderConfigController();
}

String _$providerConfigControllerHash() =>
    r'950ac73d07d8a0fd19d66f4683e10e78d7a15f06';

abstract class _$ProviderConfigController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
