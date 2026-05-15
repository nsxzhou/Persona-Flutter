import 'package:flutter/material.dart';

import '../../../core/ui/persona_page.dart';

class PlotLabPage extends StatelessWidget {
  const PlotLabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: '故事映射',
      title: '剧情实验室',
      description: '提取故事骨架，整理可复用的剧情档案，并为项目规划准备 Story Engine。',
      actions: [
        FilledButton.icon(
          onPressed: null,
          icon: Icon(Icons.account_tree_outlined),
          label: Text('生成骨架'),
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
            title: 'Story Engine 流程',
            description: '从样本文本到可复用剧情档案的结构化路径。',
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: PersonaMetric(
                  label: '输入',
                  value: 'TXT',
                  detail: '样本手稿或大纲来源。',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: PersonaMetric(
                  label: '提取',
                  value: '骨架',
                  detail: '分幕、转折、场景、风险和揭示。',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: PersonaMetric(
                  label: '输出',
                  value: '档案',
                  detail: '供项目工作台复用的剧情指导。',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
