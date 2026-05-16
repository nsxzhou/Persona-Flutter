import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/plot_lab/presentation/plot_lab_page.dart';
import '../../features/projects/presentation/project_detail_page.dart';
import '../../features/projects/presentation/projects_page.dart';
import '../../features/settings/presentation/provider_detail_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/style_lab/presentation/style_lab_page.dart';
import '../../features/workflow_runs/presentation/workflow_runs_page.dart';
import '../ui/app_shell.dart';
import 'app_route.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.projects.path,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.projects.path,
                builder: (context, state) => const ProjectsPage(),
                routes: [
                  GoRoute(
                    path: ':projectId',
                    builder: (context, state) => ProjectDetailPage(
                      projectId: state.pathParameters['projectId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.styleLab.path,
                builder: (context, state) => const StyleLabPage(),
                routes: [
                  GoRoute(
                    path: 'profiles/:profileId',
                    builder: (context, state) => StyleLabProfileDetailPage(
                      profileId: state.pathParameters['profileId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'drafts/:runId',
                    builder: (context, state) => StyleLabDraftDetailPage(
                      runId: state.pathParameters['runId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'tasks/:runId',
                    builder: (context, state) => StyleLabTaskDetailPage(
                      runId: state.pathParameters['runId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.plotLab.path,
                builder: (context, state) => const PlotLabPage(),
                routes: [
                  GoRoute(
                    path: 'profiles/:profileId',
                    builder: (context, state) => PlotLabProfileDetailPage(
                      profileId: state.pathParameters['profileId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'tasks/:runId',
                    builder: (context, state) => PlotLabTaskDetailPage(
                      runId: state.pathParameters['runId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.workflowRuns.path,
                builder: (context, state) => const WorkflowRunsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.settings.path,
                builder: (context, state) => const SettingsPage(),
                routes: [
                  GoRoute(
                    path: 'providers/:providerId',
                    builder: (context, state) => ProviderDetailPage(
                      providerId: state.pathParameters['providerId']!,
                    ),
                  ),
                ],
              ),
            ],
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
