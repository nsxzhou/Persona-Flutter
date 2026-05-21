# Optimize generated asset incremental updates

## Goal

Make AI-generated Novel Workshop assets incremental by default so generated drafts update only the intended target while preserving existing user edits and unrelated generated content.

## What I already know

* The user wants AI draft application to be "incremental first"; omitted fields, volumes, chapters, characters, and relationships must be preserved.
* Manual editors remain full-source saves: saving outline YAML or Runtime Memory form content overwrites with the user-provided complete value.
* `AssetGenerationRun.targetVolumeId` already records the target volume for per-volume outline detail generation.
* Current outline detail draft application calls `saveOutlineDetailYaml`, which stores the draft YAML as the whole `ProjectBible.outlineDetailYaml` and can drop other volumes.
* Current character graph parsing normalizes omitted fields to empty strings; applying a partial character/relationship patch can clear existing fields.
* Current memory sync prompt asks for full `runtimeMemory` fields, and applying empty proposals can clear stored Runtime Memory.

## Requirements

* AI-generated character/relationship patches merge by field; missing fields preserve existing values.
* AI-generated Runtime Memory patches merge by field; missing fields preserve existing values, and chapter archive additions append unless explicitly replaced.
* Empty Runtime Memory patches must not clear stored memory.
* Applying a target-volume outline detail draft updates only that volume and preserves other volumes.
* Manual `saveOutlineDetailYaml` and `saveRuntimeMemory` keep full overwrite semantics.
* Applying AI volume blueprint drafts preserves existing volumes not present in the draft.
* Draft review UI communicates merge semantics when existing content is present.
* No new full-regenerate-and-overwrite UI entry is added.

## Acceptance Criteria

* [ ] Repository tests cover partial character patch preserving old character fields.
* [ ] Repository tests cover partial relationship patch preserving old relationship fields.
* [ ] Repository tests cover Runtime Memory patch preserving omitted fields and empty patch preserving old memory.
* [ ] Repository tests cover target-volume outline detail draft preserving other volumes.
* [ ] Repository tests confirm manual outline YAML save still overwrites with full input.
* [ ] Prompt tests confirm memory sync no longer requests full five-field snapshots.
* [ ] UI tests or focused widget assertions cover merge semantics copy in the draft review dialog.
* [ ] Relevant Flutter tests pass.

## Definition of Done

* Tests added or updated for changed behavior.
* Lint/typecheck/test status reported.
* No unrelated dirty worktree changes are reverted.
* Existing Trellis tasks and user edits are left intact.

## Out of Scope

* No automatic memory application after chapter generation.
* No new full overwrite UI mode for AI generation.
* No database schema migration unless strictly required.
* No broad redesign of the Novel Workshop page.

## Technical Notes

* Relevant files: `chapter_generation_pipeline.dart`, `character_graph_parser.dart`, `drift_novel_workshop_repository.dart`, `asset_generation_prompts.dart`, `novel_workshop_page.dart`.
* Specs to read: backend database/error/quality/logging, frontend component/state/quality/type-safety, shared guides.
