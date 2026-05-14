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
            builder: (context, state) => const ProjectsPage(),
          ),
          GoRoute(
            path: AppRoute.styleLab.path,
            builder: (context, state) => const StyleLabPage(),
          ),
          GoRoute(
            path: AppRoute.plotLab.path,
            builder: (context, state) => const PlotLabPage(),
          ),
          GoRoute(
            path: AppRoute.workflowRuns.path,
            builder: (context, state) => const WorkflowRunsPage(),
          ),
          GoRoute(
            path: AppRoute.settings.path,
            builder: (context, state) => const SettingsPage(),
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
