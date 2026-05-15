# Visual Design Guidelines

> Product-level visual conventions for Persona Flutter.

---

## Overview

Persona Flutter should feel like a professional desktop writing workspace: calm, precise, text-first, and high-texture without becoming decorative. The default experience is a writing desk, while specialized feature areas can adopt stronger local visual languages when their work model requires it.

These rules apply to Flutter presentation work in `lib/src/core/ui/`, `lib/src/core/theme/`, and feature `presentation/` layers.

---

## Design Model

Use a layered visual model:

| Area | Visual Model | Purpose |
|------|--------------|---------|
| App shell, Projects, Settings, future Zen Editor | Writing desk | Long-session writing, project organization, reading, editing |
| `Style Lab`, `Plot Lab` | Creative canvas | Style exploration, plot mapping, story relationships, idea organization |
| `Workflow Runs` | Operations console | Queues, logs, progress, run state, diagnostics |

Do not force every route into the same template. Variation is allowed when it maps to the user's task, but the global product identity must remain white/graphite/cobalt, restrained, and text-first.

---

## Theme Direction

Use a light-first theme with switchable light/dark support.

Rules:

* Light mode is the primary design baseline.
* Dark mode must remain a first-class switchable counterpart.
* Hybrid surfaces are allowed when useful, such as a light manuscript area with a darker AI context panel.
* Avoid warm/yellow paper dominance. The product should not read as parchment, beige productivity software, or a nostalgic notebook.

Pending implementation decision:

* The app may default to system mode and persist user override, but the visual baseline is light-first.

---

## Palette

Primary light palette:

* Cool white and near-white surfaces.
* Graphite black text and structural contrast.
* Silver gray borders, separators, and secondary surfaces.
* Cobalt blue as a sparse functional accent.

Use cobalt blue only for:

* Primary actions.
* Active navigation and selected states.
* Links and focused controls.
* Workflow run states, progress, and operational signals.

Do not use cobalt blue for:

* Large page backgrounds.
* Broad decorative gradients.
* Dominant brand panels.
* Generic blue dashboard surfaces.

Texture should come from layered whites/grays, crisp borders, subtle shadows, material contrast, and typography, not from warm color casts.

---

## Typography

Use modern sans-serif as the primary UI typography.

Rules:

* Global labels, navigation, controls, settings, and workflow metadata should use clean modern sans-serif typography.
* Manuscript previews, chapter titles, project titles, and selected writing surfaces may use a light editorial treatment.
* Do not make the entire app serif-heavy or retro-bookish.
* Do not make the entire app mono/technical.
* Reserve mono styling for logs, run IDs, generated artifact names, diagnostics, and other operational metadata.

The typography should support crisp hierarchy, strong readability, and restrained personality.

---

## Component Shape

Use a mixed but explicitly rule-based shape system.

| Component Area | Radius Direction |
|----------------|------------------|
| App shell panels, document sheets | 2-6 px |
| Buttons, inputs, chips, selected navigation states | 6-10 px |
| Creative canvas notes/nodes | 8-14 px when useful |
| Console/log/status cells | 2-6 px or hard rectangular |

Rules:

* Main interface and document areas should be sharp, minimal, and restrained.
* Buttons, inputs, selected states, and compact controls may use small radius for click affordance and readable focus states.
* Creative canvas areas can be freer when the task is ideation, relationship mapping, or visual story organization.
* Operations console areas should be harder-edged and denser.
* Avoid globally soft rounded cards.
* Shape variation must be tied to work model, not arbitrary decoration.

---

## Desktop Navigation

Use an expandable sidebar for the desktop shell.

Rules:

* Default/collapsed state: narrow rail with icons and clear selected state.
* Expanded state: navigation labels, current project context, and relevant contextual entry points.
* Use graphite text, silver/gray dividers, and cobalt selected/action marks.
* The default sidebar should not feel like a large heavy menu.
* Expansion should reveal useful context, not decoration.

The current fixed-width labeled `NavigationRail` is not the final visual target. Material primitives are acceptable when they can support this behavior cleanly; custom shell composition is acceptable if Material defaults look too generic.

---

## Spacing And Density

Use slightly spacious density for the main interface and denser layouts for task-specific sub-pages.

Rules:

* Main shell, Projects, Settings, and future Zen Editor should leave enough breathing room for long sessions.
* Writing and reading surfaces should avoid dashboard-like compression and noisy controls.
* `Style Lab` and `Plot Lab` may be denser when showing many story/style nodes, relationships, or comparison states.
* `Workflow Runs` may be dense because queues, logs, status rows, and diagnostics need scan efficiency.
* Density follows task type: writing/reading is spacious; analysis, mapping, and operations can be compact.

---

## Motion And Interaction Feedback

Use restrained, fast, and state-clear motion.

Rules:

* Global motion should explain state changes and spatial relationships.
* Do not use showy or decorative motion in the global interface.
* Navigation expansion, selected states, run-status updates, and panel transitions should have short, clean feedback.
* Use quick transitions in roughly the 150-220 ms range for common UI state changes.
* Creative canvas interactions may be slightly more expressive when manipulating story/style nodes.
* Operations console motion should prioritize clarity for running, queued, error, and progress states.
* Respect reduced-motion accessibility settings when implemented.

---

## Forbidden Patterns

Do not introduce:

* Warm/yellow/beige palette dominance.
* Purple/blue gradient AI-app aesthetics.
* Decorative blobs, bokeh, or large gradient ornaments.
* Globally soft rounded card-heavy layouts.
* Blue-dominant backgrounds.
* Generic Material 3 surfaces without product-specific typography, spacing, and palette treatment.
* Marketing-page hero layouts for the app shell.

---

## Implementation Checklist

Before implementing a new shared UI surface or feature page:

* Which visual model applies: writing desk, creative canvas, or operations console?
* Does the surface preserve the white + graphite + cobalt palette rules?
* Is cobalt used only for intent/state?
* Are radius choices consistent with the component area?
* Is the density appropriate for the task type?
* Are motion choices short, purposeful, and state-clear?
* Does the page avoid generic Material defaults and warm/yellow palette drift?
