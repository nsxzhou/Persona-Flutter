import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_flutter/src/app/persona_app.dart';
import 'package:persona_flutter/src/core/router/app_route.dart';
import 'package:persona_flutter/src/core/ui/app_shell.dart';

void main() {
  testWidgets('shows the desktop shell and core product entries', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PersonaApp()));
    await tester.pumpAndSettle();

    expect(find.text('项目'), findsWidgets);
    expect(find.text('风格实验室'), findsWidgets);
    expect(find.text('剧情实验室'), findsWidgets);
    expect(find.text('工作流任务'), findsWidgets);
    expect(find.text('设置'), findsWidgets);
    expect(find.text('本地写作系统'), findsOneWidget);
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

  testWidgets('does not keep outgoing route page content during navigation', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PersonaApp()));
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
    return MaterialApp.router(routerConfig: router);
  }
}
