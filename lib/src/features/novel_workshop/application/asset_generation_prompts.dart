import '../../projects/domain/writing_project.dart';
import '../domain/novel_workshop.dart';
import '../domain/writing_context.dart';

class AssetGenerationPromptBuilder {
  const AssetGenerationPromptBuilder();

  String buildPrompt({
    required AssetGenerationKind kind,
    required WritingProject project,
    required ProjectBible bible,
    required ProjectPromptAssets assets,
    ChapterVolume? targetVolume,
  }) {
    return switch (kind) {
      AssetGenerationKind.worldBuilding => _worldBuilding(project, bible),
      AssetGenerationKind.charactersBlueprint => _characters(project, bible),
      AssetGenerationKind.outlineMaster => _outlineMaster(
        project,
        bible,
        assets,
      ),
      AssetGenerationKind.volumeBlueprintYaml => _volumeBlueprintYaml(
        project,
        bible,
        assets,
      ),
      AssetGenerationKind.outlineDetailYaml => _outlineDetailYaml(
        project,
        bible,
        assets,
        targetVolume,
      ),
    };
  }

  String _worldBuilding(WritingProject project, ProjectBible bible) {
    return '''
你是长篇小说项目的世界观设定编辑。

## 输出契约
- 只输出 Markdown 文档。
- 不要输出代码围栏。
- 不要解释生成过程。
- 内容必须可直接保存为“世界观设定”。
- 明确世界规则、地域/组织、资源/技术或魔法边界、不可破坏设定。

## 项目参数
${_projectBlock(project)}

## 项目简介
${_fallback(bible.descriptionMarkdown, project.description)}

## 已有世界观设定
${_fallback(bible.worldBuildingMarkdown, '暂无。请从项目参数和简介生成第一版。')}
''';
  }

  String _characters(WritingProject project, ProjectBible bible) {
    return '''
你是长篇小说项目的角色设定编辑。

## 输出契约
- 只输出 YAML。
- 不要输出 Markdown。
- 不要输出代码围栏。
- 不要解释生成过程。
- 输出必须可解析为 YAML 对象。
- 根节点允许 `characters` 和 `relationships`。
- 每个 character 必须有 `name`，可包含 `aliases`、`tags`、`faction`、`role`、`longTermGoal`、`currentStatus`、`secrets`、`firstChapterIndex`、`lastChapterIndex`。
- 每个 relationship 必须有 `from`、`to`，可包含 `type`、`strength`、`status`、`description`、`lastChangedChapterIndex`。
- `relationship.from` 和 `relationship.to` 必须引用 `characters.name`。
- `strength` 使用 -5 到 5 的整数，负数代表冲突/敌意，正数代表信任/亲近。
- 至少包含核心角色、阵营/关系、长期动机、显性冲突和写作禁忌。
- 不要违背已确认世界观。

## YAML 模板
characters:
  - name: 林岚
    aliases: [林调查员]
    tags: [主角, 调查者]
    faction: 港务外来者
    role: 主线调查者
    longTermGoal: 查清失踪案真相
    currentStatus: 刚抵达雾港
    secrets: 不要提前揭露旧案身份
relationships:
  - from: 林岚
    to: 向导
    type: 临时合作
    strength: 1
    status: 互相试探
    description: 林岚需要向导进入港务禁区。

## 项目参数
${_projectBlock(project)}

## 世界观设定
${_fallback(bible.worldBuildingMarkdown, '暂无。若信息不足，请显式标注待确认。')}

## 旧角色索引参考
${_fallback(bible.charactersBlueprintMarkdown, '暂无。请生成第一版结构化角色卡片。')}
''';
  }

  String _outlineMaster(
    WritingProject project,
    ProjectBible bible,
    ProjectPromptAssets assets,
  ) {
    return '''
你是长篇小说项目的总纲编辑。

## 输出契约
- 只输出 Markdown 文档。
- 不要输出代码围栏。
- 不要解释生成过程。
- 内容必须可直接保存为“总纲”。
- 必须包含主线推进、核心矛盾、卷间结构、主题演进、结局约束。
- 必须按全书目标字数规划完整开端、发展、转折、高潮和结局，不要只写第一卷。
- 不要违背已确认世界观和角色设定。

## 项目参数
${_projectBlock(project)}

## 世界观设定
${_fallback(bible.worldBuildingMarkdown, '暂无。')}

## 角色索引与关系网
${_fallback(bible.charactersBlueprintMarkdown, '暂无。')}

## Story Engine
${_fallback(assets.storyEngineMarkdown, '暂无。')}

## 已有总纲
${_fallback(bible.outlineMasterMarkdown, '暂无。请生成第一版总纲。')}
''';
  }

  String _volumeBlueprintYaml(
    WritingProject project,
    ProjectBible bible,
    ProjectPromptAssets assets,
  ) {
    return '''
你是长篇小说项目的分卷规划师。

## 输出契约
- 只输出 YAML。
- 不要输出 Markdown。
- 不要输出代码围栏。
- 不要解释生成过程。
- 输出必须可被解析为 YAML 对象，根节点必须是 `volumes`。
- 必须先生成全书所有分卷，不要只生成第一卷。
- 每个 volume 必须有 `index`、`title`。
- 每个 volume 可包含 `targetLength`、`summary`、`centralConflict`、`characterProgression`、`endingHook`。
- 所有分卷 targetLength 总和应接近全书目标字数。
- 不要输出 chapters，章节细纲会在用户选择具体分卷后再生成。

## YAML 模板
volumes:
  - index: 1
    title: 第一卷
    targetLength: 25000
    summary: 本卷摘要
    centralConflict: 本卷核心矛盾
    characterProgression: 本卷角色推进
    endingHook: 本卷结尾钩子

## 项目参数
${_projectBlock(project)}

## 世界观设定
${_fallback(bible.worldBuildingMarkdown, '暂无。')}

## 旧角色索引参考
${_fallback(bible.charactersBlueprintMarkdown, '暂无。')}

## 总纲
${_fallback(bible.outlineMasterMarkdown, '暂无。')}

## Story Engine
${_fallback(assets.storyEngineMarkdown, '暂无。')}
''';
  }

  String _outlineDetailYaml(
    WritingProject project,
    ProjectBible bible,
    ProjectPromptAssets assets,
    ChapterVolume? targetVolume,
  ) {
    final targetVolumeBlock = targetVolume == null
        ? '未指定。若已有分卷规划，请生成全部分卷的章节细纲。'
        : [
            '- 卷序：${targetVolume.volumeIndex}',
            '- 卷名：${targetVolume.title}',
            '- 目标字数：${targetVolume.targetLength}',
            '- 摘要：${_fallback(targetVolume.summary, '暂无。')}',
            '- 核心矛盾：${_fallback(targetVolume.centralConflict, '暂无。')}',
            '- 角色推进：${_fallback(targetVolume.characterProgression, '暂无。')}',
            '- 结尾钩子：${_fallback(targetVolume.endingHook, '暂无。')}',
          ].join('\n');
    return '''
你是长篇小说项目的分卷与章节细纲规划师。

## 输出契约
- 只输出 YAML。
- 不要输出 Markdown。
- 不要输出代码围栏。
- 不要解释生成过程。
- 输出必须可被解析为 YAML 对象，根节点必须是 `volumes`。
- 每个 volume 必须有 `index`、`title`、`chapters`。
- 每个 chapter 必须有 `index`、`title`。
- 每个 chapter 可包含 `objective`、`pressureSource`、`payoffTarget`、`relationshipShift`、`hookType`、`coreEvent`、`emotionArc`、`chapterHook`、`outlineMarkdown`。
- chapter.index 是卷内序号，从 1 开始；全书章节序号由系统按分卷顺序自动推导。
- 如果提供了目标分卷，只输出该分卷一个 volume 的章节细纲。
- 不要违背已确认世界观、角色设定和总纲。

## YAML 模板
volumes:
  - index: 1
    title: 第一卷
    chapters:
      - index: 1
        title: 第一章
        objective: 本章目标
        pressureSource: 本章压力源
        payoffTarget: 本章兑现点
        relationshipShift: 关系变化
        hookType: 钩子类型
        coreEvent: 核心事件
        emotionArc: 情绪弧
        chapterHook: 章末钩子
        outlineMarkdown: |-
          - 场景推进
          - 关键转折

## 项目参数
${_projectBlock(project)}

## 世界观设定
${_fallback(bible.worldBuildingMarkdown, '暂无。')}

## 角色索引与关系网
${_fallback(bible.charactersBlueprintMarkdown, '暂无。')}

## 总纲
${_fallback(bible.outlineMasterMarkdown, '暂无。')}

## 目标分卷
$targetVolumeBlock

## Story Engine
${_fallback(assets.storyEngineMarkdown, '暂无。')}

## 已有细纲 YAML
${_fallback(bible.outlineDetailYaml, '暂无。请生成第一版分卷与章节细纲。')}
''';
  }

  String _projectBlock(WritingProject project) {
    return [
      '- 标题：${project.title.trim()}',
      '- 语言：${project.language.trim()}',
      '- 单章目标字数：${project.targetLength} 字左右',
      '- 全书目标字数：${project.totalTargetLength} 字左右',
      '- 叙事视角：${project.narrativePerspective.trim()}',
    ].join('\n');
  }

  String _fallback(String value, String fallback) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }
}
