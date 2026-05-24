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

@ProviderFor(workflowTasks)
final workflowTasksProvider = WorkflowTasksProvider._();

final class WorkflowTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkflowTask>>,
          List<WorkflowTask>,
          Stream<List<WorkflowTask>>
        >
    with
        $FutureModifier<List<WorkflowTask>>,
        $StreamProvider<List<WorkflowTask>> {
  WorkflowTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workflowTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workflowTasksHash();

  @$internal
  @override
  $StreamProviderElement<List<WorkflowTask>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WorkflowTask>> create(Ref ref) {
    return workflowTasks(ref);
  }
}

String _$workflowTasksHash() => r'1036153a5b3d152da655713e23a0b240865bd7a8';

@ProviderFor(workflowTask)
final workflowTaskProvider = WorkflowTaskFamily._();

final class WorkflowTaskProvider
    extends
        $FunctionalProvider<
          AsyncValue<WorkflowTask?>,
          WorkflowTask?,
          Stream<WorkflowTask?>
        >
    with $FutureModifier<WorkflowTask?>, $StreamProvider<WorkflowTask?> {
  WorkflowTaskProvider._({
    required WorkflowTaskFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'workflowTaskProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workflowTaskHash();

  @override
  String toString() {
    return r'workflowTaskProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<WorkflowTask?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<WorkflowTask?> create(Ref ref) {
    final argument = this.argument as String;
    return workflowTask(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkflowTaskProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workflowTaskHash() => r'2facc32625f751a05fd24bf9da475f91d3320cd6';

final class WorkflowTaskFamily extends $Family
    with $FunctionalFamilyOverride<Stream<WorkflowTask?>, String> {
  WorkflowTaskFamily._()
    : super(
        retry: null,
        name: r'workflowTaskProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkflowTaskProvider call(String id) =>
      WorkflowTaskProvider._(argument: id, from: this);

  @override
  String toString() => r'workflowTaskProvider';
}

@ProviderFor(workflowPromptTrace)
final workflowPromptTraceProvider = WorkflowPromptTraceFamily._();

final class WorkflowPromptTraceProvider
    extends
        $FunctionalProvider<
          AsyncValue<WorkflowPromptTrace?>,
          WorkflowPromptTrace?,
          Stream<WorkflowPromptTrace?>
        >
    with
        $FutureModifier<WorkflowPromptTrace?>,
        $StreamProvider<WorkflowPromptTrace?> {
  WorkflowPromptTraceProvider._({
    required WorkflowPromptTraceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'workflowPromptTraceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workflowPromptTraceHash();

  @override
  String toString() {
    return r'workflowPromptTraceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<WorkflowPromptTrace?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<WorkflowPromptTrace?> create(Ref ref) {
    final argument = this.argument as String;
    return workflowPromptTrace(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkflowPromptTraceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workflowPromptTraceHash() =>
    r'b86ae2cdbca40565c60f68d332c22da2949bb4af';

final class WorkflowPromptTraceFamily extends $Family
    with $FunctionalFamilyOverride<Stream<WorkflowPromptTrace?>, String> {
  WorkflowPromptTraceFamily._()
    : super(
        retry: null,
        name: r'workflowPromptTraceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkflowPromptTraceProvider call(String workflowTaskId) =>
      WorkflowPromptTraceProvider._(argument: workflowTaskId, from: this);

  @override
  String toString() => r'workflowPromptTraceProvider';
}
