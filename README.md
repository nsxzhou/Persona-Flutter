# Persona Flutter

Persona Flutter 是 Persona 的桌面优先重写版本，Persona 是一个单用户、本地优先、BYOK 的 AI 长文写作工作区。

## 架构基线

第一个脚手架使用进程内 Dart 业务层，而非独立的本地 HTTP 后端。

```text
lib/src/
├── app/                 # Flutter 应用根
├── core/                # 横切基础设施
│   ├── database/        # Drift SQLite 数据库引导
│   ├── router/          # go_router 路由
│   ├── tasks/           # 共享长时间运行任务原语
│   ├── theme/           # 应用主题
│   └── ui/              # 共享 Shell 和组件
└── features/
    ├── projects/
    ├── style_lab/
    ├── plot_lab/
    ├── workflow_runs/
    └── settings/
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

## 当前范围

已包含：

* 桌面优先应用 Shell，含核心导航入口
* `Projects`、`Style Lab`、`Plot Lab`、`Workflow Runs` 和 `Settings` 占位符
* SQLite 初始化边界
* 共享工作流任务模型和仓储契约
* Drift、Freezed 和 JSON 的代码生成设置

尚未包含：

* Provider CRUD
* 项目/章节 CRUD
* 风格/剧情 AI 工作流实现
* Zen 编辑器
* 导入/导出/备份行为
* 账户、登录、云同步或远程后端
