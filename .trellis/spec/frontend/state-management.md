# State Management

> How state is managed in this project.

---

## Overview

Use Riverpod for app state, dependency wiring, and async data subscriptions. Prefer `riverpod_generator` annotations for providers unless a provider must remain deliberately hand-written.

---

## State Categories

* Widget-local state: ephemeral UI state that never leaves a widget.
* Provider state: app services, repositories, task streams, and cross-widget state.
* URL state: selected top-level page and later project/editor child routes via `go_router`.
* Persistence state: Drift streams exposed through repository contracts and Riverpod providers.

---

## Routing State

Use `StatefulShellRoute.indexedStack` for persistent top-level shell navigation such as `NavigationRail` destinations. The shell should consume `StatefulNavigationShell.currentIndex` for the selected destination and call `StatefulNavigationShell.goBranch(...)` for branch changes.

Do not model top-level shell tabs as a plain `ShellRoute` plus independent page transitions. That can keep outgoing and incoming branch pages painted together during route changes on desktop.

Do not wrap the top-level `StatefulNavigationShell` body in a route-level `AnimatedSwitcher`, fade, or slide transition. Tab switching in the desktop shell should feel immediate and stable; animation belongs to local controls or explicitly opted-in feature surfaces, not the main shell page body.

Shell widgets that read Riverpod providers must be wrapped in `ProviderScope` in tests and demos. If a shell owns app-level state like theme mode, route changes, or top-level selection, its tests should construct the same provider boundary that production uses.

---

## When to Use Global State

Use a provider when state:

* is shared by multiple widgets,
* represents a service/repository dependency,
* wraps a Drift stream or long-running task status,
* must survive route changes.

Command-style providers that run async mutations from transient UI controls
(for example popup menu actions) must either be `keepAlive` or explicitly guard
`ref.mounted` after async gaps before writing `state`. Prefer `keepAlive` when
the provider represents a feature command surface rather than widget-local
state.

## App Preference State

Small cross-session app preferences, such as theme mode, should use a tiny
storage abstraction that is injected through Riverpod. Initialize any cached
preference store before `runApp`, then override the store provider at the root
`ProviderScope` so synchronous app-shell providers can read the restored value
without introducing a startup loading state or theme flash.

Example contract:

* `ThemeModeStore.read()` returns the current cached preference synchronously.
* `ThemeModeStore.write(mode)` persists user changes asynchronously.
* Missing or invalid preference values must fall back to the documented default.

---

## Server State

Persona Flutter has no remote server in the baseline. Local persisted data is exposed from Drift through repository contracts and Riverpod providers.

---

## Common Mistakes

* Do not let presentation widgets import Drift tables directly.
* Do not bypass repository contracts from feature UI.
* Do not store cross-session preferences only in a `Notifier` field or `state`;
  the value will reset when the app restarts.
* Keep generated provider files in sync with `dart run build_runner build`.

## Scenario: Project-scoped Novel Workshop workspace

### 1. Scope / Trigger
- Trigger: A writing workspace is opened for one existing `WritingProject` and coordinates project data, chapter plans, chapter content, generation runs, prompt assets, and runtime memory.
- This is a frontend routing/state contract because the workspace is project-scoped but should not become an always-visible top-level shell destination.

### 2. Signatures
- Route: `/projects/:projectId/workshop`.
- Entry point: active project row action labeled `打开工作台`.
- Page widget: `NovelWorkshopPage(projectId: state.pathParameters['projectId']!)`.
- Command provider: `NovelWorkshopController` wraps chapter-plan save, chapter save, and generation commands.

### 3. Contracts
- The workspace lives under the Projects `StatefulShellBranch`; do not add a new `AppRoute` item or sidebar navigation destination for the first workspace iteration.
- Archived projects must not expose the Projects-row workspace action; if the route is opened directly for an archived project, render a read-only blocked state.
- Presentation widgets consume `ProjectRepository`, `NovelWorkshopRepository`, `ProjectPromptAssetResolver`, and `ChapterGenerationPipeline` through Riverpod providers/application contracts only.
- The editor owns unsaved Markdown text as widget-local state; persisted content continues to flow through `NovelWorkshopRepository.saveChapter`.
- Full Prompt Trace rendering remains owned by Workflow Runs; Novel Workshop may link to `/workflow-runs/:taskId`.

### 4. Validation & Error Matrix
- Missing project -> render a missing-project page with a return-to-Projects action.
- Archived project -> render an archived-project blocked state.
- Empty chapter list -> render an empty state with chapter creation action.
- Dirty editor before chapter switch or generation -> offer save, discard, or cancel before continuing.
- Existing saved chapter content before generation -> confirm overwrite before calling `generateChapter(..., replaceExisting: true)`.

### 5. Good/Base/Bad Cases
- Good: Project row opens `/projects/<id>/workshop`; the page reads project-scoped providers and links generation diagnostics to Workflow Runs.
- Base: Manual chapter plans are created inside the workspace until automatic splitting exists.
- Bad: Add a shell sidebar destination that opens an unscoped workspace without a project id.
- Bad: Let the page import Drift table records or call LLM services directly.

### 6. Tests Required
- Widget test that active project rows expose `打开工作台` and archived rows do not.
- Widget test that `/projects/:projectId/workshop` handles empty chapters, plan creation/editing, dirty editor prompts, overwrite confirmation, running generation lockout, and Workflow Runs navigation.
- Provider/controller tests or widget fakes must avoid live LLM calls.

### 7. Wrong vs Correct
#### Wrong
Add `novelWorkshop(path: '/novel-workshop')` to `AppRoute` and make the page infer a current project from global state.
#### Correct
Keep the first workspace project-scoped under `/projects/:projectId/workshop` and enter it from an active project row.
