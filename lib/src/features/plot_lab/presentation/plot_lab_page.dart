import '../../../core/ui/feature_placeholder_page.dart';

class PlotLabPage extends FeaturePlaceholderPage {
  const PlotLabPage({super.key})
    : super(
        title: 'Plot Lab',
        description:
            'TXT sample ingestion, story skeleton extraction, story engine creation, and plot profiles.',
        items: const [
          'Sample import',
          'Skeleton generation',
          'Story Engine',
          'Plot Profile',
        ],
      );
}
