# 小说加料导入型项目

## Goal

新增“小说加料”导入型项目分支：用户从项目页导入 `txt` 或 `epub` 小说，本地解析章节并在可编辑预览中确认后创建项目。导入项目使用简化工作台和专用加料编辑器流程，对选中章节执行整章加料改写，结果先预览再应用。

## What I Already Know

- 当前 Flutter 项目已有普通小说工作台、章节计划、章节正文、章节生成管线、项目设置、Voice Profile 绑定和 `txt/epub` 依赖。
- `reference_projects/Persona_副本` 已有导入小说和章节改写参考实现：导入后作为特殊项目，章节正文进入章节树，加料/改写以章节为单位运行。
- 本功能是普通新建小说之外的分支，不应暴露完整 10 个工作台 tab。

## Requirements

- 项目模型增加来源标记，用于区分普通项目和导入加料项目；旧项目默认普通项目。
- 项目页新增导入入口，支持选择 `txt` / `epub` 文件。
- 本地解析导入文件：
  - `txt` 通过章节标题规则切分。
  - `epub` 通过 `epubx` 目录章节提取。
  - v1 不接入 AI 章节解析。
  - 导入章节统一放入单卷“导入正文”。
- 导入后先展示可编辑预览：
  - 展示章节标题、字数和解析警告。
  - 支持编辑章节标题、删除章节、合并相邻章节。
  - 用户确认后创建导入型项目。
- 导入创建后复用现有 `ChapterVolume` / `ChapterPlan` / `ProjectChapter` 数据结构存储章节树与正文。
- 导入型项目工作台只保留：
  - 概览：导入统计、章节数、总字数、最近加料批次和进入编辑器入口。
  - Voice Profile：选择/展示绑定风格。
  - 设置：模型、语言、目标字数等项目参数。
- 导入型项目编辑器：
  - 默认显示章节树。
  - 隐藏新建分卷/章节入口。
  - 主操作从“生成”改为“加料”。
- 加料功能：
  - 支持在章节树中选择单章或多章。
  - 弹窗中填写自由加料指令和扩写比例。
  - 扩写比例默认 `20%`，范围 `1-100`。
  - 采用整章直接改写，模型输出完整新章节正文。
  - 只注入 Voice Profile 作为风格上下文，不使用 Plot Profile、Story Engine 或 Runtime Memory。
  - 允许大幅重写，但必须限制在选中章节内，不续写下一章。
  - 批量章节失败不中断后续章节，失败项可单独重试。
  - 生成结果先进入预览，不自动覆盖正文。
  - 支持逐章应用或批量应用已成功生成的条目。
- v1 不长期额外保存原始导入正文；加料条目保存生成时正文快照用于预览差异。

## Acceptance Criteria

- [ ] 旧项目在数据库迁移后仍作为普通项目运行。
- [ ] 用户可从项目页导入 `txt` / `epub`，看到可编辑章节预览并创建导入型项目。
- [ ] 导入型项目进入工作台只显示“概览 / Voice Profile / 设置”三个 tab。
- [ ] 普通项目仍显示完整工作台 tab 和原章节生成流程。
- [ ] 导入型编辑器隐藏新建入口，并以“加料”替代“生成”。
- [ ] 加料批次保存预览结果，不自动覆盖章节正文。
- [ ] 用户可逐章或批量应用加料结果。
- [ ] 批量加料中单章失败不会阻断后续章节。
- [ ] 测试覆盖导入解析、数据库持久化、加料管线、应用逻辑和关键 UI 回归。

## Out of Scope

- v1 不做 AI 增强章节解析。
- v1 不识别多卷结构。
- v1 不提供恢复最初导入正文的长期版本管理。
- v1 不新增 Plot Profile / Story Engine 上下文注入。

## Technical Notes

- Current platform confirmed: macOS/Darwin, `zsh`, workspace `/Users/zhouzirui/code/AI/Persona-Flutter`.
- Existing import reference: `lib/src/features/plot_lab/application/plot_sample_importer.dart`.
- Existing workshop files likely impacted:
  - `lib/src/features/projects/**`
  - `lib/src/features/novel_workshop/**`
  - `lib/src/core/database/app_database.dart`
  - `lib/src/core/router/**`
- Reference implementation files inspected under `reference_projects/Persona_副本`:
  - `api/app/services/novel_imports.py`
  - `api/app/services/novel_chapter_rewrite_jobs.py`
  - `api/app/services/chapter_rewrite_batches.py`
  - `api/app/prompts/imported_chapter_rewrite.py`
