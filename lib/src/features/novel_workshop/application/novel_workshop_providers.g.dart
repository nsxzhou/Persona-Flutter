// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'novel_workshop_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(novelWorkshopRepository)
final novelWorkshopRepositoryProvider = NovelWorkshopRepositoryProvider._();

final class NovelWorkshopRepositoryProvider
    extends
        $FunctionalProvider<
          NovelWorkshopRepository,
          NovelWorkshopRepository,
          NovelWorkshopRepository
        >
    with $Provider<NovelWorkshopRepository> {
  NovelWorkshopRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'novelWorkshopRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$novelWorkshopRepositoryHash();

  @$internal
  @override
  $ProviderElement<NovelWorkshopRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NovelWorkshopRepository create(Ref ref) {
    return novelWorkshopRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NovelWorkshopRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NovelWorkshopRepository>(value),
    );
  }
}

String _$novelWorkshopRepositoryHash() =>
    r'95745322e5dea0ceb076e684b4a1bb68dd0e273e';

@ProviderFor(writingContextAssembler)
final writingContextAssemblerProvider = WritingContextAssemblerProvider._();

final class WritingContextAssemblerProvider
    extends
        $FunctionalProvider<
          WritingContextAssembler,
          WritingContextAssembler,
          WritingContextAssembler
        >
    with $Provider<WritingContextAssembler> {
  WritingContextAssemblerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'writingContextAssemblerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$writingContextAssemblerHash();

  @$internal
  @override
  $ProviderElement<WritingContextAssembler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WritingContextAssembler create(Ref ref) {
    return writingContextAssembler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WritingContextAssembler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WritingContextAssembler>(value),
    );
  }
}

String _$writingContextAssemblerHash() =>
    r'78c6f7bc4e9615e8ea31a10d6e06ade07f6ecad9';

@ProviderFor(projectPromptAssetResolver)
final projectPromptAssetResolverProvider =
    ProjectPromptAssetResolverProvider._();

final class ProjectPromptAssetResolverProvider
    extends
        $FunctionalProvider<
          ProjectPromptAssetResolver,
          ProjectPromptAssetResolver,
          ProjectPromptAssetResolver
        >
    with $Provider<ProjectPromptAssetResolver> {
  ProjectPromptAssetResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectPromptAssetResolverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectPromptAssetResolverHash();

  @$internal
  @override
  $ProviderElement<ProjectPromptAssetResolver> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProjectPromptAssetResolver create(Ref ref) {
    return projectPromptAssetResolver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProjectPromptAssetResolver value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProjectPromptAssetResolver>(value),
    );
  }
}

String _$projectPromptAssetResolverHash() =>
    r'c7a83ecc1900528b7101d0e564234e227ba9eae9';

@ProviderFor(chapterPlans)
final chapterPlansProvider = ChapterPlansFamily._();

final class ChapterPlansProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ChapterPlan>>,
          List<ChapterPlan>,
          Stream<List<ChapterPlan>>
        >
    with
        $FutureModifier<List<ChapterPlan>>,
        $StreamProvider<List<ChapterPlan>> {
  ChapterPlansProvider._({
    required ChapterPlansFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chapterPlansProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chapterPlansHash();

  @override
  String toString() {
    return r'chapterPlansProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ChapterPlan>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ChapterPlan>> create(Ref ref) {
    final argument = this.argument as String;
    return chapterPlans(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChapterPlansProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chapterPlansHash() => r'c980dfc627fccb5e5445c96e27c42cbf5580162b';

final class ChapterPlansFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ChapterPlan>>, String> {
  ChapterPlansFamily._()
    : super(
        retry: null,
        name: r'chapterPlansProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChapterPlansProvider call(String projectId) =>
      ChapterPlansProvider._(argument: projectId, from: this);

  @override
  String toString() => r'chapterPlansProvider';
}

@ProviderFor(projectChapters)
final projectChaptersProvider = ProjectChaptersFamily._();

final class ProjectChaptersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProjectChapter>>,
          List<ProjectChapter>,
          Stream<List<ProjectChapter>>
        >
    with
        $FutureModifier<List<ProjectChapter>>,
        $StreamProvider<List<ProjectChapter>> {
  ProjectChaptersProvider._({
    required ProjectChaptersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'projectChaptersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectChaptersHash();

  @override
  String toString() {
    return r'projectChaptersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ProjectChapter>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ProjectChapter>> create(Ref ref) {
    final argument = this.argument as String;
    return projectChapters(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectChaptersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectChaptersHash() => r'798dd4d6e302920b6e3b4fd317519cce8e44f295';

final class ProjectChaptersFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ProjectChapter>>, String> {
  ProjectChaptersFamily._()
    : super(
        retry: null,
        name: r'projectChaptersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProjectChaptersProvider call(String projectId) =>
      ProjectChaptersProvider._(argument: projectId, from: this);

  @override
  String toString() => r'projectChaptersProvider';
}

@ProviderFor(projectRuntimeMemory)
final projectRuntimeMemoryProvider = ProjectRuntimeMemoryFamily._();

final class ProjectRuntimeMemoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProjectRuntimeMemory>,
          ProjectRuntimeMemory,
          FutureOr<ProjectRuntimeMemory>
        >
    with
        $FutureModifier<ProjectRuntimeMemory>,
        $FutureProvider<ProjectRuntimeMemory> {
  ProjectRuntimeMemoryProvider._({
    required ProjectRuntimeMemoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'projectRuntimeMemoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectRuntimeMemoryHash();

  @override
  String toString() {
    return r'projectRuntimeMemoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ProjectRuntimeMemory> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProjectRuntimeMemory> create(Ref ref) {
    final argument = this.argument as String;
    return projectRuntimeMemory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectRuntimeMemoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectRuntimeMemoryHash() =>
    r'fcc6e069f50b50108f782141ecd9ffce6447be28';

final class ProjectRuntimeMemoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ProjectRuntimeMemory>, String> {
  ProjectRuntimeMemoryFamily._()
    : super(
        retry: null,
        name: r'projectRuntimeMemoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProjectRuntimeMemoryProvider call(String projectId) =>
      ProjectRuntimeMemoryProvider._(argument: projectId, from: this);

  @override
  String toString() => r'projectRuntimeMemoryProvider';
}

@ProviderFor(projectPromptAssets)
final projectPromptAssetsProvider = ProjectPromptAssetsFamily._();

final class ProjectPromptAssetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProjectPromptAssets>,
          ProjectPromptAssets,
          FutureOr<ProjectPromptAssets>
        >
    with
        $FutureModifier<ProjectPromptAssets>,
        $FutureProvider<ProjectPromptAssets> {
  ProjectPromptAssetsProvider._({
    required ProjectPromptAssetsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'projectPromptAssetsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectPromptAssetsHash();

  @override
  String toString() {
    return r'projectPromptAssetsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ProjectPromptAssets> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProjectPromptAssets> create(Ref ref) {
    final argument = this.argument as String;
    return projectPromptAssets(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectPromptAssetsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectPromptAssetsHash() =>
    r'0507dbc319e2d65681a54d1bff30ce422f54adaf';

final class ProjectPromptAssetsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ProjectPromptAssets>, String> {
  ProjectPromptAssetsFamily._()
    : super(
        retry: null,
        name: r'projectPromptAssetsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProjectPromptAssetsProvider call(String projectId) =>
      ProjectPromptAssetsProvider._(argument: projectId, from: this);

  @override
  String toString() => r'projectPromptAssetsProvider';
}
