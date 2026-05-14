import '../../../core/ui/feature_placeholder_page.dart';

class SettingsPage extends FeaturePlaceholderPage {
  const SettingsPage({super.key})
    : super(
        title: 'Settings',
        description:
            'Local configuration for BYOK providers, data reset, import/export, and backup boundaries.',
        items: const [
          'Provider settings',
          'Local data',
          'Import / export',
          'Backup / restore',
        ],
      );
}
