import 'package:flutter/material.dart';

import '../../../../core/ui/persona_page.dart';
import '../../domain/market_scan_run.dart';
import 'market_scan_formatters.dart';

class ScanHistoryTimeline extends StatelessWidget {
  const ScanHistoryTimeline({required this.runs, super.key});

  final List<MarketScanRun> runs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final visibleRuns = runs.take(12).toList(growable: false);

    if (visibleRuns.isEmpty) {
      return Text(
        '暂无扫描记录',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < visibleRuns.length; i++)
          _TimelineEntry(
            run: visibleRuns[i],
            isLast: i == visibleRuns.length - 1,
          ),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.run, required this.isLast});

  final MarketScanRun run;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = scanRunStatusColor(run.status, colorScheme);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.surface,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.3),
                        blurRadius: 0,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 1,
                    height: 48,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: colorScheme.outlineVariant,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: isLast
                      ? BorderSide.none
                      : BorderSide(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            platformDisplayName(run.platform),
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatRadarTime(run.startedAt),
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (run.errorMessage != null &&
                              run.errorMessage!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              run.errorMessage!,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    PersonaStatusPill(
                      label: run.status == MarketScanRunStatus.completed
                          ? '${run.itemCount} 条'
                          : scanRunStatusLabel(run.status),
                      icon: scanRunStatusIcon(run.status),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
