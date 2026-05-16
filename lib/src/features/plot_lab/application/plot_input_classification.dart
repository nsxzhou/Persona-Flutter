class PlotInputClassification {
  const PlotInputClassification({
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

  factory PlotInputClassification.detect({
    required String text,
    required int chunkCount,
  }) {
    final sampleText = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .take(240)
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

    return PlotInputClassification(
      textType: textType,
      hasTimestamps: hasTimestamps,
      hasSpeakerLabels: hasSpeakerLabels,
      hasNoiseMarkers: hasNoiseMarkers,
      usesBatchProcessing: chunkCount > 1,
      locationIndexing: locationIndexing,
      noiseNotes: hasNoiseMarkers ? '检测到对话/语气/背景音标记。' : '未发现显著噪声。',
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
}
