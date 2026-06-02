import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_client.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_request.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_stream_event.dart';
import 'package:persona_flutter/src/core/image_generation/application/image_generation_service.dart';
import 'package:persona_flutter/src/core/image_generation/domain/image_generation_client.dart';
import 'package:persona_flutter/src/core/image_generation/domain/image_generation_request.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/asset_generation_pipeline.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/chapter_generation_pipeline.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/chapter_illustration_service.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/novel_export_service.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/novel_workshop_providers.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_workshop.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_workshop_repository.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/writing_context.dart';
import 'package:persona_flutter/src/features/novel_workshop/presentation/novel_workshop_page.dart';
import 'package:persona_flutter/src/features/plot_lab/application/plot_lab_providers.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_lab_repository.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_profile.dart';
import 'package:persona_flutter/src/features/projects/application/project_providers.dart';
import 'package:persona_flutter/src/features/projects/domain/project_repository.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';
import 'package:persona_flutter/src/features/settings/application/image_provider_config_providers.dart';
import 'package:persona_flutter/src/features/settings/application/provider_config_providers.dart';
import 'package:persona_flutter/src/features/settings/domain/image_provider_config.dart';
import 'package:persona_flutter/src/features/settings/domain/image_provider_config_repository.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config_repository.dart';
import 'package:persona_flutter/src/features/style_lab/application/style_lab_providers.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_lab_repository.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_profile.dart';

const _workshopLocation = '/projects/project-1/workshop';
const _editorLocation = '/projects/project-1/workshop/editor';
const _readerLocation = '/projects/project-1/workshop/reader';
final _testCreatedAt = DateTime(2026, 5, 18, 9);
final _testUpdatedAt = DateTime(2026, 5, 18, 10);

Offset _textOffsetToPosition(RenderParagraph paragraph, int offset) {
  const caret = Rect.fromLTWH(0, 0, 2, 20);
  final localOffset =
      paragraph.getOffsetForCaret(TextPosition(offset: offset), caret) +
      Offset(0, paragraph.preferredLineHeight);
  return paragraph.localToGlobal(localOffset) + const Offset(0, -2);
}

RenderParagraph _renderParagraph(WidgetTester tester, String text) {
  return tester.renderObject<RenderParagraph>(
    find.descendant(of: find.text(text), matching: find.byType(RichText)).first,
  );
}

void main() {
  testWidgets('workshop shows tabbed workbench with asset tabs', (
    tester,
  ) async {
    final fixture = _WorkshopFixture();
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    expect(find.text('项目工作台'), findsOneWidget);
    expect(find.text('概览'), findsWidgets);
    expect(find.text('世界观设定'), findsWidgets);
    expect(find.text('角色索引与关系网'), findsWidgets);
    expect(find.text('总纲'), findsWidgets);
    expect(find.text('分卷与章节细纲'), findsWidgets);
    expect(find.text('Voice Profile'), findsWidgets);
    expect(find.text('Story Engine'), findsWidgets);
    expect(find.text('Runtime Memory'), findsWidgets);
    expect(find.text('Prompt 栈'), findsWidgets);
    expect(find.text('设置'), findsWidgets);
    expect(find.text('骨架大纲'), findsNothing);
    expect(find.text('导出 TXT'), findsOneWidget);
    expect(find.byTooltip('插图库'), findsOneWidget);
    expect(find.text('阅读模式'), findsOneWidget);
    expect(find.text('进入编辑器'), findsOneWidget);
    expect(find.byKey(const ValueKey('novel-workshop-editor')), findsNothing);
  });

  testWidgets('workshop can rebuild tab controller when tab count changes', (
    tester,
  ) async {
    final fixture = _WorkshopFixture();
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    expect(find.text('世界观设定'), findsWidgets);

    final project = fixture.projectRepository.project;
    await fixture.projectRepository.saveProject(
      input: WritingProjectInput(
        title: project.title,
        description: project.description,
        status: project.status,
        defaultProviderId: project.defaultProviderId ?? '',
        defaultModelName: project.defaultModelName ?? '',
        styleProfileId: project.styleProfileId,
        plotProfileId: project.plotProfileId,
        origin: ProjectOrigin.importedEnrichment,
        language: project.language,
        targetLength: project.targetLength,
        totalTargetLength: project.totalTargetLength,
        narrativePerspective: project.narrativePerspective,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Voice Profile'), findsWidgets);
    expect(find.text('世界观设定'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('workshop exports saved novel txt from header action', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
      chapters: [_chapter(planId: 'plan-1', index: 1, content: '正文。')],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    await tester.tap(find.text('导出 TXT'));
    await tester.pumpAndSettle();

    expect(fixture.exportService.calls, 1);
    expect(fixture.exportService.lastProjectTitle, '雾港纪事');
    expect(fixture.exportService.lastChapterCount, 1);
    expect(find.textContaining('已导出 TXT：'), findsOneWidget);
  });

  testWidgets('workshop creates chapter plan from chapter planning tab', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(withDefaultVolume: false);
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    await tester.tap(find.text('分卷与章节细纲').last);
    await tester.pumpAndSettle();

    expect(find.text('暂无分卷'), findsOneWidget);
    expect(find.text('新建分卷'), findsWidgets);
    expect(find.text('先建分卷'), findsNothing);
    expect(find.text('分卷'), findsWidgets);
    expect(find.text('章节目标'), findsOneWidget);
    expect(find.text('已成文'), findsOneWidget);
    expect(find.text('创建分卷'), findsOneWidget);
    expect(find.text('添加章节目标'), findsOneWidget);
    expect(find.text('进入编辑器写正文'), findsOneWidget);

    await tester.tap(find.text('新建分卷').first);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('新建分卷'), findsWidgets);
    await tester.enterText(find.widgetWithText(TextFormField, '分卷标题'), '第一卷');
    await tester.ensureVisible(find.widgetWithText(FilledButton, '保存'));
    await tester.ensureVisible(find.widgetWithText(FilledButton, '保存'));
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(fixture.repository.volumes.single.title, '第一卷');
    expect(find.text('该分卷暂无章节细纲。'), findsOneWidget);

    await tester.tap(find.text('新建章节').first);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('新建章节目标卡'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, '章节标题'), '第一章');
    await tester.enterText(
      find.widgetWithText(TextFormField, '章节目标'),
      '主角进入雾港。',
    );
    await tester.ensureVisible(find.widgetWithText(FilledButton, '保存'));
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('第一章'), findsWidgets);
    expect(fixture.repository.plans.single.chapterIndex, 1);
    expect(
      fixture.repository.plans.single.volumeId,
      fixture.repository.volumes.single.id,
    );
    expect(fixture.repository.plans.single.volumeIndex, 1);
    expect(fixture.repository.plans.single.volumeTitle, '第一卷');
  });

  testWidgets('workshop edits bible markdown tabs inline', (tester) async {
    final fixture = _WorkshopFixture();
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    await tester.tap(find.text('世界观设定').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, '编辑'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('edit-bible-worldBuilding')),
      '潮汐城邦由七个港务家族控制。',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-bible-worldBuilding')));
    await tester.pumpAndSettle();

    expect(fixture.repository.bible.worldBuildingMarkdown, '潮汐城邦由七个港务家族控制。');

    await tester.tap(find.text('角色索引与关系网').last);
    await tester.pumpAndSettle();
    expect(find.text('旧角色索引参考'), findsOneWidget);
    expect(find.text('林岚：调查者。'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('edit-bible-charactersBlueprint')),
      findsNothing,
    );

    await tester.tap(find.text('总纲').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, '编辑'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('edit-bible-outlineMaster')),
      '失踪案引出港务处阴谋。',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-bible-outlineMaster')));
    await tester.pumpAndSettle();

    expect(fixture.repository.bible.outlineMasterMarkdown, '失踪案引出港务处阴谋。');
  });

  testWidgets('workshop reviews recovered asset draft before merge', (
    tester,
  ) async {
    final fixture = _WorkshopFixture();
    fixture.repository.assetRuns.add(
      _assetRun(
        id: 'asset-run-world',
        projectId: 'project-1',
        kind: AssetGenerationKind.worldBuilding,
        status: AssetGenerationStatus.succeeded,
        draftMarkdown: '# 新世界观\n\n七个港务家族共同控制雾港。',
      ),
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    await tester.tap(find.text('世界观设定').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, '查看草稿'));
    await tester.pumpAndSettle();

    expect(find.text('世界观设定草稿'), findsOneWidget);
    expect(find.textContaining('七个港务家族'), findsOneWidget);
    expect(find.text('应用草稿会合并到当前已保存内容，未出现在草稿中的部分会保留。'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '合并并应用'));
    await tester.pumpAndSettle();

    expect(
      fixture.repository.bible.worldBuildingMarkdown,
      '# 新世界观\n\n七个港务家族共同控制雾港。',
    );
    expect(
      fixture.repository.assetRuns.single.status,
      AssetGenerationStatus.applied,
    );
  });

  testWidgets('outline asset generation button ignores rapid repeated taps', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(withDefaultVolume: false);
    fixture.assetPipeline.pauseGeneration = true;
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    await tester.tap(find.text('分卷与章节细纲').last);
    await tester.pumpAndSettle();

    final button = find.byKey(
      const ValueKey('generate-asset-outlineDetailYaml'),
    );
    await tester.tap(button);
    await tester.tap(button, warnIfMissed: false);
    await tester.pump();

    expect(fixture.assetPipeline.generateCalls, 1);
    expect(find.text('生成中'), findsOneWidget);
    expect(tester.widget<OutlinedButton>(button).onPressed, isNull);

    fixture.assetPipeline.completePausedGeneration();
    await tester.pump();
    await tester.pump();
    if (find.text('分卷规划草稿').evaluate().isNotEmpty) {
      await tester.tap(find.text('取消'));
      await tester.pump();
    }
  });

  testWidgets(
    'volume blueprint and outline detail use separate generation kinds',
    (tester) async {
      final fixture = _WorkshopFixture();
      addTearDown(fixture.dispose);

      await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
      await tester.pumpAndSettle();

      await tester.tap(find.text('分卷与章节细纲').last);
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('generate-asset-outlineDetailYaml')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();

      expect(fixture.assetPipeline.generateCalls, 1);
      expect(
        fixture.repository.assetRuns.single.kind,
        AssetGenerationKind.volumeBlueprintYaml,
      );
      expect(find.text('分卷规划草稿'), findsOneWidget);
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      final generateVolumeDetailButton = find.byTooltip('生成本卷细纲');
      await tester.ensureVisible(generateVolumeDetailButton);
      await tester.pumpAndSettle();
      await tester.tap(generateVolumeDetailButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();

      expect(fixture.assetPipeline.generateCalls, 2);
      expect(
        fixture.repository.assetRuns.last.kind,
        AssetGenerationKind.outlineDetailYaml,
      );
      expect(find.text('第一卷章节细纲草稿'), findsOneWidget);
    },
  );

  testWidgets('empty runtime memory is neutral in overview and prompt stack', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(runtimeMemory: const RuntimeMemoryState());
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    expect(find.text('运行时记忆为空'), findsNothing);
    expect(find.text('待完善'), findsNothing);

    await tester.ensureVisible(find.text('Runtime Memory').last);
    await tester.tap(find.text('Runtime Memory').last);
    await tester.pumpAndSettle();

    expect(find.text('运行时记忆尚未建立'), findsOneWidget);

    await tester.ensureVisible(find.text('Prompt 栈').last);
    await tester.tap(find.text('Prompt 栈').last);
    await tester.pumpAndSettle();

    expect(find.text('暂无运行时记忆，生成时会自动跳过'), findsOneWidget);
    expect(find.text('可选'), findsOneWidget);
  });

  testWidgets('overview shows compact runtime memory summary only', (
    tester,
  ) async {
    const hiddenThreadDetail =
        '未解决的秘密监控线索只应在详情页完整展示，刘建国的保密风险、家长追责、学校压力和行动监控都必须保留。';
    final fixture = _WorkshopFixture(
      runtimeMemory: const RuntimeMemoryState(
        runtimeState: '青岚庄家住宅内，诊断书仍由刘建国保管。',
        runtimeThreads: hiddenThreadDetail,
        storySummary: '庄子昂决定隐瞒病情。',
        continuityIndex: '保密状态必须延续。',
        chapterArchiveMarkdown: '## 第一章\n\n诊断书出现。',
      ),
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    expect(find.text('已记录 5/5 项'), findsOneWidget);
    expect(find.text('查看详情'), findsOneWidget);
    expect(find.textContaining('青岚庄家住宅内'), findsOneWidget);
    expect(find.textContaining('未解决的秘密监控线索'), findsNothing);

    await tester.ensureVisible(find.widgetWithText(TextButton, '查看详情'));
    await tester.tap(find.widgetWithText(TextButton, '查看详情'));
    await tester.pumpAndSettle();

    expect(find.text('记忆检查表'), findsOneWidget);
    expect(find.text(hiddenThreadDetail), findsNothing);

    await tester.tap(find.text('剧情线索'));
    await tester.pumpAndSettle();

    expect(find.text(hiddenThreadDetail), findsOneWidget);
  });

  testWidgets('runtime memory tab edits layered continuity fields', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      runtimeMemory: const RuntimeMemoryState(
        runtimeState: '旧状态。',
        runtimeThreads: '旧线索。',
        storySummary: '旧摘要。',
        continuityIndex: '旧索引。',
        chapterArchiveMarkdown: '旧归档。',
      ),
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Runtime Memory').last);
    await tester.tap(find.text('Runtime Memory').last);
    await tester.pumpAndSettle();

    expect(find.text('连续性索引'), findsOneWidget);
    expect(find.text('章节归档'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, '编辑'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, '记录连续性索引...'),
      '新索引。',
    );
    await tester.enterText(find.widgetWithText(TextField, '记录章节归档...'), '新归档。');
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(0, 600),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.widgetWithText(FilledButton, '保存'));
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();

    expect(fixture.repository.memory.state.continuityIndex, '新索引。');
    expect(fixture.repository.memory.state.chapterArchiveMarkdown, '新归档。');
  });

  testWidgets('runtime memory tab refreshes after applying memory patch', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      runtimeMemory: const RuntimeMemoryState(storySummary: '旧摘要。'),
      chapters: [
        _chapter(
          planId: 'plan-1',
          index: 1,
          content: '正文。',
          memorySyncStatus: MemorySyncStatus.pendingReview,
          proposedMemory: const RuntimeMemoryState(
            runtimeState: '新状态。',
            runtimeThreads: '新线索。',
            storySummary: '新摘要。',
            continuityIndex: '新索引。',
            chapterArchiveMarkdown: '新归档。',
          ),
          memorySyncPatchYaml: '''
runtimeMemory:
  storySummary: 新摘要。
''',
        ),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Runtime Memory').last);
    await tester.tap(find.text('Runtime Memory').last);
    await tester.pumpAndSettle();

    expect(find.text('待审阅记忆 Patch'), findsOneWidget);
    expect(find.text('旧摘要。'), findsOneWidget);
    expect(find.text('diff -- runtimeMemory/storySummary'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(FilledButton, '应用 Patch'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '应用 Patch'));
    await tester.pumpAndSettle();

    expect(fixture.repository.memory.state.storySummary, '新摘要。');
    expect(find.text('记忆 Patch 已应用。'), findsOneWidget);
    expect(find.text('待审阅记忆 Patch'), findsNothing);
    expect(find.text('旧摘要。'), findsNothing);
    expect(find.text('新摘要。'), findsWidgets);
  });

  testWidgets('pending memory patch shows partitioned diff preview', (
    tester,
  ) async {
    const rawPatch = '''
```yaml
runtimeMemory:
  storySummary: 新摘要。
  chapterArchiveMarkdown: 新归档。
characters:
  - name: 林岚
    currentStatus: 发现港务处新线索。
  - name: 周既明
    role: 线人
    currentStatus: 暗中协助调查。
relationships:
  - from: 林岚
    to: 周既明
    type: 合作
    strength: 3
    status: 初步互信
    description: 周既明向林岚交出港务处线索。
```
''';
    final fixture = _WorkshopFixture(
      runtimeMemory: const RuntimeMemoryState(
        storySummary: '旧摘要。',
        chapterArchiveMarkdown: '旧归档。',
      ),
      characters: [
        NovelCharacter(
          id: 'character-1',
          projectId: 'project-1',
          name: '林岚',
          aliases: '',
          tags: '',
          faction: '调查局',
          role: '调查者',
          longTermGoal: '查明失踪案。',
          currentStatus: '抵达雾港。',
          secrets: '',
          firstChapterIndex: 1,
          lastChapterIndex: null,
          createdAt: _testCreatedAt,
          updatedAt: _testUpdatedAt,
        ),
        NovelCharacter(
          id: 'character-2',
          projectId: 'project-1',
          name: '周既明',
          aliases: '',
          tags: '',
          faction: '港务处',
          role: '线人',
          longTermGoal: '保住自己的身份。',
          currentStatus: '尚未接触林岚。',
          secrets: '',
          firstChapterIndex: 1,
          lastChapterIndex: null,
          createdAt: _testCreatedAt,
          updatedAt: _testUpdatedAt,
        ),
      ],
      relationships: [
        NovelRelationship(
          id: 'relationship-1',
          projectId: 'project-1',
          fromCharacterId: 'character-1',
          toCharacterId: 'character-2',
          relationshipType: '试探',
          strength: 1,
          status: '互相怀疑',
          description: '林岚尚未确认周既明立场。',
          lastChangedChapterIndex: 1,
          createdAt: _testCreatedAt,
          updatedAt: _testUpdatedAt,
        ),
      ],
      chapters: [
        _chapter(
          planId: 'plan-1',
          index: 1,
          content: '正文。',
          memorySyncStatus: MemorySyncStatus.pendingReview,
          proposedMemory: const RuntimeMemoryState(
            storySummary: '新摘要。',
            chapterArchiveMarkdown: '新归档。',
          ),
          memorySyncPatchYaml: rawPatch,
        ),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Runtime Memory').last);
    await tester.tap(find.text('Runtime Memory').last);
    await tester.pumpAndSettle();

    expect(find.text('Runtime Memory'), findsWidgets);
    expect(find.text('Characters'), findsOneWidget);
    expect(find.text('Relationships'), findsOneWidget);
    expect(find.text('diff -- runtimeMemory/storySummary'), findsOneWidget);
    expect(find.text('diff -- characters/林岚'), findsOneWidget);
    expect(find.text('diff -- characters/周既明'), findsOneWidget);
    expect(find.text('diff -- relationships/林岚 -> 周既明'), findsOneWidget);
    expect(find.textContaining('+新归档。'), findsOneWidget);
    expect(find.text('Raw YAML'), findsOneWidget);
    expect(find.textContaining('runtimeMemory:'), findsNothing);
    expect(find.textContaining('无法解析 Patch YAML'), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
    expect(find.widgetWithText(FilledButton, '应用 Patch'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '丢弃 Patch'), findsOneWidget);

    await tester.ensureVisible(find.text('Raw YAML'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Raw YAML'));
    await tester.pumpAndSettle();

    expect(find.textContaining('runtimeMemory:'), findsOneWidget);
    expect(find.textContaining('characters:'), findsOneWidget);
    expect(find.textContaining('relationships:'), findsOneWidget);
    expect(find.textContaining('```yaml'), findsNothing);
  });

  testWidgets('runtime memory tab discards pending memory patch', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      runtimeMemory: const RuntimeMemoryState(storySummary: '旧摘要。'),
      chapters: [
        _chapter(
          planId: 'plan-1',
          index: 1,
          content: '正文。',
          memorySyncStatus: MemorySyncStatus.pendingReview,
          proposedMemory: const RuntimeMemoryState(storySummary: '错误摘要。'),
          memorySyncPatchYaml: '''
runtimeMemory:
  storySummary: 错误摘要。
''',
        ),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Runtime Memory').last);
    await tester.tap(find.text('Runtime Memory').last);
    await tester.pumpAndSettle();

    expect(find.text('待审阅记忆 Patch'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '应用 Patch'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '丢弃 Patch'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(OutlinedButton, '丢弃 Patch'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, '丢弃 Patch'));
    await tester.pumpAndSettle();

    expect(fixture.repository.memory.state.storySummary, '旧摘要。');
    expect(
      fixture.repository.chapters.single.memorySyncStatus,
      MemorySyncStatus.discarded,
    );
    expect(find.text('记忆 Patch 已丢弃。'), findsOneWidget);
    expect(find.text('待审阅记忆 Patch'), findsNothing);
    expect(find.text('旧摘要。'), findsWidgets);
    expect(find.text('错误摘要。'), findsNothing);
  });

  testWidgets(
    'pending memory patch tolerates malformed raw yaml by showing parse error',
    (tester) async {
      final fixture = _WorkshopFixture(
        runtimeMemory: const RuntimeMemoryState(storySummary: '旧摘要。'),
        chapters: [
          _chapter(
            planId: 'plan-1',
            index: 1,
            content: '正文。',
            memorySyncStatus: MemorySyncStatus.pendingReview,
            proposedMemory: const RuntimeMemoryState(storySummary: '新摘要。'),
            memorySyncPatchYaml: '''
runtimeMemory:
  storySummary: 新摘要。
  chapterArchiveMarkdown:
    [not valid
characters:
  - name: 林岚
    currentStatus: 发现港务处新线索。
''',
          ),
        ],
      );
      addTearDown(fixture.dispose);

      await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Runtime Memory').last);
      await tester.tap(find.text('Runtime Memory').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('Patch YAML 解析失败'), findsOneWidget);
      expect(find.text('Raw YAML'), findsOneWidget);
      await tester.ensureVisible(find.text('Raw YAML'));
      await tester.tap(find.text('Raw YAML'));
      await tester.pumpAndSettle();
      expect(find.textContaining('runtimeMemory:'), findsWidgets);
      expect(find.textContaining('characters:'), findsOneWidget);
    },
  );

  testWidgets(
    'chapter tile distinguishes discarded from no-change patch state',
    (tester) async {
      final fixture = _WorkshopFixture(
        plans: [
          _plan(id: 'plan-1', index: 1, title: '第一章', objective: '推进调查。'),
          _plan(id: 'plan-2', index: 2, title: '第二章', objective: '追查线索。'),
        ],
        chapters: [
          _chapter(
            id: 'chapter-1',
            planId: 'plan-1',
            index: 1,
            title: '第一章',
            content: '正文一。',
            memorySyncStatus: MemorySyncStatus.discarded,
          ),
          _chapter(
            id: 'chapter-2',
            planId: 'plan-2',
            index: 2,
            title: '第二章',
            content: '正文二。',
            memorySyncStatus: MemorySyncStatus.noChange,
          ),
        ],
      );
      addTearDown(fixture.dispose);

      await tester.pumpWidget(
        _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
      );
      await tester.pumpAndSettle();

      expect(find.text('Patch 已丢弃'), findsOneWidget);
      expect(find.text('记忆无变化'), findsOneWidget);
    },
  );

  testWidgets('optional prompt assets do not show warning block', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(bindPromptAssets: false);
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    expect(find.text('风格上下文，控制叙事语气与措辞'), findsOneWidget);
    expect(find.text('情节引擎，驱动章节结构与节奏'), findsOneWidget);
    expect(find.text('待完善'), findsNWidgets(2));

    await tester.ensureVisible(find.text('Prompt 栈').last);
    await tester.tap(find.text('Prompt 栈').last);
    await tester.pumpAndSettle();

    expect(find.text('Warnings'), findsNothing);
    expect(find.text('未绑定 Style Profile，生成时会自动跳过'), findsOneWidget);
    expect(find.text('未绑定 Plot Profile，生成时会自动跳过'), findsOneWidget);
  });

  testWidgets('character graph opens switches and closes character detail', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      characters: [
        NovelCharacter(
          id: 'character-1',
          projectId: 'project-1',
          name: '林岚',
          aliases: '',
          tags: '',
          faction: '调查局',
          role: '调查者',
          longTermGoal: '查明失踪案。',
          currentStatus: '抵达雾港。',
          secrets: '',
          firstChapterIndex: 1,
          lastChapterIndex: null,
          createdAt: _testCreatedAt,
          updatedAt: _testUpdatedAt,
        ),
        NovelCharacter(
          id: 'character-2',
          projectId: 'project-1',
          name: '周既明',
          aliases: '',
          tags: '',
          faction: '港务处',
          role: '线人',
          longTermGoal: '保住自己的身份。',
          currentStatus: '暗中协助调查。',
          secrets: '',
          firstChapterIndex: 1,
          lastChapterIndex: null,
          createdAt: _testCreatedAt,
          updatedAt: _testUpdatedAt,
        ),
      ],
      relationships: [
        NovelRelationship(
          id: 'relationship-1',
          projectId: 'project-1',
          fromCharacterId: 'character-1',
          toCharacterId: 'character-2',
          relationshipType: '合作',
          strength: 7,
          status: '互相试探',
          description: '林岚通过周既明接触港务处线索。',
          lastChangedChapterIndex: 1,
          createdAt: _testCreatedAt,
          updatedAt: _testUpdatedAt,
        ),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    await tester.tap(find.text('角色索引与关系网').last);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(OutlinedButton, '编辑角色'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('relationship-node-character-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('relationship-node-character-2')),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(OutlinedButton, '编辑角色'));
    await tester.pumpAndSettle();

    expect(find.text('林岚'), findsWidgets);
    expect(find.byTooltip('编辑'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final secondNode = find.byKey(
      const ValueKey('relationship-node-character-2'),
    );
    await tester.ensureVisible(secondNode);
    await tester.pumpAndSettle();
    await tester.tap(secondNode);
    await tester.pumpAndSettle();

    expect(find.text('周既明'), findsWidgets);
    expect(find.text('暗中协助调查。'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final closeButton = find.byTooltip('关闭');
    await tester.ensureVisible(closeButton);
    await tester.pumpAndSettle();
    await tester.tap(closeButton);
    await tester.pumpAndSettle();

    expect(find.text('暗中协助调查。'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editor loads from workshop sub-route', (tester) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    await tester.tap(find.text('进入编辑器'));
    await tester.pumpAndSettle();

    expect(find.text('章节'), findsOneWidget);
    expect(find.byKey(const ValueKey('novel-workshop-editor')), findsOneWidget);
  });

  testWidgets('editor back button navigates to workshop', (tester) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
    );
    await tester.pumpAndSettle();

    expect(find.text('章节'), findsOneWidget);

    await tester.tap(find.byTooltip('返回工作台'));
    await tester.pumpAndSettle();

    expect(find.text('项目工作台'), findsOneWidget);
  });

  testWidgets('reader defaults to immersive reading without review panel', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
      chapters: [
        _chapter(
          planId: 'plan-1',
          index: 1,
          content: '林岚穿过潮湿的码头。\n\n海雾把旧灯塔吞没，只剩蓝白色的光在水面晃动。',
        ),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _readerLocation),
    );
    await tester.pumpAndSettle();

    expect(find.text('雾港纪事'), findsOneWidget);
    expect(find.text('林岚穿过潮湿的码头。'), findsOneWidget);
    expect(find.text('海雾把旧灯塔吞没，只剩蓝白色的光在水面晃动。'), findsOneWidget);
    expect(find.text('插图审阅'), findsNothing);
    expect(find.text('当前章轻审核'), findsOneWidget);
    expect(find.text('生成插图'), findsNothing);
    expect(find.byType(SelectionArea), findsOneWidget);
  });

  testWidgets('reader opens chapter drawer and switches chapters', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
        _plan(id: 'plan-2', index: 2, title: '第二章', objective: '主角追查线索。'),
      ],
      chapters: [
        _chapter(
          id: 'chapter-1',
          planId: 'plan-1',
          index: 1,
          title: '第一章',
          content: '第一章正文。',
        ),
        _chapter(
          id: 'chapter-2',
          planId: 'plan-2',
          index: 2,
          title: '第二章',
          content: '第二章正文。',
        ),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _readerLocation),
    );
    await tester.pumpAndSettle();

    expect(find.text('第一章正文。'), findsOneWidget);
    expect(find.text('目录'), findsNothing);

    await tester.tap(find.byTooltip('目录'));
    await tester.pumpAndSettle();

    expect(find.text('目录'), findsOneWidget);
    await tester.tap(find.textContaining('第二章').last);
    await tester.pumpAndSettle();

    expect(find.text('第二章正文。'), findsOneWidget);
    expect(find.text('第一章正文。'), findsNothing);
  });

  testWidgets('reader shows current chapter draft illustration review rail', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
      chapters: [
        _chapter(
          id: 'chapter-1',
          planId: 'plan-1',
          index: 1,
          content: '林岚站在旧灯塔前。',
        ),
      ],
    );
    fixture.repository.illustrations.add(
      _illustration(
        id: 'draft-1',
        chapterId: 'chapter-1',
        paragraphIndex: 0,
        selectedText: '旧灯塔前',
        prompt: '旧灯塔与海雾。',
        status: ChapterIllustrationStatus.draft,
      ),
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _readerLocation),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前章轻审核'), findsOneWidget);
    expect(find.text('待确认 1'), findsOneWidget);
    expect(find.text('旧灯塔与海雾。'), findsOneWidget);
    expect(find.text('插入正文'), findsOneWidget);
  });

  testWidgets('reader can hide and restore chapter illustration review rail', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
      chapters: [
        _chapter(
          id: 'chapter-1',
          planId: 'plan-1',
          index: 1,
          content: '林岚站在旧灯塔前。',
        ),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _readerLocation),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前章轻审核'), findsOneWidget);
    expect(find.text('林岚站在旧灯塔前。'), findsOneWidget);

    await tester.tap(find.byTooltip('收起插图审核'));
    await tester.pumpAndSettle();

    expect(find.text('当前章轻审核'), findsNothing);
    expect(find.text('林岚站在旧灯塔前。'), findsOneWidget);
    expect(find.byTooltip('展开插图审核'), findsOneWidget);

    await tester.tap(find.byTooltip('展开插图审核'));
    await tester.pumpAndSettle();

    expect(find.text('当前章轻审核'), findsOneWidget);
  });

  testWidgets(
    'reader renders inserted illustrations and can remove them from text',
    (tester) async {
      final fixture = _WorkshopFixture(
        plans: [
          _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
        ],
        chapters: [
          _chapter(
            id: 'chapter-1',
            planId: 'plan-1',
            index: 1,
            content: '林岚站在旧灯塔前。',
          ),
        ],
      );
      fixture.repository.illustrations.add(
        _illustration(
          id: 'accepted-1',
          chapterId: 'chapter-1',
          paragraphIndex: 0,
          selectedText: '已插入的旧灯塔插图锚点',
          prompt: '正文内插图。',
          status: ChapterIllustrationStatus.inserted,
        ),
      );
      addTearDown(fixture.dispose);

      await tester.pumpWidget(
        _WorkshopTestApp(fixture: fixture, initialLocation: _readerLocation),
      );
      await tester.pumpAndSettle();

      expect(find.text('已插入的旧灯塔插图锚点'), findsWidgets);
      expect(find.text('正文内插图。'), findsOneWidget);
      expect(find.text('移出正文'), findsWidgets);

      await tester.ensureVisible(find.text('移出正文').first);
      await tester.tap(find.text('移出正文').first);
      await tester.pumpAndSettle();

      expect(find.text('已插入的旧灯塔插图锚点'), findsNothing);
      expect(
        fixture.repository.illustrations.single.status,
        ChapterIllustrationStatus.unused,
      );
    },
  );

  testWidgets('illustration library filters and manages chapter items', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
        _plan(id: 'plan-2', index: 2, title: '第二章', objective: '调查港务处。'),
      ],
      chapters: [
        _chapter(
          id: 'chapter-1',
          planId: 'plan-1',
          index: 1,
          content: '林岚站在旧灯塔前。',
        ),
        _chapter(
          id: 'chapter-2',
          planId: 'plan-2',
          index: 2,
          content: '她翻看港务处卷宗。',
        ),
      ],
      illustrations: [
        _illustration(
          id: 'draft-1',
          chapterId: 'chapter-1',
          paragraphIndex: 0,
          selectedText: '旧灯塔前',
          prompt: '海雾里的旧灯塔。',
          status: ChapterIllustrationStatus.draft,
        ),
        _illustration(
          id: 'inserted-1',
          chapterId: 'chapter-1',
          paragraphIndex: 0,
          selectedText: '林岚站在旧灯塔前',
          prompt: '已经插入正文的灯塔图。',
          status: ChapterIllustrationStatus.inserted,
        ),
        _illustration(
          id: 'unused-1',
          chapterId: 'chapter-2',
          paragraphIndex: 0,
          selectedText: '港务处卷宗',
          prompt: '港务处档案室。',
          status: ChapterIllustrationStatus.unused,
          planId: 'plan-2',
        ),
      ],
      illustrationRuns: [
        _illustrationRun(
          id: 'failed-run-1',
          chapterId: 'chapter-1',
          planId: 'plan-1',
          prompt: '失败的海雾远景。',
          selectedText: '海雾',
          status: ChapterIllustrationGenerationStatus.failed,
          errorMessage: '模型返回空图。',
        ),
        _illustrationRun(
          id: 'running-run-1',
          chapterId: 'chapter-2',
          planId: 'plan-2',
          prompt: '运行中的卷宗图。',
          selectedText: '卷宗',
          status: ChapterIllustrationGenerationStatus.running,
        ),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(
        fixture: fixture,
        initialLocation:
            '/projects/project-1/workshop/illustrations?plan=plan-1',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('项目插图库'), findsOneWidget);
    expect(find.text('第一章 审核队列'), findsOneWidget);
    expect(find.text('海雾里的旧灯塔。'), findsWidgets);
    expect(find.text('港务处档案室。'), findsNothing);
    expect(find.text('失败的海雾远景。'), findsOneWidget);
    expect(
      tester.widgetList<Image>(find.byType(Image)).map((image) => image.fit),
      isNot(contains(BoxFit.cover)),
    );
    await tester.tap(find.byTooltip('预览插图').first);
    await tester.pumpAndSettle();

    expect(find.byTooltip('关闭预览'), findsOneWidget);

    await tester.tap(find.byTooltip('关闭预览'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.ancestor(of: find.text('失败'), matching: find.byType(InkWell)).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('失败的海雾远景。'), findsOneWidget);
    expect(find.text('海雾里的旧灯塔。'), findsNothing);
    expect(find.text('重试'), findsOneWidget);
    expect(find.byTooltip('删除失败任务'), findsOneWidget);

    await tester.tap(
      find.ancestor(of: find.text('已插入'), matching: find.byType(InkWell)).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('已经插入正文的灯塔图。'), findsWidgets);
    expect(find.text('移出正文'), findsOneWidget);

    await tester.tap(
      find
          .ancestor(of: find.text('全部章节'), matching: find.byType(InkWell))
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.ancestor(of: find.text('未插入'), matching: find.byType(InkWell)).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('港务处档案室。'), findsWidgets);
    expect(find.text('插入正文'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '档案室');
    await tester.pumpAndSettle();

    expect(find.text('港务处档案室。'), findsWidgets);
    expect(find.text('海雾里的旧灯塔。'), findsNothing);

    await tester.tap(find.text('插入正文').first);
    await tester.pumpAndSettle();

    expect(
      fixture.repository.illustrations
          .singleWhere((illustration) => illustration.id == 'unused-1')
          .status,
      ChapterIllustrationStatus.inserted,
    );
  });

  testWidgets('illustration library compact layout avoids overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
      chapters: [
        _chapter(
          id: 'chapter-1',
          planId: 'plan-1',
          index: 1,
          content: '林岚站在旧灯塔前。',
        ),
      ],
      illustrations: [
        _illustration(
          id: 'draft-compact',
          chapterId: 'chapter-1',
          paragraphIndex: 0,
          selectedText: '旧灯塔前',
          prompt: '海雾里的旧灯塔。',
          status: ChapterIllustrationStatus.draft,
        ),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(
        fixture: fixture,
        initialLocation:
            '/projects/project-1/workshop/illustrations?plan=plan-1',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('项目插图库'), findsOneWidget);
    expect(find.text('章节与状态'), findsOneWidget);
    expect(find.text('第一章 审核队列'), findsOneWidget);
    expect(find.text('详情检查器'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reader selection toolbar offers illustration generation', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
      chapters: [_chapter(planId: 'plan-1', index: 1, content: '旧灯塔')],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _readerLocation),
    );
    await tester.pumpAndSettle();

    expect(find.text('生成插图'), findsNothing);

    await tester.longPress(find.text('旧灯塔'));
    await tester.pumpAndSettle();

    expect(find.text('生成插图'), findsOneWidget);

    await tester.tap(find.text('生成插图'));
    await tester.pumpAndSettle();

    expect(find.text('生成章节插图'), findsOneWidget);
    expect(find.widgetWithText(TextField, '提示词'), findsOneWidget);
  });

  testWidgets('reader auto optimizes illustration prompt before dialog', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-2', index: 2, title: '第二章', objective: '主角进入雾港。'),
      ],
      chapters: [
        _chapter(
          id: 'chapter-1',
          planId: 'plan-1',
          index: 1,
          title: '第一章',
          content: '前一章写雾港街道仍有煤气灯。',
        ),
        _chapter(
          id: 'chapter-2',
          planId: 'plan-2',
          index: 2,
          title: '第二章',
          content: '旧灯塔映着海雾。',
        ),
        _chapter(
          id: 'chapter-3',
          planId: 'plan-3',
          index: 3,
          title: '第三章',
          content: '后一章写钟声穿过潮湿码头。',
        ),
      ],
    );
    final promptGate = Completer<void>();
    fixture.promptLlmClient.responseGate = promptGate;
    fixture.promptLlmClient.responses.add('''
Positive Prompt:
an old lighthouse glowing through sea fog, quiet tense atmosphere

Negative Constraints:
text, watermark, unrelated objects, extra characters

Visual Notes:
Focus on the lighthouse silhouette.
''');
    fixture.promptLlmClient.responses.add('''
Positive Prompt:
a sharper old lighthouse silhouette above rolling sea fog

Negative Constraints:
text, watermark, unrelated objects, extra characters

Visual Notes:
Focus on the brighter beacon.
''');
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _readerLocation),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('旧灯塔映着海雾。'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('生成插图'));
    await tester.pump();

    expect(find.text('正在优化 Prompt...'), findsOneWidget);
    expect(find.text('生成章节插图'), findsNothing);
    expect(fixture.repository.illustrationRuns, isEmpty);

    promptGate.complete();
    await tester.pumpAndSettle();

    expect(find.text('生成章节插图'), findsOneWidget);
    expect(find.textContaining('an old lighthouse glowing'), findsOneWidget);
    expect(fixture.repository.illustrationRuns, isEmpty);
    expect(
      fixture.promptLlmClient.lastRequest!.messages.last.content,
      contains('### Previous chapter [1] 第一章'),
    );
    expect(
      fixture.promptLlmClient.lastRequest!.messages.last.content,
      contains('前一章写雾港街道仍有煤气灯。'),
    );
    expect(
      fixture.promptLlmClient.lastRequest!.messages.last.content,
      contains('### Current chapter [2] 第二章'),
    );
    expect(
      fixture.promptLlmClient.lastRequest!.messages.last.content,
      contains('### Next chapter [3] 第三章'),
    );
    expect(
      fixture.promptLlmClient.lastRequest!.messages.last.content,
      contains('后一章写钟声穿过潮湿码头。'),
    );

    await tester.tap(find.widgetWithText(TextButton, '重新优化'));
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(
      find.textContaining('a sharper old lighthouse silhouette'),
      findsOneWidget,
    );
    expect(fixture.repository.illustrationRuns, isEmpty);

    final createTaskButton = find.widgetWithText(FilledButton, '创建任务');
    await tester.ensureVisible(createTaskButton);
    await tester.tap(createTaskButton);
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    expect(fixture.repository.illustrationRuns, hasLength(1));
    expect(
      fixture.repository.illustrationRuns.single.prompt,
      contains('a sharper old lighthouse silhouette above rolling sea fog'),
    );
    expect(
      fixture.repository.illustrationRuns.single.prompt,
      isNot(contains('Avoid:')),
    );
  });

  testWidgets('reader prompt optimization failure keeps manual fallback', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
      chapters: [_chapter(planId: 'plan-1', index: 1, content: '旧灯塔')],
    );
    fixture.promptLlmClient.error = StateError('LLM offline');
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _readerLocation),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('旧灯塔'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('生成插图'));
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(find.text('生成章节插图'), findsOneWidget);
    expect(find.textContaining('Prompt 优化失败'), findsOneWidget);
    expect(find.textContaining('优化失败：'), findsOneWidget);

    final createTaskButton = find.widgetWithText(FilledButton, '创建任务');
    await tester.ensureVisible(createTaskButton);
    await tester.tap(createTaskButton);
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    expect(fixture.repository.illustrationRuns, hasLength(1));
    expect(
      fixture.repository.illustrationRuns.single.prompt,
      fixture.repository.illustrationRuns.single.selectedText,
    );
  });

  testWidgets('reader selection generation explains missing image provider', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
      chapters: [_chapter(planId: 'plan-1', index: 1, content: '旧灯塔')],
    );
    fixture.imageProviderRepository.setEnabled(false);
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _readerLocation),
    );
    await tester.pumpAndSettle();

    expect(find.text('生成插图'), findsNothing);

    await tester.longPress(find.text('旧灯塔'));
    await tester.pumpAndSettle();

    expect(find.text('生成插图'), findsOneWidget);

    await tester.tap(find.text('生成插图'));
    await tester.pumpAndSettle();

    expect(find.text('请先在设置中启用图像 Provider。'), findsOneWidget);
    expect(find.widgetWithText(AlertDialog, '生成插图'), findsNothing);
  });

  testWidgets(
    'reader can generate illustration from multi-paragraph selection',
    (tester) async {
      const firstParagraph = '第一段有海雾与灯塔。';
      const secondParagraph = '第二段写少女走进蓝门。';
      final fixture = _WorkshopFixture(
        plans: [
          _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
        ],
        chapters: [
          _chapter(
            id: 'chapter-1',
            planId: 'plan-1',
            index: 1,
            content: '$firstParagraph\n\n$secondParagraph\n\n第三段没有选择。',
          ),
        ],
      );
      addTearDown(fixture.dispose);

      await tester.pumpWidget(
        _WorkshopTestApp(fixture: fixture, initialLocation: _readerLocation),
      );
      await tester.pumpAndSettle();

      final firstRenderParagraph = _renderParagraph(tester, firstParagraph);
      final secondRenderParagraph = _renderParagraph(tester, secondParagraph);
      final gesture = await tester.startGesture(
        _textOffsetToPosition(firstRenderParagraph, 3),
        kind: PointerDeviceKind.touch,
      );
      addTearDown(gesture.removePointer);
      await tester.pump(const Duration(milliseconds: 500));
      await gesture.moveTo(_textOffsetToPosition(secondRenderParagraph, 8));
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.text('生成插图'), findsOneWidget);

      await tester.tap(find.text('生成插图'));
      await tester.pumpAndSettle();

      expect(find.text('生成章节插图'), findsOneWidget);
      expect(find.textContaining('第二段写少'), findsWidgets);

      final createTaskButton = find.widgetWithText(FilledButton, '创建任务');
      await tester.ensureVisible(createTaskButton);
      await tester.pumpAndSettle();
      await tester.tap(createTaskButton);
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      expect(fixture.repository.illustrationRuns, hasLength(1));
      expect(fixture.repository.illustrationRuns.single.paragraphIndex, 1);
      expect(
        fixture.repository.illustrationRuns.single.selectedText,
        allOf(contains('海雾与灯塔'), contains('第二段写少')),
      );
    },
  );

  testWidgets('editing chapter plan keeps chapter index readonly', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('目标'));
    await tester.pumpAndSettle();

    final indexField = tester.widget<TextField>(
      find.descendant(
        of: find.widgetWithText(TextFormField, '第 1 章').first,
        matching: find.byType(TextField),
      ),
    );
    expect(indexField.readOnly, isTrue);
  });

  testWidgets('existing chapter generation asks for overwrite confirmation', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
      chapters: [_chapter(planId: 'plan-1', index: 1, content: '旧正文。')],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('生成'));
    await tester.pumpAndSettle();

    expect(find.text('覆盖已有正文'), findsOneWidget);

    await tester.tap(find.text('确认覆盖'));
    await tester.pumpAndSettle();

    expect(find.text('生成前上下文预览'), findsOneWidget);
    expect(fixture.pipeline.previewCalls, 1);
    expect(fixture.pipeline.generateCalls, 0);

    await tester.tap(find.text('确认生成'));
    await tester.pumpAndSettle();

    expect(fixture.pipeline.replaceExisting, isTrue);
    expect(fixture.pipeline.generateCalls, 1);
  });

  testWidgets('chapter generation preview can be cancelled before generation', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('生成'));
    await tester.pumpAndSettle();

    expect(find.text('生成前上下文预览'), findsOneWidget);
    expect(find.text('Project Bible'), findsOneWidget);
    expect(find.text('Characters'), findsOneWidget);
    expect(find.text('最终 Prompt Markdown'), findsOneWidget);
    expect(fixture.pipeline.previewCalls, 1);
    expect(fixture.pipeline.generateCalls, 0);

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(fixture.pipeline.generateCalls, 0);
  });

  testWidgets('chapter generation confirms after context preview', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
      bindPromptAssets: false,
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('生成'));
    await tester.pumpAndSettle();

    expect(find.text('生成前上下文预览'), findsOneWidget);
    expect(find.text('Voice Profile'), findsOneWidget);
    expect(find.text('Story Engine'), findsOneWidget);
    expect(find.textContaining('项目未绑定 Voice Profile'), findsOneWidget);

    await tester.tap(find.text('确认生成'));
    await tester.pumpAndSettle();

    expect(fixture.pipeline.previewCalls, 1);
    expect(fixture.pipeline.generateCalls, 1);
  });

  testWidgets('batch draft starts after selecting a continuous range', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
        _plan(id: 'plan-2', index: 2, title: '第二章', objective: '调查港务处。'),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('批量草稿'));
    await tester.pumpAndSettle();

    expect(find.text('选择同一卷内连续章节。启动前会预览首章上下文，范围内已有正文会阻断。'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<ChapterPlan>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('第二章').last);
    await tester.pumpAndSettle();
    expect(find.text('将生成 2 章：1, 2'), findsOneWidget);

    await tester.tap(find.text('预览首章上下文'));
    await tester.pumpAndSettle();
    expect(find.text('生成前上下文预览'), findsOneWidget);

    await tester.tap(find.text('确认生成'));
    await tester.pumpAndSettle();

    expect(fixture.pipeline.previewCalls, 1);
    expect(fixture.pipeline.batchCalls, 1);
    expect(fixture.repository.generationBatches.single.totalCount, 2);
  });

  testWidgets('terminal batch draft panel can be dismissed for session', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
      generationBatches: [
        _generationBatch(
          id: 'generation-batch-done',
          status: ChapterGenerationBatchStatus.succeeded,
          syncedCount: 1,
        ),
      ],
      generationBatchItems: [
        _generationBatchItem(
          id: 'generation-batch-item-done',
          batchId: 'generation-batch-done',
          planId: 'plan-1',
          status: ChapterGenerationBatchItemStatus.synced,
        ),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
    );
    await tester.pumpAndSettle();

    expect(find.text('批量草稿'), findsWidgets);
    expect(find.text('已完成'), findsWidgets);
    expect(find.text('查看工作流任务'), findsOneWidget);
    expect(find.byTooltip('关闭批量草稿状态'), findsOneWidget);

    await tester.tap(find.byTooltip('关闭批量草稿状态'));
    await tester.pumpAndSettle();

    expect(find.text('查看工作流任务'), findsNothing);
    expect(find.byTooltip('关闭批量草稿状态'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, '批量草稿'), findsOneWidget);

    await tester.tap(find.byTooltip('返回工作台'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('进入编辑器').first);
    await tester.pumpAndSettle();

    expect(find.text('查看工作流任务'), findsNothing);
    expect(find.byTooltip('关闭批量草稿状态'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, '批量草稿'), findsOneWidget);

    await fixture.repository.createChapterGenerationBatch(
      const ChapterGenerationBatchInput(
        projectId: 'project-1',
        chapterPlanIds: ['plan-1'],
        providerId: 'provider-1',
        modelName: 'model-1',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('等待中'), findsWidgets);
    expect(find.byTooltip('停止批次'), findsWidgets);
  });

  testWidgets('dirty editor asks before switching chapters and can save', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
        _plan(id: 'plan-2', index: 2, title: '第二章', objective: '主角追查线索。'),
      ],
      chapters: [_chapter(planId: 'plan-1', index: 1, content: '旧正文。')],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('novel-workshop-editor')),
      '修改后的正文。',
    );
    await tester.tap(find.textContaining('第二章').first);
    await tester.pumpAndSettle();

    expect(find.text('正文尚未保存'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();

    expect(
      fixture.repository.chapters
          .singleWhere((chapter) => chapter.chapterPlanId == 'plan-1')
          .contentMarkdown,
      '修改后的正文。',
    );
    expect(find.text('第二章'), findsWidgets);
  });

  testWidgets(
    'running generation disables selected chapter save and generate',
    (tester) async {
      final fixture = _WorkshopFixture(
        plans: [
          _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
        ],
        runs: [_run(planId: 'plan-1', status: ChapterGenerationStatus.running)],
      );
      addTearDown(fixture.dispose);

      await tester.pumpWidget(
        _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        tester
            .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, '保存'))
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, '生成'))
            .onPressed,
        isNull,
      );
      expect(find.text('生成中'), findsOneWidget);
    },
  );

  testWidgets('run summary links to workflow detail route', (tester) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
      runs: [
        _run(
          id: 'run-1',
          workflowTaskId: 'task-1',
          planId: 'plan-1',
          status: ChapterGenerationStatus.succeeded,
        ),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('显示诊断面板'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Prompt Trace'));
    await tester.tap(find.text('Prompt Trace'));
    await tester.pumpAndSettle();

    expect(find.text('workflow:task-1'), findsOneWidget);
  });

  testWidgets('editor shows warning audit and can continue memory sync', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
      chapters: [
        _chapter(
          planId: 'plan-1',
          index: 1,
          content: '正文。',
          continuityVerdict: ContinuityVerdict.warning,
          continuityReportMarkdown: '# 连续性审计报告\n\n目标完成偏弱。',
        ),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
    );
    await tester.pumpAndSettle();

    expect(find.text('审计 warning'), findsWidgets);

    await tester.tap(find.byTooltip('显示诊断面板'));
    await tester.pumpAndSettle();

    expect(find.text('连续性审计'), findsOneWidget);
    expect(find.textContaining('目标完成偏弱'), findsOneWidget);

    await tester.ensureVisible(find.text('继续同步记忆'));
    await tester.tap(find.text('继续同步记忆'));
    await tester.pumpAndSettle();

    expect(
      fixture.repository.chapters.single.memorySyncStatus,
      MemorySyncStatus.pendingReview,
    );
  });

  testWidgets(
    'failed audit run shows draft and report without completed chapter',
    (tester) async {
      final fixture = _WorkshopFixture(
        plans: [
          _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
        ],
        runs: [
          _run(
            planId: 'plan-1',
            status: ChapterGenerationStatus.failed,
            draftMarkdown: '失败草稿。',
            continuityVerdict: ContinuityVerdict.fail,
            continuityReportMarkdown: '# 连续性审计报告\n\n世界规则被违反。',
          ),
        ],
      );
      addTearDown(fixture.dispose);

      await tester.pumpWidget(
        _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
      );
      await tester.pumpAndSettle();

      expect(find.text('已成文'), findsNothing);
      expect(find.text('审计 fail'), findsWidgets);

      await tester.tap(find.byTooltip('显示诊断面板'));
      await tester.pumpAndSettle();

      expect(find.text('失败草稿'), findsOneWidget);
      expect(find.textContaining('失败草稿。'), findsOneWidget);
      expect(find.textContaining('世界规则被违反'), findsOneWidget);
    },
  );

  testWidgets('compact editor stacks panels below editor without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = _WorkshopFixture(
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _WorkshopTestApp(fixture: fixture, initialLocation: _editorLocation),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('novel-workshop-editor')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('enrichment preview exposes cancel delete apply actions', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      projectOrigin: ProjectOrigin.importedEnrichment,
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
      chapters: [_chapter(planId: 'plan-1', index: 1, content: '旧正文。')],
      enrichmentBatches: [_enrichmentBatch()],
      enrichmentItems: [_enrichmentItem()],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    expect(find.text('最近加料批次'), findsOneWidget);
    await tester.ensureVisible(find.text('预览应用'));
    await tester.tap(find.text('预览应用'));
    await tester.pumpAndSettle();

    expect(find.text('取消'), findsOneWidget);
    expect(find.text('删除结果'), findsOneWidget);
    expect(find.text('应用到章节'), findsOneWidget);
    expect(find.text('删除 1 字'), findsOneWidget);
    expect(find.text('新增 1 字'), findsOneWidget);

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(fixture.repository.enrichmentItems, hasLength(1));
    expect(fixture.repository.chapters.single.contentMarkdown, '旧正文。');
  });

  testWidgets(
    'enrichment preview delete removes item without changing chapter',
    (tester) async {
      final fixture = _WorkshopFixture(
        projectOrigin: ProjectOrigin.importedEnrichment,
        plans: [
          _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
        ],
        chapters: [_chapter(planId: 'plan-1', index: 1, content: '旧正文。')],
        enrichmentBatches: [_enrichmentBatch()],
        enrichmentItems: [_enrichmentItem()],
      );
      addTearDown(fixture.dispose);

      await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('预览应用'));
      await tester.tap(find.text('预览应用'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('删除结果'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确认删除'));
      await tester.pumpAndSettle();

      expect(fixture.repository.enrichmentItems, isEmpty);
      expect(fixture.repository.chapters.single.contentMarkdown, '旧正文。');
      expect(find.text('加料结果已删除。'), findsOneWidget);
    },
  );

  testWidgets('enrichment preview apply still overwrites chapter', (
    tester,
  ) async {
    final fixture = _WorkshopFixture(
      projectOrigin: ProjectOrigin.importedEnrichment,
      plans: [
        _plan(id: 'plan-1', index: 1, title: '第一章', objective: '主角进入雾港。'),
      ],
      chapters: [_chapter(planId: 'plan-1', index: 1, content: '旧正文。')],
      enrichmentBatches: [_enrichmentBatch()],
      enrichmentItems: [_enrichmentItem()],
    );
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_WorkshopTestApp(fixture: fixture));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('预览应用'));
    await tester.tap(find.text('预览应用'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('应用到章节'));
    await tester.pumpAndSettle();

    expect(fixture.repository.enrichmentItems, hasLength(1));
    expect(fixture.repository.chapters.single.contentMarkdown, '新正文。');
    expect(find.text('加料结果已应用。'), findsOneWidget);
  });
}

class _WorkshopTestApp extends StatelessWidget {
  const _WorkshopTestApp({
    required this.fixture,
    this.initialLocation = _workshopLocation,
  });

  final _WorkshopFixture fixture;
  final String initialLocation;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        projectRepositoryProvider.overrideWithValue(fixture.projectRepository),
        providerConfigRepositoryProvider.overrideWithValue(
          fixture.providerRepository,
        ),
        llmClientProvider.overrideWithValue(fixture.promptLlmClient),
        imageProviderConfigRepositoryProvider.overrideWithValue(
          fixture.imageProviderRepository,
        ),
        novelWorkshopRepositoryProvider.overrideWithValue(fixture.repository),
        novelExportServiceProvider.overrideWithValue(fixture.exportService),
        chapterIllustrationServiceProvider.overrideWithValue(
          _FakeChapterIllustrationService(fixture.repository),
        ),
        assetGenerationPipelineProvider.overrideWithValue(
          fixture.assetPipeline,
        ),
        chapterGenerationPipelineProvider.overrideWithValue(fixture.pipeline),
        styleLabRepositoryProvider.overrideWithValue(fixture.styleRepository),
        plotLabRepositoryProvider.overrideWithValue(fixture.plotRepository),
      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: initialLocation,
          routes: [
            GoRoute(
              path: '/projects/:projectId/workshop',
              builder: (context, state) => Scaffold(
                body: NovelWorkshopPage(
                  projectId: state.pathParameters['projectId']!,
                ),
              ),
              routes: [
                GoRoute(
                  path: 'editor',
                  builder: (context, state) => Scaffold(
                    body: NovelEditorPage(
                      projectId: state.pathParameters['projectId']!,
                    ),
                  ),
                ),
                GoRoute(
                  path: 'reader',
                  builder: (context, state) => Scaffold(
                    body: NovelReaderPage(
                      projectId: state.pathParameters['projectId']!,
                    ),
                  ),
                ),
                GoRoute(
                  path: 'illustrations',
                  builder: (context, state) => Scaffold(
                    body: NovelIllustrationLibraryPage(
                      projectId: state.pathParameters['projectId']!,
                      initialPlanId: state.uri.queryParameters['plan'],
                    ),
                  ),
                ),
              ],
            ),
            GoRoute(
              path: '/projects',
              builder: (context, state) => const Text('projects'),
            ),
            GoRoute(
              path: '/workflow-runs/:taskId',
              builder: (context, state) =>
                  Text('workflow:${state.pathParameters['taskId']}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkshopFixture {
  _WorkshopFixture({
    ProjectStatus projectStatus = ProjectStatus.active,
    ProjectOrigin projectOrigin = ProjectOrigin.standard,
    List<ChapterPlan> plans = const [],
    List<ProjectChapter> chapters = const [],
    List<ChapterGenerationRun> runs = const [],
    bool withDefaultVolume = true,
    RuntimeMemoryState runtimeMemory = const RuntimeMemoryState(
      storySummary: '林岚追查失踪案。',
    ),
    bool bindPromptAssets = true,
    List<NovelCharacter> characters = const [],
    List<NovelRelationship> relationships = const [],
    List<ChapterEnrichmentBatch> enrichmentBatches = const [],
    List<ChapterEnrichmentItem> enrichmentItems = const [],
    List<ChapterGenerationBatch> generationBatches = const [],
    List<ChapterGenerationBatchItem> generationBatchItems = const [],
    List<ChapterIllustration> illustrations = const [],
    List<ChapterIllustrationGenerationRun> illustrationRuns = const [],
  }) : projectRepository = _FakeProjectRepository(
         status: projectStatus,
         origin: projectOrigin,
         bindPromptAssets: bindPromptAssets,
       ),
       repository = _FakeNovelWorkshopRepository(
         plans: plans,
         chapters: chapters,
         runs: runs,
         withDefaultVolume: withDefaultVolume,
         bindPromptAssets: bindPromptAssets,
         runtimeMemory: runtimeMemory,
         characters: characters,
         relationships: relationships,
         enrichmentBatches: enrichmentBatches,
         enrichmentItems: enrichmentItems,
         generationBatches: generationBatches,
         generationBatchItems: generationBatchItems,
         illustrations: illustrations,
         illustrationRuns: illustrationRuns,
       ),
       styleRepository = _FakeStyleLabRepository(),
       plotRepository = _FakePlotLabRepository() {
    pipeline = _FakeChapterGenerationPipeline(repository);
    assetPipeline = _FakeAssetGenerationPipeline(repository);
  }

  final _FakeProjectRepository projectRepository;
  final _FakeProviderConfigRepository providerRepository =
      _FakeProviderConfigRepository();
  final _QueuedPromptLlmClient promptLlmClient = _QueuedPromptLlmClient();
  final _FakeImageProviderConfigRepository imageProviderRepository =
      _FakeImageProviderConfigRepository();
  final _FakeNovelWorkshopRepository repository;
  final _FakeNovelExportService exportService = _FakeNovelExportService();
  final _FakeStyleLabRepository styleRepository;
  final _FakePlotLabRepository plotRepository;
  late final _FakeAssetGenerationPipeline assetPipeline;
  late final _FakeChapterGenerationPipeline pipeline;

  void dispose() {
    projectRepository.dispose();
    providerRepository.dispose();
    imageProviderRepository.dispose();
    repository.dispose();
  }
}

class _FakeAssetGenerationPipeline implements AssetGenerationPipeline {
  _FakeAssetGenerationPipeline(this.repository);

  final _FakeNovelWorkshopRepository repository;
  int generateCalls = 0;
  bool pauseGeneration = false;
  Completer<void>? _pausedGeneration;

  @override
  Future<AssetGenerationResult> generateAsset({
    required String projectId,
    required AssetGenerationKind kind,
    String? targetVolumeId,
  }) async {
    generateCalls += 1;
    if (pauseGeneration) {
      _pausedGeneration = Completer<void>();
      await _pausedGeneration!.future;
    }
    final run = targetVolumeId == null
        ? await repository.createAssetGenerationRun(
            AssetGenerationRunInput(
              projectId: projectId,
              kind: kind,
              providerId: '',
              modelName: '',
            ),
          )
        : await repository.createVolumeDetailGenerationRun(
            projectId: projectId,
            volumeId: targetVolumeId,
          );
    final completed = await repository.updateAssetGenerationRunState(
      id: run.id,
      status: AssetGenerationStatus.succeeded,
      draftMarkdown: '生成草稿。',
      completedAt: _testUpdatedAt,
    );
    return AssetGenerationResult(
      run: completed,
      workflowTaskId: completed.workflowTaskId,
    );
  }

  void completePausedGeneration() {
    _pausedGeneration?.complete();
    _pausedGeneration = null;
    pauseGeneration = false;
  }
}

class _FakeChapterIllustrationService extends ChapterIllustrationService {
  _FakeChapterIllustrationService(this.repository)
    : super(
        repository: repository,
        imageGenerationService: const ImageGenerationService(
          client: _UnusedImageGenerationClient(),
        ),
      );

  final _FakeNovelWorkshopRepository repository;

  @override
  Future<ChapterIllustration> generateIllustration({
    required ProjectChapter chapter,
    required int paragraphIndex,
    required String selectedText,
    required String prompt,
    required ImageProviderConfig provider,
    required String modelName,
    ImageAspectRatioPreset? aspectRatio,
    ImageSizePreset? size,
    ImageQualityPreset? quality,
    ImageResponseFormat? responseFormat,
  }) {
    return repository.createChapterIllustration(
      ChapterIllustrationInput(
        projectId: chapter.projectId,
        chapterId: chapter.id,
        chapterPlanId: chapter.chapterPlanId,
        paragraphIndex: paragraphIndex,
        anchorTextHash: anchorTextHash(selectedText),
        selectedText: selectedText,
        prompt: prompt,
        providerId: provider.id,
        modelName: modelName,
        localPath: '/tmp/generated-reader-illustration.png',
        mimeType: 'image/png',
      ),
    );
  }
}

class _UnusedImageGenerationClient implements ImageGenerationClient {
  const _UnusedImageGenerationClient();

  @override
  Future<ImageGenerationResult> generateImage({
    required ImageProviderConfig provider,
    required ImageGenerationRequest request,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ImageGenerationResult> editImage({
    required ImageProviderConfig provider,
    required ImageEditRequest request,
  }) async {
    throw UnimplementedError();
  }
}

class _QueuedPromptLlmClient implements LlmClient {
  final List<String> responses = [];
  Object? error;
  Completer<void>? responseGate;
  LlmRequest? lastRequest;

  @override
  Stream<LlmStreamEvent> streamChat({
    required ProviderConfig provider,
    required LlmRequest request,
  }) async* {
    lastRequest = request;
    final configuredError = error;
    if (configuredError != null) {
      throw configuredError;
    }
    final gate = responseGate;
    if (gate != null) {
      await gate.future;
      if (identical(responseGate, gate)) {
        responseGate = null;
      }
    }
    if (responses.isEmpty) {
      throw StateError('No queued prompt response.');
    }
    yield LlmStreamDelta(responses.removeAt(0));
    yield const LlmStreamDone();
  }
}

class _FakeChapterGenerationPipeline implements ChapterGenerationPipeline {
  _FakeChapterGenerationPipeline(this.repository);

  final _FakeNovelWorkshopRepository repository;
  int previewCalls = 0;
  int generateCalls = 0;
  int batchCalls = 0;
  bool? replaceExisting;

  @override
  Future<ChapterGenerationContextPreview> previewGenerationContext({
    required String projectId,
    required String chapterPlanId,
  }) async {
    previewCalls += 1;
    final assets = repository.bindPromptAssets;
    return ChapterGenerationContextPreview(
      promptMarkdown:
          '''
## Output Contract

只输出正文。

## Project Bible

${repository.bible.descriptionMarkdown}

## Chapter Objective Card

${repository.plans.singleWhere((item) => item.id == chapterPlanId).objectiveCard.objective}
''',
      warnings: [
        if (!assets) '项目未绑定 Voice Profile。',
        if (!assets) '项目未绑定 Story Engine。',
      ],
      projectBibleIncluded: !ProjectBiblePromptContext(
        descriptionMarkdown: repository.bible.descriptionMarkdown,
        worldBuildingMarkdown: repository.bible.worldBuildingMarkdown,
        charactersBlueprintMarkdown:
            repository.bible.charactersBlueprintMarkdown,
        outlineMasterMarkdown: repository.bible.outlineMasterMarkdown,
        outlineDetailYaml: repository.bible.outlineDetailYaml,
      ).isEmpty,
      chapterObjectiveCardIncluded: !repository.plans
          .singleWhere((item) => item.id == chapterPlanId)
          .objectiveCard
          .isEmpty,
      runtimeMemoryIncluded: !repository.memory.state.isEmpty,
      characterCount: repository.characters.length,
      relationshipCount: repository.relationships.length,
      voiceProfileIncluded: assets,
      storyEngineIncluded: assets,
      selectedChapterExcerptCount: 0,
      selectedAssetBlockCount: assets ? 2 : 0,
      selectionReportMarkdown: assets
          ? 'Mode: local fallback\nSelected asset blocks: voice_profile, story_engine'
          : '',
    );
  }

  @override
  Future<ChapterGenerationResult> generateChapter({
    required String projectId,
    required String chapterPlanId,
    bool replaceExisting = false,
  }) async {
    generateCalls += 1;
    this.replaceExisting = replaceExisting;
    final plan = repository.plans.singleWhere(
      (item) => item.id == chapterPlanId,
    );
    final existing = await repository.findChapterByPlan(chapterPlanId);
    final chapter = await repository.saveChapter(
      id: existing?.id,
      input: ProjectChapterInput(
        projectId: projectId,
        chapterPlanId: chapterPlanId,
        chapterIndex: plan.chapterIndex,
        title: plan.objectiveCard.chapterTitle,
        contentMarkdown: '生成正文。',
      ),
    );
    final run = _run(
      id: 'run-generated',
      workflowTaskId: 'task-generated',
      planId: chapterPlanId,
      status: ChapterGenerationStatus.succeeded,
      chapterId: chapter.id,
    );
    repository.runs.add(run);
    repository.emit();
    return ChapterGenerationResult(
      run: run,
      chapter: chapter,
      contextWarnings: const [],
      workflowTaskId: run.workflowTaskId,
    );
  }

  @override
  Future<ProjectChapter> proposeMemoryPatchForChapter({
    required String projectId,
    required String chapterId,
  }) async {
    final chapter = await repository.findChapter(chapterId);
    if (chapter == null) {
      throw StateError('Project chapter does not exist: $chapterId');
    }
    return repository.saveMemorySyncProposal(
      MemorySyncProposalInput(
        chapterId: chapter.id,
        contentHash: chapter.contentHash,
        proposedMemory: const RuntimeMemoryState(storySummary: '同步摘要。'),
      ),
    );
  }

  @override
  Future<ChapterGenerationBatchResult> startChapterGenerationBatch({
    required String projectId,
    required List<String> chapterPlanIds,
  }) async {
    batchCalls += 1;
    final batch = await repository.createChapterGenerationBatch(
      ChapterGenerationBatchInput(
        projectId: projectId,
        chapterPlanIds: chapterPlanIds,
        providerId: 'provider-1',
        modelName: 'model-1',
      ),
    );
    return ChapterGenerationBatchResult(
      batch: batch,
      items: await repository.watchChapterGenerationBatchItems(batch.id).first,
      workflowTaskId: batch.workflowTaskId,
    );
  }

  @override
  Future<ChapterGenerationBatchResult> processChapterGenerationBatch(
    String batchId,
  ) async {
    final batch = (await repository.findChapterGenerationBatch(batchId))!;
    return ChapterGenerationBatchResult(
      batch: batch,
      items: await repository.watchChapterGenerationBatchItems(batchId).first,
      workflowTaskId: batch.workflowTaskId,
    );
  }

  @override
  Future<ChapterGenerationBatchResult> stopChapterGenerationBatch(
    String batchId,
  ) async {
    final batch = await repository.updateChapterGenerationBatchState(
      id: batchId,
      status: ChapterGenerationBatchStatus.failed,
      errorMessage: '用户已停止批量草稿。',
    );
    return ChapterGenerationBatchResult(
      batch: batch,
      items: await repository.watchChapterGenerationBatchItems(batchId).first,
      workflowTaskId: batch.workflowTaskId,
    );
  }
}

class _FakeNovelExportService implements NovelExportService {
  int calls = 0;
  String? lastProjectTitle;
  int? lastChapterCount;

  @override
  Future<String?> exportTxt({
    required WritingProject project,
    required List<ChapterVolume> volumes,
    required List<ChapterPlan> plans,
    required List<ProjectChapter> chapters,
  }) async {
    calls += 1;
    lastProjectTitle = project.title;
    lastChapterCount = chapters.length;
    return '/tmp/${project.title}.txt';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProjectRepository implements ProjectRepository {
  _FakeProjectRepository({
    ProjectStatus status = ProjectStatus.active,
    ProjectOrigin origin = ProjectOrigin.standard,
    bool bindPromptAssets = true,
  }) {
    _project = WritingProject(
      id: 'project-1',
      title: '雾港纪事',
      description: '项目简介',
      status: status,
      defaultProviderId: 'provider-1',
      defaultModelName: 'gpt-4.1-mini',
      styleProfileId: bindPromptAssets ? 'style-1' : null,
      plotProfileId: bindPromptAssets ? 'plot-1' : null,
      origin: origin,
      createdAt: DateTime(2026, 5, 18, 9),
      updatedAt: DateTime(2026, 5, 18, 10),
    );
  }

  final _changes = StreamController<void>.broadcast();
  late WritingProject _project;

  WritingProject get project => _project;

  void dispose() {
    _changes.close();
  }

  @override
  Future<WritingProject> createProject(WritingProjectInput input) async {
    await saveProject(id: 'created-project', input: input);
    return _project;
  }

  @override
  Future<void> deleteProject(String id) async {}

  @override
  Future<WritingProject?> findProject(String id) async {
    return id == _project.id ? _project : null;
  }

  @override
  Future<void> saveProject({
    String? id,
    required WritingProjectInput input,
  }) async {
    _project = WritingProject(
      id: id ?? _project.id,
      title: input.title,
      description: input.description,
      status: input.status,
      defaultProviderId: input.defaultProviderId,
      defaultModelName: input.defaultModelName,
      styleProfileId: input.styleProfileId,
      plotProfileId: input.plotProfileId,
      origin: input.origin,
      language: input.language,
      targetLength: input.targetLength,
      totalTargetLength: input.totalTargetLength,
      narrativePerspective: input.narrativePerspective,
      createdAt: _project.createdAt,
      updatedAt: DateTime(2026, 5, 18, 12),
    );
    _changes.add(null);
  }

  @override
  Future<void> updateStatus({
    required String id,
    required ProjectStatus status,
  }) async {}

  @override
  Stream<WritingProject?> watchProject(String id) async* {
    yield id == _project.id ? _project : null;
    yield* _changes.stream.map((_) => id == _project.id ? _project : null);
  }

  @override
  Stream<List<WritingProject>> watchProjects(ProjectStatus status) async* {
    yield status == _project.status ? [_project] : const [];
  }
}

class _FakeProviderConfigRepository implements ProviderConfigRepository {
  _FakeProviderConfigRepository() {
    _providers = [
      ProviderConfig(
        id: 'provider-1',
        name: 'OpenAI',
        baseUrl: 'https://api.example.com/v1',
        apiKey: 'sk-test',
        defaultModel: 'gpt-4.1-mini',
        modelNames: const ['gpt-4.1-mini', 'gpt-4.1'],
        systemPrompt: '',
        isEnabled: true,
        testStatus: ProviderTestStatus.untested,
        createdAt: DateTime(2026, 5, 18, 9),
        updatedAt: DateTime(2026, 5, 18, 10),
      ),
    ];
  }

  final _changes = StreamController<void>.broadcast();
  late final List<ProviderConfig> _providers;

  void dispose() {
    _changes.close();
  }

  @override
  Future<void> deleteProvider(String id) async {}

  @override
  Future<ProviderConfig?> findProvider(String id) async {
    return _providers.where((provider) => provider.id == id).firstOrNull;
  }

  @override
  Future<void> saveProvider({
    String? id,
    required ProviderConfigInput input,
  }) async {}

  @override
  Future<void> updateSystemPrompt({
    required String id,
    required String systemPrompt,
    bool? isSystemPromptEnabled,
  }) async {}

  @override
  Future<void> updateTestResult({
    required String id,
    required ProviderTestStatus status,
    required DateTime testedAt,
    String? message,
  }) async {}

  @override
  Stream<List<ProviderConfig>> watchProviders() async* {
    yield _providers;
    yield* _changes.stream.map((_) => _providers);
  }

  @override
  Stream<ProviderConfig?> watchProvider(String id) async* {
    yield _providers.where((provider) => provider.id == id).firstOrNull;
    yield* _changes.stream.map(
      (_) => _providers.where((provider) => provider.id == id).firstOrNull,
    );
  }
}

class _FakeImageProviderConfigRepository
    implements ImageProviderConfigRepository {
  _FakeImageProviderConfigRepository() {
    _providers = [
      ImageProviderConfig(
        id: 'image-provider-1',
        name: 'OpenAI Images',
        baseUrl: 'https://api.example.com/v1',
        apiKey: 'sk-image-test',
        defaultModel: 'gpt-image-1',
        modelNames: const ['gpt-image-1'],
        isEnabled: true,
        testStatus: ProviderTestStatus.untested,
        createdAt: DateTime(2026, 5, 18, 9),
        updatedAt: DateTime(2026, 5, 18, 10),
      ),
    ];
  }

  final _changes = StreamController<void>.broadcast();
  late final List<ImageProviderConfig> _providers;

  void setEnabled(bool value) {
    _providers[0] = _providers[0].copyWith(isEnabled: value);
    _changes.add(null);
  }

  void dispose() {
    _changes.close();
  }

  @override
  Future<void> deleteProvider(String id) async {
    _providers.removeWhere((provider) => provider.id == id);
    _changes.add(null);
  }

  @override
  Future<ImageProviderConfig?> findProvider(String id) async {
    return _providers.where((provider) => provider.id == id).firstOrNull;
  }

  @override
  Future<void> saveProvider({
    String? id,
    required ImageProviderConfigInput input,
  }) async {
    final now = DateTime(2026, 5, 18, 12);
    final saved = ImageProviderConfig(
      id: id ?? 'image-provider-${_providers.length + 1}',
      name: input.name,
      baseUrl: input.baseUrl,
      apiKey: input.apiKey,
      defaultModel: input.defaultModel,
      providerKind: input.providerKind,
      modelNames: input.modelNames,
      defaultAspectRatio: input.defaultAspectRatio,
      defaultSize: input.defaultSize,
      defaultQuality: input.defaultQuality,
      defaultResponseFormat: input.defaultResponseFormat,
      isEnabled: input.isEnabled,
      testStatus: ProviderTestStatus.untested,
      createdAt: now,
      updatedAt: now,
    );
    final index = _providers.indexWhere((provider) => provider.id == saved.id);
    if (index < 0) {
      _providers.add(saved);
    } else {
      _providers[index] = saved;
    }
    _changes.add(null);
  }

  @override
  Future<void> updateTestResult({
    required String id,
    required ProviderTestStatus status,
    required DateTime testedAt,
    String? message,
  }) async {
    final index = _providers.indexWhere((provider) => provider.id == id);
    if (index < 0) return;
    _providers[index] = _providers[index].copyWith(
      testStatus: status,
      lastTestedAt: testedAt,
      lastTestMessage: message,
    );
    _changes.add(null);
  }

  @override
  Stream<ImageProviderConfig?> watchProvider(String id) async* {
    ImageProviderConfig? snapshot() =>
        _providers.where((provider) => provider.id == id).firstOrNull;
    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }

  @override
  Stream<List<ImageProviderConfig>> watchProviders() async* {
    yield [..._providers];
    yield* _changes.stream.map((_) => [..._providers]);
  }
}

class _FakeNovelWorkshopRepository implements NovelWorkshopRepository {
  _FakeNovelWorkshopRepository({
    required List<ChapterPlan> plans,
    required List<ProjectChapter> chapters,
    required List<ChapterGenerationRun> runs,
    required bool withDefaultVolume,
    required this.bindPromptAssets,
    required RuntimeMemoryState runtimeMemory,
    required List<NovelCharacter> characters,
    required List<NovelRelationship> relationships,
    required List<ChapterEnrichmentBatch> enrichmentBatches,
    required List<ChapterEnrichmentItem> enrichmentItems,
    required List<ChapterGenerationBatch> generationBatches,
    required List<ChapterGenerationBatchItem> generationBatchItems,
    required List<ChapterIllustration> illustrations,
    required List<ChapterIllustrationGenerationRun> illustrationRuns,
  }) : plans = [...plans],
       chapters = [...chapters],
       illustrations = [...illustrations],
       illustrationRuns = [...illustrationRuns],
       runs = [...runs],
       generationBatches = [...generationBatches],
       generationBatchItems = [...generationBatchItems],
       enrichmentBatches = [...enrichmentBatches],
       enrichmentItems = [...enrichmentItems],
       characters = [...characters],
       relationships = [...relationships],
       volumes = withDefaultVolume
           ? [
               ChapterVolume(
                 id: 'volume-1',
                 projectId: 'project-1',
                 volumeIndex: 1,
                 title: '第一卷',
                 createdAt: _testCreatedAt,
                 updatedAt: _testUpdatedAt,
               ),
             ]
           : [],
       bible = ProjectBible(
         projectId: 'project-1',
         descriptionMarkdown: '项目简介',
         worldBuildingMarkdown: '雾港长期被潮汐封锁。',
         charactersBlueprintMarkdown: '林岚：调查者。',
         outlineMasterMarkdown: '失踪案牵出港务处阴谋。',
         outlineDetailYaml: '',
         createdAt: _testCreatedAt,
         updatedAt: _testUpdatedAt,
       ),
       memory = ProjectRuntimeMemory(
         projectId: 'project-1',
         state: runtimeMemory,
         createdAt: _testCreatedAt,
         updatedAt: _testUpdatedAt,
       );

  final List<ChapterPlan> plans;
  final List<ProjectChapter> chapters;
  final List<ChapterIllustration> illustrations;
  final List<ChapterIllustrationGenerationRun> illustrationRuns;
  final List<ChapterGenerationRun> runs;
  final List<ChapterGenerationBatch> generationBatches;
  final List<ChapterGenerationBatchItem> generationBatchItems;
  final List<AssetGenerationRun> assetRuns = [];
  final List<ChapterEnrichmentBatch> enrichmentBatches;
  final List<ChapterEnrichmentItem> enrichmentItems;
  final List<NovelCharacter> characters;
  final List<NovelRelationship> relationships;
  final List<ChapterVolume> volumes;
  final bool bindPromptAssets;
  ProjectBible bible;
  ProjectRuntimeMemory memory;
  final _changes = StreamController<void>.broadcast();

  void emit() {
    _changes.add(null);
  }

  void dispose() {
    _changes.close();
  }

  @override
  Future<void> clearRuntimeMemory(String projectId) async {}

  @override
  Future<ProjectChapter> applyChapterEnrichmentItem(String itemId) async {
    final item = enrichmentItems.singleWhere((entry) => entry.id == itemId);
    final chapter = chapters.singleWhere((entry) => entry.id == item.chapterId);
    return saveChapter(
      id: chapter.id,
      input: ProjectChapterInput(
        projectId: chapter.projectId,
        chapterPlanId: chapter.chapterPlanId,
        chapterIndex: chapter.chapterIndex,
        title: chapter.title,
        contentMarkdown: item.generatedContentMarkdown,
      ),
    );
  }

  @override
  Future<void> deleteChapterEnrichmentItem(String itemId) async {
    final index = enrichmentItems.indexWhere((entry) => entry.id == itemId);
    if (index < 0) {
      throw StateError('Chapter enrichment item does not exist: $itemId');
    }
    enrichmentItems.removeAt(index);
    emit();
  }

  @override
  Future<ChapterEnrichmentBatch> createChapterEnrichmentBatch(
    ChapterEnrichmentBatchInput input,
  ) async {
    final now = DateTime(2026, 5, 18, 13);
    final batch = ChapterEnrichmentBatch(
      id: 'enrichment-batch-${enrichmentBatches.length + 1}',
      workflowTaskId: 'enrichment-task-${enrichmentBatches.length + 1}',
      projectId: input.projectId,
      instruction: input.instruction,
      expansionRatioPercent: input.expansionRatioPercent,
      providerId: input.providerId,
      modelName: input.modelName,
      status: ChapterEnrichmentBatchStatus.pending,
      errorMessage: null,
      totalCount: input.chapterIds.length,
      generatedCount: 0,
      failedCount: 0,
      appliedCount: 0,
      logs: '',
      createdAt: now,
      updatedAt: now,
      startedAt: null,
      completedAt: null,
    );
    enrichmentBatches.add(batch);
    for (var index = 0; index < input.chapterIds.length; index += 1) {
      enrichmentItems.add(
        ChapterEnrichmentItem(
          id: 'enrichment-item-${enrichmentItems.length + 1}',
          batchId: batch.id,
          projectId: input.projectId,
          chapterId: input.chapterIds[index],
          position: index,
          status: ChapterEnrichmentItemStatus.waiting,
          errorMessage: null,
          originalContentMarkdown: '',
          generatedContentMarkdown: '',
          providerId: input.providerId,
          modelName: input.modelName,
          logs: '',
          createdAt: now,
          updatedAt: now,
          startedAt: null,
          completedAt: null,
          appliedAt: null,
        ),
      );
    }
    emit();
    return batch;
  }

  @override
  Future<ProjectBible> ensureProjectBible(String projectId) async {
    return bible;
  }

  @override
  Future<ProjectBible?> findProjectBible(String projectId) async {
    return ensureProjectBible(projectId);
  }

  @override
  Future<ChapterGenerationRun> createChapterGenerationRun(
    ChapterGenerationRunInput input,
  ) async {
    final run = _run(
      id: 'run-${runs.length + 1}',
      workflowTaskId: 'task-run-${runs.length + 1}',
      planId: input.chapterPlanId,
      status: ChapterGenerationStatus.pending,
    );
    runs.add(run);
    emit();
    return run;
  }

  @override
  Future<ChapterGenerationBatch> createChapterGenerationBatch(
    ChapterGenerationBatchInput input,
  ) async {
    final batch = ChapterGenerationBatch(
      id: 'generation-batch-${generationBatches.length + 1}',
      workflowTaskId: 'task-generation-batch-${generationBatches.length + 1}',
      projectId: input.projectId,
      providerId: input.providerId,
      modelName: input.modelName,
      status: ChapterGenerationBatchStatus.pending,
      errorMessage: null,
      totalCount: input.chapterPlanIds.length,
      syncedCount: 0,
      failedCount: 0,
      logs: '',
      createdAt: _testCreatedAt,
      updatedAt: _testUpdatedAt,
      startedAt: null,
      completedAt: null,
    );
    generationBatches.add(batch);
    for (var index = 0; index < input.chapterPlanIds.length; index += 1) {
      generationBatchItems.add(
        ChapterGenerationBatchItem(
          id: 'generation-batch-item-${generationBatchItems.length + 1}',
          batchId: batch.id,
          projectId: input.projectId,
          chapterPlanId: input.chapterPlanIds[index],
          chapterId: null,
          latestRunId: null,
          position: index,
          status: ChapterGenerationBatchItemStatus.waiting,
          errorMessage: null,
          draftAttemptCount: 0,
          patchAttemptCount: 0,
          logs: '',
          createdAt: _testCreatedAt,
          updatedAt: _testUpdatedAt,
          startedAt: null,
          completedAt: null,
          syncedAt: null,
        ),
      );
    }
    emit();
    return batch;
  }

  @override
  Future<AssetGenerationRun> createAssetGenerationRun(
    AssetGenerationRunInput input,
  ) async {
    final run = _assetRun(
      id: 'asset-run-${assetRuns.length + 1}',
      projectId: input.projectId,
      kind: input.kind,
      status: AssetGenerationStatus.pending,
    );
    assetRuns.add(run);
    emit();
    return run;
  }

  @override
  Future<AssetGenerationRun> createVolumeDetailGenerationRun({
    required String projectId,
    required String volumeId,
  }) async {
    final run = _assetRun(
      id: 'asset-run-${assetRuns.length + 1}',
      projectId: projectId,
      kind: AssetGenerationKind.outlineDetailYaml,
      status: AssetGenerationStatus.pending,
      targetVolumeId: volumeId,
    );
    assetRuns.add(run);
    emit();
    return run;
  }

  @override
  Future<ChapterPlan?> findChapterPlan(String id) async {
    return plans.where((plan) => plan.id == id).firstOrNull;
  }

  @override
  Future<ProjectChapter?> findChapter(String id) async {
    return chapters.where((chapter) => chapter.id == id).firstOrNull;
  }

  @override
  Future<ChapterIllustration?> findChapterIllustration(String id) async {
    return illustrations
        .where((illustration) => illustration.id == id)
        .firstOrNull;
  }

  @override
  Future<ChapterIllustrationGenerationRun?>
  findChapterIllustrationGenerationRun(String id) async {
    return illustrationRuns.where((run) => run.id == id).firstOrNull;
  }

  @override
  Future<ProjectChapter?> findChapterByPlan(String chapterPlanId) async {
    return chapters
        .where((chapter) => chapter.chapterPlanId == chapterPlanId)
        .firstOrNull;
  }

  @override
  Future<NovelCharacter?> findCharacter(String id) async {
    return characters.where((character) => character.id == id).firstOrNull;
  }

  @override
  Future<NovelRelationship?> findRelationship(String id) async {
    return relationships
        .where((relationship) => relationship.id == id)
        .firstOrNull;
  }

  @override
  Future<ChapterGenerationRun?> findChapterGenerationRun(String id) async {
    return runs.where((run) => run.id == id).firstOrNull;
  }

  @override
  Future<ChapterGenerationBatch?> findChapterGenerationBatch(String id) async {
    return generationBatches.where((batch) => batch.id == id).firstOrNull;
  }

  @override
  Future<ChapterGenerationBatchItem?> findChapterGenerationBatchItem(
    String id,
  ) async {
    return generationBatchItems.where((item) => item.id == id).firstOrNull;
  }

  @override
  Future<AssetGenerationRun?> findAssetGenerationRun(String id) async {
    return assetRuns.where((run) => run.id == id).firstOrNull;
  }

  @override
  Future<ChapterEnrichmentBatch?> findChapterEnrichmentBatch(String id) async {
    return enrichmentBatches.where((batch) => batch.id == id).firstOrNull;
  }

  @override
  Future<ChapterEnrichmentItem?> findChapterEnrichmentItem(String id) async {
    return enrichmentItems.where((item) => item.id == id).firstOrNull;
  }

  @override
  Future<ProjectRuntimeMemory?> findRuntimeMemory(String projectId) async {
    return await ensureRuntimeMemory(projectId);
  }

  @override
  Future<ProjectRuntimeMemory> ensureRuntimeMemory(String projectId) async {
    return memory;
  }

  @override
  Future<bool> hasRunningChapterGeneration(String chapterPlanId) async {
    return runs.any(
      (run) =>
          run.chapterPlanId == chapterPlanId &&
          (run.status == ChapterGenerationStatus.pending ||
              run.status == ChapterGenerationStatus.running),
    );
  }

  @override
  Future<bool> hasRunningChapterGenerationForProject(String projectId) async {
    return runs.any(
      (run) =>
          run.projectId == projectId &&
          (run.status == ChapterGenerationStatus.pending ||
              run.status == ChapterGenerationStatus.running),
    );
  }

  @override
  Future<bool> hasRunningChapterGenerationBatch(String projectId) async {
    return generationBatches.any(
      (batch) =>
          batch.projectId == projectId &&
          (batch.status == ChapterGenerationBatchStatus.pending ||
              batch.status == ChapterGenerationBatchStatus.running),
    );
  }

  @override
  Future<bool> hasRunningAssetGeneration({
    required String projectId,
    required AssetGenerationKind kind,
    String? targetVolumeId,
  }) async {
    return assetRuns.any(
      (run) =>
          run.projectId == projectId &&
          run.kind == kind &&
          run.targetVolumeId == targetVolumeId &&
          (run.status == AssetGenerationStatus.pending ||
              run.status == AssetGenerationStatus.running),
    );
  }

  @override
  Future<ProjectChapter> saveChapter({
    String? id,
    required ProjectChapterInput input,
  }) async {
    final existingIndex = id == null
        ? -1
        : chapters.indexWhere((chapter) => chapter.id == id);
    final saved = _chapter(
      id: id ?? 'chapter-${input.chapterPlanId}',
      planId: input.chapterPlanId,
      index: input.chapterIndex,
      title: input.title,
      content: input.contentMarkdown,
    );
    if (existingIndex == -1) {
      chapters.add(saved);
    } else {
      chapters[existingIndex] = saved;
    }
    emit();
    return saved;
  }

  @override
  Future<ChapterIllustration> createChapterIllustration(
    ChapterIllustrationInput input,
  ) async {
    final now = DateTime.now();
    final saved = ChapterIllustration(
      id: 'illustration-${illustrations.length + 1}',
      projectId: input.projectId,
      chapterId: input.chapterId,
      chapterPlanId: input.chapterPlanId,
      paragraphIndex: input.paragraphIndex,
      anchorTextHash: input.anchorTextHash,
      selectedText: input.selectedText,
      prompt: input.prompt,
      providerId: input.providerId,
      modelName: input.modelName,
      localPath: input.localPath,
      mimeType: input.mimeType,
      status: ChapterIllustrationStatus.draft,
      createdAt: now,
      updatedAt: now,
    );
    illustrations.add(saved);
    emit();
    return saved;
  }

  @override
  Future<ChapterIllustration> insertChapterIllustration(String id) async {
    final index = illustrations.indexWhere((illustration) {
      return illustration.id == id;
    });
    if (index < 0) {
      throw StateError('Chapter illustration does not exist: $id');
    }
    final current = illustrations[index];
    final now = DateTime.now();
    final saved = ChapterIllustration(
      id: current.id,
      projectId: current.projectId,
      chapterId: current.chapterId,
      chapterPlanId: current.chapterPlanId,
      paragraphIndex: current.paragraphIndex,
      anchorTextHash: current.anchorTextHash,
      selectedText: current.selectedText,
      prompt: current.prompt,
      providerId: current.providerId,
      modelName: current.modelName,
      localPath: current.localPath,
      mimeType: current.mimeType,
      status: ChapterIllustrationStatus.inserted,
      createdAt: current.createdAt,
      updatedAt: now,
      acceptedAt: current.acceptedAt ?? now,
    );
    illustrations[index] = saved;
    emit();
    return saved;
  }

  @override
  Future<ChapterIllustration> removeChapterIllustrationFromText(
    String id,
  ) async {
    final index = illustrations.indexWhere((illustration) {
      return illustration.id == id;
    });
    if (index < 0) {
      throw StateError('Chapter illustration does not exist: $id');
    }
    final current = illustrations[index];
    final now = DateTime.now();
    final saved = ChapterIllustration(
      id: current.id,
      projectId: current.projectId,
      chapterId: current.chapterId,
      chapterPlanId: current.chapterPlanId,
      paragraphIndex: current.paragraphIndex,
      anchorTextHash: current.anchorTextHash,
      selectedText: current.selectedText,
      prompt: current.prompt,
      providerId: current.providerId,
      modelName: current.modelName,
      localPath: current.localPath,
      mimeType: current.mimeType,
      status: ChapterIllustrationStatus.unused,
      createdAt: current.createdAt,
      updatedAt: now,
      acceptedAt: current.acceptedAt,
    );
    illustrations[index] = saved;
    emit();
    return saved;
  }

  @override
  Future<void> deleteChapterIllustration(String id) async {
    illustrations.removeWhere((illustration) => illustration.id == id);
    emit();
  }

  @override
  Future<ChapterIllustrationGenerationRun>
  createChapterIllustrationGenerationRun(
    ChapterIllustrationGenerationRunInput input,
  ) async {
    final now = DateTime.now();
    final saved = ChapterIllustrationGenerationRun(
      id: 'illustration-run-${illustrationRuns.length + 1}',
      workflowTaskId: 'task-illustration-${illustrationRuns.length + 1}',
      projectId: input.projectId,
      chapterId: input.chapterId,
      chapterPlanId: input.chapterPlanId,
      paragraphIndex: input.paragraphIndex,
      anchorTextHash: input.anchorTextHash,
      selectedText: input.selectedText,
      prompt: input.prompt,
      providerId: input.providerId,
      modelName: input.modelName,
      aspectRatio: input.aspectRatio,
      size: input.size,
      quality: input.quality,
      responseFormat: input.responseFormat,
      status: ChapterIllustrationGenerationStatus.pending,
      stage: null,
      errorMessage: null,
      logs: '',
      illustrationId: null,
      createdAt: now,
      updatedAt: now,
      startedAt: null,
      completedAt: null,
    );
    illustrationRuns.add(saved);
    emit();
    return saved;
  }

  @override
  Future<ChapterIllustrationGenerationRun>
  createChapterIllustrationGenerationRunFromExisting(String id) async {
    final existing = await findChapterIllustrationGenerationRun(id);
    if (existing == null) {
      throw StateError(
        'Chapter illustration generation run does not exist: $id',
      );
    }
    return createChapterIllustrationGenerationRun(
      ChapterIllustrationGenerationRunInput(
        projectId: existing.projectId,
        chapterId: existing.chapterId,
        chapterPlanId: existing.chapterPlanId,
        paragraphIndex: existing.paragraphIndex,
        anchorTextHash: existing.anchorTextHash,
        selectedText: existing.selectedText,
        prompt: existing.prompt,
        providerId: existing.providerId,
        modelName: existing.modelName,
        aspectRatio: existing.aspectRatio,
        size: existing.size,
        quality: existing.quality,
        responseFormat: existing.responseFormat,
      ),
    );
  }

  @override
  Future<ChapterIllustrationGenerationRun>
  updateChapterIllustrationGenerationRunState({
    required String id,
    required ChapterIllustrationGenerationStatus status,
    ChapterIllustrationGenerationStage? stage,
    String? errorMessage,
    String? logs,
    String? illustrationId,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final index = illustrationRuns.indexWhere((run) => run.id == id);
    if (index < 0) {
      throw StateError(
        'Chapter illustration generation run does not exist: $id',
      );
    }
    final current = illustrationRuns[index];
    final saved = ChapterIllustrationGenerationRun(
      id: current.id,
      workflowTaskId: current.workflowTaskId,
      projectId: current.projectId,
      chapterId: current.chapterId,
      chapterPlanId: current.chapterPlanId,
      paragraphIndex: current.paragraphIndex,
      anchorTextHash: current.anchorTextHash,
      selectedText: current.selectedText,
      prompt: current.prompt,
      providerId: current.providerId,
      modelName: current.modelName,
      aspectRatio: current.aspectRatio,
      size: current.size,
      quality: current.quality,
      responseFormat: current.responseFormat,
      status: status,
      stage: stage,
      errorMessage: errorMessage,
      logs: logs ?? current.logs,
      illustrationId: illustrationId ?? current.illustrationId,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
      startedAt: startedAt ?? current.startedAt,
      completedAt: completedAt ?? current.completedAt,
    );
    illustrationRuns[index] = saved;
    emit();
    return saved;
  }

  @override
  Future<int> markInterruptedChapterIllustrationGenerationRunsFailed() async {
    return 0;
  }

  @override
  Future<void> deleteChapterIllustrationGenerationRun(String id) async {
    illustrationRuns.removeWhere((run) => run.id == id);
    emit();
  }

  @override
  Future<ChapterPlan> saveChapterPlan({
    String? id,
    required ChapterPlanInput input,
  }) async {
    if (input.chapterIndex <= 0 || input.objectiveCard.isEmpty) {
      throw StateError('章节目标卡不能为空。');
    }
    final existingIndex = id == null
        ? -1
        : plans.indexWhere((plan) => plan.id == id);
    final saved = ChapterPlan(
      id: id ?? 'plan-${plans.length + 1}',
      projectId: input.projectId,
      volumeId: input.volumeId,
      volumeIndex: input.volumeIndex,
      volumeTitle: input.volumeTitle,
      chapterLocalIndex: input.chapterLocalIndex,
      chapterIndex: input.chapterIndex,
      objectiveCard: input.objectiveCard,
      coreEvent: input.coreEvent,
      emotionArc: input.emotionArc,
      chapterHook: input.chapterHook,
      outlineMarkdown: input.outlineMarkdown,
      createdAt: existingIndex == -1
          ? _testCreatedAt
          : plans[existingIndex].createdAt,
      updatedAt: _testUpdatedAt,
    );
    if (existingIndex == -1) {
      plans.add(saved);
    } else {
      plans[existingIndex] = saved;
    }
    plans.sort((a, b) => a.chapterIndex.compareTo(b.chapterIndex));
    emit();
    return saved;
  }

  @override
  Future<ProjectChapter> saveMemorySyncProposal(
    MemorySyncProposalInput input,
  ) async {
    final index = chapters.indexWhere(
      (chapter) => chapter.id == input.chapterId,
    );
    final current = chapters[index];
    final saved = ProjectChapter(
      id: current.id,
      projectId: current.projectId,
      chapterPlanId: current.chapterPlanId,
      chapterIndex: current.chapterIndex,
      title: current.title,
      contentMarkdown: current.contentMarkdown,
      contentHash: current.contentHash,
      continuityVerdict: current.continuityVerdict,
      continuityReportMarkdown: current.continuityReportMarkdown,
      memorySyncStatus: MemorySyncStatus.pendingReview,
      memorySyncContentHash: input.contentHash,
      memorySyncProposedRuntimeState: input.proposedMemory.runtimeState,
      memorySyncProposedRuntimeThreads: input.proposedMemory.runtimeThreads,
      memorySyncProposedStorySummary: input.proposedMemory.storySummary,
      memorySyncProposedContinuityIndex: input.proposedMemory.continuityIndex,
      memorySyncProposedChapterArchiveMarkdown:
          input.proposedMemory.chapterArchiveMarkdown,
      memorySyncPatchYaml: input.patchYaml,
      createdAt: current.createdAt,
      updatedAt: _testUpdatedAt,
    );
    chapters[index] = saved;
    emit();
    return saved;
  }

  @override
  Future<ProjectChapter> applyMemorySyncPatch(String chapterId) async {
    final index = chapters.indexWhere((chapter) => chapter.id == chapterId);
    final current = chapters[index];
    memory = ProjectRuntimeMemory(
      projectId: current.projectId,
      state: RuntimeMemoryState(
        runtimeState: current.memorySyncProposedRuntimeState,
        runtimeThreads: current.memorySyncProposedRuntimeThreads,
        storySummary: current.memorySyncProposedStorySummary,
        continuityIndex: current.memorySyncProposedContinuityIndex,
        chapterArchiveMarkdown:
            current.memorySyncProposedChapterArchiveMarkdown,
      ),
      createdAt: memory.createdAt,
      updatedAt: _testUpdatedAt,
    );
    final saved = ProjectChapter(
      id: current.id,
      projectId: current.projectId,
      chapterPlanId: current.chapterPlanId,
      chapterIndex: current.chapterIndex,
      title: current.title,
      contentMarkdown: current.contentMarkdown,
      contentHash: current.contentHash,
      continuityVerdict: current.continuityVerdict,
      continuityReportMarkdown: current.continuityReportMarkdown,
      memorySyncStatus: MemorySyncStatus.synced,
      memorySyncContentHash: current.memorySyncContentHash,
      memorySyncProposedRuntimeState: current.memorySyncProposedRuntimeState,
      memorySyncProposedRuntimeThreads:
          current.memorySyncProposedRuntimeThreads,
      memorySyncProposedStorySummary: current.memorySyncProposedStorySummary,
      memorySyncProposedContinuityIndex:
          current.memorySyncProposedContinuityIndex,
      memorySyncProposedChapterArchiveMarkdown:
          current.memorySyncProposedChapterArchiveMarkdown,
      memorySyncPatchYaml: current.memorySyncPatchYaml,
      createdAt: current.createdAt,
      updatedAt: _testUpdatedAt,
    );
    chapters[index] = saved;
    emit();
    return saved;
  }

  @override
  Future<ProjectChapter> discardMemorySyncPatch(String chapterId) async {
    final index = chapters.indexWhere((chapter) => chapter.id == chapterId);
    final current = chapters[index];
    if (current.memorySyncStatus != MemorySyncStatus.pendingReview) {
      throw StateError('没有待审阅的记忆同步提案。');
    }
    final saved = ProjectChapter(
      id: current.id,
      projectId: current.projectId,
      chapterPlanId: current.chapterPlanId,
      chapterIndex: current.chapterIndex,
      title: current.title,
      contentMarkdown: current.contentMarkdown,
      contentHash: current.contentHash,
      continuityVerdict: current.continuityVerdict,
      continuityReportMarkdown: current.continuityReportMarkdown,
      memorySyncStatus: MemorySyncStatus.discarded,
      memorySyncContentHash: current.memorySyncContentHash,
      memorySyncProposedRuntimeState: current.memorySyncProposedRuntimeState,
      memorySyncProposedRuntimeThreads:
          current.memorySyncProposedRuntimeThreads,
      memorySyncProposedStorySummary: current.memorySyncProposedStorySummary,
      memorySyncProposedContinuityIndex:
          current.memorySyncProposedContinuityIndex,
      memorySyncProposedChapterArchiveMarkdown:
          current.memorySyncProposedChapterArchiveMarkdown,
      memorySyncPatchYaml: current.memorySyncPatchYaml,
      createdAt: current.createdAt,
      updatedAt: _testUpdatedAt,
    );
    chapters[index] = saved;
    emit();
    return saved;
  }

  @override
  Future<ProjectRuntimeMemory> saveRuntimeMemory({
    required String projectId,
    required RuntimeMemoryState state,
  }) async {
    memory = ProjectRuntimeMemory(
      projectId: projectId,
      state: state,
      createdAt: memory.createdAt,
      updatedAt: _testUpdatedAt,
    );
    emit();
    return memory;
  }

  @override
  Future<NovelCharacter> saveCharacter({
    String? id,
    required NovelCharacterInput input,
  }) async {
    final existingIndex = id == null
        ? -1
        : characters.indexWhere((character) => character.id == id);
    final saved = NovelCharacter(
      id: id ?? 'character-${characters.length + 1}',
      projectId: input.projectId,
      name: input.name,
      aliases: input.aliases,
      tags: input.tags,
      faction: input.faction,
      role: input.role,
      longTermGoal: input.longTermGoal,
      currentStatus: input.currentStatus,
      secrets: input.secrets,
      firstChapterIndex: input.firstChapterIndex,
      lastChapterIndex: input.lastChapterIndex,
      createdAt: _testCreatedAt,
      updatedAt: _testUpdatedAt,
    );
    if (existingIndex == -1) {
      characters.add(saved);
    } else {
      characters[existingIndex] = saved;
    }
    emit();
    return saved;
  }

  @override
  Future<NovelRelationship> saveRelationship({
    String? id,
    required NovelRelationshipInput input,
  }) async {
    final existingIndex = id == null
        ? -1
        : relationships.indexWhere((relationship) => relationship.id == id);
    final saved = NovelRelationship(
      id: id ?? 'relationship-${relationships.length + 1}',
      projectId: input.projectId,
      fromCharacterId: input.fromCharacterId,
      toCharacterId: input.toCharacterId,
      relationshipType: input.relationshipType,
      strength: input.strength,
      status: input.status,
      description: input.description,
      lastChangedChapterIndex: input.lastChangedChapterIndex,
      createdAt: _testCreatedAt,
      updatedAt: _testUpdatedAt,
    );
    if (existingIndex == -1) {
      relationships.add(saved);
    } else {
      relationships[existingIndex] = saved;
    }
    emit();
    return saved;
  }

  @override
  Future<ChapterVolume> saveChapterVolume({
    String? id,
    required ChapterVolumeInput input,
  }) async {
    final existingIndex = id == null
        ? -1
        : volumes.indexWhere((volume) => volume.id == id);
    final saved = ChapterVolume(
      id: id ?? 'volume-${volumes.length + 1}',
      projectId: input.projectId,
      volumeIndex: input.volumeIndex,
      title: input.title,
      targetLength: input.targetLength,
      summary: input.summary,
      centralConflict: input.centralConflict,
      characterProgression: input.characterProgression,
      endingHook: input.endingHook,
      createdAt: existingIndex == -1
          ? _testCreatedAt
          : volumes[existingIndex].createdAt,
      updatedAt: _testUpdatedAt,
    );
    if (existingIndex == -1) {
      volumes.add(saved);
    } else {
      volumes[existingIndex] = saved;
    }
    volumes.sort((a, b) => a.volumeIndex.compareTo(b.volumeIndex));
    emit();
    return saved;
  }

  @override
  Future<ProjectBible> saveProjectBible(ProjectBibleInput input) async {
    bible = ProjectBible(
      projectId: input.projectId,
      descriptionMarkdown: input.descriptionMarkdown,
      worldBuildingMarkdown: input.worldBuildingMarkdown,
      charactersBlueprintMarkdown: input.charactersBlueprintMarkdown,
      outlineMasterMarkdown: input.outlineMasterMarkdown,
      outlineDetailYaml: input.outlineDetailYaml,
      createdAt: _testCreatedAt,
      updatedAt: _testUpdatedAt,
    );
    emit();
    return bible;
  }

  @override
  Future<ProjectBible> saveOutlineDetailYaml({
    required String projectId,
    required String outlineDetailYaml,
  }) async {
    bible = ProjectBible(
      projectId: bible.projectId,
      descriptionMarkdown: bible.descriptionMarkdown,
      worldBuildingMarkdown: bible.worldBuildingMarkdown,
      charactersBlueprintMarkdown: bible.charactersBlueprintMarkdown,
      outlineMasterMarkdown: bible.outlineMasterMarkdown,
      outlineDetailYaml: outlineDetailYaml,
      createdAt: bible.createdAt,
      updatedAt: _testUpdatedAt,
    );
    emit();
    return bible;
  }

  @override
  Future<ProjectBible> applyAssetGenerationDraft(String runId) async {
    final run = assetRuns.singleWhere((item) => item.id == runId);
    final draft = run.draftMarkdown;
    final saved = switch (run.kind) {
      AssetGenerationKind.worldBuilding => await saveProjectBible(
        ProjectBibleInput(
          projectId: bible.projectId,
          descriptionMarkdown: bible.descriptionMarkdown,
          worldBuildingMarkdown: draft,
          charactersBlueprintMarkdown: bible.charactersBlueprintMarkdown,
          outlineMasterMarkdown: bible.outlineMasterMarkdown,
          outlineDetailYaml: bible.outlineDetailYaml,
        ),
      ),
      AssetGenerationKind.charactersBlueprint => bible,
      AssetGenerationKind.outlineMaster => await saveProjectBible(
        ProjectBibleInput(
          projectId: bible.projectId,
          descriptionMarkdown: bible.descriptionMarkdown,
          worldBuildingMarkdown: bible.worldBuildingMarkdown,
          charactersBlueprintMarkdown: bible.charactersBlueprintMarkdown,
          outlineMasterMarkdown: draft,
          outlineDetailYaml: bible.outlineDetailYaml,
        ),
      ),
      AssetGenerationKind.volumeBlueprintYaml => bible,
      AssetGenerationKind.outlineDetailYaml => await saveOutlineDetailYaml(
        projectId: bible.projectId,
        outlineDetailYaml: draft,
      ),
    };
    await updateAssetGenerationRunState(
      id: run.id,
      status: AssetGenerationStatus.applied,
    );
    return saved;
  }

  @override
  Future<ChapterGenerationRun> updateChapterGenerationRunState({
    required String id,
    required ChapterGenerationStatus status,
    ChapterGenerationStage? stage,
    String? chapterId,
    String? providerId,
    String? modelName,
    String? errorMessage,
    String? logs,
    String? contextWarningsMarkdown,
    String? draftMarkdown,
    ContinuityVerdict? continuityVerdict,
    String? continuityReportMarkdown,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final index = runs.indexWhere((run) => run.id == id);
    final current = runs[index];
    final updated = ChapterGenerationRun(
      id: current.id,
      workflowTaskId: current.workflowTaskId,
      projectId: current.projectId,
      chapterPlanId: current.chapterPlanId,
      chapterId: chapterId ?? current.chapterId,
      providerId: providerId ?? current.providerId,
      modelName: modelName ?? current.modelName,
      status: status,
      stage: stage,
      errorMessage: errorMessage,
      logs: logs ?? current.logs,
      contextWarningsMarkdown:
          contextWarningsMarkdown ?? current.contextWarningsMarkdown,
      draftMarkdown: draftMarkdown ?? current.draftMarkdown,
      continuityVerdict: continuityVerdict ?? current.continuityVerdict,
      continuityReportMarkdown:
          continuityReportMarkdown ?? current.continuityReportMarkdown,
      createdAt: current.createdAt,
      updatedAt: _testUpdatedAt,
      startedAt: startedAt ?? current.startedAt,
      completedAt: completedAt ?? current.completedAt,
    );
    runs[index] = updated;
    emit();
    return updated;
  }

  @override
  Future<ChapterGenerationBatch> updateChapterGenerationBatchState({
    required String id,
    required ChapterGenerationBatchStatus status,
    String? providerId,
    String? modelName,
    String? errorMessage,
    String? logs,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final index = generationBatches.indexWhere((batch) => batch.id == id);
    final current = generationBatches[index];
    final updated = ChapterGenerationBatch(
      id: current.id,
      workflowTaskId: current.workflowTaskId,
      projectId: current.projectId,
      providerId: providerId ?? current.providerId,
      modelName: modelName ?? current.modelName,
      status: status,
      errorMessage: errorMessage,
      totalCount: current.totalCount,
      syncedCount: generationBatchItems
          .where(
            (item) =>
                item.batchId == id &&
                item.status == ChapterGenerationBatchItemStatus.synced,
          )
          .length,
      failedCount: generationBatchItems
          .where(
            (item) =>
                item.batchId == id &&
                item.status == ChapterGenerationBatchItemStatus.failed,
          )
          .length,
      logs: logs ?? current.logs,
      createdAt: current.createdAt,
      updatedAt: _testUpdatedAt,
      startedAt: startedAt ?? current.startedAt,
      completedAt: completedAt ?? current.completedAt,
    );
    generationBatches[index] = updated;
    emit();
    return updated;
  }

  @override
  Future<ChapterGenerationBatchItem> updateChapterGenerationBatchItemState({
    required String id,
    required ChapterGenerationBatchItemStatus status,
    String? errorMessage,
    String? chapterId,
    String? latestRunId,
    int? draftAttemptCount,
    int? patchAttemptCount,
    String? logs,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? syncedAt,
    bool clearStartedAt = false,
    bool clearCompletedAt = false,
    bool clearSyncedAt = false,
  }) async {
    final index = generationBatchItems.indexWhere((item) => item.id == id);
    final current = generationBatchItems[index];
    final updated = ChapterGenerationBatchItem(
      id: current.id,
      batchId: current.batchId,
      projectId: current.projectId,
      chapterPlanId: current.chapterPlanId,
      chapterId: chapterId ?? current.chapterId,
      latestRunId: latestRunId ?? current.latestRunId,
      position: current.position,
      status: status,
      errorMessage: errorMessage,
      draftAttemptCount: draftAttemptCount ?? current.draftAttemptCount,
      patchAttemptCount: patchAttemptCount ?? current.patchAttemptCount,
      logs: logs ?? current.logs,
      createdAt: current.createdAt,
      updatedAt: _testUpdatedAt,
      startedAt: clearStartedAt ? null : startedAt ?? current.startedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? current.completedAt,
      syncedAt: clearSyncedAt ? null : syncedAt ?? current.syncedAt,
    );
    generationBatchItems[index] = updated;
    emit();
    return updated;
  }

  @override
  Future<AssetGenerationRun> updateAssetGenerationRunState({
    required String id,
    required AssetGenerationStatus status,
    AssetGenerationStage? stage,
    String? providerId,
    String? modelName,
    String? errorMessage,
    String? logs,
    String? draftMarkdown,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final index = assetRuns.indexWhere((run) => run.id == id);
    final current = assetRuns[index];
    final updated = AssetGenerationRun(
      id: current.id,
      workflowTaskId: current.workflowTaskId,
      projectId: current.projectId,
      targetVolumeId: current.targetVolumeId,
      kind: current.kind,
      providerId: providerId ?? current.providerId,
      modelName: modelName ?? current.modelName,
      status: status,
      stage: stage,
      errorMessage: errorMessage,
      logs: logs ?? current.logs,
      draftMarkdown: draftMarkdown ?? current.draftMarkdown,
      createdAt: current.createdAt,
      updatedAt: _testUpdatedAt,
      startedAt: startedAt ?? current.startedAt,
      completedAt: completedAt ?? current.completedAt,
    );
    assetRuns[index] = updated;
    emit();
    return updated;
  }

  @override
  Future<ChapterEnrichmentBatch> updateChapterEnrichmentBatchState({
    required String id,
    required ChapterEnrichmentBatchStatus status,
    String? providerId,
    String? modelName,
    String? errorMessage,
    String? logs,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final index = enrichmentBatches.indexWhere((batch) => batch.id == id);
    final current = enrichmentBatches[index];
    final updated = ChapterEnrichmentBatch(
      id: current.id,
      workflowTaskId: current.workflowTaskId,
      projectId: current.projectId,
      instruction: current.instruction,
      expansionRatioPercent: current.expansionRatioPercent,
      providerId: providerId ?? current.providerId,
      modelName: modelName ?? current.modelName,
      status: status,
      errorMessage: errorMessage,
      totalCount: current.totalCount,
      generatedCount: enrichmentItems
          .where(
            (item) =>
                item.batchId == id &&
                item.status == ChapterEnrichmentItemStatus.generated,
          )
          .length,
      failedCount: enrichmentItems
          .where(
            (item) =>
                item.batchId == id &&
                item.status == ChapterEnrichmentItemStatus.failed,
          )
          .length,
      appliedCount: enrichmentItems
          .where(
            (item) =>
                item.batchId == id &&
                item.status == ChapterEnrichmentItemStatus.applied,
          )
          .length,
      logs: logs ?? current.logs,
      createdAt: current.createdAt,
      updatedAt: _testUpdatedAt,
      startedAt: startedAt ?? current.startedAt,
      completedAt: completedAt ?? current.completedAt,
    );
    enrichmentBatches[index] = updated;
    emit();
    return updated;
  }

  @override
  Future<ChapterEnrichmentItem> updateChapterEnrichmentItemState({
    required String id,
    required ChapterEnrichmentItemStatus status,
    String? errorMessage,
    String? originalContentMarkdown,
    String? generatedContentMarkdown,
    String? providerId,
    String? modelName,
    String? logs,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? appliedAt,
    bool clearStartedAt = false,
    bool clearCompletedAt = false,
    bool clearAppliedAt = false,
  }) async {
    final index = enrichmentItems.indexWhere((item) => item.id == id);
    final current = enrichmentItems[index];
    final updated = ChapterEnrichmentItem(
      id: current.id,
      batchId: current.batchId,
      projectId: current.projectId,
      chapterId: current.chapterId,
      position: current.position,
      status: status,
      errorMessage: errorMessage,
      originalContentMarkdown:
          originalContentMarkdown ?? current.originalContentMarkdown,
      generatedContentMarkdown:
          generatedContentMarkdown ?? current.generatedContentMarkdown,
      providerId: providerId ?? current.providerId,
      modelName: modelName ?? current.modelName,
      logs: logs ?? current.logs,
      createdAt: current.createdAt,
      updatedAt: _testUpdatedAt,
      startedAt: clearStartedAt ? null : startedAt ?? current.startedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? current.completedAt,
      appliedAt: clearAppliedAt ? null : appliedAt ?? current.appliedAt,
    );
    enrichmentItems[index] = updated;
    emit();
    return updated;
  }

  @override
  Stream<List<ChapterGenerationRun>> watchChapterGenerationRuns(
    String projectId,
  ) async* {
    List<ChapterGenerationRun> snapshot() =>
        runs.where((run) => run.projectId == projectId).toList(growable: false);
    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }

  @override
  Stream<List<ChapterGenerationBatch>> watchChapterGenerationBatches(
    String projectId,
  ) async* {
    List<ChapterGenerationBatch> snapshot() => generationBatches
        .where((batch) => batch.projectId == projectId)
        .toList(growable: false);
    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }

  @override
  Stream<List<ChapterGenerationBatchItem>> watchChapterGenerationBatchItems(
    String batchId,
  ) async* {
    List<ChapterGenerationBatchItem> snapshot() => generationBatchItems
        .where((item) => item.batchId == batchId)
        .toList(growable: false);
    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }

  @override
  Stream<List<AssetGenerationRun>> watchAssetGenerationRuns(
    String projectId,
  ) async* {
    List<AssetGenerationRun> snapshot() => assetRuns
        .where((run) => run.projectId == projectId)
        .toList(growable: false);
    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }

  @override
  Stream<List<ChapterEnrichmentBatch>> watchChapterEnrichmentBatches(
    String projectId,
  ) async* {
    List<ChapterEnrichmentBatch> snapshot() => enrichmentBatches
        .where((batch) => batch.projectId == projectId)
        .toList(growable: false);
    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }

  @override
  Stream<List<ChapterEnrichmentItem>> watchChapterEnrichmentItems(
    String batchId,
  ) async* {
    List<ChapterEnrichmentItem> snapshot() => enrichmentItems
        .where((item) => item.batchId == batchId)
        .toList(growable: false);
    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }

  @override
  Stream<ChapterGenerationRun?> watchChapterGenerationRunByWorkflowTask(
    String workflowTaskId,
  ) async* {
    yield runs.where((run) => run.workflowTaskId == workflowTaskId).firstOrNull;
    yield* _changes.stream.map(
      (_) =>
          runs.where((run) => run.workflowTaskId == workflowTaskId).firstOrNull,
    );
  }

  @override
  Stream<ChapterGenerationBatch?> watchChapterGenerationBatchByWorkflowTask(
    String workflowTaskId,
  ) async* {
    yield generationBatches
        .where((batch) => batch.workflowTaskId == workflowTaskId)
        .firstOrNull;
    yield* _changes.stream.map(
      (_) => generationBatches
          .where((batch) => batch.workflowTaskId == workflowTaskId)
          .firstOrNull,
    );
  }

  @override
  Stream<AssetGenerationRun?> watchAssetGenerationRunByWorkflowTask(
    String workflowTaskId,
  ) async* {
    yield assetRuns
        .where((run) => run.workflowTaskId == workflowTaskId)
        .firstOrNull;
    yield* _changes.stream.map(
      (_) => assetRuns
          .where((run) => run.workflowTaskId == workflowTaskId)
          .firstOrNull,
    );
  }

  @override
  Stream<ChapterEnrichmentBatch?> watchChapterEnrichmentBatchByWorkflowTask(
    String workflowTaskId,
  ) async* {
    yield enrichmentBatches
        .where((batch) => batch.workflowTaskId == workflowTaskId)
        .firstOrNull;
    yield* _changes.stream.map(
      (_) => enrichmentBatches
          .where((batch) => batch.workflowTaskId == workflowTaskId)
          .firstOrNull,
    );
  }

  @override
  Stream<ChapterIllustrationGenerationRun?>
  watchChapterIllustrationGenerationRunByWorkflowTask(
    String workflowTaskId,
  ) async* {
    yield illustrationRuns
        .where((run) => run.workflowTaskId == workflowTaskId)
        .firstOrNull;
    yield* _changes.stream.map(
      (_) => illustrationRuns
          .where((run) => run.workflowTaskId == workflowTaskId)
          .firstOrNull,
    );
  }

  @override
  Future<void> abandonWorkflowTask(String workflowTaskId) async {}

  @override
  Stream<List<ChapterPlan>> watchChapterPlans(String projectId) async* {
    List<ChapterPlan> snapshot() => plans
        .where((plan) => plan.projectId == projectId)
        .toList(growable: false);
    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }

  @override
  Stream<ProjectBible> watchProjectBible(String projectId) async* {
    yield bible;
    yield* _changes.stream.map((_) => bible);
  }

  @override
  Stream<List<ChapterVolume>> watchChapterVolumes(String projectId) async* {
    List<ChapterVolume> snapshot() => volumes
        .where((volume) => volume.projectId == projectId)
        .toList(growable: false);
    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }

  @override
  Stream<List<NovelCharacter>> watchCharacters(String projectId) async* {
    List<NovelCharacter> snapshot() => characters
        .where((character) => character.projectId == projectId)
        .toList(growable: false);
    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }

  @override
  Stream<List<NovelRelationship>> watchRelationships(String projectId) async* {
    List<NovelRelationship> snapshot() => relationships
        .where((relationship) => relationship.projectId == projectId)
        .toList(growable: false);
    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }

  @override
  Future<void> applyCharactersYaml({
    required String projectId,
    required String charactersYaml,
  }) async {}

  @override
  Future<List<ChapterVolume>> watchChapterVolumesOnce(String projectId) async {
    return volumes
        .where((volume) => volume.projectId == projectId)
        .toList(growable: false);
  }

  @override
  Stream<List<ProjectChapter>> watchChapters(String projectId) async* {
    List<ProjectChapter> snapshot() => chapters
        .where((chapter) => chapter.projectId == projectId)
        .toList(growable: false);
    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }

  @override
  Stream<List<ChapterIllustration>> watchChapterIllustrations(
    String projectId,
  ) async* {
    List<ChapterIllustration> snapshot() => illustrations
        .where((illustration) => illustration.projectId == projectId)
        .toList(growable: false);
    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }

  @override
  Stream<List<ChapterIllustrationGenerationRun>>
  watchChapterIllustrationGenerationRuns(String projectId) async* {
    List<ChapterIllustrationGenerationRun> snapshot() => illustrationRuns
        .where((run) => run.projectId == projectId)
        .toList(growable: false);
    yield snapshot();
    yield* _changes.stream.map((_) => snapshot());
  }
}

class _FakeStyleLabRepository implements StyleLabRepository {
  @override
  Future<StyleProfile?> findProfile(String id) async {
    if (id != 'style-1') return null;
    return StyleProfile(
      id: id,
      sourceRunId: 'style-run',
      providerId: 'provider-1',
      modelName: 'gpt-4.1-mini',
      styleName: '冷峻悬疑风格',
      profileMarkdown: '# Voice Profile',
      analysisReportMarkdown: '# Report',
      createdAt: DateTime(2026, 5, 18, 9),
      updatedAt: DateTime(2026, 5, 18, 10),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlotLabRepository implements PlotLabRepository {
  @override
  Future<PlotProfile?> findProfile(String id) async {
    if (id != 'plot-1') return null;
    return PlotProfile(
      id: id,
      sourceRunId: 'plot-run',
      providerId: 'provider-1',
      modelName: 'gpt-4.1-mini',
      plotName: '港城悬疑引擎',
      storyEngineMarkdown: '# Plot Writing Guide',
      analysisReportMarkdown: '# Report',
      plotSkeletonMarkdown: '# Skeleton',
      createdAt: DateTime(2026, 5, 18, 9),
      updatedAt: DateTime(2026, 5, 18, 10),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ChapterPlan _plan({
  required String id,
  required int index,
  required String title,
  required String objective,
}) {
  return ChapterPlan(
    id: id,
    projectId: 'project-1',
    volumeId: 'volume-1',
    volumeIndex: 1,
    volumeTitle: '第一卷',
    chapterLocalIndex: index,
    chapterIndex: index,
    objectiveCard: ChapterObjectiveCard(
      chapterTitle: title,
      objective: objective,
      pressureSource: '追兵逼近。',
      payoffTarget: '找到线索。',
      relationshipShift: '主角与向导合作。',
      hookType: '信息差钩子。',
    ),
    coreEvent: '核心事件。',
    emotionArc: '情绪推进。',
    chapterHook: '章末钩子。',
    outlineMarkdown: '- 章节细纲。',
    createdAt: _testCreatedAt,
    updatedAt: _testUpdatedAt,
  );
}

ProjectChapter _chapter({
  String id = 'chapter-1',
  required String planId,
  required int index,
  String title = '第一章',
  required String content,
  ContinuityVerdict continuityVerdict = ContinuityVerdict.pass,
  String continuityReportMarkdown = '',
  MemorySyncStatus memorySyncStatus = MemorySyncStatus.idle,
  RuntimeMemoryState proposedMemory = const RuntimeMemoryState(),
  String memorySyncPatchYaml = '',
}) {
  final contentHash = content.hashCode.toString();
  return ProjectChapter(
    id: id,
    projectId: 'project-1',
    chapterPlanId: planId,
    chapterIndex: index,
    title: title,
    contentMarkdown: content,
    contentHash: contentHash,
    continuityVerdict: continuityVerdict,
    continuityReportMarkdown: continuityReportMarkdown,
    memorySyncStatus: memorySyncStatus,
    memorySyncContentHash: memorySyncStatus == MemorySyncStatus.idle
        ? ''
        : contentHash,
    memorySyncProposedRuntimeState: proposedMemory.runtimeState,
    memorySyncProposedRuntimeThreads: proposedMemory.runtimeThreads,
    memorySyncProposedStorySummary: proposedMemory.storySummary,
    memorySyncProposedContinuityIndex: proposedMemory.continuityIndex,
    memorySyncProposedChapterArchiveMarkdown:
        proposedMemory.chapterArchiveMarkdown,
    memorySyncPatchYaml: memorySyncPatchYaml,
    createdAt: DateTime(2026, 5, 18, 9),
    updatedAt: DateTime(2026, 5, 18, 10),
  );
}

ChapterIllustration _illustration({
  required String id,
  required String chapterId,
  required int paragraphIndex,
  required String selectedText,
  required String prompt,
  required ChapterIllustrationStatus status,
  String planId = 'plan-1',
}) {
  return ChapterIllustration(
    id: id,
    projectId: 'project-1',
    chapterId: chapterId,
    chapterPlanId: planId,
    paragraphIndex: paragraphIndex,
    anchorTextHash: selectedText.hashCode.toString(),
    selectedText: selectedText,
    prompt: prompt,
    providerId: 'image-provider-1',
    modelName: 'gpt-image-1',
    localPath: '/tmp/nonexistent-$id.png',
    mimeType: 'image/png',
    status: status,
    createdAt: _testCreatedAt,
    updatedAt: _testUpdatedAt,
    acceptedAt: status == ChapterIllustrationStatus.inserted
        ? _testUpdatedAt
        : null,
  );
}

ChapterIllustrationGenerationRun _illustrationRun({
  required String id,
  required String chapterId,
  required String planId,
  required String prompt,
  required String selectedText,
  required ChapterIllustrationGenerationStatus status,
  String? errorMessage,
}) {
  return ChapterIllustrationGenerationRun(
    id: id,
    workflowTaskId: 'task-$id',
    projectId: 'project-1',
    chapterId: chapterId,
    chapterPlanId: planId,
    paragraphIndex: 0,
    anchorTextHash: selectedText.hashCode.toString(),
    selectedText: selectedText,
    prompt: prompt,
    providerId: 'image-provider-1',
    modelName: 'gpt-image-1',
    aspectRatio: ImageAspectRatioPreset.square.ratio,
    size: ImageSizePreset.oneK.tier,
    quality: ImageQualityPreset.auto.quality,
    responseFormat: ImageResponseFormat.url.name,
    status: status,
    stage: null,
    errorMessage: errorMessage,
    logs: '',
    illustrationId: null,
    createdAt: _testCreatedAt,
    updatedAt: _testUpdatedAt,
    startedAt: status == ChapterIllustrationGenerationStatus.running
        ? _testCreatedAt
        : null,
    completedAt: status == ChapterIllustrationGenerationStatus.failed
        ? _testUpdatedAt
        : null,
  );
}

ChapterEnrichmentBatch _enrichmentBatch() {
  return ChapterEnrichmentBatch(
    id: 'enrichment-batch-1',
    workflowTaskId: 'enrichment-task-1',
    projectId: 'project-1',
    instruction: '增强心理描写。',
    expansionRatioPercent: 20,
    providerId: 'provider-1',
    modelName: 'model-1',
    status: ChapterEnrichmentBatchStatus.succeeded,
    errorMessage: null,
    totalCount: 1,
    generatedCount: 1,
    failedCount: 0,
    appliedCount: 0,
    logs: '',
    createdAt: _testCreatedAt,
    updatedAt: _testUpdatedAt,
    startedAt: _testCreatedAt,
    completedAt: _testUpdatedAt,
  );
}

ChapterEnrichmentItem _enrichmentItem() {
  return ChapterEnrichmentItem(
    id: 'enrichment-item-1',
    batchId: 'enrichment-batch-1',
    projectId: 'project-1',
    chapterId: 'chapter-1',
    position: 0,
    status: ChapterEnrichmentItemStatus.generated,
    errorMessage: null,
    originalContentMarkdown: '旧正文。',
    generatedContentMarkdown: '新正文。',
    providerId: 'provider-1',
    modelName: 'model-1',
    logs: '',
    createdAt: _testCreatedAt,
    updatedAt: _testUpdatedAt,
    startedAt: _testCreatedAt,
    completedAt: _testUpdatedAt,
    appliedAt: null,
  );
}

ChapterGenerationBatch _generationBatch({
  required String id,
  required ChapterGenerationBatchStatus status,
  int totalCount = 1,
  int syncedCount = 0,
  int failedCount = 0,
  String? errorMessage,
}) {
  return ChapterGenerationBatch(
    id: id,
    workflowTaskId: 'task-$id',
    projectId: 'project-1',
    providerId: 'provider-1',
    modelName: 'model-1',
    status: status,
    errorMessage: errorMessage,
    totalCount: totalCount,
    syncedCount: syncedCount,
    failedCount: failedCount,
    logs: '批量草稿完成。',
    createdAt: _testCreatedAt,
    updatedAt: _testUpdatedAt,
    startedAt: _testCreatedAt,
    completedAt:
        status == ChapterGenerationBatchStatus.pending ||
            status == ChapterGenerationBatchStatus.running
        ? null
        : _testUpdatedAt,
  );
}

ChapterGenerationBatchItem _generationBatchItem({
  required String id,
  required String batchId,
  required String planId,
  required ChapterGenerationBatchItemStatus status,
}) {
  return ChapterGenerationBatchItem(
    id: id,
    batchId: batchId,
    projectId: 'project-1',
    chapterPlanId: planId,
    chapterId: null,
    latestRunId: null,
    position: 0,
    status: status,
    errorMessage: null,
    draftAttemptCount: status == ChapterGenerationBatchItemStatus.waiting
        ? 0
        : 1,
    patchAttemptCount: status == ChapterGenerationBatchItemStatus.waiting
        ? 0
        : 1,
    logs: '',
    createdAt: _testCreatedAt,
    updatedAt: _testUpdatedAt,
    startedAt: status == ChapterGenerationBatchItemStatus.waiting
        ? null
        : _testCreatedAt,
    completedAt:
        status == ChapterGenerationBatchItemStatus.running ||
            status == ChapterGenerationBatchItemStatus.waiting
        ? null
        : _testUpdatedAt,
    syncedAt: status == ChapterGenerationBatchItemStatus.synced
        ? _testUpdatedAt
        : null,
  );
}

ChapterGenerationRun _run({
  String id = 'run-1',
  String workflowTaskId = 'task-1',
  required String planId,
  required ChapterGenerationStatus status,
  String? chapterId,
  String draftMarkdown = '',
  ContinuityVerdict continuityVerdict = ContinuityVerdict.pass,
  String continuityReportMarkdown = '',
}) {
  return ChapterGenerationRun(
    id: id,
    workflowTaskId: workflowTaskId,
    projectId: 'project-1',
    chapterPlanId: planId,
    chapterId: chapterId,
    providerId: 'provider-1',
    modelName: 'gpt-4.1-mini',
    status: status,
    stage: status == ChapterGenerationStatus.running
        ? ChapterGenerationStage.generatingDraft
        : null,
    errorMessage: null,
    logs: '章节生成完成。',
    contextWarningsMarkdown: '',
    draftMarkdown: draftMarkdown,
    continuityVerdict: continuityVerdict,
    continuityReportMarkdown: continuityReportMarkdown,
    createdAt: DateTime(2026, 5, 18, 9),
    updatedAt: DateTime(2026, 5, 18, 10),
    startedAt: DateTime(2026, 5, 18, 9),
    completedAt: status == ChapterGenerationStatus.running
        ? null
        : DateTime(2026, 5, 18, 10),
  );
}

AssetGenerationRun _assetRun({
  required String id,
  required String projectId,
  required AssetGenerationKind kind,
  required AssetGenerationStatus status,
  String? targetVolumeId,
  String draftMarkdown = '生成草稿。',
}) {
  return AssetGenerationRun(
    id: id,
    workflowTaskId: 'task-$id',
    projectId: projectId,
    targetVolumeId: targetVolumeId,
    kind: kind,
    providerId: 'provider-1',
    modelName: 'gpt-4.1-mini',
    status: status,
    stage: status == AssetGenerationStatus.running
        ? AssetGenerationStage.generatingDraft
        : null,
    errorMessage: null,
    logs: '资产生成完成。',
    draftMarkdown: draftMarkdown,
    createdAt: DateTime(2026, 5, 18, 9),
    updatedAt: DateTime(2026, 5, 18, 10),
    startedAt: DateTime(2026, 5, 18, 9),
    completedAt: status == AssetGenerationStatus.running
        ? null
        : DateTime(2026, 5, 18, 10),
  );
}
