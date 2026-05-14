import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  });

  testWidgets('keeps sidebar width stable when workflow runs is selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      _ShellTestHost(
        location: AppRoute.projects.path,
        child: const Text('Projects body'),
      ),
    );
    await tester.pump();

    final initialWidth = tester.getSize(find.byType(NavigationRail)).width;

    await tester.pumpWidget(
      _ShellTestHost(
        location: AppRoute.workflowRuns.path,
        child: const Text('Workflow Runs body'),
      ),
    );
    await tester.pump();

    expect(tester.getSize(find.byType(NavigationRail)).width, initialWidth);
  });

  testWidgets('does not keep outgoing route page content during navigation', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PersonaApp()));
    await tester.pumpAndSettle();

    const projectsDescription =
        'Local writing projects, blueprints, chapters, and later Zen Editor entry points.';
    const styleLabDescription =
        'TXT sample ingestion, style analysis jobs, voice profiles, and reusable style profiles.';

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

class _ShellTestHost extends StatelessWidget {
  const _ShellTestHost({required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppShell(location: location, child: child),
    );
  }
}
