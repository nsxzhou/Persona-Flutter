import '../../../core/analysis/analysis_text_tools.dart';

class StyleInputClassification {
  const StyleInputClassification({
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

  factory StyleInputClassification.detect({
    required String text,
    required int chunkCount,
  }) {
    final signals = detectAnalysisInputSignals(
      text: text,
      chunkCount: chunkCount,
      sampleLineLimit: 200,
    );

    return StyleInputClassification(
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
}
