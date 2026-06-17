import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'app_gap.dart';
import 'hoverable_widget.dart';

class PersonaPage extends StatelessWidget {
  const PersonaPage({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.children,
    this.actions = const [],
    this.maxWidth = 1240,
    this.animateChildren = false,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String description;
  final List<Widget> actions;
  final List<Widget> children;
  final double maxWidth;
  final bool animateChildren;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hasHeader =
        eyebrow.isNotEmpty ||
        title.isNotEmpty ||
        description.isNotEmpty ||
        actions.isNotEmpty;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHPadding,
          AppSpacing.pageVPadding,
          AppSpacing.pageHPadding,
          AppSpacing.pageBottom,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasHeader) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (eyebrow.isNotEmpty)
                              Text(
                                eyebrow,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontFamily: AppFonts.displayFamily,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.primary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            if (eyebrow.isNotEmpty && title.isNotEmpty)
                              const AppGap.xs(),
                            if (title.isNotEmpty)
                              Text(title, style: textTheme.headlineMedium),
                            if (title.isNotEmpty && description.isNotEmpty)
                              const AppGap.sm(),
                            if (description.isNotEmpty)
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 700,
                                ),
                                child: Text(
                                  description,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (actions.isNotEmpty) ...[
                        const AppGap.hXl(),
                        Wrap(spacing: 6, runSpacing: 6, children: actions),
                      ],
                    ],
                  ),
                  const SizedBox(height: 22),
                ],
                _StaggeredList(animate: animateChildren, children: children),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PersonaPanel extends StatelessWidget {
  const PersonaPanel({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.panelInner),
    this.backgroundColor,
    this.hoverable = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final bool hoverable;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget panel = Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor ?? colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.panel),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: AppShadows.panelRest,
        ),
        child: Padding(padding: padding, child: child),
      ),
    );

    if (!hoverable) return panel;

    return HoverableWidget(
      builder: (context, isHovered, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.panel),
            boxShadow: isHovered
                ? AppShadows.panelHover
                : AppShadows.panelRest,
          ),
          child: panel,
        );
      },
    );
  }
}

class PersonaMetric extends StatelessWidget {
  const PersonaMetric({
    required this.label,
    required this.value,
    required this.detail,
    this.progressFraction,
    super.key,
  });

  final String label;
  final String value;
  final String detail;
  final double? progressFraction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return PersonaPanel(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        14,
      ),
      hoverable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: AppFonts.monoFamily,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const AppGap.xs(),
          Text(
            detail,
            style: textTheme.bodyMedium?.copyWith(fontSize: 11.5),
          ),
          if (progressFraction != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progressFraction!.clamp(0.0, 1.0),
                minHeight: 3,
                backgroundColor:
                    colorScheme.primary.withValues(alpha: 0.08),
                valueColor:
                    AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StaggeredList extends StatefulWidget {
  const _StaggeredList({required this.children, this.animate = false});

  final List<Widget> children;
  final bool animate;

  @override
  State<_StaggeredList> createState() => _StaggeredListState();
}

class _StaggeredListState extends State<_StaggeredList> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    if (!widget.animate) {
      _animate = true;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < widget.children.length; i++)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: _animate ? 1.0 : 0.0),
            duration: widget.animate
                ? const Duration(milliseconds: 350)
                : Duration.zero,
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              final delayedValue = (value - (i * 0.08)).clamp(0.0, 1.0);
              return Opacity(
                opacity: delayedValue,
                child: Transform.translate(
                  offset: Offset(0, 16.0 * (1 - delayedValue)),
                  child: child,
                ),
              );
            },
            child: widget.children[i],
          ),
      ],
    );
  }
}

class PersonaStatusPill extends StatelessWidget {
  const PersonaStatusPill({
    required this.label,
    this.icon,
    this.color,
    super.key,
  });

  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: effectiveColor.withValues(alpha: 0.26)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: effectiveColor),
              const AppGap.hSm(),
            ],
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: effectiveColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// A minimalist tab bar designed for the workbench context.
///
/// Displays tabs in a horizontal scrollable row with a subtle animated
/// underline indicator. Supports optional [dividers] — a set of tab
/// indices *after* which a thin vertical divider line is inserted
/// (used to visually group related tabs).
class WorkbenchTabBar extends StatelessWidget {
  const WorkbenchTabBar({
    required this.controller,
    required this.tabs,
    this.dividers = const <int>{},
    super.key,
  });

  final TabController controller;
  final List<String> tabs;
  final Set<int> dividers;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              for (int i = 0; i < tabs.length; i++) ...[
                _WorkbenchTab(
                  label: tabs[i],
                  isSelected: controller.index == i,
                  onTap: () => controller.animateTo(i),
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    color: controller.index == i
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                    fontWeight: controller.index == i
                        ? FontWeight.w600
                        : FontWeight.w400,
                    fontSize: 12.5,
                  ),
                  indicatorColor: colorScheme.primary,
                  hoverColor:
                      colorScheme.onSurface.withValues(alpha: 0.03),
                ),
                if (dividers.contains(i))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: 1,
                      height: 18,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _WorkbenchTab extends StatelessWidget {
  const _WorkbenchTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.labelStyle,
    required this.indicatorColor,
    required this.hoverColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final TextStyle? labelStyle;
  final Color indicatorColor;
  final Color hoverColor;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? indicatorColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: AnimatedDefaultTextStyle(
            style: labelStyle ?? const TextStyle(),
            duration: const Duration(milliseconds: 150),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

/// A minimal monospace section label used in workbench-style pages.
///
/// Renders an uppercase label in a muted monospace font with a short
/// decorative dash prefix. Designed to sit above content sections in
/// editorial / dashboard layouts.
///
/// Use [major] = true for primary section headers on pages (e.g. the
/// main header of a PersonaPanel). This renders a slightly larger font
/// and wider dash to give proper visual weight.
class WorkbenchSectionLabel extends StatelessWidget {
  const WorkbenchSectionLabel(
    this.label, {
    this.major = false,
    super.key,
  });

  final String label;
  final bool major;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: major ? 14 : 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: major ? 24 : 10,
            height: major ? 2 : 1,
            color: major
                ? colorScheme.onSurface.withValues(alpha: 0.5)
                : colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
          const AppGap.hSm(),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: AppFonts.monoFamily,
              fontSize: major ? 18 : 10,
              fontWeight: major ? FontWeight.w600 : FontWeight.w500,
              color: major
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
              letterSpacing: major ? 1.8 : 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state card for workbench tabs using the inline layout pattern.
///
/// Shows a [WorkbenchSectionLabel] with a left accent border, description
/// text on the left, and action buttons on the right — matching the tab
/// header design language.
///
/// When [icon] is provided, a subtle icon container appears inside the
/// left-border area, giving the empty state more visual weight — useful
/// for prominent empty pages where text alone looks too sparse.
class WorkbenchEmptyState extends StatelessWidget {
  const WorkbenchEmptyState({
    required this.sectionLabel,
    required this.title,
    required this.description,
    this.icon,
    this.actions,
    this.hint,
    super.key,
  });

  final String sectionLabel;
  final String title;
  final String description;
  final IconData? icon;
  final Widget? actions;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WorkbenchSectionLabel(sectionLabel),
        Container(
          padding: const EdgeInsets.only(left: AppSpacing.lg),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 600;
              final descBlock = Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (icon != null) ...[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius:
                              BorderRadius.circular(AppRadii.badge),
                          border: Border.all(
                            color: colorScheme.primary
                                .withValues(alpha: 0.16),
                          ),
                        ),
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: Icon(
                            icon,
                            size: 20,
                            color: colorScheme.primary
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      const AppGap.hMd(),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: textTheme.bodyMedium?.copyWith(
                              height: 1.7,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
              if (actions == null) {
                return Row(children: [descBlock]);
              }
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    descBlock,
                    const AppGap.md(),
                    actions!,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  descBlock,
                  const SizedBox(width: 20),
                  actions!,
                ],
              );
            },
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.only(left: 18),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const AppGap.hSm(),
                Expanded(
                  child: Text(
                    hint!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
