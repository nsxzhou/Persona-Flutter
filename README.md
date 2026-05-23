# Persona Flutter

Persona Flutter 是 Persona 的桌面优先重写版本。它是一个单用户、本地优先、BYOK（Bring Your Own Key，用户使用自己的模型 API Key）的 AI 长篇写作工作区，面向小说创作中的风格提取、剧情建模、章节生成、正文加料、运行记忆和任务审计。

项目使用进程内 Dart 业务层和本地 SQLite 持久化，不依赖独立本地 HTTP 后端。Provider 配置、项目、章节、分析结果、任务日志和备份都以本地数据为边界。

## 功能一览

### Projects

Projects 是默认首页，用于管理本地写作项目。

* 新建、编辑、归档、恢复和永久删除项目。
* 为项目配置默认 Provider、默认模型、语言、单章目标字数、全书目标字数和叙事视角。
* 绑定 Style Profile 和 Plot Profile，作为后续 AI 写作的可复用 Prompt 资产。
* 导入 TXT / EPUB 小说，自动切分章节并创建导入型加料项目。
* 进入 Novel Workshop 或章节编辑器继续写作。

### Style Lab

Style Lab 用于从样本文本中提取可复用写作风格。

* 导入 TXT / EPUB 风格样本。
* 对长文本分块分析、聚合分析并生成风格报告。
* 生成 Voice Profile（写作风格档案），用于约束后续章节生成或加料。
* 支持保存、编辑、复制、删除 Profile。
* 支持查看分析草稿、重跑任务、删除任务和查看任务日志。

### Plot Lab

Plot Lab 用于从样本文本中提取剧情结构和故事推进规则。

* 导入 TXT / EPUB 剧情样本。
* 生成剧情账本、全书骨架和剧情分析报告。
* 生成 Story Engine（剧情规则档案），用于后续章节规划和生成。
* 支持保存、编辑、复制、删除 Plot Profile。
* 支持查看任务详情、重跑任务、删除任务和查看日志。

### Novel Workshop

Novel Workshop 是长篇小说项目的核心工作台。

* 管理项目简介、世界观设定、角色蓝图、总纲、分卷规划和章节细纲。
* 管理角色索引与关系网，包括角色别名、标签、阵营、目标、状态、秘密和关系强度。
* 通过 AI 生成世界观、角色关系网、总纲、分卷规划和章节细纲草稿。
* 草稿需要人工审阅后再应用，避免模型输出直接覆盖项目资产。
* 查看项目实际使用的 Prompt 栈，包括 Voice Profile、Story Engine、项目设定、章节目标卡和 Runtime Memory。
* 维护 Runtime Memory（运行时记忆），记录当前剧情状态、伏笔线程、故事摘要、连续性索引和章节归档。

### 章节编辑与生成

章节编辑器负责章节正文编辑和 AI 章节生成。

* 章节导航、新建章节、保存正文和返回工作台。
* 预览某章生成时使用的完整上下文和警告。
* 单章生成流程包含准备上下文、生成草稿、连续性审查、保存章节和提出记忆更新。
* 支持连续性审查结果：通过、警告、失败。
* 生成后可提出 Memory Patch（记忆更新补丁），由用户选择应用或丢弃。
* 支持批量章节生成和停止批次。

### 章节加料

章节加料主要面向导入型小说项目。

* 选择一个或多个已有章节。
* 输入加料指令和扩写比例。
* AI 输出完整新章节预览，不直接覆盖原文。
* 支持单章重试、应用预览、删除预览、忽略预览和批量应用。

### Workflow Runs

Workflow Runs 用于审计本地长任务。

* 查看最近任务、运行中任务和失败任务。
* 查看任务状态、阶段、错误原因和任务日志。
* 查看 Prompt Trace（模型调用追踪），包括请求消息、模型输出和失败信息。
* 对已完成但未应用的资产草稿或章节加料结果，可直接应用或忽略。
* 放弃运行中的任务，并清理未应用产物。

### Settings

Settings 管理模型 Provider 和本地数据。

* 管理 OpenAI-compatible Provider：名称、Base URL、API Key、默认模型、可用模型列表和启用状态。
* 测试 Provider 连接状态。
* Provider 详情页支持流式对话测试、请求参数检查和最终请求预览。
* 编辑 Provider 级 System Prompt，作为该 Provider 的全局系统约束。
* 导出和恢复完整本地 SQLite 数据库备份。
* 备份是明文 SQLite 快照，会包含本机保存的 Provider API Key，请只保存到可信位置。

## 当前边界

已包含：

* 桌面优先应用 Shell 和侧边导航。
* 项目管理、小说工作台、章节编辑器、章节生成和章节加料。
* Style Lab 风格分析与 Voice Profile 生成。
* Plot Lab 剧情分析与 Story Engine 生成。
* OpenAI-compatible Provider 配置、连接测试和流式调用测试。
* 本地 Workflow Task、Prompt Trace、任务日志和任务产物审阅。
* Drift SQLite 本地持久化和完整数据库备份/恢复。

暂不包含：

* 账户、登录、多人协作或权限系统。
* 云同步、远程后端或服务端队列。
* 自动发布、云端备份或跨设备数据合并。
* 面向生产环境的密钥托管服务；当前 API Key 保存在本地数据库中。

## 架构基线

```text
lib/src/
├── app/                 # Flutter 应用根
├── core/                # 横切基础设施
│   ├── analysis/        # 文本导入和分析工具
│   ├── database/        # Drift SQLite 数据库引导、迁移和备份
│   ├── llm/             # LLM 客户端、请求、流式事件和 Markdown completion
│   ├── router/          # go_router 路由
│   ├── tasks/           # 共享长时间运行任务和 Prompt Trace
│   ├── theme/           # 应用主题
│   ├── ui/              # 共享 Shell 和组件
│   └── utils/           # 通用工具
└── features/
    ├── projects/        # 项目管理
    ├── style_lab/       # 风格分析和 Voice Profile
    ├── plot_lab/        # 剧情分析和 Story Engine
    ├── novel_workshop/  # 小说工作台、章节生成、加料和运行记忆
    ├── workflow_runs/   # 长任务审计和产物处理
    └── settings/        # Provider 配置和本地备份
```

每个功能遵循相同的内部层契约：

```text
features/<name>/
├── domain/          # 实体、值对象、仓储契约
├── application/     # 用例、服务、Riverpod Provider
├── data/            # Drift DAO、DTO、映射器、仓储实现
└── presentation/    # 页面、组件、控制器、UI 状态
```

## 技术栈

* Flutter + Dart
* `go_router` 用于声明式路由
* `flutter_riverpod` 用于状态和依赖注入
* `drift` 用于类型化 SQLite 持久化
* `freezed` 和 `json_serializable` 用于生成模型契约
* `riverpod_generator` 用于生成 Riverpod Provider
* `langchain` / `langchain_openai` 用于 OpenAI-compatible 模型调用
* `file_picker`、`epubx` 和文本导入工具用于 TXT / EPUB 导入
* `build_runner` 用于代码生成

当前兼容的生成器组合将 `drift` / `drift_dev` 固定为 `2.31.0`，`json_serializable` 固定为 `^6.13.0`，以便 `riverpod_generator 4.0.3` 可以在 Flutter 3.41.6 上共享分析器依赖。

## 快速开始

```bash
# 安装依赖
flutter pub get

# 生成代码（Drift、Freezed、JSON 等）
dart run build_runner build

# 运行（桌面平台）
flutter run -d macos    # macOS
flutter run -d windows  # Windows
flutter run -d linux    # Linux

# 快速预览（浏览器）
flutter run -d chrome
```

查看可用设备：

```bash
flutter devices
```

## 命令

```bash
dart format .       # 自动格式化所有 Dart 文件，统一代码风格
flutter analyze     # 静态分析，检查类型错误、未使用变量、潜在 bug
flutter test        # 运行所有单元测试和组件测试
```

## 术语说明

| 术语 | 说明 |
| --- | --- |
| BYOK | Bring Your Own Key，用户使用自己的模型 API Key。 |
| Provider | 模型服务配置，包含 Base URL、API Key、默认模型和可用模型列表。 |
| Voice Profile | 风格档案，用于约束 AI 写出指定语言风格。 |
| Story Engine | 剧情档案，用于约束故事结构、节奏、冲突和推进方式。 |
| Runtime Memory | 运行时记忆，用于记录项目当前剧情状态、伏笔、摘要和连续性信息。 |
| Prompt Trace | 模型调用追踪，用于审计一次 AI 任务实际发送了什么、返回了什么、是否失败。 |
