import 'package:freezed_annotation/freezed_annotation.dart';

part 'style_analysis_run.freezed.dart';
part 'style_analysis_run.g.dart';

enum StyleAnalysisStatus { pending, running, succeeded, failed }

enum StyleAnalysisStage {
  preparingInput,
  analyzingChunks,
  aggregating,
  reporting,
  buildingVoiceProfile,
  persistingResult,
}

const styleAnalysisWorkflowTaskKind = 'style_lab_analysis';

@freezed
abstract class StyleAnalysisRun with _$StyleAnalysisRun {
  const factory StyleAnalysisRun({
    required String id,
    required String workflowTaskId,
    required String sampleId,
    required String providerId,
    required String modelName,
    required String styleName,
    String? projectId,
    required StyleAnalysisStatus status,
    StyleAnalysisStage? stage,
    String? errorMessage,
    @Default('') String logs,
    String? analysisReportMarkdown,
    String? voiceProfileMarkdown,
    String? profileId,
    required int chunkCount,
    required int characterCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _StyleAnalysisRun;

  factory StyleAnalysisRun.fromJson(Map<String, Object?> json) =>
      _$StyleAnalysisRunFromJson(json);
}

class StyleAnalysisRunInput {
  const StyleAnalysisRunInput({
    required this.sampleId,
    required this.providerId,
    required this.modelName,
    required this.styleName,
    required this.characterCount,
    this.projectId,
  });

  final String sampleId;
  final String providerId;
  final String modelName;
  final String styleName;
  final int characterCount;
  final String? projectId;
}
