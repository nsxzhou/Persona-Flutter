# Novel Workshop Tab Empty States And Edit Actions

## Goal

Improve Novel Workshop tab empty states and missing edit affordances so empty asset tabs look intentional, controls stay aligned, and character index/relationship graph editing is discoverable.

## Requirements

- Optimize empty states shown in Voice Profile, Story Engine, Runtime Memory, chapter planning, and character graph contexts for a restrained writing-workspace style.
- Avoid floating icons/actions in large blank panels; empty state content should be visually grouped and centered when the tab body is otherwise empty.
- Prompt stack optional Voice Profile and Story Engine should not render as warning/error when unbound.
- Character index and relationship graph tab must expose an explicit edit affordance, in addition to per-character inline editing.
- Preserve existing project visual language: white/graphite/cobalt, compact radius, text-first, Material theme-driven styling.

## Acceptance Criteria

- Empty states render without large disconnected icon/action placement.
- Voice Profile and Story Engine empty tabs include a clear settings CTA.
- Runtime Memory empty state remains useful but matches the shared empty-state treatment.
- Character graph tab has a visible edit entry and selected character detail remains editable.
- `flutter analyze` passes or any remaining issues are reported with scope.

## Out of Scope

- New relationship CRUD flows.
- Data model or repository schema changes.
