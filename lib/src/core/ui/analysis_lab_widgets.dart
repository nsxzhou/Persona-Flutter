import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import 'persona_page.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// State of a single stage step in a pipeline progress view.
enum StageStepState { done, active, failed, waiting }

// ---------------------------------------------------------------------------
// Generic helpers
// ---------------------------------------------------------------------------

/// Finds the first item in [items] whose [getId] matches [id], or `null`.
T? findOrNull<T>(List<T> items, String? id, String Function(T item) getId) {
  if (id == null) return null;
  for (final item in items) {
    if (getId(item) == id) return item;
  }
  return null;
}

/// Formats [value] as `MM-DD HH:mm` in local time.
String formatDate(DateTime value) {
  final local = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}

/// Returns a display label for a provider + model combination.
String providerLabel(String? providerName, String modelName) {
  if (providerName == null || providerName.isEmpty) return modelName;
  return '$providerName · $modelName';
}

/// Status label from a raw status string (pending/running/succeeded/failed).
String statusLabel(String status) => status;

/// Status icon from a raw status string.
IconData statusIcon(String status) {
  return switch (status) {
    'pending' => Icons.schedule,
    'running' => Icons.sync,
    'succeeded' => Icons.check_circle_outline,
    'failed' => Icons.error_outline,
    _ => Icons.help_outline,
  };
}

/// Status color from a raw status string.
Color statusColor(ColorScheme colorScheme, String status) {
  return switch (status) {
    'pending' => colorScheme.tertiary,
    'running' => colorScheme.primary,
    'succeeded' => const Color(0xFF16825D),
    'failed' => colorScheme.error,
    _ => colorScheme.onSurfaceVariant,
  };
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

/// A monospace code display block with optional scroll expansion.
class CodeBlock extends StatelessWidget {
  const CodeBlock({required this.text, this.expand = false, super.key});

  final String text;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(kPanelRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: expand
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                text,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5),
              ),
            )
          : ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 220, maxHeight: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  text,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
    );
    return SizedBox(width: double.infinity, child: content);
  }
}

/// An inline error banner with icon and message.
class InlineError extends StatelessWidget {
  const InlineError({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: TextStyle(color: colorScheme.error)),
            ),
          ],
        ),
      ),
    );
  }
}

/// A pill-shaped label showing the state of a pipeline stage step.
class StageStepPill extends StatelessWidget {
  const StageStepPill({required this.label, required this.state, super.key});

  final String label;
  final StageStepState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, color) = switch (state) {
      StageStepState.done => (Icons.check, const Color(0xFF16825D)),
      StageStepState.active => (Icons.sync, colorScheme.primary),
      StageStepState.failed => (Icons.error_outline, colorScheme.error),
      StageStepState.waiting => (
        Icons.radio_button_unchecked,
        colorScheme.onSurfaceVariant,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// A generic detail loading placeholder page.
class AnalysisDetailLoading extends StatelessWidget {
  const AnalysisDetailLoading({
    required this.eyebrow,
    required this.description,
    super.key,
  });

  final String eyebrow;
  final String description;

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: eyebrow,
      title: '读取中',
      description: description,
      children: const [
        PersonaPanel(
          child: SizedBox(
            height: 260,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}

/// A generic "detail not found" page with a back button.
class AnalysisMissingDetail extends StatelessWidget {
  const AnalysisMissingDetail({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.backRoute,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String description;
  final String backRoute;

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: eyebrow,
      title: title,
      description: description,
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go(backRoute),
          icon: const Icon(Icons.arrow_back_outlined),
          label: const Text('返回档案库'),
        ),
      ],
      children: const [
        PersonaPanel(
          child: PersonaEmptyStateCard(
            icon: Icons.search_off_outlined,
            title: '没有找到内容',
            description: '返回档案库选择其他 Profile。',
          ),
        ),
      ],
    );
  }
}
