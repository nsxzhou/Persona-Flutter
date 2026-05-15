import 'package:flutter/material.dart';

import '../../../core/ui/persona_page.dart';

class StyleLabPage extends StatelessWidget {
  const StyleLabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: '创作画布',
      title: '风格实验室',
      description: '分析样本文本，提炼 Voice Profile，并为长篇写作准备可复用的风格方向。',
      actions: [
        FilledButton.icon(
          onPressed: null,
          icon: Icon(Icons.upload_file_outlined),
          label: Text('导入样本'),
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
            title: '样本导入',
            description: '收集 TXT 片段和来源上下文。',
            accent: true,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: PersonaActionTile(
            icon: Icons.graphic_eq_outlined,
            title: '声音分析',
            description: '提取节奏、措辞、叙述速度和文本质感。',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: PersonaActionTile(
            icon: Icons.style_outlined,
            title: '风格档案',
            description: '保存可复用于项目写作的风格指导。',
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
            title: 'Voice Profile',
            description: '分析任务持久化结果后，风格档案会显示在这里。',
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              PersonaStatusPill(label: '措辞', icon: Icons.short_text),
              PersonaStatusPill(label: '节奏', icon: Icons.speed),
              PersonaStatusPill(label: '场景质感', icon: Icons.blur_on),
              PersonaStatusPill(label: '叙述距离', icon: Icons.tune),
            ],
          ),
        ],
      ),
    );
  }
}
