import 'package:flutter/material.dart';

import '../../../core/ui/persona_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: 'Local control',
      title: 'Settings',
      description:
          'Configure OpenAI-compatible providers, local data boundaries, import/export, and backup behavior.',
      children: const [_SettingsGrid()],
    );
  }
}

class _SettingsGrid extends StatelessWidget {
  const _SettingsGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 2 : 1;

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          shrinkWrap: true,
          childAspectRatio: columns == 2 ? 3.2 : 4,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            PersonaActionTile(
              icon: Icons.key_outlined,
              title: 'Provider settings',
              description: 'Base URL, API key, default model, and test calls.',
              accent: true,
            ),
            PersonaActionTile(
              icon: Icons.storage_outlined,
              title: 'Local data',
              description: 'SQLite workspace boundaries and reset controls.',
            ),
            PersonaActionTile(
              icon: Icons.import_export,
              title: 'Import / export',
              description: 'Move manuscripts, profiles, and project files.',
            ),
            PersonaActionTile(
              icon: Icons.settings_backup_restore,
              title: 'Backup / restore',
              description: 'Portable local workspace snapshots.',
            ),
          ],
        );
      },
    );
  }
}
