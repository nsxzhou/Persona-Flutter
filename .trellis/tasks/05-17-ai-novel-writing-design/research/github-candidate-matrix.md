# GitHub AI 小说 / 网文创作系统候选矩阵

日期：2026-05-17

## 检索策略

本轮用于纠正上一轮“抽样过窄”的问题。检索覆盖：

- GitHub API repository search：`AI novel writing assistant`、`AI novel generator long-form fiction`、`LLM novel writer worldbuilding chapter`、`AI web novel writer`、`novel writing agent LLM`、`小说 AI 创作 系统`、`AI 小说 写作 助手`、`网文 AI 创作`、`AI 网文 写作`、`LLM 小说 生成`。
- Web search：GitHub 仓库名 + README / architecture / RAG / worldbuilding / chapter / 章纲 / 伏笔 / 质检。
- 本地项目交叉验证：Persona-Flutter 已有 `WritingProject`、`Style Profile`、`Plot Profile`、`WorkflowTask`、`Prompt Trace`，所以筛选重点放在“长篇创作系统设计”，不是普通短文本续写。

## 纳入标准

- 与 AI 小说、网文、长篇 fiction、章节生成、写作工作台、故事规划明显相关。
- README 或仓库描述能显示系统设计，而非只有一次性 prompt demo。
- 优先纳入中文网文、长篇一致性、章节流水线、记忆/事实追踪、质检/修订相关项目。

## 排除或降权标准

- 只是模型训练或早期 GPT-2/RWKV 文本生成，没有现代 LLM 工作流设计。
- 只是小说转音频、小说转短剧、视频/漫画生产，除非有可借鉴的创作管线。
- 只有空壳、README 极少、无法判断设计。
- 与“小说创作”关键词误匹配。

## 深研候选

| 仓库 | 类型 | 为什么值得看 | 对 Persona-Flutter 的启发 |
|---|---|---|---|
| `Narcooo/inkos` | 自主小说 Agent / Studio+CLI | 明确的章节阶段：plan/compose/write/observe/reflect/audit/revise，带快照/回滚/审批 | 章节 Run 状态机、审查修订闭环、人工批准后入库 |
| `lingfengQAQ/webnovel-writer` | Claude Code 长篇网文系统 | Story System、章节契约、事件审计、RAG/投影、解决遗忘/幻觉 | 章节契约、事实/摘要投影、接受后回灌 |
| `ExplosiveCoderflome/AI-Novel-Writing-Assistant` | AI Director / 创作中枢 | 从创意、设定、宏观规划、分卷、章纲、执行、审查、修复全流程 | Novel Workshop 信息架构、项目资产联动 |
| `a9549521/chronicler` | 人在回路长篇工作台 | 多层摘要、事实表、上下文组装、接受版本边界 | MVP 最贴近：作者控制 + 上下文选择 |
| `ponysb/91Writing` | 轻量前端写作工具 | 小说管理、编辑器、大纲、提示词库、世界观模板、目标/成本 | UI 生产力功能、提示词模板库、成本可视化 |
| `shystab/ChatNovel` | RAG 小说写作助手 | 描述强调 RAG 能力 | 可作为后续检索记忆参考，需深读验证 |
| `hsong6809-boop/novel-continuation` | 中文续写系统 | React+FastAPI+SQLite，多 Provider、章纲、角色、伏笔、时间线、元数据提取 | 与 Flutter+Drift 本地工作台很接近 |
| `jastfkjg/InkMind` | 多模型小说写作工具 | 作品管理、章节编辑、人物设定、生成/扩写/润色/评估、导出 | 章节编辑器侧功能拆分 |
| `fuzhilin/novel-ai` | 网文质检/修订平台 | “18 个专家视角自检 + 一键修订” | 质检维度可借鉴，但 MVP 不宜上 18 维 |
| `eugenequyn/open-writing` | DAG 协同写作 CLI | 配置驱动 DAG 工作流 | 章节流水线可配置化的远期方向 |
| `Tieamone/novel-ai` | 自动化网文 CLI | 从书名/类型/关键词到章节导出 | 反例：全自动可做演示，但控制弱 |
| `xiaotiewinner/xt-webnovel-writing` | OpenClaw 网文 Skill | 参考文本拆解、立书、剧情设计、爽点文笔、反 AI 味、长篇记忆 | 与现有 Style/Plot 分析非常契合 |
| `NousResearch/autonovel` | 全自动小说生成 | 端到端自动生成代表 | 可借鉴流水线，不适合作为首版产品体验 |
| `forsonny/book-os` | book/workflow OS | 创作项目 OS 类思路 | 可验证后用于项目/资产组织参考 |
| `tallman2014/fiction-project-scaffold` | fiction 项目脚手架 | 类型档案、启动向导、多 Agent 钩子 | 类型模板与项目启动向导 |
| `ddmmbb-2/Novel-AI-Agent` | 长记忆小说 Agent | 自动章节生成、story tracking、rollback、Ollama | 本地模型、回滚、长记忆模式 |
| `HBAI-Ltd/Toonflow-app` | 小说/剧本转短剧工具 | 小说到剧本/分镜/角色/视频的媒体流水线 | 主要是远期衍生，不是小说文本 MVP |

## 初步分类

### A. 长篇一致性优先型

代表：`webnovel-writer`、`chronicler`、`Novel-AI-Agent`。

共同点：
- 明确区分“原文/契约/设定”与“摘要/事实/索引”这种派生记忆。
- 关注遗忘、幻觉、角色状态漂移、伏笔断裂。
- 通常会把用户接受的章节作为正式事实边界。

Persona-Flutter 应借鉴：
- `ChapterContract`：章节契约。
- `AcceptedChapter`：已确认章节。
- `ProjectMemoryProjection`：从已确认章节派生出来的摘要、事实、角色状态、伏笔账本。

### B. Agent 流水线优先型

代表：`inkos`、`AI-Novel-Writing-Assistant`、`open-writing`、`xt-webnovel-writing`。

共同点：
- 把写作拆为多个阶段，而不是一个 prompt。
- 常见阶段：创意/立书、世界观、人物、卷纲、章纲、正文、审查、修订、回灌。
- 比较成熟的系统会有失败恢复、可继续执行、审批节点。

Persona-Flutter 应借鉴：
- 直接复用 `WorkflowTask` 和 `PromptTrace` 做 Novel Chapter Run。
- 用枚举阶段表达：prepareContext / buildContract / draft / audit / revise / awaitingAcceptance / projectingMemory。
- UI 上显示每次章节生成为什么失败、哪一阶段失败、可否重试。

### C. 作者工作台优先型

代表：`91Writing`、`novel-continuation`、`InkMind`、`novel-studio`。

共同点：
- 以项目、章节、角色、世界观、编辑器、提示词模板为核心。
- AI 是工具栏/侧边栏能力，而不是完全接管作者。
- 更重视可编辑性、导出、成本、进度。

Persona-Flutter 应借鉴：
- 在已有 `ProjectDetailPage` 中扩展入口，而不是新造独立孤岛。
- 章节工作台应能同时看：章节列表、当前章 brief、上下文资产、生成结果、审查意见。
- 提示词模板应该以变量化形式保存，便于用户理解和调试。

### D. 全自动生成型

代表：`autonovel`、`Tieamone/novel-ai`、部分 GPT-2/RWKV 旧项目。

共同点：
- 强演示效果：从少量输入到大量文本。
- 弱点：长期一致性、作者可控性、风格/剧情资产复用、质量可解释性通常不足。

Persona-Flutter 不建议第一版走这个方向。可以保留远期“批量生成草稿”能力，但不应作为核心架构前提。

## 映射到当前 Persona-Flutter

已确认本地代码事实：

- `WritingProject` 已存在，字段包括 `styleProfileId`、`plotProfileId`、`defaultProviderId`、`defaultModelName`、`language`、`targetLength`、`narrativePerspective`。
- `StyleProfile` 保存 `profileMarkdown` 和 `analysisReportMarkdown`。
- `PlotProfile` 保存 `storyEngineMarkdown`、`analysisReportMarkdown`、`plotSkeletonMarkdown`。
- `WorkflowTask` / `PromptTrace` 已能记录 LLM 调用阶段、输入输出摘要、错误。

所以小说创作模块不应先创建“新的小说项目表”替代 Project；应扩展 Project 下面的创作子域：

1. `StoryBible`
   - projectId
   - world/lore/characters/facts/currentFocus/authorIntent

2. `ChapterPlan`
   - projectId
   - index/title/summary/targetBeat/mustInclude/mustAvoid/hook/payoff/status

3. `ChapterDraftRun`
   - workflowTaskId
   - projectId/chapterPlanId/provider/model/status/stage/logs
   - contractMarkdown/draftMarkdown/auditMarkdown/revisedMarkdown/acceptedChapterId

4. `AcceptedChapter`
   - projectId/chapterPlanId/content/acceptedAt/revision/sourceRunId

5. `MemoryProjection`
   - projectId
   - recentSummary/globalSummary/factLedger/characterStates/unresolvedHooks

## 更严格的 MVP 建议

第一版不要只做“生成一章”。应该做最小但完整的闭环：

1. 项目详情页新增“章节工作台”入口。
2. 项目必须绑定 Style Profile 和 Plot Profile，或在生成前明确提示缺失项。
3. 用户创建 Chapter Plan。
4. 系统生成 Chapter Contract。
5. 系统生成 Draft。
6. 系统做 Audit。
7. 系统按 Audit 修订一次，或显示问题让用户手动处理。
8. 用户 Accept。
9. Accept 后更新 Memory Projection。

这比一键生成慢，但它复用了你已经做好的风格/剧情分析，也符合长篇网文最关键的连续性需求。
