import 'package:flutter/material.dart';

import '../../domain/market_book.dart';
import '../../domain/chart_key.dart';
import '../../domain/market_scan_run.dart';
import '../../domain/recommendation_direction.dart';

String chartKeyLabel(String key) {
  final platform = parseChartKeyPlatform(key);
  final chartName = parseChartKeyName(key);
  if (platform == null) {
    return chartName;
  }
  return '${platformDisplayName(platform.name)} · $chartName';
}

String platformDisplayName(String platform) {
  return switch (platform) {
    'qidian' => '起点中文网',
    'fanqie' => '番茄小说',
    _ => platform,
  };
}

Color platformColor(MarketPlatform platform, ColorScheme colorScheme) {
  return switch (platform) {
    MarketPlatform.qidian => const Color(0xFF2758D9),
    MarketPlatform.fanqie => const Color(0xFFE64A19),
  };
}

String projectSynopsisForDirection(RecommendationDirection direction) {
  final buffer = StringBuffer()
    ..writeln(direction.synopsis.trim())
    ..writeln()
    ..writeln('## 开书方案')
    ..writeln('- 方向角色：${direction.directionRole}')
    ..writeln('- 主角：${direction.protagonist}')
    ..writeln('- 核心机制：${direction.coreMechanism}')
    ..writeln('- 前三章钩子：${direction.firstThreeChaptersHook}')
    ..writeln('- 主冲突：${direction.mainConflict}')
    ..writeln('- 第一个爽点：${direction.firstPayoff}')
    ..writeln()
    ..writeln('## 市场定位')
    ..writeln('- 目标平台：${platformDisplayName(direction.targetPlatform.name)}')
    ..writeln('- 目标读者：${direction.targetAudience}')
    ..writeln('- 核心卖点：${direction.coreSellingPoint}')
    ..writeln('- 市场验证：${direction.marketValidation}')
    ..writeln('- 差异化：${direction.differentiation}')
    ..writeln()
    ..writeln('## 风险与验证')
    ..writeln('- 失败风险：${direction.failureRisk}')
    ..writeln('- 连载风险：${direction.serialRisk}')
    ..writeln('- 验证动作：${direction.validationAction}');
  return buffer.toString().trim();
}

IconData scanRunStatusIcon(MarketScanRunStatus status) {
  return switch (status) {
    MarketScanRunStatus.running => Icons.sync_outlined,
    MarketScanRunStatus.completed => Icons.check_circle_outline,
    MarketScanRunStatus.failed => Icons.error_outline,
  };
}

Color scanRunStatusColor(MarketScanRunStatus status, ColorScheme colorScheme) {
  return switch (status) {
    MarketScanRunStatus.running => colorScheme.primary,
    MarketScanRunStatus.completed => const Color(0xFF2E7D32),
    MarketScanRunStatus.failed => colorScheme.error,
  };
}

String scanRunStatusLabel(MarketScanRunStatus status) {
  return switch (status) {
    MarketScanRunStatus.running => '运行中',
    MarketScanRunStatus.completed => '已完成',
    MarketScanRunStatus.failed => '失败',
  };
}

String formatRadarTime(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$month-$day $hour:$minute';
}

List<String> genreOptionsForPlatform(
  List<MarketBook> books,
  MarketPlatform? platform,
) {
  if (platform == null) {
    return const [];
  }
  final counts = <String, int>{};
  for (final book in books.where((book) => book.platform == platform)) {
    for (final tag in [...book.categories, ...book.tags]) {
      final normalized = tag.trim();
      if (normalized.isEmpty) {
        continue;
      }
      counts[normalized] = (counts[normalized] ?? 0) + 1;
    }
  }
  final entries = counts.entries.toList()
    ..sort((a, b) {
      final count = b.value.compareTo(a.value);
      return count == 0 ? a.key.compareTo(b.key) : count;
    });
  return entries.map((entry) => entry.key).take(8).toList(growable: false);
}

Color heatColor(String summary) {
  final lower = summary.toLowerCase();
  if (lower.contains('高') || lower.contains('hot') || lower.contains('强')) {
    return const Color(0xFFE65100);
  }
  if (lower.contains('低') || lower.contains('cold') || lower.contains('弱')) {
    return const Color(0xFF78909C);
  }
  return const Color(0xFFF9A825);
}

String heatLabel(String summary) {
  final lower = summary.toLowerCase();
  if (lower.contains('高') || lower.contains('hot') || lower.contains('强')) {
    return '热度高';
  }
  if (lower.contains('低') || lower.contains('cold') || lower.contains('弱')) {
    return '热度低';
  }
  return '热度中';
}

double heatScore(String summary) {
  final lower = summary.toLowerCase();
  if (lower.contains('高') || lower.contains('hot') || lower.contains('强')) {
    return 0.88;
  }
  if (lower.contains('低') || lower.contains('cold') || lower.contains('弱')) {
    return 0.34;
  }
  return 0.62;
}

Color competitionColor(String summary, ColorScheme colorScheme) {
  final lower = summary.toLowerCase();
  if (lower.contains('激') || lower.contains('high') || lower.contains('高')) {
    return colorScheme.error;
  }
  if (lower.contains('低') || lower.contains('low') || lower.contains('少')) {
    return const Color(0xFF2E7D32);
  }
  return const Color(0xFF78909C);
}

double competitionScore(String summary) {
  final lower = summary.toLowerCase();
  if (lower.contains('激') || lower.contains('high') || lower.contains('高')) {
    return 0.82;
  }
  if (lower.contains('低') || lower.contains('low') || lower.contains('少')) {
    return 0.36;
  }
  return 0.58;
}

Color feasibilityColor(String value, ColorScheme colorScheme) {
  final lower = value.toLowerCase();
  if (lower.contains('高') || lower.contains('high') || lower.contains('强')) {
    return const Color(0xFF16825D);
  }
  if (lower.contains('低') || lower.contains('low') || lower.contains('弱')) {
    return colorScheme.error;
  }
  return const Color(0xFFF9A825);
}

double feasibilityScore(String value) {
  final lower = value.toLowerCase();
  if (lower.contains('高') || lower.contains('high') || lower.contains('强')) {
    return 0.82;
  }
  if (lower.contains('低') || lower.contains('low') || lower.contains('弱')) {
    return 0.36;
  }
  return 0.58;
}

String competitionLabel(String summary) {
  final lower = summary.toLowerCase();
  if (lower.contains('激') || lower.contains('high') || lower.contains('高')) {
    return '竞争激烈';
  }
  if (lower.contains('低') || lower.contains('low') || lower.contains('少')) {
    return '竞争较低';
  }
  return '竞争适中';
}
