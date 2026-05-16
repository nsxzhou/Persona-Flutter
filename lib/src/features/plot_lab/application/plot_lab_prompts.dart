import 'dart:convert';

import 'plot_input_classification.dart';

const plotAnalysisSections = [
  '3.1 阶段划分与字数节奏',
  '3.2 主爽点线与兑现节奏',
  '3.3 冲突类型谱',
  '3.4 主角道德与能力走向',
  '3.5 关键角色引入模式',
  '3.6 关系性质演变',
  '3.7 爽点类型与兑现方式',
  '3.8 章末钩子模式',
  '3.9 反套路/颠覆点分布',
  '3.10 道德灰度与下限',
  '3.11 结局形状',
  '3.12 标志性场景类型',
];

const storyEngineSectionHeaders = [
  '# Plot Writing Guide',
  '## Core Plot Formula',
  '## Chapter Progression Loop',
  '## Scene Construction Rules',
  '## Setup and Payoff Rules',
  '## Payoff and Tension Rhythm',
  '## Side Plot Usage',
  '## Hook Recipes',
  '## Anti-Drift Rules',
];

const _sharedAnalysisRules = '''
你必须遵守以下规则：
1. 只分析上传样本中有证据支撑的内容，不得编造不存在的事件链、人物关系、道德转折或推进机制。
2. 输出必须是 Markdown；若当前步骤要求 YAML front matter，YAML 后的正文也必须是 Markdown。
3. 如果证据不足，必须在对应章节明确写出“当前样本中证据有限”。
4. 区分叙事出现顺序与可推断的真实时序；若无法确定，必须明确标注“时序不确定”。
5. 标题层级、章节顺序必须严格遵守要求，不要缺节，不要重排。
6. 分析必须追踪核心DNA、角色欲望、世界断层线、章节悬念单元、伏笔三步法、认知颠覆的证据，但不得把样本外剧情补成完整小说。
''';

const _plotPropulsionRules = '''
情节推进硬账：
- 核心DNA要清楚：主角身份、核心事件、关键行动、灾难后果、隐藏危机必须能互相咬合。
- 欲望驱动要落地：表层目标推动行动，深层渴望决定选择，灵魂需求制造代价。
- 每个悬念单元都要包含压力、半兑现、反噬和下一轮诱惑；不要只扩大地图或堆设定名词。
- 设伏必须可回收：埋设 -> 强化 -> 回收，每次兑现后留下新压力或新债务。
- 读者奖励必须具体到资源、地位、关系、真相、掌控力、打脸结果或禁忌后果。
''';

const _sketchRules = '''
你必须遵守以下规则：
1. 只记录当前 chunk 的直接证据，不得编造不存在的事件链、人物关系或推进机制。
2. 输出必须是一个 Markdown 文档，并且顶部必须包含 YAML front matter；不要输出解释前言、代码围栏或额外寒暄。
3. YAML 内部字符串和 Markdown 正文必须使用中文简体；字段名称必须严格使用指定的英文字段名，不得翻译。
4. 若证据不足，宁可保留空数组或给出最小可支撑结论，也不要编造。
5. YAML front matter 必须只包含指定字段，不得出现任何额外字段；YAML 后的正文必须从 `# Chunk Sketch` 开始。
''';

const _plotReportTemplate = '''
# 执行摘要
用 1-3 段总结上传样本真正依赖什么情节机制推进读者追读；只分析上传样本，不推断完整小说。

# 基础判断
- 样本覆盖范围：
- 样本是否包含开篇：
- 样本是否包含高潮：
- 样本是否包含结尾：
- 核心推进模式：

# 情节分析
## 2.5.1 主线剧情分析
## 2.5.2 支线剧情分析
## 2.5.3 细纲
## 2.5.4 场景纲
## 2.5.5 爽点
## 2.5.6 节奏

# 附录
写明当前样本未覆盖、证据不足或时序不确定的部分；如果没有可写“无”。
''';

const plotSkeletonTemplate = '''
# 全书骨架

## 样本覆盖范围
（按 chunk 索引说明上传样本覆盖了开篇/发展/高潮/结尾中的哪些部分；未覆盖必须写明。）

## 主线推进链
（列出样本内可证据支持的关键推进链；用 @chunkA -> @chunkB 标注设伏与兑现。）

## 支线线索
（列出样本内支线、对照线、关系线，说明如何回流或映照主线。）

## 场景账本
（按 chunk 范围概括关键场景最小单元：地点/人物/事件/变化点。）

## 爽点与钩子
（列出样本内爽点、虐点、章末钩子和半兑现位置。）

## 节奏曲线
（说明张弛、压迫、反击、过渡、密集兑现的分布。）

## 证据不足项
（未覆盖开篇、高潮或结尾时必须列出；否则写“无”。）
''';

const storyEngineTemplate = '''
---
name: ""
tags: []
plot_summary: ""
core_formula: ""
progression_loop: ""
tension_rhythm: ""
hook_strategy: ""
anti_drift: []
intensity: 0.7
---

# Plot Writing Guide

## Core Plot Formula
- 

## Chapter Progression Loop
- 

## Scene Construction Rules
- 

## Setup and Payoff Rules
- 

## Payoff and Tension Rhythm
- 

## Side Plot Usage
- 

## Hook Recipes
- 

## Anti-Drift Rules
- 
''';

class PlotLabPromptBuilder {
  const PlotLabPromptBuilder();

  String buildSketchPrompt({
    required String chunk,
    required int chunkIndex,
    required int chunkCount,
    required PlotInputClassification classification,
  }) {
    return '''
$_sketchRules

你正在执行 Plot Lab 的分块速写阶段（sketch pass）。请基于当前 chunk 产出一份用于后续搭建样本情节骨架的紧凑 YAML+MD 账本，整份内容合计不得超过 500 个汉字。
只分析上传样本，不得推断完整小说；样本未覆盖开篇、高潮或结尾时，只能在 `sample_coverage` 中标注片段状态。
只记录当前 chunk 的直接证据：当前 chunk 没有发生、没有出场、没有明确点名的内容，不得写入任何事件、场景或人物字段。
请在已有字段中压缩记录可见的核心DNA、角色欲望、世界断层线、伏笔三步法或认知颠覆信号；没有直接证据时不得补写。
$_plotPropulsionRules

YAML front matter 字段定义（字段名必须保持英文原样，不要翻译）：
- `characters_present`：本 chunk 中直接出场或被点名的主要角色列表，仅保留主要行动者，最多 10 个。
- `scene_units`：关键场景最小叙事单元，每条写清地点/人物/事件/变化点，最多 6 条。
- `main_events`：本 chunk 直接支撑主线推进的事件，最多 6 条。
- `side_threads`：支线、对照线、关系线或次要冲突，最多 6 条；没有则空数组。
- `payoff_points`：爽点、高光、反击、揭示、阶段性兑现，最多 6 条。
- `tension_points`：压迫、虐点、威胁、代价、误判或阻碍，最多 6 条。
- `hooks`：章末/场景末制造追读的问题、威胁、诱惑或选择，最多 6 条。
- `setup_payoff_links`：样本内可见的“铺垫 -> 兑现”链条，最多 6 条；只写当前样本能证明的链条。
- `pacing_shift`：用一句话说明本 chunk 的节奏变化，例如“压迫转入反击”。
- `time_marker`：本 chunk 的时间线标记，取值必须是以下之一：`linear`、`flashback`、`unclear`。
- `sample_coverage`：本 chunk 直接覆盖的样本阶段信号，取值只能来自 `opening_seen`、`development_seen`、`climax_seen`、`ending_seen`、`partial_fragment`、`coverage_unclear`。

YAML 后的 Markdown 正文要求：
- 必须从一级标题 `# Chunk Sketch` 开始。
- 只写 2-4 条 bullet，压缩说明本 chunk 的证据摘要、推进机制、设伏兑现或证据不足项。
- 正文不得引入 YAML 中没有证据支撑的新人物、新事件或新关系。

输入判定：${jsonEncode(classification.toJson())}
当前 chunk：${chunkIndex + 1}/$chunkCount（chunk_index=$chunkIndex, chunk_count=$chunkCount）

输出形状示例（仅用于说明 YAML+MD 结构，不要照搬其中内容）：
---
characters_present:
  - 林凡
  - 宗主
scene_units:
  - 宗门大比现场：林凡被宗主点名参加考核，局面从旁观转为被迫应战
main_events:
  - 林凡遭遇宗门考核
side_threads:
  - 同门观望形成压力
payoff_points:
  - 林凡当场展示能力
tension_points:
  - 宗门权威压迫
hooks:
  - 考核结果未公布
setup_payoff_links:
  - 前置轻视 -> 当场反击
pacing_shift: 压迫转入反击
time_marker: linear
sample_coverage:
  - development_seen
  - partial_fragment
---

# Chunk Sketch
- 宗门考核把主角从旁观者推入行动位，压力来自权威点名与同门围观。
- 当前 chunk 可见压迫到反击的半兑现，但结局走向仍未覆盖。

请仅输出符合上述要求的 YAML front matter + Markdown 正文，不要输出任何其他字符。

主分析文本（当前 chunk，结论优先以此为准）：
$chunk
''';
  }

  String buildSkeletonPrompt({
    required List<Map<String, Object?>> sketches,
    required PlotInputClassification classification,
    required int chunkCount,
  }) {
    return '''
$_sharedAnalysisRules

你正在执行 Plot Lab 的样本骨架聚合阶段。请基于已按 `chunk_index` 升序排列的分块速写（sketches），压缩输出一份紧凑的样本情节骨架 Markdown，用于最终 2.5 分析报告提供上下文。
整份骨架合计不得超过约 2500 tokens；章节、层级与顺序必须严格沿用下方输出模板。
只分析上传样本，不得推断完整小说；未覆盖开篇、高潮或结尾时必须写入“证据不足项”。
若证据不足，宁可在“证据不足项”中声明，不要凭空臆断；每一阶段、每一推进链条都必须能够在输入的 sketches 中找到对应证据。
请尽量用 chunk 索引（例如 `@chunk42`、`chunk 12-45`）来锚定阶段、设伏、兑现和时间线。
主线推进链请优先写成“设伏 @chunkX -> 兑现 @chunkY”的可追踪链条；无法配对则写当前样本中证据有限。
请显式提炼样本内可见的核心DNA雏形、角色表层目标/深层渴望/灵魂需求线索、世界断层线、悬念单元边界、伏笔三步法证据和认知颠覆点；证据不足时写入“证据不足项”。

输入判定：${jsonEncode(classification.toJson())}
chunk 总数：$chunkCount

输出模板：
$plotSkeletonTemplate

分块速写列表（已按 chunk_index 升序排列）：
${jsonEncode(sketches)}
''';
  }

  String buildReportPrompt({
    required String plotSkeletonMarkdown,
    required PlotInputClassification classification,
  }) {
    return '''
$_sharedAnalysisRules

你正在基于样本骨架整理最终 Plot Lab 分析报告。输出必须是完整 Markdown 文档。
只分析上传样本，不得推断完整小说。样本未覆盖开篇、高潮或结尾时，必须在对应位置写“当前样本未覆盖/证据不足”。
报告采用 2.5 结构，用于审阅情节写法。

$_plotPropulsionRules
最终报告必须能支撑下一步生成 Plot Writing Guide：请在各节里保留可复用的写作机制，尤其是核心DNA公式、章节推进循环、场景压力结构、设伏兑现节奏与反漂移边界。

输入判定：${jsonEncode(classification.toJson())}
固定章节：
${plotAnalysisSections.map((section) => '- $section').join('\n')}

输出模板：
$_plotReportTemplate

全书骨架：
$plotSkeletonMarkdown
''';
  }

  String buildStoryEnginePrompt({
    required String reportMarkdown,
    required String plotName,
  }) {
    return '''
$_sharedAnalysisRules

你正在从完整 Plot Lab 报告生成一个可复用的 Plot Writing Guide。输出必须是一个 Markdown 文档，并且顶部必须包含 YAML front matter。
Plot Writing Guide 的目标是说明如何写小说剧情，而不是复述分析报告或样本剧情。

情节档案名称：$plotName
输出必须直接从 YAML front matter 的 `---` 开始，不要写前言、解释、结语或代码围栏。

硬性结构：
- YAML front matter 必须包含这些字段：name、tags、plot_summary、core_formula、progression_loop、tension_rhythm、hook_strategy、anti_drift、intensity。
- YAML 字段必须去样本化：不要保留样本人物名、地名、势力名、事件名、世界专名或章节号。
- YAML 后的正文必须从一级标题 `# Plot Writing Guide` 开始。
- 只允许输出 8 个二级标题：`Core Plot Formula`、`Chapter Progression Loop`、`Scene Construction Rules`、`Setup and Payoff Rules`、`Payoff and Tension Rhythm`、`Side Plot Usage`、`Hook Recipes`、`Anti-Drift Rules`。
- 每节必须写成可执行写作规则，使用短 bullet，不要写分析口吻。

抽象要求：
- Core Plot Formula 必须提炼为类似“当[主角+身份]遭遇[核心事件]，必须[关键行动]，否则[灾难后果]；与此同时，[隐藏危机]发酵”的可迁移公式，但不得复用样本专名。
- Chapter Progression Loop 必须说明 3-5 章悬念单元如何推进，如何安排认知过山车和阶段性兑现。
- Scene Construction Rules 必须说明场景如何从欲望/压力入手，如何让角色目标、世界断层线和即时阻碍同时在场。
- Setup and Payoff Rules 必须显式使用伏笔三步法：埋设 -> 强化 -> 回收。
- Payoff and Tension Rhythm 必须说明压制、反击、虚假胜利、反噬、灵魂黑夜或代价显现如何形成节奏。
- Hook Recipes 必须给出章末钩子的类型：新压力、关系变化、资源诱惑、信息差、认知颠覆或阶段性兑现。
- 不要复述分析报告，不要列样本剧情摘要。
- 禁止保留样本人物名、地名、势力名、事件名、世界专名或章节号。
- Anti-Drift Rules 必须防止输出变成世界观说明、剧情摘要或空泛分析。

输出模板：
$storyEngineTemplate

分析报告：
$reportMarkdown
''';
  }
}
