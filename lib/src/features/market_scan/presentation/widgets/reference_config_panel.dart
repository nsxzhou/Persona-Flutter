import 'package:flutter/material.dart';

import '../../domain/market_book.dart';
import 'market_scan_formatters.dart';

class ReferenceConfigPanel extends StatelessWidget {
  const ReferenceConfigPanel({
    required this.availablePlatforms,
    required this.availableChartKeys,
    required this.selectedPlatforms,
    required this.selectedChartKeys,
    required this.commandsDisabled,
    required this.onPlatformToggled,
    required this.onChartKeyToggled,
    required this.onProceed,
    super.key,
  });

  final List<MarketPlatform> availablePlatforms;
  final List<String> availableChartKeys;
  final Set<MarketPlatform> selectedPlatforms;
  final Set<String> selectedChartKeys;
  final bool commandsDisabled;
  final ValueChanged<MarketPlatform> onPlatformToggled;
  final ValueChanged<String> onChartKeyToggled;
  final VoidCallback onProceed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canProceed =
        selectedPlatforms.isNotEmpty &&
        selectedChartKeys.isNotEmpty &&
        !commandsDisabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '配置参考数据',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '选择创作目标平台与参考榜单。AI 将仅基于你选中的榜单生成方案。',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '目标平台',
          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final platform in availablePlatforms)
              FilterChip(
                key: ValueKey('target-platform-${platform.name}'),
                label: Text(platformDisplayName(platform.name)),
                selected: selectedPlatforms.contains(platform),
                onSelected: commandsDisabled
                    ? null
                    : (_) => onPlatformToggled(platform),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          '参考榜单',
          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          selectedChartKeys.isEmpty
              ? '请至少选择一个参考榜单'
              : '已选 ${selectedChartKeys.length} 个榜单',
          style: textTheme.bodySmall?.copyWith(
            color: selectedChartKeys.isEmpty
                ? colorScheme.error
                : colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        if (availableChartKeys.isEmpty)
          Text(
            '暂无可用榜单，请先完成市场数据扫描。',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final chartKey in availableChartKeys)
                FilterChip(
                  key: ValueKey('reference-chart-$chartKey'),
                  label: Text(chartKeyLabel(chartKey)),
                  selected: selectedChartKeys.contains(chartKey),
                  onSelected: commandsDisabled
                      ? null
                      : (_) => onChartKeyToggled(chartKey),
                ),
            ],
          ),
        const SizedBox(height: 28),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            key: const ValueKey('reference-config-next'),
            onPressed: canProceed ? onProceed : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('下一步'),
          ),
        ),
      ],
    );
  }
}
