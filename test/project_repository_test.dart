import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/database/app_database.dart';
import 'package:persona_flutter/src/features/projects/data/drift_project_repository.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';

void main() {
  test('project repository round-trips and filters project records', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = DriftProjectRepository(database);
    const input = WritingProjectInput(
      title: '雾港纪事',
      description: '潮湿港城里的长篇悬疑。',
      status: ProjectStatus.active,
    );

    await repository.saveProject(input: input);

    final active = await repository.watchProjects(ProjectStatus.active).first;
    expect(active, hasLength(1));
    expect(active.single.title, input.title);
    expect(active.single.description, input.description);
    expect(active.single.status, ProjectStatus.active);

    final saved = active.single;
    await repository.saveProject(
      id: saved.id,
      input: const WritingProjectInput(
        title: '雾港纪事：修订',
        description: '新的项目简介。',
        status: ProjectStatus.archived,
      ),
    );

    final archived = await repository
        .watchProjects(ProjectStatus.archived)
        .first;
    expect(archived, hasLength(1));
    expect(archived.single.id, saved.id);
    expect(archived.single.title, '雾港纪事：修订');
    expect(archived.single.createdAt, saved.createdAt);
    expect(archived.single.updatedAt.isAfter(saved.updatedAt), isTrue);

    final activeAfterArchive = await repository
        .watchProjects(ProjectStatus.active)
        .first;
    expect(activeAfterArchive, isEmpty);

    await repository.updateStatus(id: saved.id, status: ProjectStatus.active);
    expect(
      await repository.watchProjects(ProjectStatus.active).first,
      hasLength(1),
    );

    await repository.deleteProject(saved.id);
    expect(await repository.findProject(saved.id), isNull);
  });
}
