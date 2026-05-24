# Repo Context: Image Generation Model Integration

## Local Evidence

- Runtime platform confirmed from session context and local paths: macOS/Darwin style paths under `/Users/zhouzirui`, shell `zsh`, Flutter/Dart project.
- Existing text model configuration lives under `lib/src/features/settings/`.
- Existing model invocation infrastructure lives under `lib/src/core/llm/`.
- Existing task audit and prompt trace infrastructure lives under `lib/src/core/tasks/`.
- Existing novel project workflows use text providers through project default provider/model fields.

## Current Text Provider Model

- `lib/src/features/settings/domain/provider_config.dart`
  - `ProviderConfig` contains `baseUrl`, `apiKey`, `defaultModel`, `modelNames`, `systemPrompt`, `isSystemPromptEnabled`, `isEnabled`, and test metadata.
  - The shape is generic by name but semantically chat/text oriented because it contains provider-level system prompt and is consumed by LLM chat services.
- `lib/src/core/database/app_database.dart`
  - `ProviderConfigRecords` stores provider settings.
  - `ProviderModelRecords` stores model names per provider.
  - Schema version is currently `23`.
- `lib/src/features/settings/data/drift_provider_config_repository.dart`
  - Persists provider records and model lists.
  - Saves reset test state on provider edits.
- `lib/src/features/settings/application/provider_connectivity_tester.dart`
  - Tests text provider connectivity by `GET {baseUrl}/models` with `Authorization: Bearer <apiKey>`.
- `lib/src/features/settings/presentation/settings_page.dart`
  - Settings page has a Provider console list, add/edit dialog, connection test, delete action.
- `lib/src/features/settings/presentation/provider_detail_page.dart`
  - Provider detail page has a stream chat workbench, Provider Prompt editor, parameter controls, and Actual Request inspector.

## Current LLM Invocation

- `lib/src/core/llm/domain/llm_client.dart`
  - Defines `streamChat(provider, request)`.
- `lib/src/core/llm/application/llm_invocation_service.dart`
  - Composes business prompt and provider system prompt.
  - Streams text responses.
  - Records prompt trace events when configured.
- `lib/src/core/llm/data/langchain_llm_client.dart`
  - Uses `langchain_openai` `ChatOpenAI`.
  - Normalizes base URLs ending in `/chat/completions` or `/completions`.
- `lib/src/core/llm/application/markdown_completion_service.dart`
  - Wraps streaming chat into full Markdown completion.

## Existing Prompt Trace Pattern

- `lib/src/core/tasks/application/prompt_trace_recorder.dart`
  - Records sanitized prompt trace Markdown.
  - Redacts provider API keys and bearer tokens.
  - Stores request messages, output excerpt, model name, temperature, duration, error summary.

## Screenshot API Evidence

The provided intermediary appears to expose an OpenAI-style image generation endpoint:

- Base URL: `https://uuerqapsfftez.sealosqzq.site`
- Endpoint: `POST /v1/images/generations`
- Headers:
  - `Content-Type: application/json`
  - Initially inferred as `token: <api key>` from the screenshot, but this was corrected after live testing.
- Body example:
  - `model`: `gpt-5-3`
  - `prompt`: user prompt
- NewAPI/OpenAI documented `size` values are model-specific concrete sizes or `auto`.
- OpenAI/NewAPI `quality` values for `gpt-image-1` are `auto`, `low`, `medium`, and `high`; DALL-E 3 also documents `standard`/`hd`.
- Cost note from screenshot: each image generation deducts 7 星火币.

The image API differs from the existing text provider test path because it must run a sample generation instead of `GET /models`, and image generation returns image URLs or base64 payloads instead of text deltas.

## Live Site Verification Evidence

User-provided endpoint tested on 2026-05-24:

- Base URL: `https://ai.centos.hk/v1`
- Model: `gpt-image-2`
- `token: <api key>` and `Token: <api key>` both returned HTTP 401 `Invalid token`.
- `Authorization: Bearer <api key>` succeeded.
- `size: auto` with Bearer returned HTTP 200 but an empty `data` list.
- `size: 1024x1024` with Bearer returned an image response.

Implementation should therefore use Bearer auth and make the built-in sample generation send a concrete `1024x1024` size.

## NewAPI Image Documentation Evidence

Source: https://doc.newapi.pro/api/openai-image/

- Text-to-image endpoint: `POST /v1/images/generations`.
- Image edit endpoint: `POST /v1/images/edits`.
- Variation endpoint: `POST /v1/images/variations`, but this is out of scope for the first implementation.
- Create image request parameters include `prompt`, `model`, `n`, `quality`, `response_format`, `size`, `style`, and `user`.
- Edit image request parameters include uploaded `image` file(s), `prompt`, optional `mask`, `model`, `quality`, and `size`.
- The documented success response contains `created` and `data`; each image object can contain `url`, `b64_json`, and `revised_prompt`; `usage` may appear for `gpt-image-1`.
- The public NewAPI document uses `Authorization: Bearer $NEWAPI_API_KEY`; the live target intermediary also requires Bearer auth.

## CookSleep/gpt_image_playground Evidence

Source: https://github.com/CookSleep/gpt_image_playground

- The reference project models task params as `size: string`, `quality: 'auto' | 'low' | 'medium' | 'high'`, `output_format`, `output_compression`, moderation, and `n`.
- Its size helper uses size tiers `1K`, `2K`, and `4K` as pixel budgets, then combines a chosen aspect ratio with a tier into a concrete `WIDTHxHEIGHT` size.
- This means the Persona UI should treat `1K/2K/4K` as a size tier, not as the API `quality` field.

## Integration Implications

- Do not route image generation through `LlmClient.streamChat`; introduce a separate image generation client/service.
- Avoid making existing project default text provider accidentally select image-only models.
- Settings UI can reuse the Provider console pattern, but image providers need image-specific fields:
  - Bearer auth support for this intermediary
  - model list
  - aspect ratio and size tier choices
  - quality and response format controls
  - built-in test prompt
  - generated image preview and raw response/request inspector
- Prompt trace can be extended or a parallel image trace can be introduced, but previews should avoid storing secrets and should not assume text output.
