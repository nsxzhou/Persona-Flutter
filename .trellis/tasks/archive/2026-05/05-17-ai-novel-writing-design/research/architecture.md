# Persona-Flutter 本地架构取证

日期：2026-05-17

范围：本文件只记录为后续“AI 小说写作模块”设计提供依据的本地代码结构，不包含实现改动。

## 结论摘要

Persona-Flutter 适合把小说写作做成一个新的 `features/novel_workshop` 纵切模块，而不是嵌入到 Style Lab、Plot Lab 或 Settings 中。原因是现有代码已经形成稳定模式：Flutter 展示层 + Riverpod provider + Drift repository + Freezed domain model + `MarkdownCompletionService` + `WorkflowTask` prompt trace。小说模块需要复用 Style/Plot/Profile/Project 资产，但运行状态、章节、事实、摘要应有自己的表和仓储。

## App 与导航结构

本项目入口为 `lib/main.dart` 和 `lib/src/app/persona_app.dart`，路由由 `lib/src/core/router/app_router.dart` 管理，导航枚举在 `lib/src/core/router/app_route.dart`。

当前一级路由：

* `/projects`：项目页，默认首页。
* `/style-lab`：风格实验室。
* `/plot-lab`：剧情实验室。
* `/workflow-runs`：工作流任务。
* `/settings`：设置。

`app_router.dart` 使用 `StatefulShellRoute.indexedStack`，侧边栏项目来自 `lib/src/core/ui/app_shell.dart` 的 `_navigationItems`。后续新增小说工作台时，需要同时扩展：

* `AppRoute`：新增类似 `novelWorkshop(path: '/novel-workshop', label: '小说工作台')`。
* `app_router.dart`：新增 `StatefulShellBranch` 和页面 builder。
* `app_shell.dart`：新增导航图标项。

## 分层与模块惯例

现有功能按 `lib/src/features/<feature>/` 分层：

* `domain/`：Freezed 模型、repository 抽象、输入 DTO。
* `data/`：Drift repository 实现。
* `application/`：pipeline、provider、prompt、解析器、导入器。
* `presentation/`：页面和组件。

可参考：

* `lib/src/features/style_lab/`
* `lib/src/features/plot_lab/`
* `lib/src/features/projects/`

小说模块后续应沿用该结构，避免把章节生成流程写成 presentation 层内的临时方法。

## 状态管理

项目使用 Riverpod 注解生成 provider。典型文件：

* `lib/src/features/style_lab/application/style_lab_providers.dart`
* `lib/src/features/plot_lab/application/plot_lab_providers.dart`
* `lib/src/features/projects/application/project_providers.dart`

仓储 provider 通常 `keepAlive: true`，流式列表使用 `@riverpod Stream<T>`。Style/Plot pipeline 都通过 provider 注入：

* Drift repository
* `MarkdownCompletionService`
* `WorkflowTaskRepository`
* 解析器或 normalizer

小说模块后续可对应建立：

* `novelWorkshopRepositoryProvider`
* `chapterRunPipelineProvider`
* `novelProjects/chapters/facts/summaries` 的 stream provider

## 持久化与数据库

Drift 数据库定义在 `lib/src/core/database/app_database.dart`。当前 `schemaVersion` 为 9，已有表包括：

* `WorkflowTaskRecords`
* `WorkflowPromptTraceRecords`
* `ProviderConfigRecords`
* `ProviderModelRecords`
* `ProjectRecords`
* `StyleSampleRecords`
* `StyleAnalysisRunRecords`
* `StyleProfileRecords`
* `PlotSampleRecords`
* `PlotAnalysisRunRecords`
* `PlotProfileRecords`

`ProjectRecords` 已包含小说写作的基础绑定字段：

* `defaultProviderId`
* `defaultModelName`
* `styleProfileId`
* `plotProfileId`
* `language`
* `targetLength`
* `narrativePerspective`

因此 MVP 不需要新建“项目”概念。应复用 `WritingProject` 作为小说项目入口，再新增章节/事实/摘要/运行记录等表。未来实现会提升 schema version，需要补充 `onUpgrade` 迁移和 repository 测试。

## 现有项目模型

`lib/src/features/projects/domain/writing_project.dart` 定义：

* `WritingProject`
* `WritingProjectInput`
* `ProjectStatus`
* 默认语言、目标长度、叙事视角常量

`lib/src/features/projects/data/drift_project_repository.dart` 已校验：

* 项目标题不能为空。
* 默认 Provider 必须存在。
* 默认模型必须属于 Provider 或等于 Provider 默认模型。
* 绑定的 Style Profile / Plot Profile 必须存在。

小说模块应直接读取项目绑定，而不是重复维护 provider/model/profile 选择。

## LLM 抽象与 Prompt Trace

LLM 调用入口：

* `lib/src/core/llm/application/llm_invocation_service.dart`
* `lib/src/core/llm/application/markdown_completion_service.dart`

`MarkdownCompletionService.completeMarkdown` 支持：

* provider
* prompt
* temperature
* maxAttempts
* modelName
* `LlmPromptTraceConfig`

prompt trace 由 `lib/src/core/tasks/application/prompt_trace_recorder.dart` 记录，落表到 `WorkflowPromptTraceRecords`。Style/Plot pipeline 已用该机制记录模型输入输出。小说章节运行也应复用这一机制，并把阶段标签设为类似：

* `contract`
* `draft`
* `audit`
* `revise`
* `projection`

这能让长链路生成可回放、可审计、可排错。

## Style Lab / Plot Lab 可复用资产

Style Lab：

* `lib/src/features/style_lab/domain/style_profile.dart`
* `lib/src/features/style_lab/application/style_analysis_pipeline.dart`
* `lib/src/features/style_lab/application/style_lab_prompts.dart`
* `lib/src/features/style_lab/application/voice_profile_front_matter.dart`

Plot Lab：

* `lib/src/features/plot_lab/domain/plot_profile.dart`
* `lib/src/features/plot_lab/application/plot_analysis_pipeline.dart`
* `lib/src/features/plot_lab/application/plot_lab_prompts.dart`
* `lib/src/features/plot_lab/application/story_engine_normalizer.dart`
* `lib/src/features/plot_lab/application/plot_chunk_sketch_document.dart`

设计含义：小说写作 MVP 应以已绑定的 Style Profile 和 Plot Profile 作为生成上下文的核心输入，而不是让用户重新粘贴风格/剧情说明。

## UI 约定

核心 Shell 和通用组件：

* `lib/src/core/ui/app_shell.dart`
* `lib/src/core/ui/persona_page.dart`
* `lib/src/core/ui/glass_container.dart`
* `lib/src/core/ui/skeleton_loader.dart`
* `lib/src/core/ui/staggered_list.dart`

视觉规范入口：

* `.trellis/spec/frontend/visual-design-guidelines.md`
* `.trellis/spec/frontend/component-guidelines.md`

后续小说工作台应是工作型界面：左侧项目/章节列表，中间章节编辑与运行状态，右侧上下文/事实/质量检查。不要做营销页、聊天页或纯卡片陈列页。

## 测试结构

现有测试覆盖：

* repository：`test/project_repository_test.dart`
* pipeline：`test/style_lab_test.dart`、`test/plot_lab_test.dart`
* prompt trace：`test/prompt_trace_test.dart`
* 页面：`test/style_lab_page_test.dart`、`test/plot_lab_page_test.dart`、`test/projects_page_test.dart`

小说模块后续至少需要：

* Drift repository 测试：章节顺序、状态流转、级联/引用约束、project 绑定。
* prompt/pipeline 单测：上下文组装、缺失 profile/provider 时的错误、accept 后 projection 边界。
* widget test：章节列表、章节运行状态、缺少配置时的 UI 提示。

## 后续实现边界建议

第一版实现不应包含：

* 富文本编辑器。
* EPUB/PDF 导出。
* 图谱 RAG。
* 全书自动生成。
* 独立聊天机器人界面。

第一版应包含：

* 复用 `WritingProject` 的 Novel Workshop 入口。
* 章节列表和章节 brief。
* 章节 contract -> draft -> audit -> revise -> accept 的持久化运行链路。
* accept 后才更新摘要/事实/人物状态。
* 使用 `WorkflowTask` 和 prompt trace 记录每次 LLM 调用。
