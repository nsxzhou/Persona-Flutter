---
name: specguard-finish
description: "Finishes an engineering change by confirming spec checks ran, deciding whether .specguard/spec/ needs updates, and applying clear spec updates."
---

Finish an engineering change with final SpecGuard review and spec sync.

Mandatory steps:

1. Confirm `specguard-check` has been run for the current diff. If not, run it
   first.

2. Decide whether `.specguard/spec/` needs an update. Update specs only when
   the work introduced or revealed durable knowledge, such as:
   - a project convention future agents must follow
   - a recurring pitfall or forbidden pattern
   - a new interface, payload, environment variable, command, or cross-layer
     contract
   - a reusable implementation pattern backed by real code

3. Do not update specs for trivia: formatting, typo fixes, one-off mechanical
   edits, or behavior that is already covered by existing specs.

4. When updating a spec:
   - read the target spec first
   - add the shortest actionable rule that prevents future mistakes
   - include a concrete example or file reference when useful
   - for infrastructure, cross-layer, or public contract changes, include
     scope, contract, failure behavior, and required tests
   - update the package/layer `index.md` only when a new topic or checklist
     entry is added

5. Final report must include:
   - "Spec update: none" or the spec files changed
   - why each spec update was or was not needed
   - verification status

If the right spec location is unclear, do not guess. Report the proposed update
and target area as a follow-up instead of writing speculative rules.
