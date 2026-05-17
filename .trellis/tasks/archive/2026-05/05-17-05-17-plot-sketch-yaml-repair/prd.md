# Fix analysis YAML repair

## Goal

Fix analysis runs that fail when reusable artifacts return malformed `YAML+MD`, such as missing the closing YAML front matter delimiter.

## What I already know

* The reported UI error is `Sketch chunk 1 produced invalid YAML+MD: YAML front matter 缺少结束分隔符。`
* `PlotAnalysisPipeline` parses each sketch through `PlotChunkSketchDocumentParser`.
* `StyleAnalysisPipeline` validates generated Voice Profiles through `VoiceProfileFrontMatterParser`.
* Project spec requires reusable analysis artifacts to remain strict `YAML front matter + Markdown body`.
* Prompt traces already capture every LLM call, so a repair pass can be audited with a separate label.

## Requirements

* Keep strict validation for sketch artifacts.
* When an initial Plot sketch output fails validation, attempt one repair pass that only restructures the existing draft into the required `YAML+MD` contract.
* When an initial Style Voice Profile output fails validation, attempt one repair pass under the same constraints.
* If the repaired output is still invalid, fail the run with the existing error path.
* Add focused regression coverage for missing front matter closing delimiter.

## Acceptance Criteria

* [ ] A malformed first sketch can be repaired into a valid sketch and the pipeline continues.
* [ ] A malformed first Voice Profile can be repaired into a valid profile and the pipeline continues.
* [ ] Prompt trace includes a separate repair call label.
* [ ] Invalid unrecoverable sketch output still fails.
* [ ] Invalid unrecoverable Voice Profile output still fails.
* [ ] Focused Plot Lab tests pass.
* [ ] Focused Style Lab tests pass.

## Out of Scope

* Changing persisted artifact format away from `YAML+MD`.
* Broad UI changes.
* Silent coercion inside `PlotChunkSketchDocumentParser`.

## Technical Notes

* Relevant spec: `.trellis/spec/backend/quality-guidelines.md`, scenario “Analysis artifact YAML+MD output contract”.
* Relevant files: `plot_analysis_pipeline.dart`, `plot_lab_prompts.dart`, `style_analysis_pipeline.dart`, `style_lab_prompts.dart`, `test/plot_lab_test.dart`, `test/style_lab_test.dart`.
