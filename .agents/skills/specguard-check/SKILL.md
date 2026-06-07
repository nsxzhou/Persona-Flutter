---
name: specguard-check
description: "Checks recent changes against .specguard/spec/ guidelines and runs targeted verification. Use after edits and before reporting completion."
---

Check recent changes against SpecGuard specs before reporting completion.

Mandatory steps:

1. Inspect the changed files:
   ```bash
   git diff --name-only HEAD
   git diff --stat HEAD
   ```

2. Re-read the spec files that apply to the changed paths. At minimum, read:
   - `.specguard/spec/guides/index.md`
   - each relevant `.specguard/spec/<package>/<layer>/index.md`
   - the guideline files named in each index's Quality Check section

3. Review the diff against the loaded specs. Fix concrete violations directly
   when the fix is in scope.

4. Run the smallest useful verification for the changed area: lint,
   type-check, unit tests, build, or a targeted command already used by the
   project.

5. Report:
   - spec files read
   - issues fixed
   - verification commands and results
   - remaining risks or skipped checks

Do not claim the work is complete until this check has run or you clearly state
why it could not run.
