// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow_run_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workflowRunItems)
final workflowRunItemsProvider = WorkflowRunItemsProvider._();

final class WorkflowRunItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkflowRunItem>>,
          List<WorkflowRunItem>,
          FutureOr<List<WorkflowRunItem>>
        >
    with
        $FutureModifier<List<WorkflowRunItem>>,
        $FutureProvider<List<WorkflowRunItem>> {
  WorkflowRunItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workflowRunItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workflowRunItemsHash();

  @$internal
  @override
  $FutureProviderElement<List<WorkflowRunItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkflowRunItem>> create(Ref ref) {
    return workflowRunItems(ref);
  }
}

String _$workflowRunItemsHash() => r'1cfa5269504e4aa30757719c01fb3f74b1bc36f1';
