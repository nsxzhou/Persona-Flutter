import '../../features/settings/domain/provider_config.dart';

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

String sanitizeAnalysisError(
  Object error,
  ProviderConfig provider, {
  int maxLength = 220,
}) {
  var message = error.toString();
  final apiKey = provider.apiKey.trim();
  if (apiKey.isNotEmpty) {
    message = message.replaceAll(apiKey, '[REDACTED]');
  }
  if (message.length <= maxLength) {
    return message;
  }
  return '${message.substring(0, maxLength - 3)}...';
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
