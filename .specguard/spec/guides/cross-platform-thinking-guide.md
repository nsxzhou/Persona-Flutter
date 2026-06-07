# Cross-Platform Thinking Guide

Use this guide when a change affects operating systems, shells, path handling,
encoding, line endings, package managers, or multiple AI coding platforms.

## Checklist

- [ ] Prefer structured path APIs over string concatenation.
- [ ] Treat Windows, macOS, and Linux shell differences as real behavior, not
  formatting noise.
- [ ] Keep generated config files minimal and preserve user-owned fields.
- [ ] Verify command examples use the project CLI name and current directory
  structure.
- [ ] If a platform-specific gotcha is discovered, record it in the relevant
  spec during `specguard-finish`.

## Common Failure Modes

- Hard-coding `python3`, path separators, or shell-only syntax where the project
  supports multiple systems.
- Deleting user-owned settings while removing generated entries.
- Forgetting that a config file can be both human documentation and runtime
  input.
