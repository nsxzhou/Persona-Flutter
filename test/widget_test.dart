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

    expect(find.text('Projects'), findsWidgets);
    expect(find.text('Style Lab'), findsWidgets);
    expect(find.text('Plot Lab'), findsWidgets);
    expect(find.text('Workflow Runs'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Local writing OS'), findsOneWidget);
  });

  testWidgets('keeps sidebar width stable when workflow runs is selected', (
    tester,
  ) async {
    final router = _buildShellTestRouter();

    await tester.pumpWidget(_ShellTestApp(router: router));
    await tester.pumpAndSettle();

    final sidebar = find.byKey(const ValueKey('app-sidebar'));
    final initialWidth = tester.getSize(sidebar).width;

    await tester.tap(find.text('Workflow Runs').first);
    await tester.pumpAndSettle();

    expect(tester.getSize(sidebar).width, initialWidth);
  });

  testWidgets('does not keep outgoing route page content during navigation', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PersonaApp()));
    await tester.pumpAndSettle();

    const projectsDescription =
        'Your local writing desk for long-form projects, blueprints, chapter work, and future Zen Editor sessions.';
    const styleLabDescription =
        'Analyze sample prose, distill voice profiles, and prepare reusable style direction for long-form drafting.';

    expect(find.text(projectsDescription), findsOneWidget);
    expect(find.text(styleLabDescription), findsNothing);

    await tester.tap(find.text('Style Lab').first);
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
