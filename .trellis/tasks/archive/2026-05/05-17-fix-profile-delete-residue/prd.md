# Fix Profile Delete Residue

## Goal

Deleting a saved Plot Profile or Style Profile must remove the asset from the library in one action. The source analysis run must not reappear as a draft after the profile deletion succeeds.

## What I Already Know

* `deleteProfile()` currently deletes the profile and clears `run.profileId`.
* Library asset builders treat a succeeded run with `profileId == null` and non-empty generated markdown as a draft.
* This makes the deleted saved profile appear to remain in the list, because its source run is immediately shown as a draft asset.
* Plot Lab and Style Lab share the same persistence and list-building pattern.

## Requirements

* Deleting a saved Plot Profile deletes the profile record, its source plot analysis run, and that run's workflow task in one transaction.
* Deleting a saved Style Profile deletes the profile record, its source style analysis run, and that run's workflow task in one transaction.
* Keep repository interfaces unchanged.
* Do not edit generated `*.g.dart` files.
* Do not introduce a database schema change.

## Acceptance Criteria

* [ ] `DriftPlotLabRepository.deleteProfile` removes the source run instead of restoring it as a draft.
* [ ] `DriftStyleLabRepository.deleteProfile` removes the source run instead of restoring it as a draft.
* [ ] Repository tests assert profile, source run, and workflow task removal.
* [ ] Targeted tests pass for Plot Lab and Style Lab repositories.
* [ ] `flutter analyze` passes.

## Out of Scope

* Adding soft delete or restore behavior.
* Changing UI labels, routes, or generated provider files.
* Changing database schema or migrations.

## Technical Notes

* Main files: `lib/src/features/plot_lab/data/drift_plot_lab_repository.dart`, `lib/src/features/style_lab/data/drift_style_lab_repository.dart`.
* Tests: `test/plot_lab_test.dart`, `test/style_lab_test.dart`.
* Existing page-level behavior should update automatically once streams emit deleted run/profile rows.
