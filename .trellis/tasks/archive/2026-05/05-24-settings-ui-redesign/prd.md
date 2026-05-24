# Settings Page UI Redesign

## Problem
当前 settings 页面存在三个核心问题：
1. 视觉简陋 — 三个面板垂直堆叠，没有层次感
2. 信息组织混乱 — 所有设置平铺在一页，没有分类
3. 代码质量差 — 大量重复代码在 4 个文件中复制粘贴

## Design Direction
- 精致 Material 3（保持实色卡片，通过间距/阴影/排版提升质感）
- 顶部 Tab 切换（SegmentedButton）
- 完全重新设计视觉样式
- 不改动详情页（provider_detail_page.dart / image_provider_detail_page.dart）

## Scope

### Phase 1: Extract Shared Components
- `persona_status_indicator.dart` — StatusDot, statusColor, statusLabel, statusIcon
- `persona_info_pill.dart` — MonoPill, HeaderStatusBadge
- `persona_form_utils.dart` — requiredValidator, urlValidator, parseModelNames

### Phase 2: Tab-Based Settings Shell
- 重写 settings_page.dart 为 Tab 结构（模型配置 / 数据与备份 / 外观）
- model_config_tab.dart — 统一 LLM/Image Provider 列表，内层 SegmentedButton 切换
- data_backup_tab.dart — 迁移备份面板
- appearance_tab.dart — 迁移主题切换
- 删除 image_provider_settings_panel.dart

### Phase 3: Unified Provider Dialog
- provider_dialog.dart — 共享表单字段 + LLM/Image 专用包装

### Phase 4: Visual Polish
- SegmentedButton 主题、hover 渐变、状态 glow、操作栏背景

## Verification
- flutter analyze 无错误
- Tab 切换正常
- Provider 增删改查正常
- flutter test 通过
