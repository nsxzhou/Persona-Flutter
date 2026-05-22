// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_backup_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localBackupService)
final localBackupServiceProvider = LocalBackupServiceProvider._();

final class LocalBackupServiceProvider
    extends
        $FunctionalProvider<
          LocalBackupService,
          LocalBackupService,
          LocalBackupService
        >
    with $Provider<LocalBackupService> {
  LocalBackupServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localBackupServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localBackupServiceHash();

  @$internal
  @override
  $ProviderElement<LocalBackupService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalBackupService create(Ref ref) {
    return localBackupService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalBackupService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalBackupService>(value),
    );
  }
}

String _$localBackupServiceHash() =>
    r'34a692f15ef8ca4bfa13accac57da307358ffd7b';

@ProviderFor(LocalBackupController)
final localBackupControllerProvider = LocalBackupControllerProvider._();

final class LocalBackupControllerProvider
    extends $AsyncNotifierProvider<LocalBackupController, LocalBackupState> {
  LocalBackupControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localBackupControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localBackupControllerHash();

  @$internal
  @override
  LocalBackupController create() => LocalBackupController();
}

String _$localBackupControllerHash() =>
    r'4db6b0e33dcb5e8e68e000e0d3b735914bad4313';

abstract class _$LocalBackupController
    extends $AsyncNotifier<LocalBackupState> {
  FutureOr<LocalBackupState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<LocalBackupState>, LocalBackupState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LocalBackupState>, LocalBackupState>,
              AsyncValue<LocalBackupState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
