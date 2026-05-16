import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/llm/application/markdown_completion_service.dart';
import '../../settings/application/provider_config_providers.dart';
import '../data/drift_style_lab_repository.dart';
import '../domain/style_analysis_run.dart';
import '../domain/style_lab_repository.dart';
import '../domain/style_profile.dart';
import '../domain/style_sample.dart';
import 'style_analysis_pipeline.dart';
import 'style_sample_importer.dart';
import 'voice_profile_front_matter.dart';

part 'style_lab_providers.g.dart';

@Riverpod(keepAlive: true)
StyleLabRepository styleLabRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftStyleLabRepository(database);
}

@Riverpod(keepAlive: true)
StyleSampleImporter styleSampleImporter(Ref ref) {
  return const StyleSampleImporter();
}

@Riverpod(keepAlive: true)
VoiceProfileFrontMatterParser voiceProfileFrontMatterParser(Ref ref) {
  return const VoiceProfileFrontMatterParser();
}

@Riverpod(keepAlive: true)
MarkdownCompletionService markdownCompletionService(Ref ref) {
  return MarkdownCompletionService(
    invocation: ref.watch(llmInvocationServiceProvider),
  );
}

@Riverpod(keepAlive: true)
StyleAnalysisPipeline styleAnalysisPipeline(Ref ref) {
  return StyleAnalysisPipeline(
    repository: ref.watch(styleLabRepositoryProvider),
    completionService: ref.watch(markdownCompletionServiceProvider),
  );
}

@riverpod
Stream<List<StyleSample>> styleSamples(Ref ref) {
  return ref.watch(styleLabRepositoryProvider).watchSamples();
}

@riverpod
Stream<StyleSample?> styleSample(Ref ref, String id) {
  return ref.watch(styleLabRepositoryProvider).watchSample(id);
}

@riverpod
Stream<List<StyleAnalysisRun>> recentStyleAnalysisRuns(Ref ref) {
  return ref.watch(styleLabRepositoryProvider).watchRecentRuns();
}

@riverpod
Stream<StyleAnalysisRun?> styleAnalysisRun(Ref ref, String id) {
  return ref.watch(styleLabRepositoryProvider).watchRun(id);
}

@riverpod
Stream<List<StyleProfile>> styleProfiles(Ref ref) {
  return ref.watch(styleLabRepositoryProvider).watchProfiles();
}

@riverpod
Stream<StyleProfile?> styleProfile(Ref ref, String id) {
  return ref.watch(styleLabRepositoryProvider).watchProfile(id);
}

@Riverpod(keepAlive: true)
class StyleLabController extends _$StyleLabController {
  @override
  FutureOr<void> build() async {
    await ref.read(styleLabRepositoryProvider).markInterruptedRunsFailed();
  }

  Future<List<StyleSample>> importFile(String path) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final inputs = await ref
          .read(styleSampleImporterProvider)
          .importFile(path);
      final repository = ref.read(styleLabRepositoryProvider);
      final saved = <StyleSample>[];
      for (final input in inputs) {
        saved.add(await repository.saveSample(input));
      }
      return saved;
    });
    state = result.whenData((_) {});
    return result.requireValue;
  }

  Future<StyleAnalysisRun> createAndRun({
    required String sampleId,
    required String providerId,
    required String styleName,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final repository = ref.read(styleLabRepositoryProvider);
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
        StyleAnalysisRunInput(
          sampleId: sample.id,
          providerId: provider.id,
          modelName: provider.defaultModel,
          styleName: styleName.trim().isEmpty ? sample.title : styleName.trim(),
          projectId: sample.projectId,
          characterCount: sample.characterCount,
        ),
      );
      unawaited(
        ref
            .read(styleAnalysisPipelineProvider)
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
      final repository = ref.read(styleLabRepositoryProvider);
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
      unawaited(
        ref
            .read(styleAnalysisPipelineProvider)
            .run(runId: run.id, provider: provider)
            .catchError((Object _) {}),
      );
    });
  }

  Future<StyleProfile> saveProfile({
    required String runId,
    required String styleName,
    required String profileMarkdown,
    String? projectId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      ref.read(voiceProfileFrontMatterParserProvider).parse(profileMarkdown);
      return ref
          .read(styleLabRepositoryProvider)
          .saveProfileFromRun(
            StyleProfileInput(
              runId: runId,
              styleName: styleName,
              profileMarkdown: profileMarkdown,
              projectId: projectId,
            ),
          );
    });
    state = result.whenData((_) {});
    return result.requireValue;
  }

  Future<StyleProfile> updateProfile({
    required String id,
    required String styleName,
    required String profileMarkdown,
    String? projectId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      ref.read(voiceProfileFrontMatterParserProvider).parse(profileMarkdown);
      return ref
          .read(styleLabRepositoryProvider)
          .updateProfile(
            id: id,
            input: StyleProfileUpdateInput(
              styleName: styleName,
              profileMarkdown: profileMarkdown,
              projectId: projectId,
            ),
          );
    });
    state = result.whenData((_) {});
    return result.requireValue;
  }
}
