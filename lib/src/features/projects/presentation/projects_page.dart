import '../../../core/ui/feature_placeholder_page.dart';

class ProjectsPage extends FeaturePlaceholderPage {
  const ProjectsPage({super.key})
    : super(
        title: 'Projects',
        description:
            'Local writing projects, blueprints, chapters, and later Zen Editor entry points.',
        items: const [
          'Project list',
          'Project workbench',
          'Chapter tree',
          'Zen Editor child route',
        ],
      );
}
