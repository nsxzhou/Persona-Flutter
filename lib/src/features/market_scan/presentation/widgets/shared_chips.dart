import 'package:flutter/material.dart';

import '../../../../core/ui/persona_page.dart';
import '../../application/market_scan_controller.dart';

class CommandStateChip extends StatelessWidget {
  const CommandStateChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.compact = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 5)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 7);
    final radius = compact ? 6.0 : 8.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: compact ? 13 : 15, color: color),
            const SizedBox(width: 5),
            Text(
              '$label · ',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 11 : null,
              ),
            ),
            Text(
              value,
              style: textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: compact ? 11 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ButtonSpinner extends StatelessWidget {
  const ButtonSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

enum ScanMenuAction { scan, clear, abandon }

class ScanCommandMoreMenu extends StatelessWidget {
  const ScanCommandMoreMenu({
    required this.commandsDisabled,
    required this.scanState,
    required this.runningTaskId,
    required this.onScanNow,
    required this.onClearScanData,
    required this.onAbandonTask,
    super.key,
  });

  final bool commandsDisabled;
  final MarketScanState scanState;
  final String? runningTaskId;
  final Future<void> Function() onScanNow;
  final Future<void> Function() onClearScanData;
  final Future<void> Function(String taskId) onAbandonTask;

  @override
  Widget build(BuildContext context) {
    final hasEnabledAction = !commandsDisabled || runningTaskId != null;

    return Tooltip(
      message: '更多操作',
      child: PopupMenuButton<ScanMenuAction>(
        enabled: hasEnabledAction,
        icon: const Icon(Icons.more_horiz),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: ScanMenuAction.scan,
            enabled: !commandsDisabled,
            child: Row(
              children: [
                Icon(
                  scanState.isScanning
                      ? Icons.sync_outlined
                      : Icons.radar_outlined,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(scanState.isScanning ? '扫描中...' : '重新扫描'),
              ],
            ),
          ),
          PopupMenuItem(
            value: ScanMenuAction.clear,
            enabled: !commandsDisabled,
            child: const Row(
              children: [
                Icon(Icons.delete_outline, size: 18),
                SizedBox(width: 10),
                Text('清空数据'),
              ],
            ),
          ),
          if (runningTaskId != null)
            const PopupMenuItem(
              value: ScanMenuAction.abandon,
              child: Row(
                children: [
                  Icon(Icons.stop_circle_outlined, size: 18),
                  SizedBox(width: 10),
                  Text('放弃任务'),
                ],
              ),
            ),
        ],
        onSelected: (action) {
          switch (action) {
            case ScanMenuAction.scan:
              onScanNow();
              return;
            case ScanMenuAction.clear:
              onClearScanData();
              return;
            case ScanMenuAction.abandon:
              final taskId = runningTaskId;
              if (taskId != null) {
                onAbandonTask(taskId);
              }
              return;
          }
        },
      ),
    );
  }
}

class WorkflowNotice extends StatelessWidget {
  const WorkflowNotice({
    required this.icon,
    required this.title,
    required this.message,
    this.isError = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = isError ? colorScheme.error : colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MarketDataLoadingPanel extends StatelessWidget {
  const MarketDataLoadingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 14),
          Text('正在检查市场数据...'),
        ],
      ),
    );
  }
}

class MarketDataErrorPanel extends StatelessWidget {
  const MarketDataErrorPanel({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Text(
      '无法加载市场数据状态：$error',
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    );
  }
}

class MarketDataMissingPanel extends StatelessWidget {
  const MarketDataMissingPanel({
    required this.onScanNow,
    this.subtitle,
    super.key,
  });

  final Future<void> Function() onScanNow;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '尚无市场扫描数据',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle ??
                  'AI 推荐需要市场扫描数据作为基础。先采集起点、番茄平台的榜单数据。',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onScanNow,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('立即扫描市场数据'),
            ),
          ],
        ),
      ),
    );
  }
}

class ScanStatusStrip extends StatelessWidget {
  const ScanStatusStrip({
    required this.hasMarketData,
    required this.scanState,
    required this.runningTaskId,
    this.compact = false,
    super.key,
  });

  final bool hasMarketData;
  final MarketScanState scanState;
  final String? runningTaskId;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRunning = scanState.isScanning;
    final taskLabel = isRunning
        ? '运行中'
        : scanState.isClearing
        ? '清空中'
        : '空闲';

    final chips = [
      CommandStateChip(
        icon: Icons.dataset_outlined,
        label: '市场数据',
        value: hasMarketData ? '可用' : '待扫描',
        color: hasMarketData
            ? const Color(0xFF16825D)
            : colorScheme.onSurfaceVariant,
        compact: compact,
      ),
      CommandStateChip(
        icon: Icons.radar_outlined,
        label: '扫描',
        value: scanState.isScanning
            ? '${scanState.completedCount}/${scanState.platforms.length} 完成'
            : '未运行',
        color: scanState.isScanning
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant,
        compact: compact,
      ),
      _CompactTaskPill(
        label: taskLabel,
        icon: isRunning ? Icons.sync : Icons.task_alt_outlined,
        active: isRunning,
      ),
    ];

    return Wrap(
      spacing: compact ? 6 : 8,
      runSpacing: compact ? 6 : 8,
      alignment: WrapAlignment.end,
      children: chips,
    );
  }
}

class _CompactTaskPill extends StatelessWidget {
  const _CompactTaskPill({
    required this.label,
    required this.icon,
    required this.active,
  });

  final String label;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = active ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
              style: textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
