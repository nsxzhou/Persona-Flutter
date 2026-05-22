# 分区 Git Diff Patch 预览

## Goal

将 Novel Workshop 的“待审阅记忆 Patch”预览改为按 `Runtime Memory`、`Characters`、`Relationships` 分区展示的 Git diff 风格视图，让用户在整份应用或整份丢弃前能清楚看到 AI 生成 patch 对运行时记忆、角色卡片和关系图的影响。

## Requirements

* Pending memory patch 卡片保留章节标题与整份 `应用 Patch` / `丢弃 Patch` 操作。
* 预览区按 `Runtime Memory`、`Characters`、`Relationships` 三块展示。
* 每块使用类似 `git diff` 的新增/删除/上下文文本风格，新增为绿色，删除为红色。
* `Raw YAML` 默认折叠，展开后显示完整 `memorySyncPatchYaml`。
* 不提供逐行、逐字段、逐分区勾选；操作仍只支持整份应用或整份丢弃。
* 不新增数据库字段，不修改 Drift schema，不改变 repository 公共接口。
* YAML 解析失败时，预览降级为错误提示加 Raw YAML；丢弃仍可用，应用沿用现有 repository 校验。

## Acceptance Criteria

* [ ] Runtime Memory tab 的待审阅 patch 卡片显示三块分区。
* [ ] Raw YAML 默认折叠，展开后可查看完整 YAML。
* [ ] `chapterArchiveMarkdown` 预览为追加效果，与现有 apply 语义一致。
* [ ] 角色按 `name` 生成 diff，关系按 `from -> to` 生成 diff。
* [ ] 页面仍只有整份 `应用 Patch` 和 `丢弃 Patch` 操作，不出现 checkbox。
* [ ] `flutter test test/novel_workshop/novel_workshop_page_test.dart` 通过。
* [ ] `flutter test test/novel_workshop/novel_workshop_repository_test.dart` 通过。
* [ ] `flutter analyze` 通过。

## Technical Notes

* 主要改动位于 `lib/src/features/novel_workshop/presentation/novel_workshop_page.dart`。
* 当前文件已使用 `diff_match_patch`，应复用该依赖。
* 当前值来源于 `projectRuntimeMemoryProvider`、`novelCharactersProvider`、`novelRelationshipsProvider` 已在 workbench 顶层读取的状态。
* 测试优先扩展 `test/novel_workshop/novel_workshop_page_test.dart` 里的现有 fixture。
