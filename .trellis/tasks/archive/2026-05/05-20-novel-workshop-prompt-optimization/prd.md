# Optimize Novel Workshop Fixed Prompts

## Goal

Improve Novel Workshop's fixed prompts by adapting ideas from `/Users/zhouzirui/Downloads/Prompt/小说相关` for long-form continuity, without copying those prompts verbatim.

Primary quality target: make generated assets and chapters more stable for long-form writing through core DNA, character state, setup/payoff, chapter continuity, and memory updates.

## Scope

- Update Novel Workshop prompt text for asset generation, chapter draft generation, writing rules, and memory patch generation.
- Keep existing YAML schemas compatible with current parsers and UI.
- Update focused Novel Workshop tests to assert the new prompt contracts.

## Non-Goals

- Do not change Drift schema, repository contracts, parsers, UI, Riverpod providers, or generated files.
- Do not copy external reference prompts directly.
- Do not add new YAML fields that require parser or persistence changes.

## Acceptance Criteria

- Asset prompts include long-form continuity rules: core DNA, three-dimensional world constraints, character drivers, suspense units, and setup/payoff.
- YAML prompts still require existing roots and fields: `characters` / `relationships`, `volumes`, and existing chapter/volume keys.
- Chapter draft prompt includes current-chapter-only output, context priority, continuity, and anti-repetition rules.
- Memory patch prompt remains delta-only and fact-bound, and prioritizes `runtimeMemory` updates for current state, unresolved suspense, setup/payoff debt, and story summary.
- Focused Novel Workshop prompt tests and `flutter analyze` pass.
