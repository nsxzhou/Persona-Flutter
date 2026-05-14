enum AppRoute {
  projects(path: '/projects', label: 'Projects', pageTitle: 'Projects'),
  styleLab(path: '/style-lab', label: 'Style Lab', pageTitle: 'Style Lab'),
  plotLab(path: '/plot-lab', label: 'Plot Lab', pageTitle: 'Plot Lab'),
  workflowRuns(
    path: '/workflow-runs',
    label: 'Workflow Runs',
    pageTitle: 'Workflow Runs',
  ),
  settings(path: '/settings', label: 'Settings', pageTitle: 'Settings');

  const AppRoute({
    required this.path,
    required this.label,
    required this.pageTitle,
  });

  final String path;
  final String label;
  final String pageTitle;
}
