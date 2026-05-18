import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/database/app_database.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/project_prompt_asset_resolver.dart';
import 'package:persona_flutter/src/features/plot_lab/data/drift_plot_lab_repository.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_analysis_run.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_profile.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_sample.dart';
import 'package:persona_flutter/src/features/projects/data/drift_project_repository.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';
import 'package:persona_flutter/src/features/settings/data/drift_provider_config_repository.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:persona_flutter/src/features/style_lab/data/drift_style_lab_repository.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_analysis_run.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_profile.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_sample.dart';

void main() {
  test(
    'resolves project-bound voice profile and story engine assets',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final provider = await _saveProvider(database);
      final styleRepository = DriftStyleLabRepository(database);
      final plotRepository = DriftPlotLabRepository(database);
      final projectRepository = DriftProjectRepository(database);

      final styleProfile = await _saveStyleProfile(
        repository: styleRepository,
        provider: provider,
      );
      final plotProfile = await _savePlotProfile(
        repository: plotRepository,
        provider: provider,
      );
      await projectRepository.saveProject(
        input: WritingProjectInput(
          title: '雾港纪事',
          description: '潮湿港城里的长篇悬疑。',
          status: ProjectStatus.active,
          defaultProviderId: provider.id,
          defaultModelName: provider.defaultModel,
          styleProfileId: styleProfile.id,
          plotProfileId: plotProfile.id,
        ),
      );
      final project =
          (await projectRepository.watchProjects(ProjectStatus.active).first)
              .single;

      final assets = await ProjectPromptAssetResolver(
        projectRepository: projectRepository,
        styleLabRepository: styleRepository,
        plotLabRepository: plotRepository,
      ).resolve(project.id);

      expect(assets.voiceProfileMarkdown, contains('# Voice Profile'));
      expect(assets.voiceProfileMarkdown, contains('短句'));
      expect(assets.storyEngineMarkdown, contains('# Plot Writing Guide'));
      expect(assets.storyEngineMarkdown, contains('半兑现'));
      expect(assets.plotSkeletonMarkdown, contains('# 全书骨架'));
      expect(assets.warnings, isEmpty);
    },
  );

  test('keeps malformed prompt assets usable with health warnings', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final provider = await _saveProvider(database);
    final styleRepository = DriftStyleLabRepository(database);
    final plotRepository = DriftPlotLabRepository(database);
    final projectRepository = DriftProjectRepository(database);

    final styleProfile = await _saveStyleProfile(
      repository: styleRepository,
      provider: provider,
      profileMarkdown: '没有标题的文风资产。',
    );
    final plotProfile = await _savePlotProfile(
      repository: plotRepository,
      provider: provider,
      storyEngineMarkdown: '---\nname: broken\nMissing close',
    );
    await projectRepository.saveProject(
      input: WritingProjectInput(
        title: '雾港纪事',
        description: '',
        status: ProjectStatus.active,
        defaultProviderId: provider.id,
        defaultModelName: provider.defaultModel,
        styleProfileId: styleProfile.id,
        plotProfileId: plotProfile.id,
      ),
    );
    final project =
        (await projectRepository.watchProjects(ProjectStatus.active).first)
            .single;

    final assets = await ProjectPromptAssetResolver(
      projectRepository: projectRepository,
      styleLabRepository: styleRepository,
      plotLabRepository: plotRepository,
    ).resolve(project.id);

    expect(assets.voiceProfileMarkdown, '没有标题的文风资产。');
    expect(assets.storyEngineMarkdown, '---\nname: broken\nMissing close');
    expect(assets.warnings, [
      'Voice Profile 缺少 Markdown 标题。',
      'Story Engine 缺少 Markdown 标题。',
      'Story Engine front matter 异常，已按纯 Markdown 继续使用。',
    ]);
  });
}

Future<ProviderConfig> _saveProvider(AppDatabase database) async {
  final repository = DriftProviderConfigRepository(database);
  await repository.saveProvider(
    input: const ProviderConfigInput(
      name: 'OpenAI',
      baseUrl: 'https://api.example.com/v1',
      apiKey: 'sk-test',
      defaultModel: 'gpt-4.1-mini',
      systemPrompt: '',
      isEnabled: true,
    ),
  );
  return (await repository.watchProviders().first).single;
}

Future<StyleProfile> _saveStyleProfile({
  required DriftStyleLabRepository repository,
  required ProviderConfig provider,
  String profileMarkdown = _validVoiceProfile,
}) async {
  final sample = await repository.saveSample(
    const StyleSampleInput(
      sourceType: StyleSampleSourceType.txt,
      title: '风格样本',
      content: '第一段。\n\n第二段。',
    ),
  );
  final run = await repository.createRun(
    StyleAnalysisRunInput(
      sampleId: sample.id,
      providerId: provider.id,
      modelName: provider.defaultModel,
      styleName: '雾港文风',
      characterCount: sample.characterCount,
    ),
  );
  await repository.updateRunState(
    id: run.id,
    status: StyleAnalysisStatus.succeeded,
    analysisReportMarkdown: '# 风格报告',
    voiceProfileMarkdown: profileMarkdown,
  );
  return repository.saveProfileFromRun(
    StyleProfileInput(
      runId: run.id,
      styleName: '雾港文风',
      profileMarkdown: profileMarkdown,
    ),
  );
}

Future<PlotProfile> _savePlotProfile({
  required DriftPlotLabRepository repository,
  required ProviderConfig provider,
  String storyEngineMarkdown = _validStoryEngine,
}) async {
  final sample = await repository.saveSample(
    const PlotSampleInput(
      sourceType: PlotSampleSourceType.txt,
      title: '剧情样本',
      content: '第一章。\n\n第二章。',
    ),
  );
  final run = await repository.createRun(
    PlotAnalysisRunInput(
      sampleId: sample.id,
      providerId: provider.id,
      modelName: provider.defaultModel,
      plotName: '雾港剧情',
      characterCount: sample.characterCount,
    ),
  );
  await repository.updateRunState(
    id: run.id,
    status: PlotAnalysisStatus.succeeded,
    analysisReportMarkdown: '# 剧情报告',
    plotSkeletonMarkdown: '# 全书骨架\n\n- 雾港失踪案持续升级。',
    storyEngineMarkdown: storyEngineMarkdown,
  );
  return repository.saveProfileFromRun(
    PlotProfileInput(
      runId: run.id,
      plotName: '雾港剧情',
      storyEngineMarkdown: storyEngineMarkdown,
    ),
  );
}

const _validVoiceProfile = '''---
name: "雾港文风"
---

# Voice Profile

- 短句。
- 压迫感强。''';

const _validStoryEngine = '''---
name: "雾港剧情"
---

# Plot Writing Guide

- 目标 -> 阻碍 -> 半兑现。''';
