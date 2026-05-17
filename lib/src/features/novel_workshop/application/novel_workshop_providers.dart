import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/database_providers.dart';
import '../data/drift_novel_workshop_repository.dart';
import '../domain/accepted_chapter.dart';
import '../domain/chapter_plan.dart';
import '../domain/memory_projection.dart';
import '../domain/novel_workshop_repository.dart';
import '../domain/story_bible.dart';

part 'novel_workshop_providers.g.dart';

@Riverpod(keepAlive: true)
NovelWorkshopRepository novelWorkshopRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftNovelWorkshopRepository(database);
}

@riverpod
Stream<List<ChapterPlan>> chapterPlans(Ref ref, String projectId) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .watchChapterPlans(projectId);
}

@riverpod
Stream<List<AcceptedChapter>> acceptedChapters(Ref ref, String projectId) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .watchAcceptedChapters(projectId);
}

@riverpod
Stream<StoryBible?> storyBible(Ref ref, String projectId) {
  return ref.watch(novelWorkshopRepositoryProvider).watchStoryBible(projectId);
}

@riverpod
Stream<MemoryProjection?> memoryProjection(Ref ref, String projectId) {
  return ref
      .watch(novelWorkshopRepositoryProvider)
      .watchMemoryProjection(projectId);
}

@Riverpod(keepAlive: true)
class NovelWorkshopController extends _$NovelWorkshopController {
  @override
  FutureOr<void> build() async {
    await ref.read(novelWorkshopRepositoryProvider).markInterruptedRunsFailed();
  }

  Future<ChapterPlan> saveChapterPlan({
    String? id,
    required ChapterPlanInput input,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() {
      return ref
          .read(novelWorkshopRepositoryProvider)
          .saveChapterPlan(id: id, input: input);
    });
    state = result.whenData((_) {});
    return result.requireValue;
  }

  Future<void> deleteChapterPlan(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(novelWorkshopRepositoryProvider).deleteChapterPlan(id);
    });
  }
}
