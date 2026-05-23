# Fix LLM selector YAML output contract

## Goal

Fix the Novel Workshop context selector so its LLM-facing output contract uses YAML instead of JSON. This aligns the selector with the project LLM artifact contract: model outputs may be YAML-only, Markdown-only, or YAML front matter plus Markdown, while JSON is limited to internal inputs or in-memory payloads.

## What I already know

* The user found a Prompt Trace where `select_generation_context` asks the model to output JSON.
* The offending prompt is in `lib/src/features/novel_workshop/application/writing_context_retriever.dart`.
* The selector parser currently uses `jsonDecode` on the LLM output.
* Related tests currently mock selector output as JSON.
* Repo search found no other business LLM prompt with `只输出 JSON` / `JSON 形状` in `lib` besides this selector.
* Backend spec explicitly permits YAML-only, Markdown-only, and YAML+MD LLM artifact output shapes, and forbids JSON-only saved/user-editable artifacts.

## Assumptions

* `selected_chapters`, `selected_assets`, and `summary` keep the same semantic fields and snake_case names.
* Candidate lists may still be encoded as JSON inside the prompt as input data; the fix targets the model output contract.
* The selector remains strict enough to fall back locally when LLM output is malformed.

## Requirements

* Change the selector prompt output contract from JSON to YAML.
* Parse selector LLM output with `package:yaml`.
* Support fenced YAML/YML cleanup as a defensive parser cleanup, while still instructing the model not to emit fences.
* Update focused tests and selector mocks to YAML.
* Confirm repo text search no longer finds LLM prompts asking for JSON output.

## Acceptance Criteria

* [ ] Prompt contains `只输出 YAML` and no longer contains `只输出 JSON` or `JSON 形状`.
* [ ] Valid YAML selector output selects the intended chapter and asset blocks.
* [ ] Malformed selector output triggers the existing local fallback warning path.
* [ ] `flutter test test/novel_workshop/writing_context_retriever_test.dart` passes.
* [ ] `flutter test test/novel_workshop/chapter_generation_pipeline_test.dart` passes.
* [ ] `rg -n "只输出 JSON|输出 JSON|JSON 形状" lib test` has no remaining business LLM output-contract hit.

## Out of Scope

* Changing selector input candidate encoding.
* Refactoring unrelated LLM prompt builders.
* Changing stored domain field names or UI rendering.

## Technical Notes

* Relevant implementation file: `lib/src/features/novel_workshop/application/writing_context_retriever.dart`.
* Relevant tests: `test/novel_workshop/writing_context_retriever_test.dart`, `test/novel_workshop/chapter_generation_pipeline_test.dart`.
* Relevant spec: `.trellis/spec/backend/quality-guidelines.md`, especially the "LLM artifact document output contract" scenario.
