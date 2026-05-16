import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/features/projects/application/project_providers.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';
import 'package:persona_flutter/src/features/projects/presentation/project_detail_page.dart';
import 'package:persona_flutter/src/features/projects/presentation/projects_page.dart';

void main() {
  testWidgets('projects page shows empty active state with create entry', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          writingProjectsProvider.overrideWith(
            (ref, status) => Stream<List<WritingProject>>.value(const []),
          ),
        ],
        child: const MaterialApp(home: ProjectsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('尚未创建项目'), findsOneWidget);
    expect(find.text('新建项目'), findsWidgets);
    expect(find.text('活动'), findsWidgets);
  });

  testWidgets(
    'projects page hides archived projects until archived view is selected',
    (tester) async {
      final active = _project(
        id: 'active-project',
        title: '活动长篇',
        status: ProjectStatus.active,
      );
      final archived = _project(
        id: 'archived-project',
        title: '归档长篇',
        status: ProjectStatus.archived,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            writingProjectsProvider.overrideWith(
              (ref, status) => Stream<List<WritingProject>>.value([
                if (status == ProjectStatus.active) active,
                if (status == ProjectStatus.archived) archived,
              ]),
            ),
          ],
          child: const MaterialApp(home: ProjectsPage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('活动长篇'), findsOneWidget);
      expect(find.text('归档长篇'), findsNothing);

      await tester.tap(find.text('归档').last);
      await tester.pumpAndSettle();

      expect(find.text('活动长篇'), findsNothing);
      expect(find.text('归档长篇'), findsOneWidget);
    },
  );

  testWidgets('project detail page renders loaded project dossier', (
    tester,
  ) async {
    final project = _project(
      id: 'project-1',
      title: '雾港纪事',
      description: '潮湿港城里的长篇悬疑。',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          writingProjectProvider.overrideWith(
            (ref, id) => Stream<WritingProject?>.value(project),
          ),
        ],
        child: const MaterialApp(
          home: ProjectDetailPage(projectId: 'project-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('雾港纪事'), findsOneWidget);
    expect(find.text('潮湿港城里的长篇悬疑。'), findsWidgets);
    expect(find.text('项目概要'), findsOneWidget);
    expect(find.text('后续工作台入口'), findsOneWidget);
  });

  testWidgets('project detail page handles missing project', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          writingProjectProvider.overrideWith(
            (ref, id) => Stream<WritingProject?>.value(null),
          ),
        ],
        child: const MaterialApp(
          home: ProjectDetailPage(projectId: 'missing-project'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('项目不存在'), findsOneWidget);
    expect(find.text('没有找到对应的项目记录。'), findsOneWidget);
  });
}

WritingProject _project({
  required String id,
  required String title,
  String description = '项目简介',
  ProjectStatus status = ProjectStatus.active,
}) {
  return WritingProject(
    id: id,
    title: title,
    description: description,
    status: status,
    createdAt: DateTime(2026, 5, 16, 9),
    updatedAt: DateTime(2026, 5, 16, 10),
  );
}
