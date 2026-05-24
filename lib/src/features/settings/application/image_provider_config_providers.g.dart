// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_provider_config_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(imageProviderHttpClient)
final imageProviderHttpClientProvider = ImageProviderHttpClientProvider._();

final class ImageProviderHttpClientProvider
    extends $FunctionalProvider<http.Client, http.Client, http.Client>
    with $Provider<http.Client> {
  ImageProviderHttpClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageProviderHttpClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageProviderHttpClientHash();

  @$internal
  @override
  $ProviderElement<http.Client> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  http.Client create(Ref ref) {
    return imageProviderHttpClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(http.Client value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<http.Client>(value),
    );
  }
}

String _$imageProviderHttpClientHash() =>
    r'27bc5ed69d202e12fc6d43b87000cfa11553d762';

@ProviderFor(imageProviderConfigRepository)
final imageProviderConfigRepositoryProvider =
    ImageProviderConfigRepositoryProvider._();

final class ImageProviderConfigRepositoryProvider
    extends
        $FunctionalProvider<
          ImageProviderConfigRepository,
          ImageProviderConfigRepository,
          ImageProviderConfigRepository
        >
    with $Provider<ImageProviderConfigRepository> {
  ImageProviderConfigRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageProviderConfigRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageProviderConfigRepositoryHash();

  @$internal
  @override
  $ProviderElement<ImageProviderConfigRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ImageProviderConfigRepository create(Ref ref) {
    return imageProviderConfigRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImageProviderConfigRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImageProviderConfigRepository>(
        value,
      ),
    );
  }
}

String _$imageProviderConfigRepositoryHash() =>
    r'e150076a2ddabbdf4dd37b2513aa3b7025fc7858';

@ProviderFor(imageGenerationClient)
final imageGenerationClientProvider = ImageGenerationClientProvider._();

final class ImageGenerationClientProvider
    extends
        $FunctionalProvider<
          ImageGenerationClient,
          ImageGenerationClient,
          ImageGenerationClient
        >
    with $Provider<ImageGenerationClient> {
  ImageGenerationClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageGenerationClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageGenerationClientHash();

  @$internal
  @override
  $ProviderElement<ImageGenerationClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ImageGenerationClient create(Ref ref) {
    return imageGenerationClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImageGenerationClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImageGenerationClient>(value),
    );
  }
}

String _$imageGenerationClientHash() =>
    r'1723d3b7a8eb55cf66059d033ba64f017eb0d75b';

@ProviderFor(imageGenerationService)
final imageGenerationServiceProvider = ImageGenerationServiceProvider._();

final class ImageGenerationServiceProvider
    extends
        $FunctionalProvider<
          ImageGenerationService,
          ImageGenerationService,
          ImageGenerationService
        >
    with $Provider<ImageGenerationService> {
  ImageGenerationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageGenerationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageGenerationServiceHash();

  @$internal
  @override
  $ProviderElement<ImageGenerationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ImageGenerationService create(Ref ref) {
    return imageGenerationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImageGenerationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImageGenerationService>(value),
    );
  }
}

String _$imageGenerationServiceHash() =>
    r'1b807c5b9895a4cf6a3d116a30d86ad581204f4e';

@ProviderFor(imageProviderConfigs)
final imageProviderConfigsProvider = ImageProviderConfigsProvider._();

final class ImageProviderConfigsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ImageProviderConfig>>,
          List<ImageProviderConfig>,
          Stream<List<ImageProviderConfig>>
        >
    with
        $FutureModifier<List<ImageProviderConfig>>,
        $StreamProvider<List<ImageProviderConfig>> {
  ImageProviderConfigsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageProviderConfigsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageProviderConfigsHash();

  @$internal
  @override
  $StreamProviderElement<List<ImageProviderConfig>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ImageProviderConfig>> create(Ref ref) {
    return imageProviderConfigs(ref);
  }
}

String _$imageProviderConfigsHash() =>
    r'99c8a31bee951278b413f1a82c446681ec9830b6';

@ProviderFor(imageProviderConfig)
final imageProviderConfigProvider = ImageProviderConfigFamily._();

final class ImageProviderConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<ImageProviderConfig?>,
          ImageProviderConfig?,
          Stream<ImageProviderConfig?>
        >
    with
        $FutureModifier<ImageProviderConfig?>,
        $StreamProvider<ImageProviderConfig?> {
  ImageProviderConfigProvider._({
    required ImageProviderConfigFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'imageProviderConfigProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$imageProviderConfigHash();

  @override
  String toString() {
    return r'imageProviderConfigProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ImageProviderConfig?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ImageProviderConfig?> create(Ref ref) {
    final argument = this.argument as String;
    return imageProviderConfig(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ImageProviderConfigProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$imageProviderConfigHash() =>
    r'3d38820844b03f47630956a56825edb7eda62bc4';

final class ImageProviderConfigFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ImageProviderConfig?>, String> {
  ImageProviderConfigFamily._()
    : super(
        retry: null,
        name: r'imageProviderConfigProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ImageProviderConfigProvider call(String id) =>
      ImageProviderConfigProvider._(argument: id, from: this);

  @override
  String toString() => r'imageProviderConfigProvider';
}

@ProviderFor(ImageProviderConfigController)
final imageProviderConfigControllerProvider =
    ImageProviderConfigControllerProvider._();

final class ImageProviderConfigControllerProvider
    extends $AsyncNotifierProvider<ImageProviderConfigController, void> {
  ImageProviderConfigControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageProviderConfigControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageProviderConfigControllerHash();

  @$internal
  @override
  ImageProviderConfigController create() => ImageProviderConfigController();
}

String _$imageProviderConfigControllerHash() =>
    r'd27945fa7502639ab504ab18dc3794a11b368ce3';

abstract class _$ImageProviderConfigController extends $AsyncNotifier<void> {
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
