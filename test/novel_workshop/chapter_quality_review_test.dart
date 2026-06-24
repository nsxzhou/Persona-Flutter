import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/chapter_quality_review.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_workshop.dart';

void main() {
  test('parses quality review front matter and markdown body', () {
    final result = const ChapterQualityReviewParser().parse('''---
verdict: needsRevision
needsRevision: true
overallScore: 64
dimensions:
  thrill: 72
  pacing: 60
  pull: 58
  characterHit: 80
  naturalLanguage: 70
majorIssues:
  - 节奏拖慢
revisionInstructions: |-
  压缩解释段落。
---
# 质量评审报告

节奏拖慢，需要修订。''');

    expect(result.verdict, ChapterQualityVerdict.needsRevision);
    expect(result.needsRevision, isTrue);
    expect(result.overallScore, 64);
    expect(result.dimensionScores['pacing'], 60);
    expect(result.majorIssues, ['节奏拖慢']);
    expect(result.revisionInstructions, '压缩解释段落。');
    expect(result.reportMarkdown, contains('质量评审报告'));
  });

  test('malformed quality review downgrades to warning without revision', () {
    final result = const ChapterQualityReviewParser().parse('我忘了输出 YAML。');

    expect(result.verdict, ChapterQualityVerdict.warning);
    expect(result.needsRevision, isFalse);
    expect(result.reportMarkdown, contains('无法完整解析'));
  });
}
