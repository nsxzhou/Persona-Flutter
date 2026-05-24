# Plan: Image Generation Model Integration

## Goal

Add image generation model support to Persona Flutter so users can configure an image-generation provider and test built-in prompts in a way that mirrors the current text Provider detail workflow.

## What I Already Know

- The project is a Flutter/Dart desktop-first app using Riverpod, Drift SQLite, go_router, and local BYOK provider configuration.
- Current text Provider support is OpenAI-compatible chat oriented:
  - configuration: `ProviderConfig`
  - persistence: `ProviderConfigRecords` and `ProviderModelRecords`
  - connectivity test: `GET /models` with `Authorization: Bearer <apiKey>`
  - detail test UI: streaming chat workbench, Provider Prompt editor, test parameters, Actual Request inspector
- The supplied image intermediary was later verified against the user's actual endpoint:
  - `POST https://ai.centos.hk/v1/images/generations`
  - header `Authorization: Bearer <api key>`
  - JSON body with `model`, `prompt`, concrete `size`, `quality`, `response_format`, and `n`
  - example model `gpt-image-2`
  - `size: 1024x1024` returned image data; `size: auto` returned HTTP 200 with an empty `data` list on this site.
- The referenced NewAPI image documentation describes OpenAI-style image endpoints:
  - text-to-image: `POST /v1/images/generations`
  - image-to-image/edit: `POST /v1/images/edits`
  - variation: `POST /v1/images/variations`
  - successful responses contain `created` and `data`; image objects may contain `url`, `b64_json`, and `revised_prompt`.
- The existing text model abstractions should not be overloaded for image generation because image requests are non-streaming, return media artifacts, and use different auth/response semantics.

## Assumptions

- MVP should first support manual configuration and testing from Settings before wiring image generation into Novel Workshop workflows.
- The image provider can share local SQLite storage and BYOK privacy boundaries with text providers.
- The first supported endpoint shape should follow the actual site and NewAPI documentation: use only `Authorization: Bearer <api key>` for image requests.
- Generated test images are previewed in memory only and disappear when leaving the page; long-term asset persistence can be a later workflow decision.

## Requirements

- Add an image-generation provider concept that does not pollute existing text provider model selection.
- Do not perform `/models` discovery for image providers.
- Treat image provider connectivity test as a real sample text-to-image generation using a built-in short prompt.
- Support configuring:
  - name
  - base URL
  - API Key
  - default image model
  - optional image model list
  - supported aspect ratio, size tier, quality, and default response format
  - default response format for text-to-image tests
  - enabled/test status metadata
- Support only Bearer authentication for MVP: `Authorization: Bearer <api key>`.
- Support text-to-image test generation through `/v1/images/generations`.
- Plan image-to-image support through `/v1/images/edits`; include the service/client request shape and tests now, but do not expose image-to-image UI in MVP.
- Do not implement `/v1/images/variations` in MVP.
- Provide an image Provider detail/test screen with:
  - built-in test prompt
  - editable prompt for the current test
  - model selector
  - aspect ratio selector: 自动, 方形 1:1, 竖版 3:4, 故事版 9:16, 横版 4:3, 宽屏 16:9
  - size tier selector with 1K, 2K, and 4K options
  - quality selector with auto, low, medium, and high options
  - response format selector, defaulting to `url`
  - generate button with loading/error state
  - image preview
  - Actual Request inspector that hides secrets
  - raw/summarized response inspector if useful
- Preserve existing text Provider behavior and tests.
- Add unit/widget tests around repository persistence, request building, error sanitization, and the new image test UI.

## Proposed Architecture

### Option A: Separate Image Provider Domain (Recommended)

Create a parallel image provider stack:

- `features/settings/domain/image_provider_config.dart`
- `features/settings/data/drift_image_provider_config_repository.dart`
- `features/settings/application/image_provider_config_providers.dart`
- `core/image_generation/domain/image_generation_client.dart`
- `core/image_generation/application/image_generation_service.dart`
- `core/image_generation/data/bearer_image_generation_client.dart`
- `features/settings/presentation/image_provider_detail_page.dart`

Pros:
- Keeps text chat and image generation contract clean.
- Avoids breaking existing project default provider/model behavior.
- Makes image-specific UI and auth explicit.

Cons:
- Adds new Drift tables and repository code.
- Settings UI needs a second provider section or tabs.

### Option B: Add Provider Capability to Existing ProviderConfig

Add a provider `kind`/`capabilities` field and reuse most Provider tables.

Pros:
- Fewer new tables.
- One provider list in Settings.

Cons:
- Existing `systemPrompt`, project default model, and chat test detail become awkward for image-only models.
- Higher regression risk for current text workflows.
- Future mixed text+image providers become harder to reason about unless capability modeling is done carefully.

### Recommended MVP

Use Option A for the first implementation:

1. Add separate image provider config and image model tables.
2. Add image generation client/service that builds `POST /v1/images/generations` and sends `Authorization: Bearer <api key>`.
3. Add a Settings section named `图像 Provider` below the current `Provider 控制台` and above `本地备份`; do not convert Settings to tabs in MVP.
4. Add route `/settings/image-providers/:providerId`.
5. Build a detail test workbench visually consistent with current Provider detail, but tailored to image preview and request inspection.
6. Parse `url` and `b64_json` image response objects; show `revised_prompt` when present.
7. Keep image-to-image/edit as a client/service primitive only; no file picker, mask upload, or edit preview UI in MVP.
8. Store only configuration and test metadata in the MVP; do not persist generated images as project assets yet.

## MVP Test Parameters

- Expose in UI:
  - `prompt`
  - `model`
  - aspect ratio preset
  - size tier preset
  - `quality`
  - `response_format`
- Fixed defaults:
  - `n`: 1
  - `style`: omitted
  - `user`: omitted
- Request `size` is resolved from aspect ratio plus size tier. `自动` sends `size: auto`; fixed ratios send a concrete `WIDTHxHEIGHT` value. The sample generation test deliberately uses `1:1 + 1K` so this site receives `1024x1024`.
- Quality values follow OpenAI/NewAPI: `auto`, `low`, `medium`, `high`.
- `response_format` defaults to `url`, with `b64_json` available for providers that return inline image data.

## Connectivity Test Strategy

- Image Provider connection tests must not call `/models`.
- The Settings list test action should call `/v1/images/generations` with:
  - built-in short prompt
  - configured default model
  - `size: 1024x1024` from `1:1 + 1K`
  - `quality: auto`
  - `response_format: url`
  - fixed `n: 1`
  - header `Authorization: Bearer <api key>`
- A test succeeds only when the response contains at least one parseable image result (`url` or `b64_json`).
- The saved test message should summarize that a sample image generation succeeded and should not persist the returned image in MVP.
- The generated sample image should not be cached on disk or stored in SQLite.
- Failures must be sanitized so the API Key is not shown in UI or test messages.

## UI Direction

Keep the current product tone: desktop-first, dense, utilitarian, local-control oriented. The image test workbench should feel like a tool surface rather than a gallery page:

- Left: prompt/test panel and generated image preview.
- Right: model/size controls, request inspector, provider metadata.
- Use existing `PersonaPage`, `PersonaPanel`, `PersonaSectionHeader`, `PersonaStatusPill`.
- Avoid large marketing-style image cards or decorative layout shifts.

## Acceptance Criteria

- [ ] Existing text Provider tests continue to pass unchanged.
- [ ] User can create/edit/delete an image Provider from Settings.
- [ ] Settings keeps the current text Provider panel unchanged and adds a separate `图像 Provider` panel below it.
- [ ] User can configure the image intermediary with base URL, API Key, model, aspect ratio, size tier, quality, and response format.
- [ ] Image Provider list test action performs a real built-in sample text-to-image generation and does not call `/models`.
- [ ] User can open image Provider detail page and run a built-in prompt test.
- [ ] Text-to-image requests use `/v1/images/generations` and send `Authorization: Bearer <api key>`.
- [ ] Text-to-image UI exposes prompt, model, aspect ratio, size tier, quality, and response format.
- [ ] Text-to-image size controls support 自动, 1:1, 3:4, 9:16, 4:3, 16:9 plus 1K, 2K, and 4K generation tiers.
- [ ] Image-edit client contract targets `/v1/images/edits`, with no visible image-to-image UI in MVP.
- [ ] The generated image is rendered in the app when the endpoint returns a supported image URL or base64 response.
- [ ] `revised_prompt` and `usage` are captured in the response inspector when present.
- [ ] Generated test images are memory-only and disappear when leaving the detail page.
- [ ] Errors are shown without leaking API keys.
- [ ] Actual Request inspector shows endpoint, model, prompt, size, response format, quality/style if used, and no secrets.
- [ ] Repository and client tests cover persistence, URL normalization, auth header, response parsing, and error sanitization.

## Out of Scope for MVP

- Project-level image asset generation workflows.
- Persistent generated image library.
- Disk caching of generated test images.
- Batch image generation.
- Variations through `/v1/images/variations`.
- Full image editing UX with file upload, masks, multi-image management, and image-to-image preview panels.
- Cost tracking beyond showing a static warning that the configured intermediary may charge per generation.
- Cloud sync or encrypted keychain migration.

## Open Questions

- Should the implementation start now with this MVP scope, or should another requirement branch be clarified first?

## Research References

- `research/repo-context.md` - local code evidence for existing text Provider, LLM invocation, prompt trace, and screenshot endpoint implications.
- NewAPI Image documentation: https://doc.newapi.pro/api/openai-image/
