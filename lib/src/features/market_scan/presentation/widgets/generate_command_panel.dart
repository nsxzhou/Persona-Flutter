import 'package:flutter/material.dart';

import '../../application/market_recommendation_controller.dart';
import '../../domain/market_book.dart';
import 'shared_chips.dart';

class GenerateCommandPanel extends StatelessWidget {
  const GenerateCommandPanel({
    required this.hasMarketData,
    required this.recommendationState,
    required this.targetPlatformCount,
    required this.referenceChartCount,
    required this.genreOptions,
    required this.genreQueryController,
    required this.commandsDisabled,
    required this.onBackToConfig,
    required this.onGenerate,
    super.key,
  });

  final bool hasMarketData;
  final MarketRecommendationState recommendationState;
  final int targetPlatformCount;
  final int referenceChartCount;
  final List<String> genreOptions;
  final TextEditingController genreQueryController;
  final bool commandsDisabled;
  final VoidCallback onBackToConfig;
  final Future<void> Function() onGenerate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canGenerate = hasMarketData && !commandsDisabled;
    final recommendationLabel = _statusLabel(recommendationState);
    final configSummary =
        '$targetPlatformCount 个目标平台 · $referenceChartCount 个参考榜单';

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 860;
        final genreField = TextField(
          controller: genreQueryController,
          enabled: !commandsDisabled,
          decoration: const InputDecoration(
            labelText: '题材方向（可选）',
            hintText: '例如：悬疑、无限流、古言',
            border: OutlineInputBorder(),
          ),
        );
        final genreChips = genreOptions.isEmpty
            ? null
            : Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final genre in genreOptions)
                    ActionChip(
                      label: Text(genre),
                      onPressed: commandsDisabled
                          ? null
                          : () => genreQueryController.text = genre,
                    ),
                ],
              );
        final generateButton = FilledButton.icon(
          onPressed: canGenerate ? onGenerate : null,
          icon: recommendationState.isGenerating
              ? const ButtonSpinner()
              : const Icon(Icons.auto_awesome),
          label: Text(
            recommendationState.isGenerating ? '生成中...' : '生成推荐',
          ),
        );
        final statusChip = CommandStateChip(
          icon: Icons.auto_awesome_outlined,
          label: '推荐',
          value: recommendationLabel,
          color: recommendationState.isGenerating
              ? colorScheme.primary
              : recommendationState.hasDirections
              ? const Color(0xFF16825D)
              : colorScheme.onSurfaceVariant,
        );
        final configBar = DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.tune,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    configSummary,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  key: const ValueKey('generate-back-to-config'),
                  onPressed: commandsDisabled ? null : onBackToConfig,
                  child: const Text('返回修改'),
                ),
              ],
            ),
          ),
        );

        if (wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '生成创作方向',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '基于选定的参考榜单，AI 将为每个目标平台生成三个可对照的创作方向。',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  statusChip,
                ],
              ),
              const SizedBox(height: 16),
              configBar,
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        genreField,
                        if (genreChips != null) ...[
                          const SizedBox(height: 8),
                          genreChips,
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(width: 160, child: generateButton),
                ],
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '生成创作方向',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '基于选定的参考榜单，AI 将为每个目标平台生成三个可对照的创作方向。',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            statusChip,
            const SizedBox(height: 16),
            configBar,
            const SizedBox(height: 16),
            genreField,
            if (genreChips != null) ...[
              const SizedBox(height: 8),
              genreChips,
            ],
            const SizedBox(height: 16),
            generateButton,
          ],
        );
      },
    );
  }

  String _statusLabel(MarketRecommendationState state) {
    if (state.isGenerating) {
      if (state.totalPlatformCount > 1 &&
          state.currentGeneratingPlatform != null) {
        final platform = state.currentGeneratingPlatform!;
        final label = switch (platform) {
          MarketPlatform.qidian => '起点',
          MarketPlatform.fanqie => '番茄',
        };
        return '生成中 ($label ${state.completedPlatformCount + 1}/${state.totalPlatformCount})';
      }
      return '生成中';
    }
    if (state.hasDirections) {
      final count = state.directionsByPlatform.values.fold<int>(
        0,
        (sum, items) => sum + items.length,
      );
      return '$count 个方向';
    }
    return '待生成';
  }
}
