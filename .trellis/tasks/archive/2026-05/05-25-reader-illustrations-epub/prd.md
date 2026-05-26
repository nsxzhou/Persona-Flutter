# Reader Mode, Chapter Illustrations, and EPUB Export MVP

## Goal

Add an end-to-end MVP for reviewing a novel as a finished book, manually generating illustrations from selected reading passages through configured image providers, accepting only reviewed illustrations into the reading flow, and exporting a practical EPUB with chapters, table of contents, and accepted illustrations.

## What I Already Know

- The app is a Flutter desktop-style project using Riverpod, GoRouter, Drift, Material 3, and shared `PersonaPage`/`PersonaPanel` UI primitives.
- The project workbench already has `/projects/:projectId/workshop` and `/projects/:projectId/workshop/editor`.
- `NovelExportService` currently exports TXT through `buildNovelTxt`.
- `epubx: ^4.0.0` is already in `pubspec.yaml`; local package contents include `epub_writer.dart` and writer tests.
- Image provider management already exists under Settings, with GPT/Grok provider kinds and `ImageGenerationService` returning URL or base64 image results.
- There is no existing persisted illustration/image-asset model tied to chapters or paragraph anchors.

## Requirements

- Add a `阅读模式` entry in the workbench actions, routing to `/projects/:projectId/workshop/reader`.
- Implement Reader Mode as a finished-book review surface, not a second text editor.
- Reader Mode must show:
  - chapter/volume navigation,
  - a quiet paper-like reading column,
  - chapter content split into readable paragraphs,
  - accepted illustrations rendered after their anchored paragraph,
  - draft/pending illustration review controls,
  - return-to-workbench, edit-in-editor, and export EPUB actions.
- Illustration generation must be manual:
  - user selects or chooses a paragraph/text passage,
  - generation dialog defaults the prompt to the selected text only,
  - user can edit the prompt before sending,
  - dialog dynamically lists enabled image providers and model names,
  - no project-level image provider setting is added in this MVP.
- Generated illustration storage:
  - save image bytes to the local application data directory,
  - persist metadata in Drift,
  - do not write image Markdown into chapter body text.
- Illustration state:
  - new generated images start as draft/pending review,
  - only accepted images appear inline in the official reading flow and EPUB,
  - draft images remain reviewable and can be accepted, retried, or deleted.
- EPUB export:
  - add `exportEpub` alongside TXT export,
  - package project title, language, description, ordered volumes/chapters, table of contents, and accepted illustrations,
  - exclude draft/rejected/deleted illustrations,
  - keep TXT export text-only.

## Out of Scope

- Automatic scene/person detection or chapter scanning.
- Cover generation or cover selection.
- Full publishing/print-grade EPUB layout controls.
- Project-level default image provider settings.
- Writing generated image links back into chapter Markdown.
- Character/style consistency enrichment beyond user-edited prompt text.

## Acceptance Criteria

- [ ] Workbench exposes `阅读模式`, `进入编辑器`, `导出 TXT`, and Reader Mode can return to workbench.
- [ ] Reader Mode displays ordered chapters and body paragraphs without offering inline text editing.
- [ ] User can create an illustration draft from a paragraph/text selection through an enabled image provider.
- [ ] URL and base64 image generation results are persisted as local image files with metadata.
- [ ] Pending/draft illustrations are reviewable but do not appear in official reading flow or EPUB.
- [ ] Accepted illustrations render after their paragraph and are exported into EPUB.
- [ ] EPUB export produces a readable non-empty file with table of contents and accepted images.
- [ ] Existing TXT export behavior remains unchanged.
- [ ] Repository, image persistence, reader widget, EPUB, and regression tests are added or updated.
- [ ] `dart analyze` and `flutter test` pass.

## Technical Notes

- Likely impacted files:
  - `lib/src/core/database/app_database.dart`
  - `lib/src/core/router/app_router.dart`
  - `lib/src/features/novel_workshop/domain/novel_workshop.dart`
  - `lib/src/features/novel_workshop/domain/novel_workshop_repository.dart`
  - `lib/src/features/novel_workshop/data/drift_novel_workshop_repository.dart`
  - `lib/src/features/novel_workshop/application/novel_export_service.dart`
  - `lib/src/features/novel_workshop/application/novel_workshop_providers.dart`
  - new reader/illustration application and presentation files under `features/novel_workshop/`
- Follow `.trellis/spec/frontend/component-guidelines.md`: use `PersonaPage`, `PersonaPanel`, Material 3 theme values, responsive controls, and Riverpod providers instead of direct data access in widgets.
- Visual direction: "quiet review paper" with restrained desktop tool chrome and comfortable long-form typography.

## Definition of Done

- Tests added/updated for storage, repository, rendering, export, and regressions.
- Generated Drift/Riverpod code is refreshed where needed.
- Lint/type-check/test suite passes.
- Any new technical decision worth preserving is reviewed for spec update.
