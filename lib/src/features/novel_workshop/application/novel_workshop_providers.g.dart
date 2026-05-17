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

@ProviderFor(acceptedChapters)
final acceptedChaptersProvider = AcceptedChaptersFamily._();

final class AcceptedChaptersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AcceptedChapter>>,
          List<AcceptedChapter>,
          Stream<List<AcceptedChapter>>
        >
    with
        $FutureModifier<List<AcceptedChapter>>,
        $StreamProvider<List<AcceptedChapter>> {
  AcceptedChaptersProvider._({
    required AcceptedChaptersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'acceptedChaptersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$acceptedChaptersHash();

  @override
  String toString() {
    return r'acceptedChaptersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<AcceptedChapter>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AcceptedChapter>> create(Ref ref) {
    final argument = this.argument as String;
    return acceptedChapters(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AcceptedChaptersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$acceptedChaptersHash() => r'043a93116bae29dc0e85871227138a957a67df27';

final class AcceptedChaptersFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<AcceptedChapter>>, String> {
  AcceptedChaptersFamily._()
    : super(
        retry: null,
        name: r'acceptedChaptersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AcceptedChaptersProvider call(String projectId) =>
      AcceptedChaptersProvider._(argument: projectId, from: this);

  @override
  String toString() => r'acceptedChaptersProvider';
}

@ProviderFor(storyBible)
final storyBibleProvider = StoryBibleFamily._();

final class StoryBibleProvider
    extends
        $FunctionalProvider<
          AsyncValue<StoryBible?>,
          StoryBible?,
          Stream<StoryBible?>
        >
    with $FutureModifier<StoryBible?>, $StreamProvider<StoryBible?> {
  StoryBibleProvider._({
    required StoryBibleFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'storyBibleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$storyBibleHash();

  @override
  String toString() {
    return r'storyBibleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<StoryBible?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<StoryBible?> create(Ref ref) {
    final argument = this.argument as String;
    return storyBible(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StoryBibleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$storyBibleHash() => r'36a823b4f2323887fe68b6146d4210e36414f089';

final class StoryBibleFamily extends $Family
    with $FunctionalFamilyOverride<Stream<StoryBible?>, String> {
  StoryBibleFamily._()
    : super(
        retry: null,
        name: r'storyBibleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StoryBibleProvider call(String projectId) =>
      StoryBibleProvider._(argument: projectId, from: this);

  @override
  String toString() => r'storyBibleProvider';
}

@ProviderFor(memoryProjection)
final memoryProjectionProvider = MemoryProjectionFamily._();

final class MemoryProjectionProvider
    extends
        $FunctionalProvider<
          AsyncValue<MemoryProjection?>,
          MemoryProjection?,
          Stream<MemoryProjection?>
        >
    with
        $FutureModifier<MemoryProjection?>,
        $StreamProvider<MemoryProjection?> {
  MemoryProjectionProvider._({
    required MemoryProjectionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'memoryProjectionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memoryProjectionHash();

  @override
  String toString() {
    return r'memoryProjectionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<MemoryProjection?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<MemoryProjection?> create(Ref ref) {
    final argument = this.argument as String;
    return memoryProjection(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MemoryProjectionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memoryProjectionHash() => r'8f72d3b2d660d9a7d9c0c9c14599885b08a20b63';

final class MemoryProjectionFamily extends $Family
    with $FunctionalFamilyOverride<Stream<MemoryProjection?>, String> {
  MemoryProjectionFamily._()
    : super(
        retry: null,
        name: r'memoryProjectionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MemoryProjectionProvider call(String projectId) =>
      MemoryProjectionProvider._(argument: projectId, from: this);

  @override
  String toString() => r'memoryProjectionProvider';
}

@ProviderFor(NovelWorkshopController)
final novelWorkshopControllerProvider = NovelWorkshopControllerProvider._();

final class NovelWorkshopControllerProvider
    extends $AsyncNotifierProvider<NovelWorkshopController, void> {
  NovelWorkshopControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'novelWorkshopControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$novelWorkshopControllerHash();

  @$internal
  @override
  NovelWorkshopController create() => NovelWorkshopController();
}

String _$novelWorkshopControllerHash() =>
    r'8ebd945bde6edb9ad7fd6b434bd917f0847165d0';

abstract class _$NovelWorkshopController extends $AsyncNotifier<void> {
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
