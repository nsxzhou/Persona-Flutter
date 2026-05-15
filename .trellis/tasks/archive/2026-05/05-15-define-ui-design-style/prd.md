# Define UI Design Style

## Goal

Define and record a coherent UI design style for Persona Flutter before future UI implementation work. The output should guide app shell, navigation, pages, components, typography, color, density, and motion decisions for a desktop-first local AI writing workspace.

## What I Already Know

* Persona Flutter is a desktop-first rewrite of Persona, a single-user, local-first, BYOK AI long-form writing workspace.
* The current app shell uses Flutter `MaterialApp.router`, `go_router`, and a `NavigationRail`-based desktop shell.
* Top-level product areas are `Projects`, `Style Lab`, `Plot Lab`, `Workflow Runs`, and `Settings`.
* The current visible UI is mostly scaffold-level: app shell, side navigation, placeholder pages, and one workflow page.
* Current theme is generated from `ColorScheme.fromSeed(seedColor: Color(0xFF496A68))` with Material 3 enabled.
* Current placeholder pages use large padding, `headlineMedium`, `bodyLarge`, and `Chip` controls.
* Existing frontend specs focus on Flutter architecture, routing, component structure, state management, type safety, and quality. They do not yet define a product-level visual style.
* The user could not evaluate abstract mood labels alone, so style decisions should use visual comparisons before locking terminology.
* The first visual comparison was too similar across directions because it reused the same layout and information hierarchy; the user correctly identified it as mostly color variation.
* The user currently leans toward a light-first product theme, while still requiring both light and dark themes to coexist and be switchable.
* The user does not like the current palette direction because it lacks texture/material quality; palette exploration should focus on surface material, paper tone, ink tone, accent color, borders, and shadow feel.
* The first palette exploration overused warm/yellow paper tones. The user explicitly prefers blue, white, black, and related cool neutral directions.

## Current UI Diagnosis

* The current UI reads as a default Material 3 dark scaffold with teal accent rather than a deliberate writing-product identity.
* The app has stable navigation structure, but the visual hierarchy is sparse: the content area does not yet communicate writing workflow, project state, or creative focus.
* The sidebar is functional but visually heavy for the amount of information shown; the selected destination treatment is clear but generic.
* The design currently lacks documented rules for information density, typography tone, surface layering, semantic colors, component shape, and motion.

## Assumptions To Validate

* The target user is a solo writer or creator using local AI assistance for long-form projects.
* The app should feel like a focused production workspace rather than a marketing site, toy, or generic admin dashboard.
* The design style should be distinctive enough to avoid default Material appearance, while staying maintainable in Flutter.
* This task records the style direction and constraints first; implementation can be a separate follow-up task.

## Requirements (Evolving)

* Record the chosen UI style in a durable project document.
* Use visual artifacts to compare style directions when wording is ambiguous.
* Visual comparisons must vary product work model, layout, information hierarchy, component shape, and density, not only palette.
* Global/main app surfaces should use the writing desk-centered direction from visual comparison V2.
* Theme mode exploration should assume light-first by default, but preserve a full dark counterpart for switching.
* Local feature areas may use stronger sub-styles when they match the user's task:
  * `Style Lab` and `Plot Lab` can use the creative canvas direction for relationship mapping, ideation, and style exploration.
  * `Workflow Runs` can use the operations console direction for queues, logs, run status, and diagnostics.
* Define a style direction that covers:
  * product personality
  * color palette
  * typography direction
  * spacing and information density
  * navigation and shell treatment
  * surfaces, borders, elevation, and component shape
  * icon and motion language
  * accessibility constraints
* Palette exploration should compare multiple materially distinct palettes using the same UI structure so color and surface quality can be judged directly.
* Primary palette candidates should avoid broad yellow/beige dominance and focus on blue/white/black/cool-neutral material quality.
* Keep the style compatible with Flutter desktop and Material 3 customization.
* Avoid generic AI-app aesthetics such as purple gradients, vague glassmorphism, decorative blobs, and default-looking Material surfaces.

## Acceptance Criteria (Evolving)

* [x] User and assistant converge on one named UI style direction.
* [ ] The style direction includes concrete rules, not just adjectives.
* [ ] The result is recorded in a project document that future implementation tasks can consult.
* [ ] Any open decisions are explicitly listed rather than hidden.

## Decisions

### 1. Product-Level Style Model

Decision: Persona should use a layered style model:

* Main/global interface: **Writing desk-centered**.
* `Style Lab` and `Plot Lab`: **Creative canvas** as a local sub-style.
* `Workflow Runs`: **Operations console** as a local sub-style.

Rationale:

* Persona's core use case is long-form writing, so the default experience should prioritize manuscript focus, calm surfaces, readable hierarchy, and low distraction.
* Creative exploration pages need a stronger spatial and expressive language because their core task is combining style, plot, motifs, and relationships.
* Workflow pages need operational density because their core task is monitoring AI jobs, state, logs, and errors.

Implication:

* The project should not force every route into the same visual template.
* Shared shell, Projects, Settings, and future Zen Editor should start from the writing desk language.
* Feature pages can deliberately deviate when the work model requires it, but the deviation should be documented and bounded.

### 2. Theme Mode Direction

Current preference: **Light-first with switchable light/dark themes**.

Rationale to validate:

* Light surfaces fit the writing desk-centered model because long-form reading and editing can lean on paper-like contrast, warm neutral surfaces, and calm document hierarchy.
* Dark mode should remain a first-class switchable mode, but may be derived from the light design system rather than treated as the primary design baseline.
* Hybrid surfaces are allowed: for example, a light manuscript area can coexist with darker AI context panels when focus or contrast benefits from it.

Pending decision:

* Confirm whether the app default should be light mode, system mode, or last-used user preference.

### 3. Primary Light Palette

Decision: Use **white + graphite black** as the primary light theme baseline.

Rationale:

* The user prefers blue, white, black, and cool-neutral directions over warm/yellow paper palettes.
* White + graphite black best matches the requested restrained, high-texture, non-yellow baseline.
* This palette supports the writing desk-centered main interface without making the product feel like parchment, beige productivity software, or a generic warm notebook app.

Implementation implications to validate later:

* Main surfaces should use cool white, near-white, silver gray, and graphite black rather than beige/yellow paper tones.
* Text hierarchy should rely on graphite/black contrast and carefully spaced gray levels.
* Blue should appear as a sparse functional accent for primary actions, selected states, links, and run/status indicators.
* Blue must not be used as a large background field or dominant page color.
* Additional texture should come from crisp borders, subtle shadows, layered whites/grays, and material contrast rather than warm color casts.

### 4. Blue Accent Usage

Decision: Include blue as a limited accent only.

Allowed use:

* Primary actions.
* Active navigation/selected states.
* Links and focused controls.
* Workflow run states, progress, and operational signals.

Forbidden use:

* Large page backgrounds.
* Broad decorative gradients.
* Replacing the white + graphite identity with a blue-dominant brand surface.

Rationale:

* The product keeps the restraint and texture of the white + graphite palette while still gaining interaction focus and brand memory.
* Blue carries tool precision and AI/workflow affordance better than warm accents, but large blue surfaces would push the app toward generic SaaS or dashboard aesthetics.

Accent character: **cobalt blue**.

Guardrail:

* Cobalt blue should be high-contrast and precise, but tightly rationed.
* Avoid broad cobalt panels, cobalt page backgrounds, or heavy blue gradients.
* Use graphite, white, and silver gray for structure; cobalt marks intent and state.

### 5. Typography Direction

Decision: Use **modern sans-serif as the primary UI typography**, with **light editorial influence in writing-specific text and selected headings**.

Rules:

* Global UI labels, navigation, controls, settings, and workflow metadata should use a clean modern sans-serif.
* Manuscript previews, chapter titles, project titles, and selected writing surfaces can use a more editorial text treatment to reinforce the writing-product identity.
* Avoid making the entire app serif-heavy or retro-bookish.
* Avoid making the entire app mono/technical; mono styling should be reserved for logs, run IDs, generated artifacts, and diagnostics.
* Typography should support the white + graphite + cobalt direction: crisp hierarchy, strong readability, and restrained personality.

Rationale:

* Persona should feel like a professional writing workspace, not a generic dashboard and not a nostalgic notebook app.
* Modern sans-serif keeps the app maintainable and clear across dense desktop UI.
* Light editorial accents preserve the writing identity where the user is dealing with manuscripts, chapters, and prose.

### 6. Component Shape Language

Decision: Use a **mixed but explicitly rule-based shape system**.

Rules:

* Main interface and document areas should be sharp, minimal, and restrained.
* Buttons, inputs, selected states, and compact controls may use small radius for click affordance and readable focus states.
* Creative canvas areas can be freer when the task is ideation, relationship mapping, or visual story organization.
* Operations console areas should be harder-edged and denser, with tighter borders and more rectangular state containers.
* Shape variation must be tied to work model, not arbitrary decoration.
* Avoid globally soft rounded cards because they weaken the white + graphite professional direction and can make the UI feel like a generic productivity app.

Practical radius direction:

* App shell panels and document sheets: 2-6 px.
* Buttons, inputs, chips, and navigation selection: 6-10 px.
* Creative notes/canvas items: 8-14 px when useful.
* Console/log/status cells: 2-6 px or hard rectangular.

Rationale:

* Persona needs enough restraint to feel professional and text-first.
* Interaction controls still need clear hit targets and state feedback.
* Local sub-styles should communicate different work modes without fragmenting the whole product.

### 7. Desktop Navigation Model

Decision: Use an **expandable sidebar** for the desktop shell.

Rules:

* Default/collapsed state should be a narrow rail with icons and clear selected state.
* Expanded state should show navigation labels, current project context, and relevant contextual entry points.
* The sidebar should preserve the white + graphite + cobalt palette: graphite text, silver/gray dividers, cobalt selected/action marks.
* The sidebar should not feel like a large heavy menu in the default state.
* Expansion should be useful, not decorative: it should reveal project context, shortcuts, and labels that help orientation.

Rationale:

* A narrow icon rail keeps the main writing desk focused and less visually heavy than the current fixed labeled `NavigationRail`.
* A fully labeled sidebar is clearer but occupies too much persistent space for a writing-centered desktop app.
* Expandability gives both clarity and restraint: default compactness for experienced use, labels/context when needed.

Implementation implications to validate later:

* Current fixed-width labeled `NavigationRail` is not the final target direction.
* The Flutter implementation may still use Material navigation primitives if they can support this behavior cleanly, but custom shell composition is acceptable if Material defaults look too generic.

### 8. Spacing And Information Density

Decision: Use **slightly spacious density for the main interface**, with **denser layouts allowed in task-specific sub-pages**.

Rules:

* Main shell, Projects, Settings, and future Zen Editor should have enough breathing room for long sessions and writing focus.
* The main writing desk should avoid dashboard-like compression, dense card grids, and visually noisy controls.
* `Style Lab` and `Plot Lab` can be denser when presenting many story/style nodes, relationships, or comparison states.
* `Workflow Runs` can be dense because queues, logs, status rows, and diagnostics require scan efficiency.
* Density should follow task type, not route hierarchy alone: writing and reading are spacious; analysis, mapping, and operations can be compact.

Rationale:

* Persona's primary experience is long-form writing and project thinking, which benefits from visual breathing room.
* AI workflow and lab pages need higher information density to remain useful and efficient.
* This preserves a calm global identity while allowing power-user surfaces where they are warranted.

### 9. Motion And Interaction Feedback

Decision: Use **restrained, fast, and state-clear motion**.

Rules:

* Do not use showy or decorative motion in the global interface.
* Motion should explain state changes and spatial relationships, not call attention to itself.
* Navigation expansion, selected states, run-status updates, and panel transitions should have short, clean feedback.
* Prefer quick transitions in the 150-220 ms range for common UI state changes.
* Creative canvas interactions may be slightly more expressive when manipulating story/style nodes, but should still stay purposeful.
* Operations console motion should prioritize clarity: progress, running/queued/error states, and row updates should be legible and calm.
* Respect reduced-motion accessibility settings when implemented.

Rationale:

* Persona is a long-session writing workspace, so motion should reduce cognitive load rather than add visual noise.
* Fast feedback makes the desktop app feel responsive and precise.
* Different sub-styles can have local motion nuances, but the global product should remain restrained.

## Out Of Scope

* Implementing the new UI style in Dart widgets.
* Redesigning domain workflows such as project CRUD, Zen Editor behavior, or AI workflow execution.
* Selecting final production fonts that require licensing review.

## Technical Notes

* Inspected `lib/src/core/theme/app_theme.dart`.
* Inspected `lib/src/core/ui/app_shell.dart`.
* Inspected `lib/src/core/ui/feature_placeholder_page.dart`.
* Inspected `lib/src/app/persona_app.dart`.
* Inspected `README.md`.
* Existing frontend spec index: `.trellis/spec/frontend/index.md`.
* Created `style-visual-comparison.html` and `style-visual-comparison.png` as a static comparison artifact for three possible UI moods.
* Created `style-visual-comparison-v2.html` and `style-visual-comparison-v2.png` to compare three distinct work models:
  * writing desk centered on manuscript editing and quiet context
  * creative canvas centered on story/style relationship mapping
  * operations console centered on AI job queues, metrics, and logs
* Created `theme-mode-comparison.html` and `theme-mode-comparison.png` to compare light-first writing desk, dark writing desk, hybrid reading surfaces, and local creative/operations sub-styles.
* Created `palette-comparison.html` and `palette-comparison.png` to compare six materially distinct palette directions:
  * warm paper and deep teal
  * porcelain white and mist green
  * graphite gray and blue-gray ink
  * parchment and terracotta
  * archive greige and smoky violet
  * night ink and antique gold paper
* Created `blue-white-black-palette-comparison.html` and `blue-white-black-palette-comparison.png` to correct the palette direction toward:
  * cool white and electric blue
  * mist blue-white and deep ocean blue
  * white and graphite black
  * obsidian blue shell and white paper
  * silver white and cobalt blue
  * ice blue-white and cyan blue

## Open Questions

* Should these decisions now be consolidated into a formal frontend design style spec?
