# Database Guidelines

> Database patterns and conventions for this project.

---

## Overview

Persona Flutter uses Drift over SQLite for local persistence. The database is initialized in-process from Dart; there is no separate local HTTP backend.

---

## Query Patterns

Keep raw Drift access behind repositories or data sources. UI and feature presentation code should consume domain/application contracts, not table records.

---

## Migrations

Schema changes must update Drift table definitions and generated files.

Run:

```bash
dart run build_runner build
flutter analyze
flutter test
```

---

## Naming Conventions

Use descriptive table class names ending in `Records` for persisted task-like records, for example `WorkflowTaskRecords`.

---

## Common Mistakes

* Do not expose Drift row types directly to UI.
* Do not edit generated `*.g.dart` files manually.

---

## Scenario: Provider configuration storage

### 1. Scope / Trigger
- Trigger: Provider management now persists OpenAI-compatible connection settings, including API Key, in SQLite.
- This is a cross-layer persistence contract change and requires explicit storage, migration, and masking rules.

### 2. Signatures
- Drift table: `ProviderConfigRecords`
- Repository contract: `ProviderConfigRepository`
- Persistence fields:
  - `id: Text`
  - `name: Text`
  - `baseUrl: Text`
  - `apiKey: Text`
  - `defaultModel: Text`
  - `isEnabled: Bool`
  - `testStatus: Text`
  - `lastTestedAt: DateTime?`
  - `lastTestMessage: Text?`
  - `createdAt: DateTime`
  - `updatedAt: DateTime`

### 3. Contracts
- API Key is stored in SQLite and is treated as sensitive data.
- UI must not display the full API Key after save.
- Provider test state is persisted as a string enum name.
- On save, `testStatus` resets to `untested` and last test metadata clears.

### 4. Validation & Error Matrix
- Missing name/baseUrl/apiKey/defaultModel -> validation error before write.
- Invalid URL -> validation error before write.
- Failed connectivity test -> persist `failed` with sanitized message; do not delete the Provider.
- HTTP non-2xx -> record a readable failure message without the raw secret.

### 5. Good/Base/Bad Cases
- Good: save Provider metadata and API Key to SQLite, then run a real `GET /models` probe.
- Base: save Provider first, test later.
- Bad: log or render the full API Key in UI or diagnostics.

### 6. Tests Required
- Widget test for the Settings surface rendering the Provider area.
- Repository test for round-tripping `ProviderConfigRecords`.
- Connectivity test unit coverage for success, non-2xx, timeout, and invalid JSON.

### 7. Wrong vs Correct
#### Wrong
Store Provider metadata in SQLite but keep API Key in logs, snackbars, or plain text UI.
#### Correct
Store API Key only in SQLite, mask it in UI, and sanitize any test failure message.
