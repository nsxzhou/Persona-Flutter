# 图像 Provider 区分 GPT 与 Grok

## Goal

让项目的图像 Provider 显式区分 GPT 与 Grok 两类接入。GPT 使用 `/v1/images/generations`，Grok 使用 `/v1/chat/completions`，按模型生态发送不同请求字段，兼容更多 Grok 中转站点。

## What I already know

- 当前 `BearerImageGenerationClient` 统一请求 `/v1/images/generations`。
- 当前请求体包含 `model`、`prompt`、`size`、`quality`、`n`、`response_format`。
- 当前 `ImageGenerationService` 已固定 `n: 1`，但请求体仍发送 `n`。
- 图像 Provider 配置当前没有类型字段，只保存 baseUrl、apiKey、defaultModel、defaultQuality、defaultResponseFormat 等。
- 实测 `https://api.sccens.net/v1` 的 `grok-imagine-image-lite` 可通过 `/chat/completions` 返回 Markdown 图片链接。
- Grok Chat Completions 兼容模式返回 URL 图片链接；部分站点的外链可访问性取决于中转和 CDN。
- 实测 Grok `/images/edits` multipart 方式返回 400，本任务不支持 Grok 图片编辑。

## Requirements

- 新增图像 Provider 类型：GPT 与 Grok，由用户显式选择。
- 旧图像 Provider 迁移后默认类型为 GPT。
- GPT Provider 使用 `POST {baseUrl}/v1/images/generations`。
- Grok Provider 使用 `POST {baseUrl}/v1/chat/completions`。
- 请求体完全移除 `n` 字段。
- 业务层只返回第一张有效图片。
- GPT 保持现有请求策略：继续发送 `quality` 和配置的 `response_format`。
- Grok 使用 Chat Completions 兼容请求：`messages + image_config`，不发送 `quality`，固定 `image_config.response_format: url`。
- Grok 类型下设置 UI 隐藏质量和返回格式控件。
- Provider 连接测试按类型区分：GPT 保持现有测试语义但移除 `n`；Grok 使用 `/chat/completions + image_config`，固定 `1:1 + 1K + url`，不发送 `quality` 和顶层 `n`。
- Grok 图片编辑调用应返回明确不支持错误。

## Acceptance Criteria

- [ ] 用户可在图像 Provider 设置 UI 中选择 GPT / Grok。
- [ ] 数据库 schema 升级并将旧图像 Provider 默认迁移为 GPT。
- [ ] GPT 生成请求不包含 `n`，仍包含 `quality` 和配置的 `response_format`。
- [ ] Grok 生成请求使用 `/chat/completions`，不包含顶层 `n` 和 `quality`，图片参数在 `image_config` 内。
- [ ] 响应多张图片时业务结果只包含第一张有效图片。
- [ ] Grok 图片编辑返回明确不支持错误。
- [ ] 相关单元测试更新并通过。

## Out of Scope

- 不支持 Grok 图片编辑。
- 不引入自动模型名或 URL 推断。

## Technical Notes

- 主要涉及 `ImageProviderConfig`、Drift 数据库、图像 Provider 保存表单、Provider 测试流程、`BearerImageGenerationClient`、相关 provider config 测试。
