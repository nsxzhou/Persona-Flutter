import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/database_providers.dart';
import '../data/drift_project_repository.dart';
import '../domain/project_repository.dart';
import '../domain/writing_project.dart';

part 'project_providers.g.dart';

@Riverpod(keepAlive: true)
ProjectRepository projectRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftProjectRepository(database);
}

@riverpod
Stream<List<WritingProject>> writingProjects(Ref ref, ProjectStatus status) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchProjects(status);
}

@riverpod
Stream<WritingProject?> writingProject(Ref ref, String id) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchProject(id);
}

@riverpod
class ProjectController extends _$ProjectController {
  @override
  FutureOr<void> build() {}

  Future<void> save({String? id, required WritingProjectInput input}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(projectRepositoryProvider)
          .saveProject(id: id, input: input);
    });
  }

  Future<void> archive(String id) async {
    await _updateStatus(id: id, status: ProjectStatus.archived);
  }

  Future<void> restore(String id) async {
    await _updateStatus(id: id, status: ProjectStatus.active);
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(projectRepositoryProvider).deleteProject(id);
    });
  }

  Future<void> _updateStatus({
    required String id,
    required ProjectStatus status,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(projectRepositoryProvider)
          .updateStatus(id: id, status: status);
    });
  }
}
