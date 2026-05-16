# Project CRUD Vertical Slice

## Goal

Implement the first usable Projects vertical slice: local project CRUD backed by SQLite, a data-bound Projects page, and a project detail route.

## Requirements

* Add `WritingProject`, `WritingProjectInput`, and `ProjectStatus { active, archived }`.
* Persist projects in Drift through a new `ProjectRecords` table.
* Expose project persistence through a repository contract and Riverpod providers.
* Projects list defaults to active projects and can switch to archived projects.
* UI supports create, edit, archive/restore, and hard delete.
* Add a project detail page for project dossier information and future workbench placeholders.
* Keep scope limited to project CRUD; do not implement chapters, Zen Editor, imports, exports, or Style/Plot profile mounting.

## Acceptance Criteria

* Creating a project stores it in SQLite and renders it in the Projects page.
* Editing updates title/description/status and updated timestamp.
* Archived projects are hidden from the default list and visible in the archived view.
* Deleting removes the record permanently.
* Project detail route handles found, missing, loading, and error states.
* `dart run build_runner build`, `dart format .`, `flutter analyze`, and `flutter test` pass.

## Technical Notes

* Follow existing Provider configuration patterns for Drift repositories, Riverpod providers, generated files, and widget tests.
* Presentation widgets must not import Drift records.
* Visual direction: writing dossier desk, text-first and restrained.
