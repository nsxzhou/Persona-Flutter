# ADR-0002: AI Recommendation as Primary Creation Flow

## Status

Accepted

## Context

The original project creation flow required users to manually fill in all fields without guidance. We want to provide data-driven AI recommendations grounded in real market signals, while keeping a minimal manual path for users with clear vision.

## Decision

"New Project" opens the recommendation page, which displays 3-5 Recommendation Direction cards generated from cached Market Scan Data. Recommendation generation is fully automatic — users provide no input. If no market data exists (scraping has not yet run), the recommendation page is unavailable and only the manual path is accessible.

Users select a direction and enter the Unified Creation Form with creative fields pre-filled. From this same form, they edit creative content and configure technical parameters (Provider/Model, Voice Profile, Story Engine). A "manual creation" link at the bottom of the recommendation page opens the same form blank.

The manual creation form is minimal: only title is required, plus description, word count target, and Provider/Model selector. All other fields use smart defaults and can be modified after project creation.

Recommendation Direction contains only creative-layer data (title, description, genre tags, word count target, market heat, competitive density). It does not carry technical parameters — those are configured separately in the Unified Creation Form.

## Considered Options

- **Hybrid mode (LLM without market data)**: Generate recommendations from LLM alone when no market data is available — rejected because recommendations without real market signals lose their core value proposition
- **User preference input**: Ask users to select genres before generating — rejected to keep the flow frictionless; the system uses market opportunity scores to determine what to recommend
- **Parallel entry points**: Separate "New Project" (manual) and "AI Recommend" buttons — rejected because it fragments the creation experience
- **Separate UIs for recommendation and manual**: Two distinct creation screens — rejected in favor of the Unified Creation Form to reduce code duplication and user confusion

## Consequences

- Market data scraping (background daily) becomes a hard prerequisite for the recommendation flow; the manual path remains the only option until scraping runs at least once
- The recommendation page is the primary onboarding experience, setting expectations about AI-assisted creation
- The Unified Creation Form is a single shared component, reducing maintenance burden but requiring it to handle both pre-filled and blank states gracefully
- Manual creation form is drastically simplified — users who need fine-grained control must configure parameters after project creation
