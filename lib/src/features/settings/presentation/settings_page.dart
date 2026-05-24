import 'package:flutter/material.dart';

import '../../../core/ui/persona_page.dart';
import 'appearance_tab.dart';
import 'data_backup_tab.dart';
import 'model_config_tab.dart';

enum _SettingsTab {
  modelConfig(label: '模型配置', icon: Icons.smart_toy_outlined),
  dataBackup(label: '数据与备份', icon: Icons.storage_outlined),
  appearance(label: '外观', icon: Icons.palette_outlined);

  const _SettingsTab({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  _SettingsTab _selectedTab = _SettingsTab.modelConfig;

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: '本地控制',
      title: '设置',
      description: '配置 OpenAI-compatible Provider、本地数据边界、导入导出和备份行为。',
      children: [
        _buildTabBar(),
        const SizedBox(height: 20),
        _buildTabContent(),
      ],
    );
  }

  Widget _buildTabBar() {
    final textTheme = Theme.of(context).textTheme;
    return SegmentedButton<_SettingsTab>(
      showSelectedIcon: false,
      segments: [
        for (final tab in _SettingsTab.values)
          ButtonSegment(
            value: tab,
            icon: Icon(tab.icon, size: 15),
            label: Text(tab.label),
          ),
      ],
      selected: {_selectedTab},
      onSelectionChanged: (selection) {
        setState(() => _selectedTab = selection.first);
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.standard,
        textStyle: WidgetStatePropertyAll(textTheme.labelSmall),
      ),
    );
  }

  Widget _buildTabContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: switch (_selectedTab) {
        _SettingsTab.modelConfig => const ModelConfigTab(
          key: ValueKey('model-config'),
        ),
        _SettingsTab.dataBackup => const DataBackupTab(
          key: ValueKey('data-backup'),
        ),
        _SettingsTab.appearance => const AppearanceTab(
          key: ValueKey('appearance'),
        ),
      },
    );
  }
}
