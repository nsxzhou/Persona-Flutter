# Logging Guidelines

> How logging is done in this project.

---

## Overview

No logging package has been introduced in the scaffold. Prefer structured, explicit logging only when a feature needs diagnosability for long-running local tasks or provider calls.

Until a logging library is selected, avoid ad-hoc `print`/`debugPrint` in committed code.

---

## Log Levels

When logging is introduced:

* `debug`: local development details that are not needed by users.
* `info`: lifecycle events for user-visible long-running tasks.
* `warning`: recoverable failures, retries, or degraded local state.
* `error`: failed operations requiring user-visible feedback or repair.

---

## Structured Logging

Task logs should include task id, task kind, stage, and timestamp. Avoid free-form logs that cannot be tied back to a persisted task record.

---

## What to Log

Log long-running workflow lifecycle events when implemented:

* task queued,
* task started,
* stage changed,
* task paused/resumed,
* task failed/succeeded.

---

## What NOT to Log

Never log API keys, full provider credentials, manuscript content, imported source text, or prompt payloads by default.

---

## Scenario: Provider connectivity and credential handling

### 1. Scope / Trigger
- Trigger: The Provider settings slice persists API Keys in SQLite and performs real network connectivity tests.
- This increases the risk of leaking secrets through logs or diagnostics.

### 2. Validation & Error Matrix
- Test failure -> surface sanitized error text only.
- Unexpected exception -> truncate or sanitize the message before showing it to users.
- API Key present -> never emit it in logs, even in debug builds.

### 3. Good/Base/Bad Cases
- Good: log the Provider id, test status, and timestamp only.
- Base: log a short sanitized error reason when a probe fails.
- Bad: print the request headers, model list payload, or API Key value.

### 4. Wrong vs Correct
#### Wrong
`debugPrint('Provider test failed: $apiKey')`
#### Correct
Log only the Provider id and a sanitized failure reason, never the secret itself.
