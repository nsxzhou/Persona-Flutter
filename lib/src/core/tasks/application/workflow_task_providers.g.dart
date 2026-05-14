// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow_task_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workflowTaskRepository)
final workflowTaskRepositoryProvider = WorkflowTaskRepositoryProvider._();

final class WorkflowTaskRepositoryProvider
    extends
        $FunctionalProvider<
          WorkflowTaskRepository,
          WorkflowTaskRepository,
          WorkflowTaskRepository
        >
    with $Provider<WorkflowTaskRepository> {
  WorkflowTaskRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workflowTaskRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workflowTaskRepositoryHash();

  @$internal
  @override
  $ProviderElement<WorkflowTaskRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WorkflowTaskRepository create(Ref ref) {
    return workflowTaskRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkflowTaskRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkflowTaskRepository>(value),
    );
  }
}

String _$workflowTaskRepositoryHash() =>
    r'30a39fe15d75afd934038b0125693b252981e30b';

@ProviderFor(recentWorkflowTasks)
final recentWorkflowTasksProvider = RecentWorkflowTasksProvider._();

final class RecentWorkflowTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkflowTask>>,
          List<WorkflowTask>,
          Stream<List<WorkflowTask>>
        >
    with
        $FutureModifier<List<WorkflowTask>>,
        $StreamProvider<List<WorkflowTask>> {
  RecentWorkflowTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentWorkflowTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentWorkflowTasksHash();

  @$internal
  @override
  $StreamProviderElement<List<WorkflowTask>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WorkflowTask>> create(Ref ref) {
    return recentWorkflowTasks(ref);
  }
}

String _$recentWorkflowTasksHash() =>
    r'a71bf2f4be9fbc815ac2b4ae77f0bb3236d24a54';
