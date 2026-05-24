# Quality Guidelines

> Code quality standards for backend development.

---

## Overview

Backend-like Dart code must keep persistence, domain, application, and presentation boundaries separate. The app uses Drift, Riverpod, Freezed, JSON serialization, and build_runner-generated files.

---

## Forbidden Patterns

* Do not import Drift table records directly into feature presentation widgets.
* Do not edit generated `*.g.dart` or `*.freezed.dart` files.
* Do not add separate local HTTP backend abstractions without an explicit architecture decision.
* Do not store API keys or manuscript content in logs.

---

## Required Patterns

* Expose persistence through repository contracts.
* Convert Drift rows to domain models before UI consumption.
* Use Riverpod providers for service/repository wiring.
* Run `dart run build_runner build` after changing Drift, Freezed, JSON, or Riverpod annotations.
* Keep LLM framework types behind `core/llm/data` adapters. UI and feature
  application code must depend on Persona-owned contracts such as `LlmClient`,
  `LlmRequest`, `LlmMessage`, and `LlmStreamEvent`, not LangChain.dart types.

---

## Testing Requirements

Run:

```bash
dart run build_runner build
dart format lib test .trellis/spec
flutter analyze
flutter test
```

Add focused tests for changed behavior. Current smoke coverage lives in `test/widget_test.dart`.

---

## Code Review Checklist

* Are generated files up to date?
* Does UI depend only on providers/application contracts?
* Are local persistence contracts typed and testable?
* Are async provider loading/error/data states handled?

---

## Scenario: macOS outbound provider connectivity

### 1. Scope / Trigger
- Trigger: Any feature that performs outbound HTTPS from the macOS Flutter app, including Provider connectivity tests.

### 2. Signatures
- Entitlement keys:
  - `macos/Runner/DebugProfile.entitlements`: `com.apple.security.network.client`
  - `macos/Runner/Release.entitlements`: `com.apple.security.network.client`

### 3. Contracts
- Debug/Profile and Release builds must both include client networking when the app calls external Provider endpoints.
- `com.apple.security.network.server` is not sufficient for outbound HTTPS.

### 4. Validation & Error Matrix
- Missing `network.client` -> macOS sandbox can throw `SocketException: Operation not permitted, errno = 1`.
- Incorrect Provider URL/API Key -> HTTP or provider-specific failure, not `Operation not permitted`.

### 5. Good/Base/Bad Cases
- Good: add `network.client` before shipping Provider network calls.
- Base: re-run the macOS app after changing entitlements.
- Bad: debug the URL/model/key when the OS error is sandbox permission denial.

### 6. Tests Required
- `flutter analyze`
- `flutter test`
- Manual macOS rerun is required because entitlement changes apply after rebuilding/relaunching the app.

### 7. Wrong vs Correct
#### Wrong
Assume `com.apple.security.network.server` permits outbound Provider requests.
#### Correct
Enable `com.apple.security.network.client` for outbound Provider connectivity.

## Scenario: Shared LLM invocation boundary

### 1. Scope / Trigger
- Trigger: Any feature that calls a user-configured OpenAI-compatible Provider.
- This is a cross-layer contract because Provider persistence, prompt composition, streaming model calls, UI state, and secret redaction all meet at the LLM boundary.

### 2. Signatures
- Domain port: `LlmClient.streamChat({required ProviderConfig provider, required LlmRequest request})`.
- Request types: `LlmRequest(model, temperature, messages)`, `LlmMessage(role, content)`.
- Stream events: `LlmStreamDelta(text)` and `LlmStreamDone()`.
- Adapter: `LangChainLlmClient implements LlmClient` lives under `core/llm/data`.
- Prompt composition: `ProviderPromptComposer.compose(businessSystemPrompt, providerSystemPrompt)`.

### 3. Contracts
- Business code and presentation widgets must not import LangChain.dart message, model, or result types directly.
- Provider-level system prompt is appended after the business system prompt; it does not replace feature-specific prompts.
- Empty Provider prompt means "append nothing" for production calls.
- API keys may be passed to the adapter but must never be logged or rendered in UI/debug panels.

### 4. Validation & Error Matrix
- Empty Provider prompt -> skip Provider prompt append.
- Empty business prompt + non-empty Provider prompt -> use Provider prompt as the system prompt.
- Adapter error containing API key -> replace the key with `[REDACTED]` before surfacing the error.
- Unsupported Provider protocol -> fail at the adapter boundary, not in UI.

### 5. Good/Base/Bad Cases
- Good: feature service calls `LlmInvocationService`, which composes prompts and delegates to `LlmClient`.
- Base: Provider settings uses `LlmClient` for chat tests with fake clients in tests.
- Bad: a widget constructs `ChatOpenAI` directly or stores LangChain messages in feature state.

### 6. Tests Required
- Unit test `ProviderPromptComposer` for empty and non-empty prompt composition.
- Unit test `LlmInvocationService` for system-message ordering and temperature.
- Adapter test with fake chat model for stream-event conversion and key redaction.
- Widget tests should override `llmClientProvider` instead of making live LLM calls.

### 7. Wrong vs Correct
#### Wrong
Import `ChatOpenAI` in a feature page and stream directly into widget state.
#### Correct
Feature code depends on `LlmInvocationService` / `LlmClient`; only `core/llm/data` imports LangChain.dart.

## Scenario: Image generation provider boundary

### 1. Scope / Trigger
- Trigger: Settings manages text-to-image Provider configuration and the app calls a Bearer-auth OpenAI-style image endpoint.
- This is a cross-layer contract because Drift persistence, Settings UI, Riverpod wiring, image-generation services, request/response parsing, and secret redaction must agree.

### 2. Signatures
- Drift tables:
  - `ImageProviderConfigRecords`
  - `ImageProviderModelRecords`
- Repository contract: `ImageProviderConfigRepository`
- Domain model: `ImageProviderConfig`
- Core port: `ImageGenerationClient`
- Service: `ImageGenerationService`
- Adapter: `BearerImageGenerationClient`
- Text-to-image endpoint: `POST /v1/images/generations`
- Image-edit endpoint contract: `POST /v1/images/edits`

### 3. Contracts
- Image providers are separate from text `ProviderConfig`; do not add image-only models to project default text model selection.
- MVP authentication uses only the `Authorization: Bearer <api key>` header. Do not send a custom `token` header for image provider requests.
- Image provider connectivity tests do not call `/models`. They perform a real sample text-to-image generation through `/v1/images/generations`.
- Text-to-image requests expose `prompt`, `model`, `size`, `quality`, `response_format`, and fixed `n: 1` in MVP. Omit `style` and `user`.
- `quality` follows OpenAI/NewAPI values `auto`, `low`, `medium`, and `high`.
- UI stores an aspect-ratio preset (`auto`, `1:1`, `3:4`, `9:16`, `4:3`, `16:9`) and a size tier (`1K`, `2K`, `4K`), then resolves them into the final `size` value sent to the API. `auto` aspect ratio sends `size: auto`; sample generation should use `1:1 + 1K` and send `1024x1024` because the current target site returns empty image data for `auto`.
- Image responses must parse `data[].url` and `data[].b64_json`; preserve `data[].revised_prompt` and `usage` for diagnostics when present.
- Generated test images are memory-only. Do not store image bytes or URLs in SQLite or on disk in MVP.
- API keys may be passed to adapters but must never appear in UI, logs, test messages, request inspectors, or surfaced errors.

### 4. Validation & Error Matrix
- Missing name/baseUrl/apiKey/defaultModel -> validation error before write.
- Invalid URL -> validation error before write.
- Sample generation HTTP non-2xx -> persist `failed` with a sanitized message.
- Response body is not JSON object -> image generation client exception.
- Response lacks `data` list -> image generation client exception.
- Response contains no image with `url` or `b64_json` -> image generation client exception.
- Adapter error containing an API key -> replace the key with `[REDACTED]` before surfacing.

### 5. Good/Base/Bad Cases
- Good: create an image Provider, test it with one `1:1`/`1K` sample generation, render the returned image in memory, and show request/response inspectors without secrets.
- Base: image-edit request primitives exist for `/v1/images/edits`, but the first UI only exposes text-to-image testing.
- Bad: reuse `LlmClient.streamChat` for image generation.
- Bad: use `/models` discovery as the image Provider readiness check.
- Bad: store sample image output in SQLite backup data during MVP.

### 6. Tests Required
- Repository test for `ImageProviderConfig` round-trip, model normalization, test status update, and delete.
- Client tests for `/v1/images/generations` URL normalization, Bearer auth header, response parsing, and API key redaction.
- Client test for `/v1/images/edits` request endpoint contract.
- Widget tests for Settings image Provider panel, dialog controls, detail generation preview, request/response inspector, and secret masking.

### 7. Wrong vs Correct
#### Wrong
Add image models to `ProviderConfig.modelNames` and test them through `GET /models` or `LlmClient.streamChat`.
#### Correct
Keep image providers in `ImageProviderConfig`, call `ImageGenerationService`, and validate readiness with a real sample `/v1/images/generations` request using Bearer auth.

## Scenario: LLM artifact document output contract

### 1. Scope / Trigger
- Trigger: Any Style Lab, Plot Lab, or future feature prompts an LLM to generate a saved artifact, reusable profile/engine, structured domain proposal, review report, or user-editable document.
- This is an application-layer contract because prompt builders, document parsers, persisted text fields, detail pages, and tests must agree on each artifact's declared output shape.

### 2. Signatures
- Style artifact: `StyleLabPromptBuilder.buildVoiceProfilePrompt(...)` -> `VoiceProfileFrontMatterParser.parse(...)`
- Plot sketch artifact: `PlotLabPromptBuilder.buildSketchPrompt(...)` -> `PlotChunkSketchDocumentParser.parse(...)`
- Plot engine artifact: `PlotLabPromptBuilder.buildStoryEnginePrompt(...)` -> `StoryEngineNormalizer.normalize(...)`
- Allowed document shapes:
  - YAML-only: the entire model output is a YAML mapping or list that matches the artifact schema.
  - Markdown-only: the entire model output is Markdown and contains no machine-required structured fields.
  - YAML+MD: YAML front matter starts at the first character with `---`, ends with a closing `---`, and the Markdown body starts with the required H1 for that artifact.

### 3. Contracts
- LLM artifact outputs may be YAML-only, Markdown-only, or YAML+MD. Pick one shape per artifact and document that shape in the prompt, parser, tests, and UI copy.
- Saved or user-editable artifacts must not be JSON-only. JSON may be used as internal prompt input or in-memory pipeline payload, but it must not become the LLM-facing editable artifact format.
- Prompt builders must explicitly tell the model to output only the declared document shape, with no preface, explanation, conclusion, or code fence.
- Artifacts that feed structured domain models must include a YAML schema, whether YAML-only or YAML+MD. The owning parser/normalizer converts YAML fields into domain input objects before repository writes.
- Parsers/normalizers must reject malformed required contracts instead of silently coercing missing structure. Markdown section extraction is acceptable only for Markdown-only artifacts whose sections are not authoritative structured fields.
- YAML parsers may accept JSON as a YAML subset. When migrating or enforcing a YAML-only LLM output contract, reject root-level JSON/flow-style output explicitly so old JSON prompts or mocks cannot keep passing through parser compatibility.
- If an LLM artifact needs repair, do it in the owning pipeline with a separate repair prompt and prompt-trace label; keep the parser strict so malformed persisted artifacts cannot pass silently.
- Plain reports, drafts, revisions, and intermediate summaries that are not structured domain inputs may remain Markdown-only.
- Preview surfaces for YAML+MD artifacts should render the Markdown body, not the YAML front matter; source/edit modes still expose the full document. YAML-only artifacts should render as structured source unless the feature provides a derived preview.

### 4. Validation & Error Matrix
- Output does not start with `---` when YAML is required -> validation error.
- Missing closing front matter delimiter -> validation error.
- Required YAML field missing or unknown field present where the parser has a whitelist -> validation error.
- YAML-only contract receives root-level JSON object/array syntax -> validation error, even if the YAML parser can technically parse it.
- YAML enum/list type does not match the parser contract -> validation error.
- Markdown body missing the required H1, such as `# Chunk Sketch`, `# Voice Profile`, or `# Plot Writing Guide` -> validation error.
- Markdown-only artifact is configured as a structured domain input -> validation/design error; add YAML schema or keep it as a non-authoritative report.
- Model wraps the document in a Markdown code fence -> strip only when the owning pipeline has an explicit cleanup step, then validate the resulting declared shape.
- First model output violates the contract but contains recoverable draft content -> run one constrained repair call, then validate the repaired document; if repair fails, surface the original validation context plus repair error.

### 5. Good/Base/Bad Cases
- Good: Plot sketch prompt asks for YAML front matter plus `# Chunk Sketch`, then `PlotChunkSketchDocumentParser` validates fields before converting to `PlotChunkSketch`.
- Base: Style Voice Profile and Plot Story Engine are saved as editable `YAML+MD` documents after parser/normalizer validation.
- Bad: Ask the model for a structured domain proposal in Markdown headings only, then write missing sections as empty strings.
- Bad: Change a saved reusable artifact prompt to JSON-only and bypass the existing document editing surfaces.

### 6. Tests Required
- Parser tests for each declared shape: valid YAML-only/YAML+MD/Markdown-only, missing fields, extra fields, invalid enum/list values, missing body H1 when required, and code-fence cleanup when supported.
- Pipeline tests confirming Plot sketches still become structured inputs for skeleton/report/story-engine generation.
- Pipeline tests for any repair pass, including the malformed input, repaired output, and prompt trace label.
- UI/widget tests should keep validating that saved artifacts are shown in their declared source format where the page exposes source editing or validation state.
- UI/widget tests should validate that YAML+MD preview mode strips YAML front matter and renders only the artifact body.

### 7. Wrong vs Correct
#### Wrong
Ask the model to return JSON for a saved analysis artifact and store that JSON directly in the profile markdown field.
#### Correct
Ask the model to return YAML-only, Markdown-only, or YAML+MD according to the artifact's declared contract. If the artifact feeds domain models, validate YAML fields first and only then derive structured objects for repository writes.

## Scenario: Novel Workshop continuity audit gate

### 1. Scope / Trigger
- Trigger: Chapter generation produces manuscript content that may be saved as the current project chapter and used to propose Runtime Memory updates.
- This is a cross-layer contract because the LLM output, generation run table, project chapter table, application pipeline, and editor diagnostics must agree on verdict semantics.

### 2. Signatures
- Pipeline: `ChapterGenerationPipeline.generateChapter(projectId, chapterPlanId, replaceExisting)`.
- Follow-up action: `ChapterGenerationPipeline.proposeMemoryPatchForChapter(projectId, chapterId)`.
- Run fields: `draftMarkdown`, `continuityVerdict`, `continuityReportMarkdown`.
- Chapter fields: `continuityVerdict`, `continuityReportMarkdown`.
- Stage enum: `ChapterGenerationStage.auditContinuity`.

### 3. Contracts
- The continuity audit runs after draft generation and before chapter save.
- Audit output shape is YAML front matter followed by Markdown report. YAML must include `verdict`, `summary`, `characterState`, `worldRules`, `foreshadowing`, `chapterObjective`, `blockingIssues`, and `warningIssues`.
- `pass` saves the chapter and immediately proposes a Memory Patch.
- `warning` saves the chapter and report but does not propose a Memory Patch until the user invokes the follow-up action.
- `fail` stores the draft and audit report on the generation run, marks the run failed, and does not create or overwrite a chapter record.
- A malformed audit artifact is treated as `warning` and the report must include the parse failure context.

### 4. Validation & Error Matrix
- Missing chapter or wrong project on follow-up sync -> throw at the pipeline boundary.
- Empty chapter content on follow-up sync -> throw before calling the LLM.
- Chapter hash changed before follow-up sync -> throw and require the caller to reload.
- Audit verdict not in `pass|warning|fail` -> downgrade to `warning`.
- Fail verdict -> generation run failed, chapter unchanged.

### 5. Good/Base/Bad Cases
- Good: draft -> audit pass -> save chapter -> Memory Patch pending review.
- Base: draft -> audit warning -> save chapter -> editor shows report -> user continues Memory Patch later.
- Bad: audit fail still writes chapter content or updates Runtime Memory.
- Bad: style or prose-quality complaints are used as hard `fail` reasons.

### 6. Tests Required
- Pipeline tests for pass, warning, fail, malformed audit, and warning follow-up sync.
- Repository tests for run audit fields round-trip and workflow task status sync.
- Widget tests for editor audit display, failed draft/report visibility, and warning continue-sync action.

### 7. Wrong vs Correct
#### Wrong
Save every generated draft first and let the audit only annotate the chapter later.
#### Correct
Audit before chapter save; only `pass` and `warning` create or update a chapter, and only `pass` advances Runtime Memory automatically.

## Scenario: Novel Workshop batch draft mode

### 1. Scope / Trigger
- Trigger: The app generates multiple Novel Workshop chapter drafts in one user-started batch.
- This is a cross-layer contract because chapter plans, generation runs, Runtime Memory patches, workflow tasks, Drift batch records, application retries, and editor progress UI must stay in sync.

### 2. Signatures
- Pipeline start: `ChapterGenerationPipeline.startChapterGenerationBatch(projectId, chapterPlanIds)`.
- Pipeline worker: `ChapterGenerationPipeline.processChapterGenerationBatch(batchId)`.
- Stop action: `ChapterGenerationPipeline.stopChapterGenerationBatch(batchId)`.
- Workflow task kind: `novel_chapter_generation_batch`.
- Domain records: `ChapterGenerationBatch` and `ChapterGenerationBatchItem`.

### 3. Contracts
- Batch draft mode only supports standard Novel Workshop projects, not imported enrichment projects.
- Selected chapter plans must belong to the same project and same volume, be ordered by `chapterIndex`, and be continuous.
- Startup must block if any selected chapter already has manuscript content, if any project chapter has a pending Memory Patch review, if the project has any running single-chapter generation, or if the project already has a pending/running batch.
- Each item must pass the continuity audit before Memory Patch work begins.
- Memory Patch review may only auto-apply when the AI review verdict is `pass`.
- Patch review reports are appended to batch/item logs, not stored as additional structured report fields.
- Draft retry exhaustion or Patch review retry exhaustion fails the batch and leaves later waiting items unprocessed.
- Stopping a batch marks it `failed`; already `synced` items remain synced, and `processChapterGenerationBatch` must not restart a failed or succeeded batch.
- Retrying Patch generation/review must not rewrite the chapter draft.
- After a batch enters `running`, every non-cancellation exception that escapes item processing or batch stream reads must mark the batch and workflow task `failed` before rethrowing. Do not leave `pending`/`running` task locks behind.

### 4. Validation & Error Matrix
- Cross-volume selection -> reject before creating records.
- Non-contiguous selection -> reject before creating records.
- Existing selected chapter content -> reject before creating records.
- Project-level running single chapter generation -> reject before creating records, even if the selected chapter differs.
- Pending Memory Patch review anywhere in the project -> reject before creating records.
- `warning` or `fail` continuity verdict after max draft attempts -> mark item and batch failed.
- `warning` or `fail` Patch review after max patch attempts -> mark item and batch failed without rewriting the draft.
- `stopChapterGenerationBatch` followed by `processChapterGenerationBatch` -> return the failed batch state without processing waiting items.
- Batch item stream or batch-level processing throws after start -> mark batch failed, persist sanitized error, set `completedAt`, and make `hasRunningChapterGenerationBatch(projectId)` return false.

### 5. Good/Base/Bad Cases
- Good: Chapter 1 syncs Runtime Memory, then Chapter 2 builds context from the updated memory.
- Base: A failed item records latest run id, attempt counts, error message, and logs for UI diagnosis.
- Bad: Continue processing the next chapter after the batch has been stopped.
- Bad: Check running single generation only for selected chapters; the lock is project-scoped.

### 6. Tests Required
- Pipeline tests for successful sequential sync, project-level running-generation lockout, retry exhaustion, Patch-only retry, stop idempotence, and non-cancellation batch-level failure releasing the running lock.
- Repository tests for batch/item persistence, counts, workflow task synchronization, and project-level running-generation lookup.
- Widget tests for entry point, range selection, progress list, stop action, and failure details.

## Scenario: Workflow task abandonment and LLM cancellation

### 1. Scope / Trigger
- Trigger: Any long-running workflow task that can be cancelled from Workflow Runs while an LLM request or Novel Workshop pipeline is active.
- This is a cross-layer contract because UI commands, Riverpod controllers, task records, Novel Workshop run records, prompt traces, and request-scoped HTTP clients must agree on abandon semantics.

### 2. Signatures
- `WorkflowTaskStatus { pending, running, succeeded, failed, abandoned }`
- `LlmRequest(..., LlmCancellationToken? cancellationToken)`; cancellation types live in `core/llm/domain/llm_cancellation.dart`.
- `MarkdownCompletionService.completeMarkdown(..., LlmCancellationToken? cancellationToken)`
- `WorkflowTaskCancellationRegistry.register(workflowTaskId)`, `cancel(workflowTaskId)`, `unregister(workflowTaskId, token)`
- `WorkflowTaskRepository.abandonTask(String id)`
- `NovelWorkshopRepository.abandonWorkflowTask(String workflowTaskId)`
- `WorkflowTaskController.abandon(String taskId)`

### 3. Contracts
- Generic workflow abandonment may only transition `pending` or `running` tasks to `abandoned`.
- Novel abandonment may only clean recoverable outputs for pending/running/non-applied work. Succeeded/applied records must remain intact.
- Abandon clears recoverable outputs for that workflow task, including draft markdown, generated previews, logs, errors, and prompt trace.
- Abandon must not implicitly roll back content already applied to project bible, chapter body, Runtime Memory, or other user-facing project state.
- Pipelines must register one cancellation token per workflow task and pass it through every LLM boundary.
- Pipelines must check cancellation before and after stage transitions and LLM calls. `LlmCancellationException` writes `abandoned`, not `failed`.
- `LangChainLlmClient` must use a request-scoped `http.Client` only when a cancellation token is present, and cancellation must close only that scoped client, not a shared provider client.
- `LlmRequest` is a domain contract, so its cancellation token type must not be defined in an application-layer file.

### 4. Validation & Error Matrix
- Unknown task id -> no-op.
- Task already `succeeded`, `failed`, or `abandoned` -> do not overwrite status and do not delete trace through the generic repository path.
- Asset run already `applied` -> do not mark run or workflow task abandoned.
- Chapter generation has written a chapter -> do not delete the chapter during abandon.
- Batch item already `synced` -> do not roll it back; waiting/running/failed items can become `abandoned`.
- Enrichment item already `applied` -> do not roll it back; waiting/running/generated/failed items can become `abandoned`.
- Cancellation during retry loop -> rethrow `LlmCancellationException` and do not perform further retries.

### 5. Good/Base/Bad Cases
- Good: User abandons a running asset generation, active HTTP request closes, draft and prompt trace clear, task and run show `abandoned`.
- Base: User abandons a queued generic workflow task before any trace exists; task becomes `abandoned`.
- Bad: Closing the global LLM HTTP client cancels unrelated concurrent tasks.
- Bad: Abandoning an already applied asset changes it back to `abandoned` or clears accepted project bible content.

### 6. Tests Required
- Unit/pipeline tests for cancellation token propagation stopping retries and marking run/task `abandoned`.
- Repository tests that asset/chapter/batch/enrichment abandon clears only recoverable outputs and preserves applied or synced outputs.
- Widget tests that pending/running tasks expose abandon confirmation and abandoned tasks render `已放弃`.

### 7. Wrong vs Correct
#### Wrong
Catch cancellation as a generic error and persist a failed task with the partial trace.
#### Correct
Catch `LlmCancellationException`, call `abandonWorkflowTask`, clear recoverable outputs, remove prompt trace, and rethrow cancellation to stop the pipeline.

## Scenario: Novel Workshop memory patch YAML boundary

### 1. Scope / Trigger
- Trigger: Memory Patch generation, preview, storage, and application all consume the same patch document.
- This is a cross-layer contract because the generation pipeline may normalize draft output before storage, while preview and apply paths must reject malformed persisted YAML instead of silently repairing it.

### 2. Signatures
- Prompt builder / pipeline: `ChapterGenerationPipeline.proposeMemoryPatchForChapter(projectId, chapterId)`
- Shared parser: `MemoryPatchParser.parse(rawYaml)`
- Storage normalizer: `normalizeMemoryPatchYaml(rawYaml)`
- Preview source: `novel_workshop_page.dart` memory patch preview block
- Apply path: `DriftNovelWorkshopRepository.applyMemorySyncPatch(chapterId)`

### 3. Contracts
- `normalizeMemoryPatchYaml` may clean fenced drafts and canonicalize eligible runtime memory block scalars before storage.
- `MemoryPatchParser.parse` must be strict: it strips fences, parses YAML, and returns structured patch data or `MemoryPatchValidationException`.
- Preview and apply paths must use the strict parser, not the storage normalizer.
- A malformed persisted patch must keep raw YAML visible in the UI while surfacing a parse warning.

### 4. Validation & Error Matrix
- Root node not a YAML map -> `MemoryPatchValidationException('Patch YAML 根节点必须是对象。')`
- Non-list `characters` / `relationships` -> `MemoryPatchValidationException('Patch YAML 列表字段必须是列表。')`
- Non-map `runtimeMemory` -> `MemoryPatchValidationException('runtimeMemory 必须是对象。')`
- Fenced YAML -> strip fence before parsing
- Parsed patch with invalid structure in preview/apply -> show inline warning, do not auto-repair persisted data

### 5. Good/Base/Bad Cases
- Good: generation normalizes a fenced draft with block scalar runtime memory before saving.
- Base: preview shows a warning and raw YAML when a stored patch is malformed.
- Bad: preview or apply path calls the storage normalizer and silently repairs a malformed persisted patch.
- Bad: apply path swallows parser failures and merges partial memory changes.

### 6. Tests Required
- Parser tests for fenced and unfenced valid YAML, malformed YAML, and non-map root input.
- Repository tests that invalid persisted patches are rejected and do not mutate Runtime Memory.
- Widget tests that the review panel renders raw YAML plus a parse warning when the stored patch is malformed.
- Pipeline tests that generation still normalizes valid multiline runtime memory output before storage.

### 7. Wrong vs Correct
#### Wrong
Use the same lenient normalization path for generated drafts, preview, and apply.
#### Correct
Normalize only at generation/storage boundaries; keep preview and apply strict so persisted malformed patches cannot be silently repaired.
