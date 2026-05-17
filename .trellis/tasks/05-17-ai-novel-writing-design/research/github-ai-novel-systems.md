# GitHub AI Novel Writing Systems Research

Date: 2026-05-17

Scope note: This is representative GitHub research, not a literal exhaustive inventory of every repository. Search covered GitHub topic `novel-generation` and mixed English/Chinese queries for AI novel writing, AI web novel writing, worldbuilding, outline, chapter generation, RAG, and agent workflows.

## Repositories Reviewed

### Narcooo/inkos

Source: https://github.com/Narcooo/inkos

Design shape:
- Autonomous novel writing agent with Studio/TUI/CLI surfaces sharing one interaction runtime.
- Book workflow exposes bottom-level commands such as `book create`, `write next`, `review`, `approve`, and `export`.
- Chapter pipeline is explicit: Planner, Composer, Architect, Writer, Observer, Reflector, Normalizer, Auditor, Reviser.
- Strong reliability posture: chapter snapshots, rollback, file locks, schema validation, runtime deltas, and audit/revise loops.
- Style import analyzes reference text and injects style fingerprints into later chapter writing and revision.
- Long-term author control is kept in editable Markdown files such as author intent and current focus.

Borrowable for Persona-Flutter:
- Use one chapter execution pipeline with stages, not separate unrelated buttons.
- Treat write/review/revise as one run with persisted state and trace.
- Keep human approval gates before accepting chapters.
- Add "author intent" and "current focus" as first-class project context.
- Use writing output to update structured facts instead of only saving chapter text.

Avoid copying early:
- Full autonomous daemon, push notifications, cover generation, market radar, and multi-interface CLI/TUI/Studio complexity.

### lingfengQAQ/webnovel-writer

Source: https://github.com/lingfengQAQ/webnovel-writer

Design shape:
- Claude Code based long-form web novel system focused on not forgetting and not hallucinating.
- Uses a contract-first Story System: master setting, volume contracts, chapter contracts, accepted chapter commits, event audit, and read-model projections.
- Separates source of truth from projections: story system files are canonical; state/index/summaries/memory are read models.
- Context agent builds writing task briefs, data agent extracts accepted events/state/entity deltas after writing, reviewer checks consistency, pacing, OOC, continuity, hooks, and reader-pull.
- RAG uses vector/BM25/hybrid/graph-hybrid retrieval, with rerank and fallback behavior.

Borrowable for Persona-Flutter:
- Introduce a "chapter contract" before drafting. It should include must-advance, must-avoid, characters, continuity constraints, hook/payoff obligations, and style/plot assets.
- Save "accepted chapter commit" after user approval, then update facts/summaries/entities from the accepted version only.
- Treat memory/facts/summaries as projections, not the source of truth.
- Add preflight health before generating: missing style profile, plot guide, chapter brief, model config, or stale project facts should be visible.

Avoid copying early:
- Heavy `.story-system` file hierarchy and graph-hybrid RAG in MVP. Persona-Flutter already has Drift and local app state, so start with database-backed contracts and summaries.

### ExplosiveCoderflome/AI-Novel-Writing-Assistant

Source: https://github.com/ExplosiveCoderflome/AI-Novel-Writing-Assistant

Design shape:
- AI Director product: from one idea to story direction, project setting, macro planning, characters, volume strategy, pacing/chapter splitting, chapter execution, audit, repair, and full-book production.
- Creative Hub centralizes conversation, planning, tool execution, approval nodes, execution status, and resume.
- Writing style is a saved/editable/bindable asset, not only a prompt paragraph.
- Worldbuilding, characters, book analysis, knowledge base, style assets, and chapter generation are linked as long-term assets.
- Chapter execution shows plan, drafting, audit, repair, sync, and payoff backfill in one workspace.

Borrowable for Persona-Flutter:
- For this project, the natural bridge is: existing Style Profile + Plot Writing Guide -> Novel Project -> Chapter Board -> Chapter Run.
- Create one "Novel Workshop" as the central surface, not separate pages for every agent.
- Let users bind Style Profiles and Plot Profiles to a novel project.
- Make each chapter stateful: planned, drafted, reviewed, accepted, needs repair.
- Show why a chapter run stopped and what can be fixed locally versus requiring replanning.

Avoid copying early:
- Full "AI director from one vague sentence to first 10 chapters" should be a later mode. Persona-Flutter's current advantage is analysis-derived control, so MVP should start from selected profiles and user-approved planning.

### a9549521/chronicler

Source: https://github.com/a9549521/chronicler

Design shape:
- Human-in-the-loop long-form writing workspace, explicitly skeptical of fully automatic long novel generation.
- Core is context assembly, not one-click auto writing.
- Uses multi-level memory: recent chapters verbatim, near-term long summaries, mid-term short summaries, far-term one-line summaries.
- Maintains a structured facts table for character state, world state, key events, and revealed information.
- Lore is categorized and selected for injection per chapter to avoid irrelevant setting overload.
- Chapter writing is conversational, with editable turns and accepted version saved as official text.

Borrowable for Persona-Flutter:
- This matches Persona-Flutter's likely first version best.
- Use progressive memory compression before RAG-heavy retrieval.
- Let users choose which lore/style/plot assets enter a chapter generation context.
- Make "accept this version" the boundary that triggers official chapter save and fact updates.

Avoid copying early:
- Do not underbuild the asset model into only Markdown/YAML files if the existing app already uses Drift repositories and run state.

### ponysb/91Writing

Source: https://github.com/ponysb/91Writing

Design shape:
- Browser/front-end local AI writing tool with novel management, rich editor, outline/chapter management, prompt library, worldbuilding templates, goals, token cost tracking, and local storage.
- Focuses on usability and creator productivity rather than deep long-form consistency engineering.

Borrowable for Persona-Flutter:
- Prompt library with variables is valuable for explainability and user customization.
- Token/cost tracking by feature is useful once generation runs become frequent.
- Writing goals and progress stats can improve daily writer workflow, but are not core to the first AI novel engine.

Avoid copying early:
- Rich-text and gamified writing goals before the chapter-generation loop is reliable.

### guerra2fernando/libriscribe and raestrada/storycraftr

Sources:
- https://github.com/guerra2fernando/libriscribe
- https://github.com/raestrada/storycraftr

Design shape:
- General book creation systems: concept, outline, characters, worldbuilding, chapter generation, review/editing/export.
- Useful as baseline decomposition, but less specialized for Chinese serial web novels and less aligned with Persona-Flutter's existing Style Lab / Plot Lab assets.

Borrowable for Persona-Flutter:
- Simple/advanced mode split can reduce UX complexity.
- Export pipeline should eventually support Markdown/PDF/EPUB.

Avoid copying early:
- Generic book-writing flow if the goal is specifically AI novel/webnovel creation with style and plot profiles.

## Common Design Patterns

1. Asset-first, not chat-first
   Successful systems preserve reusable assets: style, plot, world, characters, lore, facts, summaries, outlines, chapter plans.

2. Multi-stage chapter run
   Stronger systems do not generate final chapter text in one call. They plan, assemble context, draft, audit, revise, then accept.

3. Human approval gate
   Accepted chapter text is a product event. Facts and memories should update after acceptance, not after every draft.

4. Memory as projections
   Long-form writing systems separate canonical text/contracts from derived summaries, facts, vector indexes, or graph memory.

5. Context budgeting
   Mature systems avoid dumping the whole book into the prompt. They use chapter-local contracts, selected lore, recent text, summaries, and relevant facts.

6. Quality checks become product UI
   Better systems show missing obligations, continuity warnings, pacing issues, hook/payoff gaps, and repair suggestions.

## Recommendation for Persona-Flutter

Do not start with a fully automatic "AI Director writes an entire novel" mode.

Start with a human-in-the-loop "Novel Workshop":

1. Novel Project
   - Title, genre, premise, target reader experience.
   - Bind one Style Profile and one Plot Profile.
   - Optional project-level author intent and current focus.

2. Story Bible
   - Structured world/lore/character/facts area.
   - Initially manual + AI assisted extraction from user notes.
   - Later can import from existing chapters.

3. Chapter Board
   - Chapter list with outline, target beat, must-include, must-avoid, hook/payoff, status.
   - Supports generating/refining chapter briefs before prose.

4. Chapter Run
   - Build chapter contract from Style Profile, Plot Profile, story bible, prior accepted chapters, current focus, and chapter brief.
   - Draft chapter.
   - Audit against contract.
   - Revise once or present repair suggestions.
   - User accepts version.

5. Post-Accept Projection
   - Update recent summary, facts table, character states, unresolved hooks/payoffs, and chapter index.
   - Record prompt trace using the existing workflow task infrastructure.

This design borrows the strongest ideas from InkOS, webnovel-writer, AI-Novel-Writing-Assistant, and Chronicler while fitting the existing Persona-Flutter architecture.

