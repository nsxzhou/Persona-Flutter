import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SettingsSidebar(
              selectedTab: _selectedTab,
              onTabChanged: (tab) => setState(() => _selectedTab = tab),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topLeft,
          children: [
            ...previousChildren,
            currentChild ?? const SizedBox.shrink(),
          ],
        );
      },
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

class _SettingsSidebar extends StatelessWidget {
  const _SettingsSidebar({
    required this.selectedTab,
    required this.onTabChanged,
  });

  final _SettingsTab selectedTab;
  final ValueChanged<_SettingsTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: PersonaPanel(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final tab in _SettingsTab.values)
              _SettingsSidebarItem(
                tab: tab,
                isSelected: tab == selectedTab,
                onTap: () => onTabChanged(tab),
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSidebarItem extends StatelessWidget {
  const _SettingsSidebarItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final _SettingsTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.panel - 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer.withValues(alpha: 0.35)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.panel - 4),
          ),
          child: Row(
            children: [
              Icon(
                tab.icon,
                size: 18,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tab.label,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
