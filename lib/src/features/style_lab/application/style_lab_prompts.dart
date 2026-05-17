import 'dart:convert';

import 'style_input_classification.dart';

const styleAnalysisSections = [
  '3.1 口头禅与常用表达',
  '3.2 固定句式与节奏偏好',
  '3.3 词汇选择偏好',
  '3.4 句子构造习惯',
  '3.5 生活经历线索',
  '3.6 行业／地域词汇',
  '3.7 自然化缺陷',
  '3.8 写作忌口与避讳',
  '3.9 比喻口味与意象库',
  '3.10 思维模式与表达逻辑',
  '3.11 常见场景的说话方式',
  '3.12 个人价值取向与反复母题',
];

const _sharedRules = '''
你必须遵守以下规则：
1. 证据边界优先：不得编造不存在的设定、说话人或风格特征。
2. 只输出 Markdown，不要输出解释前言、代码围栏或额外寒暄。
3. 如果证据不足，必须在对应章节明确写出“当前样本中证据有限”。
4. 关注文本类型、索引方式、噪声、批处理条件，并在后续分析中保持一致。
5. 标题层级、章节顺序必须严格遵守要求，不要缺节，不要重排。
6. 分析结论必须最终能转化为可执行写作资产：句法、节奏、词汇、标点、对白、意象和叙述视角必须尽量落到操作规则。
''';

const _reportTemplate = '''
# 执行摘要
用 1-3 段总结整体文风。

# 基础判断
- 文本类型：
- 是否多说话人：
- 是否分块处理：
- 证据定位方式：
- 噪声处理：

# 风格维度
## 3.1 口头禅与常用表达
## 3.2 固定句式与节奏偏好
## 3.3 词汇选择偏好
## 3.4 句子构造习惯
## 3.5 生活经历线索
## 3.6 行业／地域词汇
## 3.7 自然化缺陷
## 3.8 写作忌口与避讳
## 3.9 比喻口味与意象库
## 3.10 思维模式与表达逻辑
## 3.11 常见场景的说话方式
## 3.12 个人价值取向与反复母题

# 附录
可选补充说明；如果没有可写“无”。
''';

const _voiceProfileTemplate = '''
---
name: ""
tags: []
voice_summary: ""
tone: ""
pacing: ""
diction: ""
syntax: ""
do: []
avoid: []
intensity: 0.5
---

# Voice Profile

## 3.1 口头禅与常用表达
- 执行规则：

## 3.2 固定句式与节奏偏好
- 执行规则：

## 3.3 词汇选择偏好
- 执行规则：

## 3.4 句子构造习惯
- 执行规则：

## 3.5 生活经历线索
- 执行规则：

## 3.6 行业／地域词汇
- 执行规则：

## 3.7 自然化缺陷
- 执行规则：

## 3.8 写作忌口与避讳
- 执行规则：

## 3.9 比喻口味与意象库
- 执行规则：

## 3.10 思维模式与表达逻辑
- 执行规则：

## 3.11 常见场景的说话方式
- 执行规则：

## 3.12 个人价值取向与反复母题
- 执行规则：
''';

class StyleLabPromptBuilder {
  const StyleLabPromptBuilder();

  String buildChunkAnalysisPrompt({
    required String chunk,
    required int chunkIndex,
    required int chunkCount,
    required StyleInputClassification classification,
  }) {
    return '''
$_sharedRules

你正在执行分块分析阶段。请基于当前 chunk 输出一份 Markdown 分析片段。
要求：保留全部 12 个风格章节，每节写 1-3 个要点；证据不足时明确写出证据有限。
每个要点优先采用“风格现象 -> 可复用写法 -> 证据摘要”的结构：先说文本怎么写，再说明后续生成时可以如何执行，最后用样本证据压缩支撑。

输入判定：${jsonEncode(classification.toJson())}
当前 chunk：${chunkIndex + 1}/$chunkCount
固定章节：
${styleAnalysisSections.map((section) => '- $section').join('\n')}

输出模板：
$_reportTemplate

样本文本：
$chunk
''';
  }

  String buildMergePrompt({
    required List<String> chunkAnalyses,
    required StyleInputClassification classification,
  }) {
    return '''
$_sharedRules

你正在执行全局聚合阶段。请把多个 chunk 的 Markdown 分析合并成一份统一的 Markdown 报告草稿。
要求：同义归并、重复证据去重、弱判断保留、多说话人差异不抹平，保持章节顺序。
合并时必须把分散证据压缩成稳定的风格指纹，区分“高频规则”“可选调味”和“证据不足”。
如果某个风格判断只能由单个 chunk 支撑，必须标记为弱证据，不得写成全局规律。

输入判定：${jsonEncode(classification.toJson())}
固定章节：
${styleAnalysisSections.map((section) => '- $section').join('\n')}

输出模板：
$_reportTemplate

待合并结果：
${jsonEncode(chunkAnalyses)}
''';
  }

  String buildReportPrompt({
    required String mergedAnalysisMarkdown,
    required StyleInputClassification classification,
  }) {
    return '''
$_sharedRules

你正在把聚合结果整理成最终分析报告。输出必须是完整 Markdown 文档。
报告既要给人审阅，也要服务后续 Voice Profile 抽象；每个风格维度都要保留“证据账本”和“可执行写法”两层。

输入判定：${jsonEncode(classification.toJson())}
输出模板：
$_reportTemplate

聚合结果：
$mergedAnalysisMarkdown
''';
  }

  String buildVoiceProfilePrompt({
    required String reportMarkdown,
    required String styleName,
  }) {
    return '''
$_sharedRules

你正在从完整分析报告生成一个可复用的 Voice Profile。输出必须是一个 Markdown 文档，并且顶部必须包含 YAML front matter。
Voice Profile 只回答“这个文本怎么写”，目标是提炼语句风格、节奏、词汇、对白、标点、意象和逻辑习惯。

风格名称：$styleName

结构要求：
- YAML front matter 必须包含这些字段：name、tags、voice_summary、tone、pacing、diction、syntax、do、avoid、intensity。
- YAML 后的正文必须从一级标题“# Voice Profile”开始。
- 正文只允许输出 12 个二级标题，标题必须逐字使用 3.1-3.12 的中文标题，不要新增、删除或重排章节。
- 每节使用“执行规则”的结构；写可执行的写法规律。
- 执行规则必须具体到句式、节奏、词汇、标点、对白、意象或逻辑，不要写“有画面感”“文笔细腻”这类空泛评价。
- 每条执行规则尽量包含触发场景和执行方式，例如“压迫场景用短句断行推进”“亲密对白先用停顿试探再给命令句”。
- 必须区分“强约束”和“弱偏好”：高频且证据稳定的写成必须遵守，证据有限的写成可选倾向。
- 不得把情节设定、世界观机制、角色关系走向写进 Voice Profile；这些只能作为语气、节奏或叙述视角的证据来源。
- Voice Profile 必须去样本化：人物名、地名、组织名、专属设定词改写为“主角”“上位者”“亲密关系角色”“对手”“组织势力”等通用关系标签。
- YAML front matter 和 Markdown 正文都不得保留样本人物名、地名、组织名、事件名、世界专名、章节号或任何只属于样本的专有名词。
- `name` 字段只能使用风格名称或通用风格标签，不得使用样本主角名；`tags`、`do`、`avoid` 中也不得出现样本专名。
- 如果分析报告中出现具体角色名，只能把它们归纳为“主角”“配角”“亲密关系角色”“上位者”“对手”“组织势力”等关系/功能标签。

章节写法重点：
- 3.1：高频短语、口头禅、反复出现的语气结构。
- 3.2：长短句比例、停顿、回勾、段落呼吸、动作链推进。
- 3.3：口语/书面/古典/网络/行业词的混合方式和替代表达。
- 3.4：句首、句中、句尾惯用结构，以及省略号、破折号、问号等标点习惯。
- 3.5：可转化为风格锚点的生活经验、物件、场景或经验语境；没有则明确证据有限。
- 3.6：行业术语、方言、俚语、网络语和地域文化词。
- 3.7：可保留的自然化不规整，如省略、跳接、断句、轻微粗粝口语。
- 3.8：作者明显少用或避开的表达方式，只写与文风有关的忌口。
- 3.9：偏好的比喻路径、感官意象和象征物。
- 3.10：观察、质疑、类比、结论、情绪转折等思维推进方式。
- 3.11：不同场景下对白的攻击性、试探、调侃、沉默和命令方式。
- 3.12：反复出现的价值判断、母题和叙事关注点。

输出模板：
$_voiceProfileTemplate

分析报告：
$reportMarkdown
''';
  }

  String buildVoiceProfileRepairPrompt({
    required String invalidProfileMarkdown,
    required String parseError,
  }) {
    return '''
你正在修复 Style Lab 的 Voice Profile 输出格式。上一轮输出没有通过 YAML+MD 校验。

修复目标：
1. 只修复格式，不得新增、删除或扩写事实内容。
2. 最终输出必须直接从 `---` 开始，并包含一个 YAML front matter 结束分隔符 `---`。
3. YAML front matter 必须只包含这些字段，顺序也按此排列：name、tags、voice_summary、tone、pacing、diction、syntax、do、avoid、intensity。
4. `name`、`voice_summary`、`tone`、`pacing`、`diction`、`syntax` 必须是字符串。
5. `tags`、`do`、`avoid` 必须是 YAML 列表；没有内容时写 `[]`。
6. `intensity` 必须是数字；不确定时写 `0.5`。
7. YAML 后的 Markdown 正文必须从 `# Voice Profile` 开始。
8. 不要输出解释、前言、结语或代码围栏。

校验错误：
$parseError

待修复输出：
$invalidProfileMarkdown
''';
  }
}
