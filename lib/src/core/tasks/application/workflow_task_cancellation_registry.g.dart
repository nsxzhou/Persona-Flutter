// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow_task_cancellation_registry.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workflowTaskCancellationRegistry)
final workflowTaskCancellationRegistryProvider =
    WorkflowTaskCancellationRegistryProvider._();

final class WorkflowTaskCancellationRegistryProvider
    extends
        $FunctionalProvider<
          WorkflowTaskCancellationRegistry,
          WorkflowTaskCancellationRegistry,
          WorkflowTaskCancellationRegistry
        >
    with $Provider<WorkflowTaskCancellationRegistry> {
  WorkflowTaskCancellationRegistryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workflowTaskCancellationRegistryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workflowTaskCancellationRegistryHash();

  @$internal
  @override
  $ProviderElement<WorkflowTaskCancellationRegistry> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WorkflowTaskCancellationRegistry create(Ref ref) {
    return workflowTaskCancellationRegistry(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkflowTaskCancellationRegistry value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkflowTaskCancellationRegistry>(
        value,
      ),
    );
  }
}

String _$workflowTaskCancellationRegistryHash() =>
    r'b75ddbcfe19a64b222d46ab5a68934c3987d57ea';
