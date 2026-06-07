# Cross-Layer Thinking Guide

Use this guide when a change crosses boundaries such as UI, API, service,
database, queue, cache, CLI, or generated files.

## Checklist

- [ ] Identify every producer and consumer of the changed data.
- [ ] Confirm whether any public API, command, file format, environment
  variable, or persistence contract changes.
- [ ] Check validation and error behavior at each boundary.
- [ ] Update tests at the layer where the contract is enforced.
- [ ] If the change creates a durable contract, record it in the relevant
  `.specguard/spec/<package>/<layer>/` file during `specguard-finish`.

## Common Failure Modes

- Updating a caller but missing another consumer.
- Changing a payload shape without updating validation or tests.
- Treating generated files as documentation only when they are runtime input.
- Adding a fallback that hides the real integration failure.
