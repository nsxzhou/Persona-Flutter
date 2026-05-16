import 'style_analysis_run.dart';
import 'style_profile.dart';
import 'style_sample.dart';

abstract interface class StyleLabRepository {
  Stream<List<StyleSample>> watchSamples();

  Stream<StyleSample?> watchSample(String id);

  Future<StyleSample?> findSample(String id);

  Future<StyleSample> saveSample(StyleSampleInput input);

  Stream<List<StyleAnalysisRun>> watchRecentRuns();

  Stream<StyleAnalysisRun?> watchRun(String id);

  Stream<StyleAnalysisRun?> watchRunByWorkflowTask(String workflowTaskId);

  Future<StyleAnalysisRun?> findRun(String id);

  Future<StyleAnalysisRun> createRun(StyleAnalysisRunInput input);

  Future<StyleAnalysisRun> createRunFromExisting(String id);

  Future<void> deleteRun(String id);

  Future<void> updateRunState({
    required String id,
    required StyleAnalysisStatus status,
    StyleAnalysisStage? stage,
    String? errorMessage,
    String? logs,
    String? analysisReportMarkdown,
    String? voiceProfileMarkdown,
    String? profileId,
    int? chunkCount,
    DateTime? startedAt,
    DateTime? completedAt,
  });

  Future<int> markInterruptedRunsFailed();

  Stream<List<StyleProfile>> watchProfiles();

  Stream<StyleProfile?> watchProfile(String id);

  Future<StyleProfile?> findProfile(String id);

  Future<StyleProfile> saveProfileFromRun(StyleProfileInput input);

  Future<StyleProfile> updateProfile({
    required String id,
    required StyleProfileUpdateInput input,
  });

  Future<void> deleteProfile(String id);
}
