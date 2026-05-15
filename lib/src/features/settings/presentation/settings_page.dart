import 'package:flutter/material.dart';

import '../../../core/ui/persona_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: '本地控制',
      title: '设置',
      description: '配置 OpenAI-compatible Provider、本地数据边界、导入导出和备份行为。',
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
              title: 'Provider 设置',
              description: 'Base URL、API Key、默认模型和连通性测试。',
              accent: true,
            ),
            PersonaActionTile(
              icon: Icons.storage_outlined,
              title: '本地数据',
              description: 'SQLite 工作区边界和重置控制。',
            ),
            PersonaActionTile(
              icon: Icons.import_export,
              title: '导入 / 导出',
              description: '迁移手稿、档案和项目文件。',
            ),
            PersonaActionTile(
              icon: Icons.settings_backup_restore,
              title: '备份 / 恢复',
              description: '可移植的本地工作区快照。',
            ),
          ],
        );
      },
    );
  }
}
