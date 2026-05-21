# 修复角色关系图与详情面板报错

## Goal

修复 Novel Workshop 的“角色索引与关系网”页面：用专业图形库替换手写关系画布，避免关系线和节点布局异常；修复角色详情面板关闭、切换角色、编辑状态下的 TextEditingController 生命周期错误。

## What I already know

* 用户截图显示当前关系图布局奇怪，边线被挤到右侧并与详情卡片重叠。
* 用户截图显示关闭/切换详情卡片后出现 `A TextEditingController was used after being disposed` 和 `LateInitializationError: Field '_nameCtrl...' has already been initialized`。
* 当前实现位于 `lib/src/features/novel_workshop/presentation/character/relationship_canvas.dart`、`character_graph_tab.dart`、`character_detail_panel.dart`。
* 当前关系图为手写 `CustomPainter + ForceDirectedLayout`，每次 build 重新计算布局，且详情面板使用叠加式 Stack。
* 当前详情面板 controller 为 `late final`，`didUpdateWidget` 中 dispose 后再次赋值，符合截图错误根因。

## Requirements

* 添加 `graphview` 依赖并更新 lockfile。
* 使用 `GraphView.builder` 渲染角色节点和有向关系边。
* 保留节点点击选择、选中高亮、关系强度视觉区分。
* 将图区域和详情面板改为互不遮挡的约束布局。
* 关闭详情面板后必须移除面板并恢复图区域宽度。
* controller 只创建一次、dispose 一次；角色切换只同步文本。
* 不修改角色/关系生成、解析、存储 schema。

## Acceptance Criteria

* [ ] 打开角色关系页无红屏和布局溢出。
* [ ] 打开详情面板、关闭详情面板不会抛 Flutter 异常。
* [ ] 切换选中角色不会抛 `LateInitializationError` 或 controller disposed 错误。
* [ ] 有多角色多关系时关系图正常渲染。
* [ ] `flutter analyze` 通过或明确说明非本任务遗留问题。
* [ ] 相关 widget test 覆盖面板关闭和图渲染基本路径。

## Out of Scope

* 不新增关系边编辑功能。
* 不调整数据库 schema、repository contract 或资产生成 pipeline。
* 不重构 Novel Workshop 其他 tab。

## Technical Notes

* Follow frontend component/state/quality/visual guidelines under `.trellis/spec/frontend/`.
* `graphview` API should be verified through resolved package sources after `flutter pub get`.
