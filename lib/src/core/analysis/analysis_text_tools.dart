import '../../features/settings/domain/provider_config.dart';
import '../llm/domain/llm_error_utils.dart';

const defaultAnalysisChunkSize = 12000;

List<String> splitAnalysisTextIntoChunks(
  String text, {
  int chunkSize = defaultAnalysisChunkSize,
}) {
  final normalized = text.trim();
  if (normalized.isEmpty) {
    return const [];
  }
  if (normalized.length <= chunkSize) {
    return [normalized];
  }

  final paragraphs = normalized.split(RegExp(r'\n{2,}'));
  final chunks = <String>[];
  final buffer = StringBuffer();
  for (final paragraph in paragraphs) {
    if (buffer.isNotEmpty && buffer.length + paragraph.length + 2 > chunkSize) {
      chunks.add(buffer.toString().trim());
      buffer.clear();
    }
    if (paragraph.length > chunkSize) {
      var start = 0;
      while (start < paragraph.length) {
        final end = (start + chunkSize).clamp(0, paragraph.length);
        chunks.add(paragraph.substring(start, end).trim());
        start = end;
      }
      continue;
    }
    if (buffer.isNotEmpty) {
      buffer.write('\n\n');
    }
    buffer.write(paragraph);
  }
  if (buffer.isNotEmpty) {
    chunks.add(buffer.toString().trim());
  }
  return chunks.where((chunk) => chunk.isNotEmpty).toList(growable: false);
}

AnalysisInputSignals detectAnalysisInputSignals({
  required String text,
  required int chunkCount,
  int sampleLineLimit = 220,
}) {
  final sampleText = text
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .take(sampleLineLimit)
      .join('\n');
  final hasTimestamps = RegExp(
    r'(?:\[|\()\d{1,2}:\d{2}(?::\d{2})?(?:\]|\))|^\d{1,2}:\d{2}',
    multiLine: true,
  ).hasMatch(sampleText);
  final hasSpeakerLabels = RegExp(
    r'^[A-Z][A-Za-z ]{0,20}[:：]|^[一-龥]{1,6}[:：]',
    multiLine: true,
  ).hasMatch(sampleText);
  final hasNoiseMarkers = RegExp(
    r'\[(?:pauses?|laughs?|inaudible|静默|笑|背景音)\]',
    caseSensitive: false,
  ).hasMatch(sampleText);

  final textType = hasTimestamps
      ? '口语字幕'
      : hasSpeakerLabels
      ? '混合文本'
      : '章节正文';
  final locationIndexing = hasTimestamps ? '时间戳' : '章节或段落位置';

  return AnalysisInputSignals(
    textType: textType,
    hasTimestamps: hasTimestamps,
    hasSpeakerLabels: hasSpeakerLabels,
    hasNoiseMarkers: hasNoiseMarkers,
    usesBatchProcessing: chunkCount > 1,
    locationIndexing: locationIndexing,
    noiseNotes: hasNoiseMarkers ? '检测到对话/语气/背景音标记。' : '未发现显著噪声。',
  );
}

/// Delegates to [sanitizeLlmError] for consistent error sanitization.
String sanitizeAnalysisError(
  Object error,
  ProviderConfig provider, {
  int maxLength = 220,
}) {
  return sanitizeLlmError(error, provider.apiKey, maxLength: maxLength);
}

class InputClassification {
  const InputClassification({
    required this.textType,
    required this.hasTimestamps,
    required this.hasSpeakerLabels,
    required this.hasNoiseMarkers,
    required this.usesBatchProcessing,
    required this.locationIndexing,
    required this.noiseNotes,
  });

  final String textType;
  final bool hasTimestamps;
  final bool hasSpeakerLabels;
  final bool hasNoiseMarkers;
  final bool usesBatchProcessing;
  final String locationIndexing;
  final String noiseNotes;

  factory InputClassification.detect({
    required String text,
    required int chunkCount,
    int sampleLineLimit = 220,
  }) {
    final signals = detectAnalysisInputSignals(
      text: text,
      chunkCount: chunkCount,
      sampleLineLimit: sampleLineLimit,
    );
    return InputClassification(
      textType: signals.textType,
      hasTimestamps: signals.hasTimestamps,
      hasSpeakerLabels: signals.hasSpeakerLabels,
      hasNoiseMarkers: signals.hasNoiseMarkers,
      usesBatchProcessing: signals.usesBatchProcessing,
      locationIndexing: signals.locationIndexing,
      noiseNotes: signals.noiseNotes,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'text_type': textType,
      'has_timestamps': hasTimestamps,
      'has_speaker_labels': hasSpeakerLabels,
      'has_noise_markers': hasNoiseMarkers,
      'uses_batch_processing': usesBatchProcessing,
      'location_indexing': locationIndexing,
      'noise_notes': noiseNotes,
    };
  }

  factory InputClassification.fromJson(Map<String, Object?> json) {
    return InputClassification(
      textType: json['text_type'] as String? ?? '',
      hasTimestamps: json['has_timestamps'] as bool? ?? false,
      hasSpeakerLabels: json['has_speaker_labels'] as bool? ?? false,
      hasNoiseMarkers: json['has_noise_markers'] as bool? ?? false,
      usesBatchProcessing: json['uses_batch_processing'] as bool? ?? false,
      locationIndexing: json['location_indexing'] as String? ?? '',
      noiseNotes: json['noise_notes'] as String? ?? '',
    );
  }
}

class AnalysisInputSignals {
  const AnalysisInputSignals({
    required this.textType,
    required this.hasTimestamps,
    required this.hasSpeakerLabels,
    required this.hasNoiseMarkers,
    required this.usesBatchProcessing,
    required this.locationIndexing,
    required this.noiseNotes,
  });

  final String textType;
  final bool hasTimestamps;
  final bool hasSpeakerLabels;
  final bool hasNoiseMarkers;
  final bool usesBatchProcessing;
  final String locationIndexing;
  final String noiseNotes;
}
