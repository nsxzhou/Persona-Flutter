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
