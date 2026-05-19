# Novel Workshop Chapter Generation Loop

## Goal

Implement the first non-UI chapter generation loop for Novel Workshop.

## Requirements

- Generate a chapter from an existing project and `ChapterPlan`.
- Assemble context from project metadata, prompt assets, runtime memory, chapter objective, output contract, and writing rules.
- Call the existing LLM boundary and persist prompt trace through `WorkflowTask`.
- Save generated Markdown正文 into the single current chapter table.
- Require explicit replacement when a chapter already has content.
- Record failed run/task diagnostics before LLM invocation failures when possible.
- Do not implement UI, continuity audit, memory-sync proposal generation, fact snapshots, or chapter version history.

## Acceptance

- Drift schema includes `ChapterGenerationRunRecords` and schema 13 migration.
- Repository tests cover run/task sync, prompt trace row, migration, and running-run detection.
- Pipeline tests cover successful generation, missing optional prompt assets warnings, explicit replacement, failed validation diagnostics, same-chapter concurrency block, and trace redaction.
- `flutter analyze` and `flutter test` pass.
