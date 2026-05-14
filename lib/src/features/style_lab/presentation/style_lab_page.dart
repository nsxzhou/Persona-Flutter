import '../../../core/ui/feature_placeholder_page.dart';

class StyleLabPage extends FeaturePlaceholderPage {
  const StyleLabPage({super.key})
    : super(
        title: 'Style Lab',
        description:
            'TXT sample ingestion, style analysis jobs, voice profiles, and reusable style profiles.',
        items: const [
          'Sample import',
          'Analysis task',
          'Voice Profile',
          'Style Profile',
        ],
      );
}
