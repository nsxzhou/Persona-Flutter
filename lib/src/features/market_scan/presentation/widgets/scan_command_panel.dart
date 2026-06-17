import 'package:flutter/material.dart';

import '../../application/market_scan_controller.dart';
import '../../application/market_scan_providers.dart';
import 'market_scan_formatters.dart';
import 'shared_chips.dart';

/// Scan controls + data health in one compact card.
class MarketDataOperationsPanel extends StatelessWidget {
  const MarketDataOperationsPanel({
    required this.bundle,
    required this.hasMarketData,
    required this.scanState,
    required this.runningTaskId,
    required this.healthDescription,
    required this.onScanNow,
    required this.onClearScanData,
    required this.onAbandonTask,
    super.key,
  });

  final ScanDataBundle bundle;
  final bool hasMarketData;
  final MarketScanState scanState;
  final String? runningTaskId;
  final String healthDescription;
  final Future<void> Function() onScanNow;
  final Future<void> Function() onClearScanData;
  final Future<void> Function(String taskId) onAbandonTask;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final commandsDisabled = scanState.isScanning || scanState.isClearing;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 760;
                final titleBlock = _ScanTitleBlock(hasMarketData: hasMarketData);
                final statusStrip = ScanStatusStrip(
                  hasMarketData: hasMarketData,
                  scanState: scanState,
                  runningTaskId: runningTaskId,
                  compact: true,
                );
                final actions = _ScanActions(
                  commandsDisabled: commandsDisabled,
                  scanState: scanState,
                  runningTaskId: runningTaskId,
                  onScanNow: onScanNow,
                  onClearScanData: onClearScanData,
                  onAbandonTask: onAbandonTask,
                );

                if (wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: titleBlock),
                          const SizedBox(width: 16),
                          statusStrip,
                        ],
                      ),
                      const SizedBox(height: 14),
                      actions,
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    titleBlock,
                    const SizedBox(height: 12),
                    statusStrip,
                    const SizedBox(height: 12),
                    actions,
                  ],
                );
              },
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  healthDescription,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                if (bundle.availablePlatforms.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  PlatformDataCoverageStrip(bundle: bundle),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanTitleBlock extends StatelessWidget {
  const _ScanTitleBlock({required this.hasMarketData});

  final bool hasMarketData;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '市场数据采集',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hasMarketData
              ? '重新扫描更新榜单样本；清空后需重新采集才能生成推荐。'
              : '采集起点、番茄榜单数据，作为推荐分析基础。',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

/// Legacy wrapper — prefer [MarketDataOperationsPanel].
class ScanCommandPanel extends StatelessWidget {
  const ScanCommandPanel({
    required this.hasMarketData,
    required this.scanState,
    required this.runningTaskId,
    required this.onScanNow,
    required this.onClearScanData,
    required this.onAbandonTask,
    super.key,
  });

  final bool hasMarketData;
  final MarketScanState scanState;
  final String? runningTaskId;
  final Future<void> Function() onScanNow;
  final Future<void> Function() onClearScanData;
  final Future<void> Function(String taskId) onAbandonTask;

  @override
  Widget build(BuildContext context) {
    final commandsDisabled =
        scanState.isScanning || scanState.isClearing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 860;
        final statusStrip = ScanStatusStrip(
          hasMarketData: hasMarketData,
          scanState: scanState,
          runningTaskId: runningTaskId,
        );
        final actions = _ScanActions(
          commandsDisabled: commandsDisabled,
          scanState: scanState,
          runningTaskId: runningTaskId,
          onScanNow: onScanNow,
          onClearScanData: onClearScanData,
          onAbandonTask: onAbandonTask,
        );
        final copy = _ScanTitleBlock(hasMarketData: hasMarketData);

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: copy),
              const SizedBox(width: 32),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    statusStrip,
                    const SizedBox(height: 14),
                    actions,
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            copy,
            const SizedBox(height: 16),
            statusStrip,
            const SizedBox(height: 14),
            actions,
          ],
        );
      },
    );
  }
}

class _ScanActions extends StatelessWidget {
  const _ScanActions({
    required this.commandsDisabled,
    required this.scanState,
    required this.runningTaskId,
    required this.onScanNow,
    required this.onClearScanData,
    required this.onAbandonTask,
  });

  final bool commandsDisabled;
  final MarketScanState scanState;
  final String? runningTaskId;
  final Future<void> Function() onScanNow;
  final Future<void> Function() onClearScanData;
  final Future<void> Function(String taskId) onAbandonTask;

  @override
  Widget build(BuildContext context) {
    final scanButton = FilledButton.icon(
      onPressed: commandsDisabled ? null : onScanNow,
      icon: scanState.isScanning
          ? const ButtonSpinner()
          : const Icon(Icons.radar_outlined),
      label: Text(scanState.isScanning ? '扫描中...' : '扫描市场数据'),
    );
    final moreMenu = ScanCommandMoreMenu(
      commandsDisabled: commandsDisabled,
      scanState: scanState,
      runningTaskId: runningTaskId,
      onScanNow: onScanNow,
      onClearScanData: onClearScanData,
      onAbandonTask: onAbandonTask,
    );

    return Row(
      children: [
        Expanded(child: scanButton),
        const SizedBox(width: 8),
        moreMenu,
      ],
    );
  }
}

class PlatformDataCoverageStrip extends StatelessWidget {
  const PlatformDataCoverageStrip({required this.bundle, super.key});

  final ScanDataBundle bundle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final platform in bundle.availablePlatforms)
          PlatformDataCoverageChip(stats: bundle.statsForPlatform(platform)),
      ],
    );
  }
}

class PlatformDataCoverageChip extends StatelessWidget {
  const PlatformDataCoverageChip({required this.stats, super.key});

  final PlatformScanDataStats stats;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = platformColor(stats.platform, colorScheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              '${platformDisplayName(stats.platform.name)} ${stats.bookCount}本 / ${stats.rankingEntryCount}条',
              style: textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlatformProgressList extends StatelessWidget {
  const PlatformProgressList({required this.entries, super.key});

  final List<PlatformScanEntry> entries;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 700;
        if (!twoColumns) {
          return Column(
            children: [
              for (var i = 0; i < entries.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == entries.length - 1 ? 0 : 10,
                  ),
                  child: PlatformProgressRow(entry: entries[i]),
                ),
            ],
          );
        }
        return Wrap(
          spacing: 18,
          runSpacing: 10,
          children: [
            for (final entry in entries)
              SizedBox(
                width: (constraints.maxWidth - 18) / 2,
                child: PlatformProgressRow(entry: entry),
              ),
          ],
        );
      },
    );
  }
}

class PlatformProgressRow extends StatelessWidget {
  const PlatformProgressRow({required this.entry, super.key});

  final PlatformScanEntry entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (icon, iconColor, trailing) = switch (entry.status) {
      PlatformScanStatus.pending => (
        Icons.hourglass_empty_outlined,
        colorScheme.onSurfaceVariant,
        Text(
          '等待中',
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      PlatformScanStatus.scanning => (
        Icons.sync_outlined,
        colorScheme.primary,
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      PlatformScanStatus.completed => (
        Icons.check_circle_outline,
        const Color(0xFF2E7D32),
        Text(
          entry.itemCount > 0 ? '${entry.itemCount} 条' : '无新数据',
          style: textTheme.labelMedium?.copyWith(
            color: const Color(0xFF2E7D32),
          ),
        ),
      ),
      PlatformScanStatus.failed => (
        Icons.error_outline,
        colorScheme.error,
        Text(
          '失败',
          style: textTheme.labelMedium?.copyWith(color: colorScheme.error),
        ),
      ),
      PlatformScanStatus.abandoned => (
        Icons.cancel_outlined,
        colorScheme.onSurfaceVariant,
        Text(
          '已放弃',
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      PlatformScanStatus.cdpRequired => (
        Icons.open_in_browser_outlined,
        colorScheme.tertiary,
        Text(
          '需要 Chrome',
          style: textTheme.labelMedium?.copyWith(color: colorScheme.tertiary),
        ),
      ),
    };

    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 10),
        Expanded(child: Text(entry.displayName, style: textTheme.bodyLarge)),
        trailing,
      ],
    );
  }
}
