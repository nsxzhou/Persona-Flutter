import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/analysis/analysis_text_tools.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';

void main() {
  test(
    'splitAnalysisTextIntoChunks preserves paragraph boundaries when possible',
    () {
      final chunks = splitAnalysisTextIntoChunks(
        '第一段。\n\n第二段很长。\n\n第三段。',
        chunkSize: 8,
      );

      expect(chunks, ['第一段。', '第二段很长。', '第三段。']);
    },
  );

  test(
    'detectAnalysisInputSignals identifies speaker labels and timestamps',
    () {
      final dialogue = detectAnalysisInputSignals(
        text: '甲：你好\n乙：不好',
        chunkCount: 2,
      );
      final transcript = detectAnalysisInputSignals(
        text: '[01:02] hello\n[laughs]',
        chunkCount: 1,
      );

      expect(dialogue.textType, '混合文本');
      expect(dialogue.hasSpeakerLabels, isTrue);
      expect(dialogue.usesBatchProcessing, isTrue);
      expect(transcript.textType, '口语字幕');
      expect(transcript.hasNoiseMarkers, isTrue);
      expect(transcript.locationIndexing, '时间戳');
    },
  );

  test(
    'sanitizeAnalysisError redacts provider api key and truncates output',
    () {
      final provider = ProviderConfig(
        id: 'provider-1',
        name: 'deepseek',
        baseUrl: 'https://api.example.com/v1',
        apiKey: 'sk-secret',
        defaultModel: 'deepseek-chat',
        isEnabled: true,
        testStatus: ProviderTestStatus.untested,
        createdAt: DateTime(2026, 5, 17),
        updatedAt: DateTime(2026, 5, 17),
      );

      final message = sanitizeAnalysisError(
        'failure sk-secret ${'x' * 60}',
        provider,
        maxLength: 32,
      );

      expect(message, isNot(contains('sk-secret')));
      expect(message, contains('[REDACTED]'));
      expect(message.length, 32);
    },
  );
}
