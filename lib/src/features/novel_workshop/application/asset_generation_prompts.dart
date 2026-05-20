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
  }) {
    return switch (kind) {
      AssetGenerationKind.worldBuilding => _worldBuilding(project, bible),
      AssetGenerationKind.charactersBlueprint => _characters(project, bible),
      AssetGenerationKind.outlineMaster => _outlineMaster(
        project,
        bible,
        assets,
      ),
      AssetGenerationKind.outlineDetailYaml => _outlineDetailYaml(
        project,
        bible,
        assets,
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
- 只输出 Markdown 文档。
- 不要输出代码围栏。
- 不要解释生成过程。
- 内容必须可直接保存为“角色索引与关系网”。
- 至少包含核心角色、阵营/关系、长期动机、显性冲突和写作禁忌。
- 不要违背已确认世界观。

## 项目参数
${_projectBlock(project)}

## 世界观设定
${_fallback(bible.worldBuildingMarkdown, '暂无。若信息不足，请显式标注待确认。')}

## 已有角色索引
${_fallback(bible.charactersBlueprintMarkdown, '暂无。请生成第一版角色索引。')}
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

  String _outlineDetailYaml(
    WritingProject project,
    ProjectBible bible,
    ProjectPromptAssets assets,
  ) {
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
      '- 目标长度：${project.targetLength} 字左右',
      '- 叙事视角：${project.narrativePerspective.trim()}',
    ].join('\n');
  }

  String _fallback(String value, String fallback) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }
}
