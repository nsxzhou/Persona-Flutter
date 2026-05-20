import 'writing_project.dart';

abstract interface class ProjectRepository {
  Stream<List<WritingProject>> watchProjects(ProjectStatus status);

  Stream<WritingProject?> watchProject(String id);

  Future<WritingProject?> findProject(String id);

  Future<void> saveProject({String? id, required WritingProjectInput input});

  Future<WritingProject> createProject(WritingProjectInput input);

  Future<void> updateStatus({
    required String id,
    required ProjectStatus status,
  });

  Future<void> deleteProject(String id);
}
