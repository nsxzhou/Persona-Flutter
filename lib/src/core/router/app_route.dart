enum AppRoute {
  projects(path: '/projects', label: '项目', pageTitle: '项目'),
  styleLab(path: '/style-lab', label: '风格实验室', pageTitle: '风格实验室'),
  plotLab(path: '/plot-lab', label: '剧情实验室', pageTitle: '剧情实验室'),
  workflowRuns(path: '/workflow-runs', label: '工作流任务', pageTitle: '工作流任务'),
  settings(path: '/settings', label: '设置', pageTitle: '设置');

  const AppRoute({
    required this.path,
    required this.label,
    required this.pageTitle,
  });

  final String path;
  final String label;
  final String pageTitle;
}
