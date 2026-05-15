import 'package:flutter/material.dart';

import '../../../core/ui/persona_page.dart';

class StyleLabPage extends StatelessWidget {
  const StyleLabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: 'Creative canvas',
      title: 'Style Lab',
      description:
          'Analyze sample prose, distill voice profiles, and prepare reusable style direction for long-form drafting.',
      actions: [
        FilledButton.icon(
          onPressed: null,
          icon: Icon(Icons.upload_file_outlined),
          label: Text('Import sample'),
        ),
      ],
      children: const [
        _StylePipeline(),
        SizedBox(height: 18),
        _StyleProfilesPanel(),
      ],
    );
  }
}

class _StylePipeline extends StatelessWidget {
  const _StylePipeline();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: PersonaActionTile(
            icon: Icons.text_snippet_outlined,
            title: 'Sample intake',
            description: 'Collect TXT excerpts and source context.',
            accent: true,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: PersonaActionTile(
            icon: Icons.graphic_eq_outlined,
            title: 'Voice analysis',
            description: 'Extract rhythm, diction, pacing, and texture.',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: PersonaActionTile(
            icon: Icons.style_outlined,
            title: 'Style profile',
            description: 'Save reusable guidance for project drafting.',
          ),
        ),
      ],
    );
  }
}

class _StyleProfilesPanel extends StatelessWidget {
  const _StyleProfilesPanel();

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          PersonaSectionHeader(
            title: 'Voice profiles',
            description:
                'Profiles will appear here after analysis tasks persist their results.',
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              PersonaStatusPill(label: 'Diction', icon: Icons.short_text),
              PersonaStatusPill(label: 'Pacing', icon: Icons.speed),
              PersonaStatusPill(label: 'Scene texture', icon: Icons.blur_on),
              PersonaStatusPill(label: 'Narrative distance', icon: Icons.tune),
            ],
          ),
        ],
      ),
    );
  }
}
