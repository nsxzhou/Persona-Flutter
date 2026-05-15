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

Shell widgets that read Riverpod providers must be wrapped in `ProviderScope` in tests and demos. If a shell owns app-level state like theme mode, route changes, or top-level selection, its tests should construct the same provider boundary that production uses.

---

## When to Use Global State

Use a provider when state:

* is shared by multiple widgets,
* represents a service/repository dependency,
* wraps a Drift stream or long-running task status,
* must survive route changes.

---

## Server State

Persona Flutter has no remote server in the baseline. Local persisted data is exposed from Drift through repository contracts and Riverpod providers.

---

## Common Mistakes

* Do not let presentation widgets import Drift tables directly.
* Do not bypass repository contracts from feature UI.
* Keep generated provider files in sync with `dart run build_runner build`.
