import 'plot_analysis_run.dart';
import 'plot_profile.dart';
import 'plot_sample.dart';

abstract interface class PlotLabRepository {
  Stream<List<PlotSample>> watchSamples();

  Stream<PlotSample?> watchSample(String id);

  Future<PlotSample?> findSample(String id);

  Future<PlotSample> saveSample(PlotSampleInput input);

  Stream<List<PlotAnalysisRun>> watchRecentRuns();

  Stream<PlotAnalysisRun?> watchRun(String id);

  Stream<PlotAnalysisRun?> watchRunByWorkflowTask(String workflowTaskId);

  Future<PlotAnalysisRun?> findRun(String id);

  Future<PlotAnalysisRun> createRun(PlotAnalysisRunInput input);

  Future<PlotAnalysisRun> createRunFromExisting(String id);

  Future<void> deleteRun(String id);

  Future<void> updateRunState({
    required String id,
    required PlotAnalysisStatus status,
    PlotAnalysisStage? stage,
    String? errorMessage,
    String? logs,
    String? analysisReportMarkdown,
    String? plotSkeletonMarkdown,
    String? storyEngineMarkdown,
    String? profileId,
    int? chunkCount,
    DateTime? startedAt,
    DateTime? completedAt,
  });

  Future<int> markInterruptedRunsFailed();

  Stream<List<PlotProfile>> watchProfiles();

  Stream<PlotProfile?> watchProfile(String id);

  Future<PlotProfile?> findProfile(String id);

  Future<PlotProfile> saveProfileFromRun(PlotProfileInput input);

  Future<PlotProfile> updateProfile({
    required String id,
    required PlotProfileUpdateInput input,
  });

  Future<void> deleteProfile(String id);
}
