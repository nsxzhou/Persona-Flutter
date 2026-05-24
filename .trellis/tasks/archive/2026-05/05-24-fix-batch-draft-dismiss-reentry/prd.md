# 修复批量草稿关闭后重新进入仍显示

## Goal

批量草稿终态面板点击关闭后，在同一次 App 会话内离开并重新进入编辑器时不应再次出现。关闭状态仍然不写数据库、不跨应用重启持久化。

## Requirements

* 终态批次关闭状态从 `NovelEditorPage` widget-local state 移到会话级状态。
* 运行中批次仍优先显示，且新批次不受旧终态批次关闭状态影响。
* 不新增数据库字段，不使用 `previewDismissedAt`。
* 补 widget 回归测试：关闭终态面板 -> 离开编辑器 -> 重新进入编辑器 -> 面板不再出现。

## Acceptance Criteria

* [ ] 同一 App 会话内重新进入编辑器不会重新显示已关闭的终态批量草稿面板。
* [ ] 新运行中批次仍能显示。
* [ ] `flutter analyze` 和相关 widget test 通过。
