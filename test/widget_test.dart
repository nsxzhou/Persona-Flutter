import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_flutter/src/app/persona_app.dart';
import 'package:persona_flutter/src/core/router/app_route.dart';
import 'package:persona_flutter/src/core/theme/app_theme.dart';
import 'package:persona_flutter/src/core/ui/app_shell.dart';
import 'package:persona_flutter/src/features/projects/application/project_providers.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';

void main() {
  testWidgets('shows the desktop shell and core product entries', (
    tester,
  ) async {
    await tester.pumpWidget(_TestProviderScope(child: const PersonaApp()));
    await tester.pumpAndSettle();

    expect(find.text('项目'), findsWidgets);
    expect(find.text('风格实验室'), findsWidgets);
    expect(find.text('剧情实验室'), findsWidgets);
    expect(find.text('工作流任务'), findsWidgets);
    expect(find.text('设置'), findsWidgets);
  });

  testWidgets('keeps sidebar width stable when workflow runs is selected', (
    tester,
  ) async {
    final router = _buildShellTestRouter();

    await tester.pumpWidget(_ShellTestApp(router: router));
    await tester.pumpAndSettle();

    final sidebar = find.byKey(const ValueKey('app-sidebar'));
    final initialWidth = tester.getSize(sidebar).width;

    await tester.tap(find.text('工作流任务').first);
    await tester.pumpAndSettle();

    expect(tester.getSize(sidebar).width, initialWidth);
  });

  testWidgets('aligns collapsed sidebar icons on the same vertical axis', (
    tester,
  ) async {
    final router = _buildShellTestRouter();

    await tester.pumpWidget(
      ProviderScope(child: _ShellTestApp(router: router)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('折叠侧栏'));
    await tester.pumpAndSettle();

    final logoCenter = tester.getCenter(
      find.byKey(const ValueKey('sidebar-brand-logo')).first,
    );
    final selectedDestinationCenter = tester.getCenter(
      find.byIcon(Icons.folder).first,
    );
    final toggleCenter = tester.getCenter(
      find.byIcon(Icons.keyboard_double_arrow_right),
    );

    expect((logoCenter.dx - selectedDestinationCenter.dx).abs(), lessThan(0.1));
    expect((logoCenter.dx - toggleCenter.dx).abs(), lessThan(0.1));
  });

  testWidgets('toggles app theme mode from the sidebar control', (
    tester,
  ) async {
    await tester.pumpWidget(_TestProviderScope(child: const PersonaApp()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    expect(find.byIcon(Icons.wb_sunny_outlined), findsNothing);
    expect(find.byTooltip('切换亮色模式'), findsOneWidget);

    await tester.tap(find.byTooltip('切换亮色模式'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.wb_sunny_outlined), findsOneWidget);
    expect(find.byTooltip('切换暗色模式'), findsOneWidget);
  });

  testWidgets('does not keep outgoing route page content during navigation', (
    tester,
  ) async {
    await tester.pumpWidget(_TestProviderScope(child: const PersonaApp()));
    await tester.pumpAndSettle();

    const projectsDescription = '用于长篇项目、蓝图、章节工作和后续 Zen Editor 写作会话的本地写作工作台。';
    const styleLabDescription = '分析样本文本，提炼 Voice Profile，并为长篇写作准备可复用的风格方向。';

    expect(find.text(projectsDescription), findsOneWidget);
    expect(find.text(styleLabDescription), findsNothing);

    await tester.tap(find.text('风格实验室').first);
    await tester.pump();

    expect(find.text(projectsDescription), findsNothing);
    expect(find.text(styleLabDescription), findsOneWidget);

    await tester.pumpWidget(const ProviderScope(child: SizedBox.shrink()));
    await tester.pump();
  });

  testWidgets('does not wrap top-level shell pages in extra switcher', (
    tester,
  ) async {
    final router = _buildShellTestRouter();

    await tester.pumpWidget(_ShellTestApp(router: router));
    await tester.pump();

    expect(
      find.ancestor(
        of: find.text('${AppRoute.projects.label} body'),
        matching: find.byType(AnimatedSwitcher),
      ),
      findsNothing,
    );
  });
}

GoRouter _buildShellTestRouter() {
  Widget branchBody(String label) {
    return Center(child: Text('$label body'));
  }

  return GoRouter(
    initialLocation: AppRoute.projects.path,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          for (final route in AppRoute.values)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: route.path,
                  builder: (context, state) => branchBody(route.label),
                ),
              ],
            ),
        ],
      ),
    ],
  );
}

class _ShellTestApp extends StatelessWidget {
  const _ShellTestApp({required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
        theme: buildPersonaTheme(Brightness.light),
        darkTheme: buildPersonaTheme(Brightness.dark),
      ),
    );
  }
}

class _TestProviderScope extends StatelessWidget {
  const _TestProviderScope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        writingProjectsProvider.overrideWith(
          (ref, status) => Stream<List<WritingProject>>.value(const []),
        ),
      ],
      child: child,
    );
  }
}
