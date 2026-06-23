import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/persona_page.dart';
import '../../../../core/ui/skeleton_loader.dart';
import '../../application/market_recommendation_controller.dart';
import '../../domain/market_book.dart';
import '../../domain/recommendation_direction.dart';
import 'market_scan_formatters.dart';

class DirectionComparisonSection extends StatefulWidget {
  const DirectionComparisonSection({
    required this.recommendationState,
    super.key,
  });

  final MarketRecommendationState recommendationState;

  @override
  State<DirectionComparisonSection> createState() =>
      _DirectionComparisonSectionState();
}

class _DirectionComparisonSectionState extends State<DirectionComparisonSection>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  TabController? _platformTabController;
  MarketPlatform? _selectedPlatform;

  MarketRecommendationState get recommendationState =>
      widget.recommendationState;

  @override
  void dispose() {
    _platformTabController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DirectionComparisonSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPlatformTabs();
    final directions = _currentDirections();
    if (directions.isEmpty) {
      _selectedIndex = 0;
      return;
    }
    if (_selectedIndex >= directions.length) {
      _selectedIndex = directions.length - 1;
    }
  }

  @override
  void initState() {
    super.initState();
    _syncPlatformTabs();
  }

  void _syncPlatformTabs() {
    final platforms = recommendationState.directionsByPlatform.keys.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    if (platforms.length <= 1) {
      _platformTabController?.dispose();
      _platformTabController = null;
      _selectedPlatform = platforms.isEmpty ? null : platforms.first;
      return;
    }
    final currentIndex = _selectedPlatform == null
        ? 0
        : platforms.indexOf(_selectedPlatform!);
    final safeIndex = currentIndex >= 0 ? currentIndex : 0;
    if (_platformTabController == null ||
        _platformTabController!.length != platforms.length) {
      _platformTabController?.dispose();
      _platformTabController = TabController(
        length: platforms.length,
        vsync: this,
        initialIndex: safeIndex,
      );
      _platformTabController!.addListener(() {
        if (_platformTabController!.indexIsChanging) {
          return;
        }
        setState(() {
          _selectedPlatform = platforms[_platformTabController!.index];
          _selectedIndex = 0;
        });
      });
    }
    _selectedPlatform = platforms[safeIndex];
  }

  List<RecommendationDirection> _currentDirections() {
    final byPlatform = recommendationState.directionsByPlatform;
    if (byPlatform.isEmpty) {
      return const [];
    }
    if (byPlatform.length == 1) {
      return byPlatform.values.first;
    }
    final platform = _selectedPlatform ?? byPlatform.keys.first;
    return byPlatform[platform] ?? const [];
  }

  @override
  Widget build(BuildContext context) {
    if (recommendationState.isGenerating &&
        recommendationState.directionsByPlatform.isEmpty) {
      return const RecommendationLoadingGrid();
    }
    if (recommendationState.errorMessage != null &&
        recommendationState.directionsByPlatform.isEmpty) {
      return RecommendationErrorPanel(error: recommendationState.errorMessage!);
    }
    if (recommendationState.directionsByPlatform.isEmpty) {
      return const RecommendationEmptyPanel();
    }

    final platforms = recommendationState.directionsByPlatform.keys.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final directions = _currentDirections();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (platforms.length > 1 && _platformTabController != null) ...[
          TabBar(
            controller: _platformTabController,
            isScrollable: true,
            tabs: [
              for (final platform in platforms)
                Tab(text: platformDisplayName(platform.name)),
            ],
          ),
          const SizedBox(height: 20),
        ],
        if (recommendationState.isGenerating &&
            recommendationState.currentGeneratingPlatform != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '正在生成 ${platformDisplayName(recommendationState.currentGeneratingPlatform!.name)} 方案…',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (recommendationState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RecommendationErrorPanel(
              error: recommendationState.errorMessage!,
            ),
          ),
        DirectionComparisonWorkspace(
          directions: directions,
          selectedIndex: _selectedIndex,
          onSelected: (index) => setState(() => _selectedIndex = index),
        ),
      ],
    );
  }
}

class DirectionComparisonWorkspace extends StatelessWidget {
  const DirectionComparisonWorkspace({
    required this.directions,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<RecommendationDirection> directions;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected =
        directions[selectedIndex.clamp(0, directions.length - 1).toInt()];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1080
                ? 3
                : constraints.maxWidth >= 720
                ? 2
                : 1;
            final spacing = columns == 1 ? 0.0 : 16.0;
            final itemWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: 16,
              children: [
                for (var i = 0; i < directions.length; i++)
                  SizedBox(
                    width: itemWidth,
                    child: DirectionComparisonCard(
                      direction: directions[i],
                      index: i,
                      selected: i == selectedIndex,
                      onTap: () => onSelected(i),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        DirectionDetailPanel(direction: selected),
      ],
    );
  }
}

class DirectionComparisonCard extends StatelessWidget {
  const DirectionComparisonCard({
    required this.direction,
    required this.index,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final RecommendationDirection direction;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final heatClr = heatColor(direction.marketHeatSummary);
    final compClr = competitionColor(direction.competitionSummary, colorScheme);
    final feasibilityClr = feasibilityColor(
      direction.feasibility,
      colorScheme,
    );

    return Material(
      color: Colors.transparent,
      elevation: selected ? 1 : 0,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
      child: InkWell(
        key: ValueKey('market-direction-compare-${direction.suggestedTitle}'),
        onTap: onTap,
        child: Stack(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '方向 ${index + 1}',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      direction.suggestedTitle,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    GenreTagRow(tags: direction.genreTags),
                    const SizedBox(height: 16),
                    DecisionMeterList(
                      heatLabel: heatLabel(direction.marketHeatSummary),
                      heatColor: heatClr,
                      heatScore: heatScore(direction.marketHeatSummary),
                      competitionLabel: competitionLabel(
                        direction.competitionSummary,
                      ),
                      competitionColor: compClr,
                      competitionScore: competitionScore(
                        direction.competitionSummary,
                      ),
                      feasibilityLabel: direction.feasibility,
                      feasibilityColor: feasibilityClr,
                      feasibilityScore: feasibilityScore(
                        direction.feasibility,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RiskPreview(
                      failureRisk: direction.failureRisk,
                      serialRisk: direction.serialRisk,
                    ),
                  ],
                ),
              ),
            ),
            if (selected)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 3, color: colorScheme.primary),
              ),
          ],
        ),
      ),
    );
  }
}

class DirectionDetailPanel extends StatefulWidget {
  const DirectionDetailPanel({required this.direction, super.key});

  final RecommendationDirection direction;

  @override
  State<DirectionDetailPanel> createState() => _DirectionDetailPanelState();
}

class _DirectionDetailPanelState extends State<DirectionDetailPanel> {
  late String _selectedTitle;

  RecommendationDirection get direction => widget.direction;

  @override
  void initState() {
    super.initState();
    _selectedTitle = direction.suggestedTitle;
  }

  @override
  void didUpdateWidget(DirectionDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.direction != widget.direction) {
      _selectedTitle = direction.suggestedTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    RecommendationTitleCandidate? selectedCandidate;
    for (final candidate in direction.titleCandidates) {
      if (candidate.title == _selectedTitle) {
        selectedCandidate = candidate;
        break;
      }
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final useStack = constraints.maxWidth < 620;
                final titleBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedTitle,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      direction.coreSellingPoint,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
                final useButton = FilledButton.icon(
                  key: const ValueKey('market-direction-use-action'),
                  onPressed: () {
                    final uri = Uri(
                      path: '/projects/create',
                      queryParameters: {
                        'title': _selectedTitle,
                        'synopsis': projectSynopsisForDirection(direction),
                        if (direction.genreTags.isNotEmpty)
                          'tags': direction.genreTags.join(','),
                        if (direction.targetWordCount > 0)
                          'wordCount': direction.targetWordCount.toString(),
                      },
                    );
                    context.go(uri.toString());
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('使用此方向'),
                );
                if (useStack) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      titleBlock,
                      const SizedBox(height: 16),
                      useButton,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: titleBlock),
                    const SizedBox(width: 16),
                    useButton,
                  ],
                );
              },
            ),
            if (direction.titleCandidates.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                '标题候选',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final candidate in direction.titleCandidates)
                    ChoiceChip(
                      label: Text(candidate.title),
                      selected: candidate.title == _selectedTitle,
                      onSelected: (_) =>
                          setState(() => _selectedTitle = candidate.title),
                    ),
                ],
              ),
            ],
            if (selectedCandidate != null) ...[
              const SizedBox(height: 8),
              Text(
                '${selectedCandidate.formula} · ${selectedCandidate.rationale}',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumns = constraints.maxWidth >= 840;
                final openBook = OpenBookPlanBlock(direction: direction);
                final insight = DirectionInsightGrid(direction: direction);
                if (!twoColumns) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [openBook, const SizedBox(height: 20), insight],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: openBook),
                    const SizedBox(width: 24),
                    Expanded(child: insight),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DirectionInsightGrid extends StatelessWidget {
  const DirectionInsightGrid({required this.direction, super.key});

  final RecommendationDirection direction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '市场验证',
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 12),
        InsightTextBlock(label: '简介', value: direction.synopsis),
        const SizedBox(height: 12),
        InsightTextBlock(label: '目标读者', value: direction.targetAudience),
        const SizedBox(height: 12),
        InsightTextBlock(label: '市场验证', value: direction.marketValidation),
        const SizedBox(height: 12),
        InsightTextBlock(label: '差异化定位', value: direction.differentiation),
        const SizedBox(height: 12),
        InsightTextBlock(label: '失败风险', value: direction.failureRisk),
        const SizedBox(height: 12),
        InsightTextBlock(label: '连载风险', value: direction.serialRisk),
        const SizedBox(height: 12),
        InsightTextBlock(label: '验证动作', value: direction.validationAction),
      ],
    );
  }
}

class RecommendationEmptyPanel extends StatelessWidget {
  const RecommendationEmptyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '尚未生成推荐',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '在上方配置目标平台与参考榜单，进入下一步后点击「生成推荐」。AI 将基于你选定的榜单数据分析创作方向。',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendationErrorPanel extends StatelessWidget {
  const RecommendationErrorPanel({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 10),
              Text(
                '生成推荐失败',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendationLoadingGrid extends StatelessWidget {
  const RecommendationLoadingGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1020
            ? 3
            : constraints.maxWidth >= 680
            ? 2
            : 1;
        final spacing = columns == 1 ? 0.0 : 16.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: 16,
          children: [
            for (var i = 0; i < 6; i++)
              SizedBox(width: itemWidth, child: const _SkeletonCard()),
          ],
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: double.infinity, height: 22),
            SizedBox(height: 10),
            SkeletonBox(width: 180, height: 14),
            SizedBox(height: 16),
            SkeletonBox(width: double.infinity, height: 12),
            SizedBox(height: 8),
            SkeletonBox(width: 400, height: 12),
          ],
        ),
      ),
    );
  }
}

class DecisionMeterList extends StatelessWidget {
  const DecisionMeterList({
    required this.heatLabel,
    required this.heatColor,
    required this.heatScore,
    required this.competitionLabel,
    required this.competitionColor,
    required this.competitionScore,
    required this.feasibilityLabel,
    required this.feasibilityColor,
    required this.feasibilityScore,
    super.key,
  });

  final String heatLabel;
  final Color heatColor;
  final double heatScore;
  final String competitionLabel;
  final Color competitionColor;
  final double competitionScore;
  final String feasibilityLabel;
  final Color feasibilityColor;
  final double feasibilityScore;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecisionMeter(
          label: '市场',
          value: heatLabel,
          color: heatColor,
          score: heatScore,
        ),
        const SizedBox(height: 8),
        DecisionMeter(
          label: '竞争',
          value: competitionLabel,
          color: competitionColor,
          score: competitionScore,
        ),
        const SizedBox(height: 8),
        DecisionMeter(
          label: '可行',
          value: feasibilityLabel,
          color: feasibilityColor,
          score: feasibilityScore,
        ),
      ],
    );
  }
}

class DecisionMeter extends StatelessWidget {
  const DecisionMeter({
    required this.label,
    required this.value,
    required this.color,
    required this.score,
    super.key,
  });

  final String label;
  final String value;
  final Color color;
  final double score;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final clampedScore = score.clamp(0.08, 1.0).toDouble();

    return Row(
      children: [
        SizedBox(
          width: 42,
          child: Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 4,
              child: ColoredBox(
                color: colorScheme.surfaceContainerHighest,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: clampedScore,
                  child: ColoredBox(color: color),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 58,
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class RiskPreview extends StatelessWidget {
  const RiskPreview({
    required this.failureRisk,
    required this.serialRisk,
    super.key,
  });

  final String failureRisk;
  final String serialRisk;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Text(
      failureRisk.isEmpty ? serialRisk : failureRisk,
      style: textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        height: 1.4,
        fontStyle: FontStyle.italic,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class DirectionRolePill extends StatelessWidget {
  const DirectionRolePill({required this.role, super.key});

  final String role;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Text(
          role,
          style: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class OpenBookPlanBlock extends StatelessWidget {
  const OpenBookPlanBlock({required this.direction, super.key});

  final RecommendationDirection direction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '开书方案',
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 12),
        InsightTextBlock(label: '主角', value: direction.protagonist),
        const SizedBox(height: 12),
        InsightTextBlock(label: '核心机制', value: direction.coreMechanism),
        const SizedBox(height: 12),
        InsightTextBlock(
          label: '前三章钩子',
          value: direction.firstThreeChaptersHook,
        ),
        const SizedBox(height: 12),
        InsightTextBlock(label: '主冲突', value: direction.mainConflict),
        const SizedBox(height: 12),
        InsightTextBlock(label: '第一个爽点', value: direction.firstPayoff),
      ],
    );
  }
}

class InsightTextBlock extends StatelessWidget {
  const InsightTextBlock({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class GenreTagRow extends StatelessWidget {
  const GenreTagRow({required this.tags, super.key});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final visible = tags.take(3).toList();
    final remaining = tags.length - visible.length;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final tag in visible)
          Text(
            tag,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (remaining > 0)
          Text(
            '+$remaining',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
