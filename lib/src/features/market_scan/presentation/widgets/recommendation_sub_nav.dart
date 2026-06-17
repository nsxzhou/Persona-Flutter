import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum RecommendationSection {
  marketData(
    segment: 'market-data',
    label: '市场数据',
    basePath: '/projects/recommend/market-data',
  ),
  rankings(
    segment: 'rankings',
    label: '榜单',
    basePath: '/projects/recommend/rankings',
  ),
  recommendations(
    segment: 'recommendations',
    label: '创作推荐',
    basePath: '/projects/recommend/recommendations',
  );

  const RecommendationSection({
    required this.segment,
    required this.label,
    required this.basePath,
  });

  final String segment;
  final String label;
  final String basePath;

  static RecommendationSection? fromPath(String path) {
    for (final section in values) {
      if (path.startsWith(section.basePath)) {
        return section;
      }
    }
    return null;
  }
}

class RecommendationSubNav extends StatelessWidget {
  const RecommendationSubNav({
    required this.hasMarketData,
    required this.hasRecommendations,
    required this.isGenerating,
    required this.onSectionSelected,
    super.key,
  });

  final bool hasMarketData;
  final bool hasRecommendations;
  final bool isGenerating;
  final ValueChanged<RecommendationSection> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentPath = GoRouterState.of(context).uri.path;
    final active = RecommendationSection.fromPath(currentPath) ??
        RecommendationSection.marketData;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < RecommendationSection.values.length; i++) ...[
            if (i > 0) const SizedBox(width: 28),
            _SubNavItem(
              label: RecommendationSection.values[i].label,
              selected: active == RecommendationSection.values[i],
              statusColor: _statusColor(
                RecommendationSection.values[i],
                colorScheme,
              ),
              onTap: () => onSectionSelected(RecommendationSection.values[i]),
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
          ],
        ],
      ),
    );
  }

  Color? _statusColor(RecommendationSection section, ColorScheme colorScheme) {
    return switch (section) {
      RecommendationSection.marketData =>
        hasMarketData ? const Color(0xFF16825D) : colorScheme.onSurfaceVariant,
      RecommendationSection.rankings =>
        hasMarketData ? const Color(0xFF16825D) : null,
      RecommendationSection.recommendations => isGenerating
          ? colorScheme.primary
          : hasRecommendations
          ? const Color(0xFF16825D)
          : null,
    };
  }
}

class _SubNavItem extends StatelessWidget {
  const _SubNavItem({
    required this.label,
    required this.selected,
    required this.statusColor,
    required this.onTap,
    required this.textTheme,
    required this.colorScheme,
  });

  final String label;
  final bool selected;
  final Color? statusColor;
  final VoidCallback onTap;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 8, 2, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    color: selected
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                    letterSpacing: selected ? -0.2 : 0,
                  ),
                ),
                if (statusColor != null) ...[
                  const SizedBox(width: 7),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Container(
              height: 2,
              width: selected ? 28 : 0,
              decoration: BoxDecoration(
                color: selected ? colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
