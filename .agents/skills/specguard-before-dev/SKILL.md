---
name: specguard-before-dev
description: "Reads project-specific coding guidelines from .specguard/spec/ before implementation begins. Use before modifying code, configuration, tests, or project documentation."
---

Read SpecGuard specs before starting any engineering change.

Mandatory steps:

1. Discover the spec tree:
   ```bash
   find .specguard/spec -name index.md -print
   ```

2. Always read shared guides first:
   ```bash
   cat .specguard/spec/guides/index.md
   ```

3. Identify the package/layer touched by the task from the requested file paths,
   code area, framework, or package name. Read the relevant index files:
   ```bash
   cat .specguard/spec/<package>/<layer>/index.md
   ```

4. Follow each index's Pre-Development Checklist and read the referenced
   guideline files. The index is only a routing file; the guideline files hold
   the actual rules.

5. Before editing, state a compact "SpecGuard specs read" list containing the
   spec files you actually loaded. If no relevant package/layer exists, say so
   and use the closest available guide instead of inventing a rule.

This step is mandatory before modifying code, configuration, tests, or project
documentation. Pure read-only analysis and short Q&A do not require it.
