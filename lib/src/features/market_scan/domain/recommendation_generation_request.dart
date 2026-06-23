import 'market_book.dart';

/// 创作方向推荐生成请求。
///
/// 一次推荐生成可覆盖多个目标平台与多个参考榜单。实际执行时由
/// [MarketRecommendationController] 逐平台拆分：通过 [forSinglePlatform]
/// 派生出仅含单个平台的请求，交给 [RecommendationGenerationService]
/// 逐个平台生成方向。
class RecommendationGenerationRequest {
  const RecommendationGenerationRequest({
    required this.targetPlatforms,
    this.selectedChartKeys = const [],
    this.selectedGenres = const [],
  });

  /// 本次生成覆盖的目标平台列表（至少一个）。
  final List<MarketPlatform> targetPlatforms;

  /// 用户在配置向导中选定的参考榜单 key 列表。
  final List<String> selectedChartKeys;

  /// 用户在题材 FilterChip 中选中的题材列表（可为空，表示不限制题材）。
  final List<String> selectedGenres;

  /// 平台与榜单均已选择，满足生成前置条件。
  bool get isValid =>
      targetPlatforms.isNotEmpty && selectedChartKeys.isNotEmpty;

  /// 单平台视图：服务层逐平台执行时使用。
  ///
  /// 调用方应先通过 [forSinglePlatform] 派生单平台请求；该 getter 取
  /// [targetPlatforms] 的首个元素，仅在请求已确保非空时使用。
  MarketPlatform get targetPlatform => targetPlatforms.first;

  /// 选中的题材以顿号拼接，供 prompt 展示；空列表返回 null。
  String? get normalizedGenreQuery {
    if (selectedGenres.isEmpty) {
      return null;
    }
    return selectedGenres.join('、');
  }

  /// 派生一个仅针对 [platform] 的单平台请求，保留原榜单与筛选条件。
  RecommendationGenerationRequest forSinglePlatform(MarketPlatform platform) {
    return RecommendationGenerationRequest(
      targetPlatforms: [platform],
      selectedChartKeys: selectedChartKeys,
      selectedGenres: selectedGenres,
    );
  }
}
