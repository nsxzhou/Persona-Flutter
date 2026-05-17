# Plot Lab Asset Library

## Goal

Implement the first Plot Lab asset-library loop: import TXT/EPUB samples, run local LLM analysis, produce an analysis report, full-book skeleton, and editable Story Engine, then save the result as a reusable Plot Profile.

## Scope

- Add `plot_lab` domain, application, data, and presentation layers aligned with existing Style Lab structure.
- Persist Plot Lab samples, analysis runs, and profiles in Drift.
- Reuse global workflow tasks with a `plot_lab_analysis` task kind.
- Support `/plot-lab`, `/plot-lab/profiles/:profileId`, and `/plot-lab/tasks/:runId`.
- Let users browse saved profiles, view drafts and task activity, rerun/delete tasks, save drafts, and edit only the saved Story Engine.

## Out of Scope

- Project attachment or project detail page changes.
- Multi-file batch profile creation.
- Pause/resume for Plot Lab tasks.
- Deep legacy backend chunk-analysis and merge branches.

## Contracts

- TXT imports become one `PlotSample`.
- EPUB imports are flattened in chapter order into one `PlotSample`.
- Empty normalized text must fail before analysis.
- Analysis stages are `preparingInput`, `sketchingChunks`, `buildingSkeleton`, `reporting`, and `postprocessing`.
- Analysis statuses are `pending`, `running`, `succeeded`, and `failed`.
- Chunk sketch output uses YAML front matter plus `# Chunk Sketch` Markdown body.
- Story Engine output uses YAML front matter plus `# Plot Writing Guide` Markdown body.
- Story Engine YAML contains `name`, `tags`, `plot_summary`, `core_formula`, `progression_loop`, `tension_rhythm`, `hook_strategy`, `anti_drift`, and `intensity`.
- Story Engine Markdown body is constrained to:
  - `Core Plot Formula`
  - `Chapter Progression Loop`
  - `Scene Construction Rules`
  - `Setup and Payoff Rules`
  - `Payoff and Tension Rhythm`
  - `Side Plot Usage`
  - `Hook Recipes`
  - `Anti-Drift Rules`
- Saved Plot Profiles keep analysis report and skeleton read-only; only Story Engine is editable.

## Acceptance

- Repository tests cover sample/run/profile persistence, workflow task synchronization, profile edit/delete, and interrupted task failure marking.
- Pipeline tests cover success, empty/invalid input failures, invalid sketch YAML+MD, and Story Engine YAML+MD normalization.
- Prompt tests cover fixed sketch and Story Engine YAML front matter fields, evidence boundaries, and fixed Story Engine sections.
- Widget tests cover Plot Lab empty state, import dialog, profile/draft/task rendering, detail tabs, saved profile edit boundary, and Workflow Runs Plot Lab navigation.
- `dart run build_runner build`, `flutter analyze`, and `flutter test` pass.
