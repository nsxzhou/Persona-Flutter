# Remove charactersStatus runtime memory

## Goal

Remove `charactersStatus` from runtime memory and make structured character
cards / relationship records the only source of long-term character state.

## Requirements

- Delete `RuntimeMemoryState.charactersStatus`.
- Delete `ProjectChapter.memorySyncProposedCharactersStatus`.
- Drop `project_runtime_memory_records.characters_status`.
- Drop `project_chapter_records.memory_sync_proposed_characters_status`.
- Keep memory patch YAML as the path for character and relationship updates.
- Keep runtime memory limited to runtime state, unresolved threads, and story summary.
- Update Novel Workshop UI copy and editors so Runtime Memory no longer presents character state.
- Update tests and generated Drift code.

## Verification

- `dart run build_runner build --delete-conflicting-outputs`
- `dart format .`
- `flutter analyze`
- `flutter test`
