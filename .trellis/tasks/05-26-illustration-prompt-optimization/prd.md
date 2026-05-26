# Optimize illustration prompt generation

## Goal

Improve the reader illustration workflow so selected novel text can first be transformed by the project's default text LLM into an English image prompt, then reviewed or edited by the user before the existing image provider creates the illustration.

## What I already know

* The reader currently opens `_GenerateIllustrationDialog` from selected text and initializes the prompt field with `selectedText`.
* `createAndRunChapterIllustration` stores the submitted prompt on `ChapterIllustrationGenerationRun` and the generation pipeline passes that prompt directly to `ChapterIllustrationService`.
* Text LLM infrastructure already exists through `ProviderConfig`, `ProviderConfigRepository`, `MarkdownCompletionService`, and prompt traces.
* Image generation already supports provider/model/aspect ratio/size/quality/response format and should remain unchanged.

## Requirements

* Add an explicit "optimize prompt" action in the illustration dialog; do not auto-call the LLM when the dialog opens.
* Generate the image prompt with the project default text provider/model.
* Send a feature-specific business system prompt that frames the LLM as a literary illustration prompt director.
* Use selected text, chapter title, paragraph index, and nearby chapter paragraphs as LLM context.
* Generate an English-first prompt that faithfully visualizes the text without imposing a fixed style.
* Use a ComfyUI-inspired structure internally: positive prompt, negative constraints, and visual notes.
* Merge the useful negative constraints into the final prompt text because the existing image provider contract has no separate negative-prompt field.
* Write only the final confirmed prompt to the existing `prompt` field; do not add database fields or migrations.
* If LLM prompt optimization fails, show an error and allow the user to keep editing or create a task manually.

## Acceptance Criteria

* [ ] User can click an optimize button in the illustration dialog and see the generated prompt fill the existing prompt field.
* [ ] Existing manual prompt submission still works without using the optimize button.
* [ ] Prompt generation does not create an image run or illustration record.
* [ ] Prompt generation uses project default text provider/model and reports a clear error if unavailable.
* [ ] Existing retry, illustration library, and image generation flows continue to use the stored final prompt.
* [ ] Unit and widget coverage verifies prompt generation success, failure fallback, and manual generation regression.

## Out of Scope

* No real ComfyUI API integration.
* No seed, CFG, steps, sampler, or node graph persistence.
* No database migration for raw/generated/negative prompt fields.
* No fixed style preset or style selector in this task.

## Technical Notes

* Code entry points: `lib/src/features/novel_workshop/presentation/novel_workshop_page.dart`, `lib/src/features/novel_workshop/application/novel_workshop_providers.dart`, and new application service under `lib/src/features/novel_workshop/application/`.
* Relevant tests: `test/novel_workshop/novel_workshop_page_test.dart`, `test/novel_workshop/chapter_illustration_service_test.dart`, and new prompt service tests.
* Research summary lives in `research/image-prompt-workflow.md`.
