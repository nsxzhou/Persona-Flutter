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
- If an LLM artifact needs repair, do it in the owning pipeline with a separate repair prompt and prompt-trace label; keep the parser strict so malformed persisted artifacts cannot pass silently.
- Plain reports, drafts, revisions, and intermediate summaries that are not structured domain inputs may remain Markdown-only.
- Preview surfaces for YAML+MD artifacts should render the Markdown body, not the YAML front matter; source/edit modes still expose the full document. YAML-only artifacts should render as structured source unless the feature provides a derived preview.

### 4. Validation & Error Matrix
- Output does not start with `---` when YAML is required -> validation error.
- Missing closing front matter delimiter -> validation error.
- Required YAML field missing or unknown field present where the parser has a whitelist -> validation error.
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
