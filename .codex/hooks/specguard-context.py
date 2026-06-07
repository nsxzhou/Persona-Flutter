#!/usr/bin/env python3
import json
import os
from pathlib import Path


def find_root(start):
    cur = Path(start).resolve()
    while cur != cur.parent:
        if (cur / ".specguard" / "spec").is_dir():
            return cur
        cur = cur.parent
    return None


def list_indexes(root):
    spec = root / ".specguard" / "spec"
    try:
        paths = sorted(p.relative_to(root).as_posix() for p in spec.rglob("index.md"))
    except OSError:
        paths = []
    return "\n".join(f"- {p}" for p in paths)


cwd = Path(os.getcwd())
root = find_root(cwd)
if root is None:
    raise SystemExit(0)

indexes = list_indexes(root)
context = f"""<specguard>
SpecGuard is active for this project.

For engineering changes:
1. Run/read specguard-before-dev before editing.
2. Run/read specguard-check before reporting completion.
3. Run/read specguard-finish to decide whether .specguard/spec needs updates.

Available spec indexes:
{indexes if indexes else "- none found"}
</specguard>"""

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "UserPromptSubmit",
        "additionalContext": context,
    }
}))
