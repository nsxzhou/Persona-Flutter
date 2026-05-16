import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/app_route.dart';
import '../theme/app_theme.dart';
import '../theme/theme_mode_provider.dart';
import 'animated_theme_toggler.dart';
import 'glass_container.dart';

const _collapsedSidebarWidth = 76.0;
const _expandedSidebarWidth = 238.0;
const _sidebarHorizontalPadding = 24.0;

class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = widget.navigationShell.currentIndex;
    final colorScheme = Theme.of(context).colorScheme;
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: _isExpanded ? 1 : 0),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      builder: (context, sidebarProgress, child) {
        return Scaffold(
          body: ColoredBox(
            color: scaffoldBackgroundColor,
            child: Row(
              children: [
                SizedBox(
                  key: const ValueKey('app-sidebar'),
                  width: lerpDouble(
                    _collapsedSidebarWidth,
                    _expandedSidebarWidth,
                    sidebarProgress,
                  )!,
                  child: _PersonaSidebar(
                    sidebarProgress: sidebarProgress,
                    isExpanded: _isExpanded,
                    selectedIndex: selectedIndex,
                    onToggle: () {
                      setState(() => _isExpanded = !_isExpanded);
                    },
                    onThemeToggle: () {
                      ref.read(themeModeProvider.notifier).toggle();
                    },
                    onDestinationSelected: (index) {
                      widget.navigationShell.goBranch(
                        index,
                        initialLocation: index == selectedIndex,
                      );
                    },
                  ),
                ),
                Container(
                  width: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.outlineVariant.withValues(alpha: 0.3),
                        colorScheme.outlineVariant.withValues(alpha: 0.08),
                      ],
                    ),
                  ),
                ),
                Expanded(child: widget.navigationShell),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PersonaSidebar extends StatelessWidget {
  const _PersonaSidebar({
    required this.sidebarProgress,
    required this.isExpanded,
    required this.selectedIndex,
    required this.onToggle,
    required this.onThemeToggle,
    required this.onDestinationSelected,
  });

  final double sidebarProgress;
  final bool isExpanded;
  final int selectedIndex;
  final VoidCallback onToggle;
  final VoidCallback onThemeToggle;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 0,
      blurSigma: 14,
      border: Border.all(color: Colors.transparent),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.hardEdge,
        child: SafeArea(
          right: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
            child: Column(
              children: [
                _SidebarBrand(sidebarProgress: sidebarProgress),
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
                        sidebarProgress: sidebarProgress,
                        isExpanded: isExpanded,
                        isSelected: selectedIndex == index,
                        onTap: () => onDestinationSelected(index),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                if (isExpanded)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedThemeToggler(onPressed: onThemeToggle),
                      const SizedBox(width: 8),
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
                  )
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedThemeToggler(onPressed: onThemeToggle),
                      const SizedBox(height: 8),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarBrand extends StatelessWidget {
  const _SidebarBrand({required this.sidebarProgress});

  final double sidebarProgress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelOpacity = _expandedContentProgress(sidebarProgress);
    const expandedContentWidth =
        _expandedSidebarWidth - _sidebarHorizontalPadding;

    return SizedBox(
      height: 44,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 1 - labelOpacity,
            child: const Center(
              child: _SidebarLogo(key: ValueKey('sidebar-brand-logo')),
            ),
          ),
          ClipRect(
            child: SizedBox(
              width: expandedContentWidth * labelOpacity,
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                minWidth: expandedContentWidth,
                maxWidth: expandedContentWidth,
                child: Opacity(
                  opacity: labelOpacity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _SidebarLogo(),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Persona', style: textTheme.titleMedium),
                          Text(
                            '本地写作系统',
                            style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarDestination extends StatelessWidget {
  const _SidebarDestination({
    required this.item,
    required this.sidebarProgress,
    required this.isExpanded,
    required this.isSelected,
    required this.onTap,
  });

  final _NavigationItem item;
  final double sidebarProgress;
  final bool isExpanded;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final labelOpacity = _expandedContentProgress(sidebarProgress);
    const expandedContentWidth =
        _expandedSidebarWidth - _sidebarHorizontalPadding - 24;
    final destination = InkWell(
      borderRadius: BorderRadius.circular(kPanelRadius),
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
          borderRadius: BorderRadius.circular(kPanelRadius),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
          ),
        ),
        child: SizedBox(
          height: 22,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: 1 - labelOpacity,
                child: Center(
                  child: Icon(
                    isSelected ? item.selectedIcon : item.icon,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ),
              ),
              ClipRect(
                child: SizedBox(
                  width: expandedContentWidth * labelOpacity,
                  child: OverflowBox(
                    alignment: Alignment.centerLeft,
                    minWidth: expandedContentWidth,
                    maxWidth: expandedContentWidth,
                    child: Opacity(
                      opacity: labelOpacity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.selectedIcon : item.icon,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item.route.label,
                            style: textTheme.labelLarge?.copyWith(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (labelOpacity < 0.5) {
      return Tooltip(message: item.route.label, child: destination);
    }

    return destination;
  }
}

double _expandedContentProgress(double sidebarProgress) {
  if (sidebarProgress <= 0.42) {
    return 0;
  }

  return ((sidebarProgress - 0.42) / 0.58).clamp(0.0, 1.0).toDouble();
}

class _SidebarLogo extends StatelessWidget {
  const _SidebarLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(kPanelRadius),
      ),
      child: Icon(Icons.auto_stories, color: colorScheme.onPrimary),
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
