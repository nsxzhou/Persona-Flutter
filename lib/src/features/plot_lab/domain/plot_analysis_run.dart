import 'package:freezed_annotation/freezed_annotation.dart';

part 'plot_analysis_run.freezed.dart';
part 'plot_analysis_run.g.dart';

enum PlotAnalysisStatus { pending, running, succeeded, failed }

enum PlotAnalysisStage {
  preparingInput,
  sketchingChunks,
  buildingSkeleton,
  reporting,
  postprocessing,
}

const plotAnalysisWorkflowTaskKind = 'plot_lab_analysis';

@freezed
abstract class PlotAnalysisRun with _$PlotAnalysisRun {
  const factory PlotAnalysisRun({
    required String id,
    required String workflowTaskId,
    required String sampleId,
    required String providerId,
    required String modelName,
    required String plotName,
    String? projectId,
    required PlotAnalysisStatus status,
    PlotAnalysisStage? stage,
    String? errorMessage,
    @Default('') String logs,
    String? analysisReportMarkdown,
    String? plotSkeletonMarkdown,
    String? storyEngineMarkdown,
    String? profileId,
    required int chunkCount,
    required int characterCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _PlotAnalysisRun;

  factory PlotAnalysisRun.fromJson(Map<String, Object?> json) =>
      _$PlotAnalysisRunFromJson(json);
}

class PlotAnalysisRunInput {
  const PlotAnalysisRunInput({
    required this.sampleId,
    required this.providerId,
    required this.modelName,
    required this.plotName,
    this.projectId,
    required this.characterCount,
  });

  final String sampleId;
  final String providerId;
  final String modelName;
  final String plotName;
  final String? projectId;
  final int characterCount;
}
