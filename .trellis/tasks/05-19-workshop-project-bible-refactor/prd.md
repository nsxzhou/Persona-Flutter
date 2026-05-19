# Workshop-only ProjectBible and Editor Refactor

## Goal

Refactor Novel Workshop so the project workbench and editor match the Persona reference model for long-form fiction work: project bible assets, volume/chapter outline structure, correct YAML/Markdown rendering, runtime memory as a first-class asset, and an immersive writing editor.

## Requirements

- Scope this task to Novel Workshop only. Do not refactor Style Lab, Plot Lab, Workflow Runs, or the Projects list information architecture except where repository contracts require project-scoped Workshop data.
- Add a Workshop-owned `ProjectBible` model keyed by `projectId` with:
  - `descriptionMarkdown`
  - `worldBuildingMarkdown`
  - `charactersBlueprintMarkdown`
  - `outlineMasterMarkdown`
  - `outlineDetailYaml`
  - `createdAt` / `updatedAt`
- Add a volume model and redesign `ChapterPlan` as a volume-scoped chapter outline node:
  - add `ChapterVolume`
  - add `volumeId`, `volumeIndex`, `volumeTitle`, `chapterLocalIndex`, and keep `chapterIndex` as whole-book order
  - preserve `ChapterObjectiveCard` mapping
  - add `coreEvent`, `emotionArc`, `chapterHook`, and `outlineMarkdown`
- Add a strict outline YAML parser for `outlineDetailYaml` that can derive `ChapterVolume + ChapterPlan` records.
- Use LLM artifact contracts by purpose inside Workshop:
  - outline detail: YAML-only
  - chapter body: Markdown-only
  - Voice Profile / Story Engine: YAML+Markdown
- Remove the standalone “骨架大纲” tab from the Workshop UI. Keep `plotSkeletonMarkdown` only as a reference input for initializing/generating outline detail.
- Redesign Workshop tabs to include:
  - 概览
  - 世界观设定
  - 角色索引与关系网
  - 总纲
  - 分卷与章节细纲
  - Voice Profile
  - Story Engine
  - Runtime Memory
  - Prompt 栈
  - 设置
- Fix Voice Profile and Story Engine display in Workshop:
  - parse YAML front matter using the existing Style/Plot parsers where possible
  - render metadata as summary chips/fields
  - render only Markdown body with `MarkdownBody`
  - show explicit format errors and a source preview if parsing fails
- Make Runtime Memory a standalone tab showing characters status, runtime state, runtime threads, and story summary.
- Refactor the editor page toward the Persona reference layout:
  - fixed top command bar with return, project title, save/generation state, save, generate
  - left volume/chapter navigator
  - center manuscript editor as dominant surface
  - right inspector with chapter objective, prompt asset status, Runtime Memory summary, latest run, and Workflow Runs link
  - compact widths must stack with explicit heights and no unbounded `Expanded` in scroll views
- Keep existing explicit save behavior and overwrite confirmation behavior.
- Keep generation run and Workflow Runs linkage through existing workflow task contracts.

## Data Migration

- Bump Drift schema.
- Create a Project Bible row for existing projects.
- Copy existing `ProjectRecords.description` into `ProjectBible.descriptionMarkdown`.
- Create a default volume `未分卷章节` for existing projects with chapter plans.
- Migrate existing flat `ChapterPlanRecords` into the default volume, preserving ids and `chapterIndex`.
- Ensure existing `ProjectChapterRecords` and `ChapterGenerationRunRecords` remain associated through `chapterPlanId`.
- After migration, new chapter plans must belong to a volume.

## Acceptance Criteria

- Repository tests prove existing projects get Project Bible rows and old chapter plans migrate into a default volume.
- Parser tests cover valid outline YAML and invalid missing volume/chapter/index/title cases.
- Saving outline YAML updates volume and chapter plan projections.
- Chapter generation prompt uses Project Bible, redesigned ChapterPlan, Voice Profile, Story Engine, and Runtime Memory.
- Chapter generation still stores Markdown-only body content and rejects/cleans code fences as before.
- Workshop tab set matches the new information architecture and no longer contains a standalone “骨架大纲” tab.
- Voice Profile and Story Engine Workshop tabs no longer render YAML front matter as body Markdown.
- Runtime Memory is visible as an independent tab.
- Editor renders the new chapter tree, manuscript area, and right inspector without overflow on compact layout tests.

## Out of Scope

- Refactoring Style Lab, Plot Lab, or Workflow Runs shared document rendering.
- Automatic memory sync proposal generation/acceptance.
- Continuity audit.
- Chapter version history.
- Full project export.
- A new top-level sidebar destination for Novel Workshop.

## Technical Notes

- Follow `.trellis/spec/backend/database-guidelines.md`, `.trellis/spec/backend/quality-guidelines.md`, `.trellis/spec/frontend/state-management.md`, `.trellis/spec/frontend/component-guidelines.md`, and `.trellis/spec/frontend/visual-design-guidelines.md`.
- Reuse existing `VoiceProfileFrontMatterParser` and `StoryEngineNormalizer.parse` for Workshop display where possible.
- UI and presentation must consume repository/provider/domain contracts, not Drift rows.
- Generated files must be regenerated with build_runner after changing Drift, Freezed, or Riverpod annotations.
