import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/plot_lab/presentation/plot_lab_page.dart';
import '../../features/projects/presentation/projects_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/style_lab/presentation/style_lab_page.dart';
import '../../features/workflow_runs/presentation/workflow_runs_page.dart';
import '../ui/app_shell.dart';
import 'app_route.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.projects.path,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(location: state.uri.path, child: child);
        },
        routes: [
          GoRoute(
            path: AppRoute.projects.path,
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const ProjectsPage(),
            ),
          ),
          GoRoute(
            path: AppRoute.styleLab.path,
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const StyleLabPage(),
            ),
          ),
          GoRoute(
            path: AppRoute.plotLab.path,
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const PlotLabPage(),
            ),
          ),
          GoRoute(
            path: AppRoute.workflowRuns.path,
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const WorkflowRunsPage(),
            ),
          ),
          GoRoute(
            path: AppRoute.settings.path,
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const SettingsPage(),
            ),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      if (state.uri.path == '/') {
        return AppRoute.projects.path;
      }
      return null;
    },
  );
});
