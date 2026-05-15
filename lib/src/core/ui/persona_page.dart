import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'hoverable_widget.dart';
import 'staggered_list.dart';

class PersonaPage extends StatelessWidget {
  const PersonaPage({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.children,
    this.actions = const [],
    this.maxWidth = 1240,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String description;
  final List<Widget> actions;
  final List<Widget> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eyebrow.toUpperCase(),
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(title, style: textTheme.headlineMedium),
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 700),
                            child: Text(
                              description,
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (actions.isNotEmpty) ...[
                      const SizedBox(width: 24),
                      Wrap(spacing: 10, runSpacing: 10, children: actions),
                    ],
                  ],
                ),
                const SizedBox(height: 28),
                StaggeredList(children: children),
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
    this.padding = const EdgeInsets.all(20),
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
          borderRadius: BorderRadius.circular(kPanelRadius),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              offset: const Offset(0, 10),
              blurRadius: 24,
            ),
          ],
        ),
        child: Padding(padding: padding, child: child),
      ),
    );

    if (!hoverable) return panel;

    return HoverableWidget(
      builder: (context, isHovered, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kPanelRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isHovered ? 0.08 : 0.035),
                offset: Offset(0, isHovered ? 14 : 10),
                blurRadius: isHovered ? 32 : 24,
              ),
            ],
          ),
          child: panel,
        );
      },
    );
  }
}

class PersonaSectionHeader extends StatelessWidget {
  const PersonaSectionHeader({
    required this.title,
    required this.description,
    this.trailing,
    super.key,
  });

  final String title;
  final String description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 16), trailing!],
      ],
    );
  }
}

class PersonaMetric extends StatelessWidget {
  const PersonaMetric({
    required this.label,
    required this.value,
    required this.detail,
    super.key,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return PersonaPanel(
      padding: const EdgeInsets.all(16),
      hoverable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: textTheme.labelMedium),
          const SizedBox(height: 14),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(detail, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class PersonaActionTile extends StatelessWidget {
  const PersonaActionTile({
    required this.icon,
    required this.title,
    required this.description,
    this.accent = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return HoverableWidget(
      builder: (context, isHovered, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kPanelRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isHovered ? 0.08 : 0.035),
                offset: Offset(0, isHovered ? 14 : 10),
                blurRadius: isHovered ? 32 : 24,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(kPanelRadius),
              onTap: () {},
              hoverColor: colorScheme.primary.withValues(alpha: 0.04),
              child: PersonaPanel(
                padding: const EdgeInsets.all(16),
                backgroundColor: accent
                    ? colorScheme.primary.withValues(alpha: isHovered ? 0.12 : 0.08)
                    : (isHovered
                        ? colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5)
                        : null),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: accent
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(kButtonRadius),
                      ),
                      child: Icon(
                        icon,
                        color: accent
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: textTheme.titleMedium),
                          const SizedBox(height: 3),
                          Text(description, style: textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: colorScheme.onSurfaceVariant,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: effectiveColor.withValues(alpha: 0.26)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: effectiveColor),
              const SizedBox(width: 6),
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
