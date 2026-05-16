// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(projectRepository)
final projectRepositoryProvider = ProjectRepositoryProvider._();

final class ProjectRepositoryProvider
    extends
        $FunctionalProvider<
          ProjectRepository,
          ProjectRepository,
          ProjectRepository
        >
    with $Provider<ProjectRepository> {
  ProjectRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProjectRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProjectRepository create(Ref ref) {
    return projectRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProjectRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProjectRepository>(value),
    );
  }
}

String _$projectRepositoryHash() => r'897d4ce2b512de7d6ef154d1cfb490c9f5fbf315';

@ProviderFor(writingProjects)
final writingProjectsProvider = WritingProjectsFamily._();

final class WritingProjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WritingProject>>,
          List<WritingProject>,
          Stream<List<WritingProject>>
        >
    with
        $FutureModifier<List<WritingProject>>,
        $StreamProvider<List<WritingProject>> {
  WritingProjectsProvider._({
    required WritingProjectsFamily super.from,
    required ProjectStatus super.argument,
  }) : super(
         retry: null,
         name: r'writingProjectsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$writingProjectsHash();

  @override
  String toString() {
    return r'writingProjectsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<WritingProject>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WritingProject>> create(Ref ref) {
    final argument = this.argument as ProjectStatus;
    return writingProjects(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WritingProjectsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$writingProjectsHash() => r'af248a7152b5dcb52d3eabe57b3ef78b07cc68db';

final class WritingProjectsFamily extends $Family
    with
        $FunctionalFamilyOverride<Stream<List<WritingProject>>, ProjectStatus> {
  WritingProjectsFamily._()
    : super(
        retry: null,
        name: r'writingProjectsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WritingProjectsProvider call(ProjectStatus status) =>
      WritingProjectsProvider._(argument: status, from: this);

  @override
  String toString() => r'writingProjectsProvider';
}

@ProviderFor(writingProject)
final writingProjectProvider = WritingProjectFamily._();

final class WritingProjectProvider
    extends
        $FunctionalProvider<
          AsyncValue<WritingProject?>,
          WritingProject?,
          Stream<WritingProject?>
        >
    with $FutureModifier<WritingProject?>, $StreamProvider<WritingProject?> {
  WritingProjectProvider._({
    required WritingProjectFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'writingProjectProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$writingProjectHash();

  @override
  String toString() {
    return r'writingProjectProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<WritingProject?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<WritingProject?> create(Ref ref) {
    final argument = this.argument as String;
    return writingProject(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WritingProjectProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$writingProjectHash() => r'9fbc21da09967ad6e3ca8f270caf0389c4680c78';

final class WritingProjectFamily extends $Family
    with $FunctionalFamilyOverride<Stream<WritingProject?>, String> {
  WritingProjectFamily._()
    : super(
        retry: null,
        name: r'writingProjectProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WritingProjectProvider call(String id) =>
      WritingProjectProvider._(argument: id, from: this);

  @override
  String toString() => r'writingProjectProvider';
}

@ProviderFor(ProjectController)
final projectControllerProvider = ProjectControllerProvider._();

final class ProjectControllerProvider
    extends $AsyncNotifierProvider<ProjectController, void> {
  ProjectControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectControllerHash();

  @$internal
  @override
  ProjectController create() => ProjectController();
}

String _$projectControllerHash() => r'2822d64cc41f18897f824968880bfdbd6bb3c441';

abstract class _$ProjectController extends $AsyncNotifier<void> {
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
