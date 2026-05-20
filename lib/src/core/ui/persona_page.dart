import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
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
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
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
                                eyebrow.toUpperCase(),
                                style: textTheme.labelMedium?.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                            if (eyebrow.isNotEmpty && title.isNotEmpty)
                              const SizedBox(height: 10),
                            if (title.isNotEmpty)
                              Text(title, style: textTheme.headlineMedium),
                            if (title.isNotEmpty && description.isNotEmpty)
                              const SizedBox(height: 10),
                            if (description.isNotEmpty)
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 700,
                                ),
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

class PersonaEmptyStateCard extends StatelessWidget {
  const PersonaEmptyStateCard({
    required this.icon,
    required this.title,
    required this.description,
    this.action,
    this.centered = false,
    this.maxWidth,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? action;
  final bool centered;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(kPanelRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(centered ? 28 : 22),
        child: centered
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _EmptyStateIcon(icon: icon),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (action != null) ...[const SizedBox(height: 22), action!],
                ],
              )
            : Row(
                children: [
                  _EmptyStateIcon(icon: icon, compact: true),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: textTheme.titleLarge),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (action != null) ...[const SizedBox(width: 16), action!],
                ],
              ),
      ),
    );

    if (maxWidth == null) return content;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth!),
      child: content,
    );
  }
}

class _EmptyStateIcon extends StatelessWidget {
  const _EmptyStateIcon({required this.icon, this.compact = false});

  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = compact ? 44.0 : 72.0;
    final iconSize = compact ? 28.0 : 34.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(compact ? 10 : 14),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, color: colorScheme.primary, size: iconSize),
      ),
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
