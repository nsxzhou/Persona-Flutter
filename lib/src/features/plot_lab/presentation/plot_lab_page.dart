import 'package:flutter/material.dart';

import '../../../core/ui/persona_page.dart';

class PlotLabPage extends StatelessWidget {
  const PlotLabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: 'Story mapping',
      title: 'Plot Lab',
      description:
          'Extract story skeletons, shape reusable plot profiles, and prepare a Story Engine for project planning.',
      actions: [
        FilledButton.icon(
          onPressed: null,
          icon: Icon(Icons.account_tree_outlined),
          label: Text('Generate skeleton'),
        ),
      ],
      children: const [_PlotMapPreview()],
    );
  }
}

class _PlotMapPreview extends StatelessWidget {
  const _PlotMapPreview();

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          PersonaSectionHeader(
            title: 'Story engine pipeline',
            description:
                'A structured path from sample text to reusable plot profile.',
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: PersonaMetric(
                  label: 'Input',
                  value: 'TXT',
                  detail: 'Sample manuscript or outline source.',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: PersonaMetric(
                  label: 'Extraction',
                  value: 'Skeleton',
                  detail: 'Acts, turns, scenes, stakes, and reveals.',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: PersonaMetric(
                  label: 'Output',
                  value: 'Profile',
                  detail: 'Reusable plot guidance for project workbench.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
