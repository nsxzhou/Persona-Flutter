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
