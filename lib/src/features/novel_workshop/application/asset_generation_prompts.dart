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

  /// Builds a prompt that asks the model to fix a previously generated draft
  /// based on validation errors and optional user feedback.
  String buildRepairPrompt({
    required AssetGenerationKind kind,
    required WritingProject project,
    required ProjectBible bible,
    required ProjectPromptAssets assets,
    required String previousDraft,
    required String validationErrors,
    String userFeedback = '',
    ChapterVolume? targetVolume,
  }) {
    final basePrompt = buildPrompt(
      kind: kind,
      project: project,
      bible: bible,
      assets: assets,
      targetVolume: targetVolume,
    );
    final feedbackBlock = userFeedback.trim().isEmpty
        ? ''
        : '\n## 用户修改意见\n${userFeedback.trim()}\n';
    return '$basePrompt\n\n'
        '## 上一次生成的草稿（存在问题）\n'
        '$previousDraft\n\n'
        '## 校验错误\n'
        '$validationErrors\n'
        '$feedbackBlock'
        '请基于上一次草稿修复以上问题。保留草稿中正确的部分，'
        '只修正有问题的地方。输出完整的修正后内容。\n';
  }

  String _worldBuilding(WritingProject project, ProjectBible bible) {
    return '''
你是长篇小说项目的世界架构师。你的工作不是堆背景资料，而是设计一套能持续制造角色选择、冲突升级和伏笔回收的故事运行系统。

## 输出契约
- 只输出 Markdown 文档。
- 不要输出代码围栏。
- 不要解释生成过程。
- 内容必须可直接保存为“世界观设定”。

## 工作方法
先从项目简介中提炼核心 DNA：主角被什么事件推上行动轨道、必须做什么、失败会失去什么、暗处还有什么危机。随后围绕这个核心设计世界，而不是写与冲突无关的百科。

世界观至少覆盖三层：
- 物理维度：地理、资源、技术/魔法、规则边界和不可破坏设定。
- 社会维度：组织、阶层、制度、利益链、信息控制和公开秩序。
- 隐喻维度：环境、仪式、传说、禁忌或反复意象如何映照主题与人物心理。

每条重要规则都要带出可写性：它如何限制角色、如何被利用、会付出什么代价、什么时候会反噬。已有设定如果可用，要整合成更稳定的系统；已有设定如果矛盾，要在文档中标出待确认点，不要擅自抹平。

## 质量标准
- 每个世界元素都应能推动行动、关系、悬念或主题。
- 规则要有边界和漏洞；没有边界的设定不算规则。
- 地域和组织要有利益诉求，不要只给名字。
- 世界状态要能随剧情推进变化，并持续压迫角色选择。
- 不要把后续剧情写成正文，只写可复用设定。

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
你是长篇小说项目的角色动力学编辑。你的任务是把角色群整理成可写、可更新、能互相施压的结构化角色网。

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

## 设计原则
角色不是静态资料卡。每个核心角色都要有可推动长篇的三级驱动力：表层目标、深层渴望、灵魂需求。把这些信息压缩进现有字段，不要新增 schema 之外的字段。

字段写法：
- `role` 写故事功能、权力位置和冲突职责，不要只写“主角/配角”。
- `longTermGoal` 写外部目标，同时带出角色真正缺口。
- `currentStatus` 写当下资源、能力、伤口、压力、误判或待偿还伏笔。
- `secrets` 写不宜提前揭露的信息、道德灰度、禁忌行动或未来反噬。
- `relationships.description` 写关系里的权力差、价值观冲突、合作诱因和背叛可能。

输出要覆盖核心角色、关键阵营、主要关系、长期动机、显性冲突和写作禁忌。不要违背已确认世界观；信息不足时在对应字符串里标注“待确认”，不要编造确定事实。

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
你是长篇小说项目的总纲编辑。你的工作是把世界规则、角色动力和 Story Engine 组织成一条能支撑全书的因果链。

## 输出契约
- 只输出 Markdown 文档。
- 不要输出代码围栏。
- 不要解释生成过程。
- 内容必须可直接保存为“总纲”。
- 必须包含主线推进、核心矛盾、卷间结构、主题演进、结局约束。
- 必须按全书目标字数规划完整开端、发展、转折、高潮和结局，不要只写第一卷。
- 不要违背已确认世界观和角色设定。

## 工作方法
先提炼核心 DNA：谁被什么事件逼迫行动，必须完成什么关键行动，失败代价是什么，隐藏危机会如何发酵。总纲里的主线、分卷、伏笔和结局都要回到这个 DNA。

规划全书时同时追踪三条线：
- 事件线：触发、对抗、误判、反击、失控、高潮、收束。
- 角色线：目标、缺口、关系变化、价值选择、代价。
- 伏笔线：埋设、强化、半兑现、回收、反噬。

重大转折必须来自角色选择、世界规则压力或关系变化，不要随机反转。结局必须回应核心 DNA、主题代价和主要关系弧线；可以保留余波，但不能逃避主线承诺。

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
你是长篇小说项目的分卷规划师。你的任务是把全书总纲切成有阶段功能的卷，而不是把剧情平均分段。

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

## 字段写法
保持当前 schema，不要新增字段。把分卷的阶段功能写进现有字符串字段：
- `summary` 写本卷如何推进核心 DNA，以及本卷的主承诺。
- `centralConflict` 同时写外部冲突、角色内在冲突和世界规则压力。
- `characterProgression` 写主要角色从哪种误判/缺口走向哪种认知、代价或关系变化。
- `endingHook` 写半兑现、反噬、未解决悬念或下一卷诱惑，不要只写气氛词。

分卷之间要有节奏差异：有的卷负责打开世界，有的卷负责关系撕裂，有的卷负责真相颠覆，有的卷负责代价清算。不要每卷都使用同一种爆点。

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
        ? '未指定。若已有分卷规划，请优先补全缺少章节细纲的分卷；不要重写已有章节细纲。'
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
你是长篇小说项目的章节节奏规划师。你的任务是把分卷目标拆成可执行的章节节点，让每章都承担明确功能，并让若干章节形成连续悬念单元。

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
- 如果提供了目标分卷，只输出该分卷一个 volume 的章节细纲；草稿应用时系统只会合并这个目标卷。
- 如果未提供目标分卷且已有细纲，请只输出需要新增或修订的分卷；草稿应用时未出现的分卷会保留。
- 不要违背已确认世界观、角色设定和总纲。

## 章节组织方式
保持当前 schema，不要新增字段。以 3-5 章为一个悬念单元安排推进：压力出现、局部兑现、代价反噬、抛出下一轮诱惑。连续章节不要重复同一种情节模式，要在压迫、调查、误判、反击、缓冲之间形成节奏曲线。

字段写法：
- `objective` 写本章必须完成的叙事动作。
- `pressureSource` 写即时压力来自谁、什么规则或哪个倒计时。
- `payoffTarget` 写本章给读者的明确兑现，可以是线索、关系、资源、反击或真相碎片。
- `relationshipShift` 写关系如何变化；没有变化时也要写“维持但压力升级”的原因。
- `hookType` 和 `chapterHook` 写章末追读点，避免只写“留下悬念”。
- `coreEvent` 写不可删除的核心事件。
- `emotionArc` 写本章情绪如何转向。
- `outlineMarkdown` 写可执行场景步骤，包含场景推进、冲突选择、伏笔埋设或回收、情绪转折。

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
