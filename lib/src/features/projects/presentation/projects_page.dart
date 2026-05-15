import 'package:flutter/material.dart';

import '../../../core/ui/persona_page.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: 'Workspace',
      title: 'Projects',
      description:
          'Your local writing desk for long-form projects, blueprints, chapter work, and future Zen Editor sessions.',
      actions: [
        FilledButton.icon(
          onPressed: null,
          icon: Icon(Icons.add),
          label: Text('New project'),
        ),
        OutlinedButton.icon(
          onPressed: null,
          icon: Icon(Icons.upload_file_outlined),
          label: Text('Import'),
        ),
      ],
      children: const [
        _WorkspaceSummary(),
        SizedBox(height: 18),
        _ProjectsLayout(),
      ],
    );
  }
}

class _WorkspaceSummary extends StatelessWidget {
  const _WorkspaceSummary();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: PersonaMetric(
            label: 'Active project',
            value: '0',
            detail: 'Create or import a project to begin.',
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: PersonaMetric(
            label: 'Draft queue',
            value: 'Ready',
            detail: 'Chapter workbench and Zen Editor entry points.',
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: PersonaMetric(
            label: 'Local state',
            value: 'Offline',
            detail: 'SQLite-backed workspace, no account required.',
          ),
        ),
      ],
    );
  }
}

class _ProjectsLayout extends StatelessWidget {
  const _ProjectsLayout();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 940;

        final recent = PersonaPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              PersonaSectionHeader(
                title: 'Recent projects',
                description:
                    'A focused launch point for project workbench and chapter navigation.',
              ),
              SizedBox(height: 18),
              _EmptyProjectsState(),
            ],
          ),
        );

        final actions = Column(
          children: const [
            PersonaActionTile(
              icon: Icons.note_add_outlined,
              title: 'Start from a blank novel',
              description: 'Create a local project shell and chapter tree.',
              accent: true,
            ),
            SizedBox(height: 12),
            PersonaActionTile(
              icon: Icons.description_outlined,
              title: 'Import manuscript',
              description: 'Bring in TXT material for future analysis.',
            ),
            SizedBox(height: 12),
            PersonaActionTile(
              icon: Icons.view_timeline_outlined,
              title: 'Open workbench',
              description: 'Review blueprint, characters, outline, and drafts.',
            ),
          ],
        );

        if (!isWide) {
          return Column(
            children: [recent, const SizedBox(height: 18), actions],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: recent),
            const SizedBox(width: 18),
            Expanded(flex: 4, child: actions),
          ],
        );
      },
    );
  }
}

class _EmptyProjectsState extends StatelessWidget {
  const _EmptyProjectsState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Icon(
              Icons.library_books_outlined,
              color: colorScheme.primary,
              size: 36,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No project opened yet', style: textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    'The project list will surface recent novels, chapter status, and Zen Editor entry points when project storage is implemented.',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
