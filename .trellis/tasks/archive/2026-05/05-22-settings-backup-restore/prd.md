# Settings Backup And Restore

## Goal

Implement full local data backup and restore for Persona Flutter. The feature exports a consistent SQLite snapshot of the current local database and restores by replacing the whole local database file. It also removes the Settings page "待开发" placeholder and replaces it with a real local backup panel.

## Requirements

* Back up all local persisted data in `persona.sqlite`, including Provider configuration, project data, samples, analysis results, chapters, workflow task records, and Provider API Keys.
* Export a consistent backup using SQLite `VACUUM INTO`, not a direct hot copy of the active database file.
* Restore by replacing the whole local database. Restore is not a merge operation.
* Validate restore input before replacement:
  * the file exists,
  * it can be opened as SQLite,
  * `PRAGMA user_version` is less than or equal to the current `AppDatabase.schemaVersion`,
  * future-version or corrupt files are rejected.
* Allow older backups to be restored and migrated by existing Drift migrations.
* Before every restore, create and keep a timestamped `pre-restore-*.sqlite` rollback copy of the current database.
* If restore fails after the current database has been moved/replaced, roll back from the pre-restore copy.
* Restore must refresh the in-app Drift/Riverpod database instance so the app does not require a manual restart.
* Backup files are plain SQLite files and may contain API Keys. The UI must explicitly warn the user.
* macOS/desktop is the acceptance target. Keep the implementation as portable as practical for Linux/Windows.

## UI Requirements

* Remove `_PendingActionsPanel` and `_PendingItem` from Settings.
* Remove tests asserting the old "待开发" placeholder.
* Add a real "本地备份" Settings panel below the Provider console.
* The panel must expose:
  * `导出备份`,
  * `恢复备份`,
  * a clear sensitive-data warning,
  * status/last operation feedback.
* Restore must show a confirmation dialog explaining that current local data will be overwritten and the backup contains API Keys.
* Busy backup/restore states must disable duplicate actions.
* Follow the existing Settings console visual style: restrained white/graphite/cobalt, compact operational controls, no decorative or marketing-style UI.

## Public Interfaces

* Add a local backup service and controller, for example:
  * `LocalBackupService`
  * `LocalBackupState`
  * `LocalBackupResult`
  * `localBackupServiceProvider`
  * `localBackupControllerProvider`
* Add database path/reload support to the database infrastructure:
  * stable resolver for `Persona/persona.sqlite`,
  * provider invalidation or generation-token approach so restore can close and recreate the `AppDatabase`.
* Do not add Drift tables or schema migrations.

## Acceptance Criteria

* Settings no longer renders "待开发".
* Settings renders a functional "本地备份" panel with export/restore controls and API Key warning.
* Export creates an openable SQLite backup whose `user_version` matches the current database.
* Restore rejects corrupt files and future-version files.
* Restore creates a pre-restore rollback copy before replacing the current database.
* Restore refreshes app data without requiring restart.
* Restore confirmation cancel path does not mutate data.
* Analyzer and focused tests pass.

## Test Plan

* Add service/unit tests for export, corrupt restore rejection, future-version restore rejection, and rollback copy creation.
* Update Settings widget tests:
  * no "待开发",
  * backup panel visible,
  * restore confirmation appears,
  * cancel does not call restore,
  * busy state disables backup/restore buttons.
* Run:
  * `dart run build_runner build`
  * `dart format lib test .trellis/spec`
  * `flutter analyze`
  * `flutter test`

## Out Of Scope

* Encrypted backups.
* Single-project export/import.
* Merge restore.
* Mobile-specific file-provider UX guarantees.

## Technical Notes

* Existing database location is under `getApplicationSupportDirectory()/Persona/persona.sqlite`.
* Existing Settings UI lives in `lib/src/features/settings/presentation/settings_page.dart`.
* Existing database provider lives in `lib/src/core/database/database_providers.dart`.
* Existing file picking dependency `file_picker` supports `pickFiles` and `saveFile`.
* Relevant specs: backend database/error/quality, frontend component/state/quality/visual design, cross-layer guide.
