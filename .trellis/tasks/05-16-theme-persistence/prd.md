# Persist selected theme across app restarts

## Goal

When the user switches between light and dark themes, the selected mode should be saved locally and restored on the next app launch instead of reverting to the hard-coded default.

## What I already know

* User reports theme changes are not saved and startup returns to default.
* `lib/src/core/theme/theme_mode_provider.dart` currently returns `ThemeMode.dark` from `build()` and only mutates in-memory state in `toggle()`.
* `lib/src/app/persona_app.dart` passes `ref.watch(themeModeProvider)` to `MaterialApp.router.themeMode`.
* Theme switching UI calls `ref.read(themeModeProvider.notifier).toggle()` from `lib/src/core/ui/app_shell.dart` and reads state from `lib/src/core/ui/animated_theme_toggler.dart`.
* `pubspec.yaml` has no existing preferences package; local persistence elsewhere is Drift-backed domain data.

## Assumptions

* Persisting theme mode as a small local key-value preference is appropriate; it does not need a Drift table.
* The existing two-state toggle should remain light/dark and not introduce system mode in this fix.
* Existing default behavior should stay dark until the user explicitly changes it.

## Requirements

* Save the theme mode every time the user toggles it.
* Restore the saved theme mode when the app starts.
* Fall back to the existing default when no saved value exists or the saved value is invalid.
* Keep `MaterialApp.router` wired through the existing Riverpod provider.

## Acceptance Criteria

* [x] Toggling from dark to light persists `light` locally.
* [x] A fresh provider/app instance restores `light` from saved local storage.
* [x] Invalid or missing saved values fall back to `ThemeMode.dark`.
* [x] Analyzer and focused tests pass.

## Out of Scope

* Adding a third `ThemeMode.system` setting.
* Redesigning the settings page or theme switch UI.
* Moving all app preferences into a larger settings repository.

## Technical Notes

* Relevant specs read: `.trellis/spec/frontend/state-management.md`, `.trellis/spec/frontend/hook-guidelines.md`, `.trellis/spec/frontend/quality-guidelines.md`, `.trellis/spec/guides/index.md`.
* Implemented with `shared_preferences` and `SharedPreferencesWithCache`, initialized before `runApp` and injected through `themeModeStoreProvider`.
* Tests use `InMemoryThemeModeStore` to verify persistence and fresh app restoration without touching real platform preferences.
* Verified with `dart run build_runner build --delete-conflicting-outputs`, `dart format lib test .trellis/spec`, `flutter analyze`, and `flutter test`.
