# Fix Novel Workshop Information Architecture

## Goal

Make the Novel Workshop workbench directly maintainable instead of read-only and concept-heavy. Worldbuilding, character blueprint, and master outline remain separate tabs but become directly editable. User-facing `Project Bible` wording becomes `项目设定集`. Volume and chapter outline management becomes a structured flow. Empty Runtime Memory should not be emphasized as a warning or incomplete state.

## Requirements

- Scope this task to Novel Workshop UI and focused tests only. Do not change database schema or refactor Style Lab, Plot Lab, Projects list, or Workflow Runs.
- Keep the existing tabs: `概览`, `世界观设定`, `角色索引与关系网`, `总纲`, `分卷与章节细纲`, `Voice Profile`, `Story Engine`, `Runtime Memory`, `Prompt 栈`, `设置`.
- Convert `世界观设定`, `角色索引与关系网`, and `总纲` from read-only Markdown tabs into direct edit surfaces with view/edit/save behavior.
- Persist those edits through existing `NovelWorkshopController.saveProjectBible(ProjectBibleInput)` and preserve untouched bible fields.
- Replace user-facing `Project Bible` labels with `项目设定集`; keep domain/code names unchanged.
- In overview, show `项目设定集完成度` instead of `Project Bible`.
- In Prompt stack, say the project setting set is part of chapter generation context, without making `Project Bible` look like a separate hidden entry point.
- In `分卷与章节细纲`, add a structured `新建分卷` flow using existing `saveChapterVolume`.
- Empty outline planning state should first guide users to create a volume. `新建章节` must not open an unusable form when no volume exists.
- Existing chapter plan creation remains volume-backed. Once a volume exists, creating a chapter plan works under that volume.
- YAML outline status is secondary/internal status only, not the main editing flow.
- Runtime Memory empty state is neutral: overview hides it or shows a neutral status, standalone tab shows normal empty state, and Prompt stack treats empty memory as optional/not connected rather than an error.

## Acceptance Criteria

- [ ] Worldbuilding tab can edit and save `worldBuildingMarkdown`.
- [ ] Character tab can edit and save `charactersBlueprintMarkdown`.
- [ ] Master outline tab can edit and save `outlineMasterMarkdown`.
- [ ] Empty asset tabs do not tell users to edit in a missing Project Bible area.
- [ ] No visible user-facing `Project Bible` wording remains in Novel Workshop workbench UI.
- [ ] Empty chapter planning shows `新建分卷` and does not require selecting a missing volume.
- [ ] Creating a volume then creating a chapter plan persists correct `volumeId`, `volumeIndex`, and `volumeTitle`.
- [ ] Runtime Memory empty state does not render as warning/todo in overview or Prompt stack.

## Technical Notes

- Main file: `lib/src/features/novel_workshop/presentation/novel_workshop_page.dart`.
- Existing persistence already supports `ProjectBibleInput`, `ChapterVolumeInput`, `saveProjectBible`, and `saveChapterVolume`; no migration is needed.
- Existing widget fake repository in `test/novel_workshop/novel_workshop_page_test.dart` already implements save methods but may need to retain mutable bible/memory state for assertions.
- Relevant specs: `.trellis/spec/frontend/component-guidelines.md`, `.trellis/spec/frontend/state-management.md`, `.trellis/spec/frontend/quality-guidelines.md`, `.trellis/spec/frontend/type-safety.md`, `.trellis/spec/frontend/visual-design-guidelines.md`.
