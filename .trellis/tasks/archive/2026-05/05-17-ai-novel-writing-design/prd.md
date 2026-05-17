# brainstorm: AI novel writing module design

## Goal

Research GitHub AI web-novel / AI novel writing systems and decide which design strengths are worth borrowing before implementing the AI novel module in Persona-Flutter.

## What I already know

* The project already has Style Lab and Plot Lab pipelines that convert source samples into reusable writing assets.
* Plot Lab already produces Plot Writing Guide / Story Engine markdown with YAML front matter.
* Style Lab already produces Voice Profile markdown with YAML front matter.
* Current architecture uses Riverpod providers, Drift repositories, MarkdownCompletionService, WorkflowTask prompt tracing, and staged run state.
* Existing architecture favors staged, persisted workflows over one-off chat interactions.

## Assumptions (temporary)

* The first AI novel implementation should reuse existing Style/Plot assets instead of creating a disconnected chat-only generator.
* GitHub research should prioritize open-source projects with inspectable README/source over closed SaaS products.
* The first implementation should optimize for controlled long-form writing, not maximum automation.

## Open Questions

* Should the first AI novel MVP start as a project-scoped Novel Workshop, with an AI Director mode deferred until the chapter loop is reliable?

## Requirements (evolving)

* Research comparable GitHub projects for architecture and UX patterns.
* Map useful patterns onto current Persona-Flutter constraints.
* Produce a recommended MVP direction and one decision question at a time.
* Preserve the ability to use existing Style Profile and Plot Profile assets directly in chapter generation.
* Treat accepted chapter text as the boundary for updating memory/facts/summaries.

## Acceptance Criteria (evolving)

* [x] Research notes cite concrete GitHub repositories and source evidence.
* [x] Reusable design patterns are separated from patterns we should avoid.
* [x] A first MVP workflow recommendation is explicit.
* [x] Local architecture constraints are mapped to the recommended MVP.

## Out of Scope (explicit)

* Implementing the AI novel module in this research pass.
* Claiming coverage of every GitHub repository literally; GitHub search is keyword and ranking limited.

## Technical Notes

* Platform confirmed locally: macOS/Darwin arm64, shell zsh, cwd /Users/zhouzirui/code/AI/Persona-Flutter.
* User-level search evidence standard path was requested by AGENTS.md but not found at ~/.codex/.docs/search-and-evidence-standard.md.
* Research reference: [research/github-ai-novel-systems.md](research/github-ai-novel-systems.md).
* Expanded candidate matrix: [research/github-candidate-matrix.md](research/github-candidate-matrix.md).
* Local architecture mapping: [research/architecture.md](research/architecture.md).
* Local architecture reference: [research/architecture.md](research/architecture.md).

## Research References

* [research/github-ai-novel-systems.md](research/github-ai-novel-systems.md) — comparable GitHub systems converge on asset-first, staged chapter runs, human acceptance gates, and memory projections.
* [research/architecture.md](research/architecture.md) — local codebase supports a new `features/novel_workshop` vertical slice using Riverpod, Drift, `MarkdownCompletionService`, and `WorkflowTask` prompt traces.

## Research Notes

### What comparable systems do

* InkOS and webnovel-writer use multi-stage chapter pipelines: plan, assemble context, draft, review/audit, revise, accept, then update memory.
* AI-Novel-Writing-Assistant centralizes planning, style, worldbuilding, chapter execution, audit, repair, and resume in a "Creative Hub" style workspace.
* Chronicler emphasizes human-in-the-loop context assembly, multi-level summaries, facts tables, and accepted-version boundaries.
* 91Writing is more lightweight: novel management, outline/chapter editing, prompt library, worldbuilding templates, cost/progress tracking.

### Patterns to borrow

* Asset-first creation: Style Profile, Plot Profile, Story Bible, characters, facts, summaries, chapter plans.
* Chapter contract before prose: must-advance, must-avoid, continuity constraints, style/plot constraints, hook/payoff obligations.
* Human approval gate: only accepted chapters update official memory and facts.
* Memory as projection: summaries, facts, entity states, and retrieval indexes should be derived from accepted text/contracts.
* Prompt trace and staged run state should be visible and reusable for debugging.

### Patterns to avoid in MVP

* One-click full-book autonomous generation.
* Heavy graph-hybrid RAG before simpler summaries/facts prove insufficient.
* Separate CLI/TUI/daemon-style architecture.
* Rich-text editor, cover generation, market radar, writing goals, and export pipeline before the chapter loop is reliable.

## Recommended MVP Direction

Build a human-in-the-loop Novel Workshop:

1. Novel Project
   - Title, genre, premise, target reader experience.
   - Bind one Style Profile and one Plot Profile.
   - Keep author intent and current focus as editable project context.

2. Story Bible
   - World/lore/characters/facts.
   - Initially manual plus AI-assisted extraction from user notes.

3. Chapter Board
   - Chapter list with outline, target beat, must-include, must-avoid, hook/payoff, and status.

4. Chapter Run
   - Build chapter contract from profiles, story bible, prior accepted chapters, current focus, and chapter brief.
   - Draft, audit, revise, and wait for user acceptance.

5. Post-Accept Projection
   - Update summaries, facts, character states, unresolved hooks/payoffs, and chapter index only after acceptance.

## Proposed First Implementation Slice

If this research is accepted, the next implementation task should be narrower than a full novel app:

1. Add a `Novel Workshop` route/page that opens from an existing `WritingProject`.
2. Persist chapter briefs and chapter statuses for a project.
3. Build one chapter run pipeline: contract, draft, audit, optional revise, accept.
4. Reuse the project default Provider/model plus bound Style Profile and Plot Profile.
5. Record every LLM call with `WorkflowTask` prompt trace.
6. On accept, save official chapter text and update simple summaries/facts; do not update official memory from drafts.

## Deferred Decisions

* Rich-text editor versus Markdown/plain text editor.
* Export format support such as Markdown/PDF/EPUB.
* Graph/RAG retrieval beyond summaries, facts, and selected profile/context snippets.
* Fully autonomous AI Director mode.
* Prompt template marketplace or user-editable template library.
