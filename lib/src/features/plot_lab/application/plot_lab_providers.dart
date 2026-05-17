import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/llm/application/markdown_completion_service.dart';
import '../../../core/tasks/application/workflow_task_providers.dart';
import '../../settings/application/provider_config_providers.dart';
import '../data/drift_plot_lab_repository.dart';
import '../domain/plot_analysis_run.dart';
import '../domain/plot_lab_repository.dart';
import '../domain/plot_profile.dart';
import '../domain/plot_sample.dart';
import 'plot_analysis_pipeline.dart';
import 'plot_sample_importer.dart';
import 'story_engine_normalizer.dart';

part 'plot_lab_providers.g.dart';

@Riverpod(keepAlive: true)
PlotLabRepository plotLabRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftPlotLabRepository(database);
}

@Riverpod(keepAlive: true)
PlotSampleImporter plotSampleImporter(Ref ref) {
  return const PlotSampleImporter();
}

@Riverpod(keepAlive: true)
StoryEngineNormalizer storyEngineNormalizer(Ref ref) {
  return const StoryEngineNormalizer();
}

@Riverpod(keepAlive: true)
MarkdownCompletionService plotMarkdownCompletionService(Ref ref) {
  return MarkdownCompletionService(
    invocation: ref.watch(llmInvocationServiceProvider),
  );
}

@Riverpod(keepAlive: true)
PlotAnalysisPipeline plotAnalysisPipeline(Ref ref) {
  return PlotAnalysisPipeline(
    repository: ref.watch(plotLabRepositoryProvider),
    completionService: ref.watch(plotMarkdownCompletionServiceProvider),
    workflowTaskRepository: ref.watch(workflowTaskRepositoryProvider),
    storyEngineNormalizer: ref.watch(storyEngineNormalizerProvider),
  );
}

@riverpod
Stream<List<PlotSample>> plotSamples(Ref ref) {
  return ref.watch(plotLabRepositoryProvider).watchSamples();
}

@riverpod
Stream<PlotSample?> plotSample(Ref ref, String id) {
  return ref.watch(plotLabRepositoryProvider).watchSample(id);
}

@riverpod
Stream<List<PlotAnalysisRun>> recentPlotAnalysisRuns(Ref ref) {
  return ref.watch(plotLabRepositoryProvider).watchRecentRuns();
}

@riverpod
Stream<PlotAnalysisRun?> plotAnalysisRun(Ref ref, String id) {
  return ref.watch(plotLabRepositoryProvider).watchRun(id);
}

@riverpod
Stream<PlotAnalysisRun?> plotAnalysisRunByWorkflowTask(
  Ref ref,
  String workflowTaskId,
) {
  return ref
      .watch(plotLabRepositoryProvider)
      .watchRunByWorkflowTask(workflowTaskId);
}

@riverpod
Stream<List<PlotProfile>> plotProfiles(Ref ref) {
  return ref.watch(plotLabRepositoryProvider).watchProfiles();
}

@riverpod
Stream<PlotProfile?> plotProfile(Ref ref, String id) {
  return ref.watch(plotLabRepositoryProvider).watchProfile(id);
}

@Riverpod(keepAlive: true)
class PlotLabController extends _$PlotLabController {
  @override
  FutureOr<void> build() async {
    await ref.read(plotLabRepositoryProvider).markInterruptedRunsFailed();
  }

  Future<PlotSample> importFile(String path) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final input = await ref.read(plotSampleImporterProvider).importFile(path);
      return ref.read(plotLabRepositoryProvider).saveSample(input);
    });
    state = result.whenData((_) {});
    return result.requireValue;
  }

  Future<PlotAnalysisRun> createAndRun({
    required String sampleId,
    required String providerId,
    required String plotName,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final repository = ref.read(plotLabRepositoryProvider);
      final sample = await repository.findSample(sampleId);
      if (sample == null) {
        throw StateError('样本不存在。');
      }
      final provider = await ref
          .read(providerConfigRepositoryProvider)
          .findProvider(providerId);
      if (provider == null) {
        throw StateError('Provider 不存在。');
      }
      if (!provider.isEnabled) {
        throw StateError('Provider 已停用。');
      }
      final run = await repository.createRun(
        PlotAnalysisRunInput(
          sampleId: sample.id,
          providerId: provider.id,
          modelName: provider.defaultModel,
          plotName: plotName.trim().isEmpty ? sample.title : plotName.trim(),
          characterCount: sample.characterCount,
        ),
      );
      unawaited(
        ref
            .read(plotAnalysisPipelineProvider)
            .run(runId: run.id, provider: provider)
            .catchError((Object _) {}),
      );
      return run;
    });
    state = result.whenData((_) {});
    return result.requireValue;
  }

  Future<void> rerun(String runId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(plotLabRepositoryProvider);
      final run = await repository.findRun(runId);
      if (run == null) {
        throw StateError('分析任务不存在。');
      }
      final provider = await ref
          .read(providerConfigRepositoryProvider)
          .findProvider(run.providerId);
      if (provider == null) {
        throw StateError('Provider 不存在。');
      }
      if (!provider.isEnabled) {
        throw StateError('Provider 已停用。');
      }
      final newRun = await repository.createRunFromExisting(run.id);
      unawaited(
        ref
            .read(plotAnalysisPipelineProvider)
            .run(runId: newRun.id, provider: provider)
            .catchError((Object _) {}),
      );
    });
  }

  Future<void> deleteRun(String runId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(plotLabRepositoryProvider).deleteRun(runId);
    });
  }

  Future<PlotProfile> saveProfile({
    required String runId,
    required String plotName,
    required String storyEngineMarkdown,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final normalized = ref
          .read(storyEngineNormalizerProvider)
          .normalize(storyEngineMarkdown);
      if (normalized.trim().isEmpty) {
        throw StateError('Story Engine 不能为空。');
      }
      return ref
          .read(plotLabRepositoryProvider)
          .saveProfileFromRun(
            PlotProfileInput(
              runId: runId,
              plotName: plotName,
              storyEngineMarkdown: normalized,
            ),
          );
    });
    state = result.whenData((_) {});
    return result.requireValue;
  }

  Future<PlotProfile> updateProfile({
    required String id,
    required String plotName,
    required String storyEngineMarkdown,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final normalized = ref
          .read(storyEngineNormalizerProvider)
          .normalize(storyEngineMarkdown);
      if (normalized.trim().isEmpty) {
        throw StateError('Story Engine 不能为空。');
      }
      return ref
          .read(plotLabRepositoryProvider)
          .updateProfile(
            id: id,
            input: PlotProfileUpdateInput(
              plotName: plotName,
              storyEngineMarkdown: normalized,
            ),
          );
    });
    state = result.whenData((_) {});
    return result.requireValue;
  }

  Future<void> deleteProfile(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(plotLabRepositoryProvider).deleteProfile(id);
    });
  }
}
