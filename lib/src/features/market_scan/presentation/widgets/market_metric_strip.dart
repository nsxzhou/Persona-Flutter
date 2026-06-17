import 'package:flutter/material.dart';

import '../../application/market_scan_providers.dart';

class MarketMetricStrip extends StatelessWidget {
  const MarketMetricStrip({required this.bundle, super.key});

  final ScanDataBundle bundle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final metrics = [
      _MetricData('覆盖平台', '${bundle.availablePlatforms.length}', '数据源'),
      _MetricData('书籍样本', '${bundle.totalBookCount}', '去重样本书'),
      _MetricData('榜单条目', '${bundle.totalRankingEntryCount}', '抓取记录'),
      _MetricData('榜单数量', '${bundle.chartCount}', '可浏览'),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          if (compact) {
            return Column(
              children: [
                for (var i = 0; i < metrics.length; i++)
                  _MetricCell(
                    data: metrics[i],
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                    showDivider: i < metrics.length - 1,
                    compact: true,
                  ),
              ],
            );
          }

          return IntrinsicHeight(
            child: Row(
              children: [
                for (var i = 0; i < metrics.length; i++)
                  Expanded(
                    child: _MetricCell(
                      data: metrics[i],
                      textTheme: textTheme,
                      colorScheme: colorScheme,
                      showDivider: i < metrics.length - 1,
                      compact: false,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetricData {
  const _MetricData(this.label, this.value, this.detail);

  final String label;
  final String value;
  final String detail;
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.data,
    required this.textTheme,
    required this.colorScheme,
    required this.showDivider,
    required this.compact,
  });

  final _MetricData data;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final bool showDivider;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.symmetric(
        vertical: compact ? 16 : 22,
        horizontal: compact ? 4 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.detail,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    if (compact) {
      return Column(
        children: [
          content,
          if (showDivider)
            Divider(height: 1, color: colorScheme.outlineVariant),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: content),
        if (showDivider)
          VerticalDivider(width: 1, color: colorScheme.outlineVariant),
      ],
    );
  }
}
