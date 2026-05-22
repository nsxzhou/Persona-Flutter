// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow_task_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WorkflowTaskController)
final workflowTaskControllerProvider = WorkflowTaskControllerProvider._();

final class WorkflowTaskControllerProvider
    extends $AsyncNotifierProvider<WorkflowTaskController, void> {
  WorkflowTaskControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workflowTaskControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workflowTaskControllerHash();

  @$internal
  @override
  WorkflowTaskController create() => WorkflowTaskController();
}

String _$workflowTaskControllerHash() =>
    r'564117a1824baa32f8a646795af312247fa9fdeb';

abstract class _$WorkflowTaskController extends $AsyncNotifier<void> {
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
