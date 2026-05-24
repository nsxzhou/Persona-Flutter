import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/tasks/domain/workflow_task.dart';
import '../../../core/ui/persona_page.dart';
import '../../plot_lab/application/plot_lab_providers.dart';
import '../../plot_lab/domain/plot_analysis_run.dart';
import '../../style_lab/application/style_lab_providers.dart';
import '../../style_lab/domain/style_analysis_run.dart';
import 'workflow_run_helpers.dart';

class WorkflowRunRow extends ConsumerStatefulWidget {
  const WorkflowRunRow({required this.task, super.key});

  final WorkflowTask task;

  @override
  ConsumerState<WorkflowRunRow> createState() => _WorkflowRunRowState();
}

class _WorkflowRunRowState extends ConsumerState<WorkflowRunRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final task = widget.task;
    final sColor = statusColor(colorScheme, task.status);

    // Only watch related providers for tasks that need business detail links
    final styleRun = task.kind == styleAnalysisWorkflowTaskKind
        ? ref.watch(styleAnalysisRunByWorkflowTaskProvider(task.id))
        : null;
    final plotRun = task.kind == plotAnalysisWorkflowTaskKind
        ? ref.watch(plotAnalysisRunByWorkflowTaskProvider(task.id))
        : null;

    final businessPath = _businessDetailPath(task, styleRun, plotRun);
    final canOpenBusiness = businessPath != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/workflow-runs/${task.id}'),
          child: Container(
            decoration: BoxDecoration(
              color: _isHovered
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.15)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 126,
                    child: PersonaStatusPill(
                      label: statusLabel(task.status),
                      icon: statusIcon(task.status),
                      color: sColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          kindLabel(task.kind),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    formatRunTime(task.updatedAt),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (canOpenBusiness)
                    IconButton(
                      icon: const Icon(Icons.open_in_new, size: 16),
                      tooltip: '打开业务详情',
                      onPressed: () => context.go(businessPath),
                      visualDensity: VisualDensity.compact,
                    )
                  else
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? _businessDetailPath(
  WorkflowTask task,
  AsyncValue<StyleAnalysisRun?>? styleRun,
  AsyncValue<PlotAnalysisRun?>? plotRun,
) {
  return switch (task.kind) {
    styleAnalysisWorkflowTaskKind => switch (styleRun) {
      AsyncData(value: final run?) => '/style-lab/tasks/${run.id}',
      _ => null,
    },
    plotAnalysisWorkflowTaskKind => switch (plotRun) {
      AsyncData(value: final run?) => '/plot-lab/tasks/${run.id}',
      _ => null,
    },
    _ => null,
  };
}
