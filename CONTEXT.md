# Persona Flutter

桌面端 AI 辅助小说创作应用，集成市场分析、风格学习、情节设计和智能写作工作流。

## Language

**Writing Project（写作项目）**:
用户创建的小说创作容器，包含元数据（书名、简介、字数目标）、绑定的风格/情节配置文件，以及所有章节和素材。
_Avoid_: Novel, Book, Story

**Market Scan Data（市场扫描数据）**:
从网文平台核心榜单采集的原始数据，包含基础元数据（书名、作者、分类/题材标签、字数、连载状态）、排行榜数据（榜单名称、排名位置）、热度指标（收藏数、推荐票、月票、评论数）和内容摘要（简介、首发时间），缓存在本地 SQLite 中供 Rule Engine 和 LLM 分析使用。
_Avoid_: Chart data, Ranking data

**Recommendation Direction（推荐方向）**:
AI 分析市场数据后生成的创意层建议，包含建议书名、简介、题材标签、字数目标、市场热度和竞品密度评估。不包含技术参数（Provider/Model、Voice Profile、Story Engine 等），用户选择后在统一创建表单中配置。用户从 3-5 个推荐方向中选择一个作为项目起点。
_Avoid_: Suggestion, Idea, Proposal

**Voice Profile（风格档案）**:
Style Lab 分析文本后生成的写作风格模型，描述语言特征、句式偏好、节奏模式等，可绑定到写作项目指导 AI 生成。
_Avoid_: Style Profile, Writing style

**Story Engine（故事引擎）**:
Plot Lab 分析故事结构后生成的情节模型，描述叙事节奏、冲突模式、情节转折规则等，可绑定到写作项目指导章节生成。
_Avoid_: Plot Profile, Story structure

**Project Bible（项目圣经）**:
项目级别的创意素材集合，包含世界观设定、角色蓝图、大纲等，在 Novel Workshop 中维护和迭代。
_Avoid_: World building, Story bible

**Data Source Adapter（数据源适配器）**:
每个网文平台的爬虫实现，负责从特定平台采集核心榜单数据，输出统一格式的 Market Scan Data。当前支持三个平台：起点、番茄、晋江。
_Avoid_: Scraper, Crawler

**Rule Engine（规则引擎）**:
对 Market Scan Data 做定量统计分析的模块，计算题材热度、频次分布、竞品密度和市场机会评分（热度高 + 竞品密度低 = 机会）四类指标，为 LLM 生成推荐方向提供结构化输入。
_Avoid_: Statistics module, Analytics

**Unified Creation Form（统一创建表单）**:
推荐流程和手动创建共享的项目创建界面。推荐选择后预填创意数据进入，手动创建时空白进入。用户在此表单中编辑创意内容（书名、简介等）并配置技术参数（Provider/Model、Voice Profile、Story Engine 等），确认后创建 Writing Project。
_Avoid_: Project creation dialog, New project form

## Architecture

应用采用分层架构：presentation（UI + controllers）、application（use cases + providers）、domain（entities + repository interfaces）、data（Drift SQLite 实现）。状态管理使用 Riverpod，路由使用 go_router，数据库使用 Drift。

核心特性模块：Projects（项目管理 + 推荐创建流程）、Market Scan（市场数据采集与分析）、Style Lab（风格分析）、Plot Lab（情节分析）、Novel Workshop（写作工作台）、Settings（配置）。
