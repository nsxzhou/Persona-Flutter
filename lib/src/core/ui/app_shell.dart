import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_route.dart';

const _collapsedSidebarWidth = 76.0;
const _expandedSidebarWidth = 238.0;

class AppShell extends StatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = widget.navigationShell.currentIndex;

    return Scaffold(
      body: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          children: [
            AnimatedContainer(
              key: const ValueKey('app-sidebar'),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: _isExpanded
                  ? _expandedSidebarWidth
                  : _collapsedSidebarWidth,
              child: _PersonaSidebar(
                isExpanded: _isExpanded,
                selectedIndex: selectedIndex,
                onToggle: () {
                  setState(() => _isExpanded = !_isExpanded);
                },
                onDestinationSelected: (index) {
                  widget.navigationShell.goBranch(
                    index,
                    initialLocation: index == selectedIndex,
                  );
                },
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: widget.navigationShell),
          ],
        ),
      ),
    );
  }
}

class _PersonaSidebar extends StatelessWidget {
  const _PersonaSidebar({
    required this.isExpanded,
    required this.selectedIndex,
    required this.onToggle,
    required this.onDestinationSelected,
  });

  final bool isExpanded;
  final int selectedIndex;
  final VoidCallback onToggle;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      child: SafeArea(
        right: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
          child: Column(
            children: [
              _SidebarBrand(isExpanded: isExpanded),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: _navigationItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = _navigationItems[index];

                    return _SidebarDestination(
                      item: item,
                      isExpanded: isExpanded,
                      isSelected: selectedIndex == index,
                      onTap: () => onDestinationSelected(index),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              _SidebarContextCard(isExpanded: isExpanded),
              const SizedBox(height: 12),
              IconButton(
                tooltip: isExpanded ? '折叠侧栏' : '展开侧栏',
                onPressed: onToggle,
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_double_arrow_left
                      : Icons.keyboard_double_arrow_right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarBrand extends StatelessWidget {
  const _SidebarBrand({required this.isExpanded});

  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(Icons.auto_stories, color: colorScheme.onPrimary),
        ),
        if (isExpanded) ...[
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Persona', style: textTheme.titleMedium),
                Text(
                  '本地写作系统',
                  style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SidebarDestination extends StatelessWidget {
  const _SidebarDestination({
    required this.item,
    required this.isExpanded,
    required this.isSelected,
    required this.onTap,
  });

  final _NavigationItem item;
  final bool isExpanded;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Tooltip(
      message: isExpanded ? '' : item.route.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isExpanded ? 12 : 0,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? item.selectedIcon : item.icon,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 22,
              ),
              if (isExpanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.route.label,
                    style: textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarContextCard extends StatelessWidget {
  const _SidebarContextCard({required this.isExpanded});

  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    if (!isExpanded) {
      return Icon(
        Icons.offline_bolt_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('工作区', style: textTheme.labelMedium),
            const SizedBox(height: 8),
            Text('本地优先', style: textTheme.titleMedium),
            const SizedBox(height: 2),
            Text('待配置 BYOK Provider', style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.route,
    required this.icon,
    required this.selectedIcon,
  });

  final AppRoute route;
  final IconData icon;
  final IconData selectedIcon;
}

const _navigationItems = [
  _NavigationItem(
    route: AppRoute.projects,
    icon: Icons.folder_outlined,
    selectedIcon: Icons.folder,
  ),
  _NavigationItem(
    route: AppRoute.styleLab,
    icon: Icons.palette_outlined,
    selectedIcon: Icons.palette,
  ),
  _NavigationItem(
    route: AppRoute.plotLab,
    icon: Icons.account_tree_outlined,
    selectedIcon: Icons.account_tree,
  ),
  _NavigationItem(
    route: AppRoute.workflowRuns,
    icon: Icons.sync_alt_outlined,
    selectedIcon: Icons.sync_alt,
  ),
  _NavigationItem(
    route: AppRoute.settings,
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
];
