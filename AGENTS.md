<!-- SPECGUARD:START -->
# SpecGuard Instructions

This project uses SpecGuard. Project-specific coding knowledge lives under
`.specguard/spec/`.

For engineering changes:

1. Before editing code, configuration, tests, or project documentation, read
   the relevant specs with `specguard-before-dev`.
2. Before reporting completion, run the spec compliance check with
   `specguard-check`.
3. At the end, run `specguard-finish` to decide whether `.specguard/spec/`
   needs updates. Apply clear, durable spec updates automatically; report
   uncertain suggestions instead of guessing.

Spec reading rules:

- Always read `.specguard/spec/guides/index.md`.
- Read the package/layer `index.md` files that match the touched area.
- Follow each index's Pre-Development Checklist or Quality Check and read the
  referenced guideline files.
- Report the spec files read when making or checking changes.

Managed by SpecGuard. Edits outside this block are preserved; edits inside may
be overwritten by `specguard update`.

<!-- SPECGUARD:END -->
