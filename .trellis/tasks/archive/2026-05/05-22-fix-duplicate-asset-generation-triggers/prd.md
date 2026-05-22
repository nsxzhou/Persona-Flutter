# Fix duplicate asset generation triggers

## Goal

Prevent repeated clicks on Novel Workshop asset-generation controls from creating multiple concurrent local workflow tasks for the same generation scope.

## What I already know

* User reproduced duplicate `novel_asset_generation` tasks while generating volume/chapter outline assets.
* `AssetGenerationPipeline.generateAsset` currently creates an asset run before checking for existing active asset runs.
* `DriftNovelWorkshopRepository.createAssetGenerationRun` and `createVolumeDetailGenerationRun` always insert new `workflowTaskRecords` + `assetGenerationRunRecords`.
* Chapter generation already has `hasRunningChapterGeneration*` checks; the primary gap is asset generation.

## Requirements

* Add immediate UI-side duplicate-click protection for asset-generation controls.
* Add repository/application-side active-run checks scoped by `projectId`, `AssetGenerationKind`, and optional `targetVolumeId`.
* Reject new asset generation when a matching `pending` or `running` run already exists.
* Allow retries when prior matching runs are terminal (`succeeded`, `failed`, or `applied`).
* Do not add database schema changes or unique indexes in this iteration.

## Acceptance Criteria

* [ ] Double tapping `generate-asset-outlineDetailYaml` creates at most one generation request.
* [ ] A pending/running whole-project asset run blocks another run with the same project/kind.
* [ ] A pending/running single-volume outline-detail run blocks another run for the same volume.
* [ ] Completed/failed/applied historical runs do not block new generation.
* [ ] Focused tests and `flutter analyze` pass.

## Out of Scope

* Database schema migration or uniqueness constraint.
* Changing chapter generation/batch generation semantics beyond confirming existing protections.
* Touching unrelated settings backup/restore task files.

## Technical Notes

* Relevant code: Novel Workshop presentation, `NovelWorkshopRepository`, `DriftNovelWorkshopRepository`, `AssetGenerationPipeline`.
* Relevant specs: frontend state/component guidelines; backend repository/error/quality/database guidelines.
