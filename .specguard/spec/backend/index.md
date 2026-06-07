# Backend Development Guidelines

> Best practices for backend development in this project.

---

## Overview

This directory contains guidelines for backend development. Fill in each file with your project's specific conventions.

---

## Guidelines Index

| Guide | Description | Status |
|-------|-------------|--------|
| [Directory Structure](./directory-structure.md) | Module organization and file layout | To fill |
| [Database Guidelines](./database-guidelines.md) | ORM patterns, queries, migrations | To fill |
| [Error Handling](./error-handling.md) | Error types, handling strategies | To fill |
| [Quality Guidelines](./quality-guidelines.md) | Code standards, forbidden patterns | To fill |
| [Logging Guidelines](./logging-guidelines.md) | Structured logging, log levels | To fill |

---

## Pre-Development Checklist

- [ ] Read [Directory Structure](./directory-structure.md) before adding or moving backend files.
- [ ] Read [Error Handling](./error-handling.md) before changing errors, validation, or API responses.
- [ ] Read [Database Guidelines](./database-guidelines.md) before changing persistence, queries, or migrations.
- [ ] Read [Logging Guidelines](./logging-guidelines.md) before adding logs or telemetry.
- [ ] Read [Quality Guidelines](./quality-guidelines.md) before implementing backend behavior.

## Quality Check

- [ ] Re-check changed backend files against [Quality Guidelines](./quality-guidelines.md).
- [ ] Verify errors and validation against [Error Handling](./error-handling.md).
- [ ] Verify persistence changes against [Database Guidelines](./database-guidelines.md).
- [ ] Run the smallest relevant backend test, type-check, lint, or build command.

---

## How to Fill These Guidelines

For each guideline file:

1. Document your project's **actual conventions** (not ideals)
2. Include **code examples** from your codebase
3. List **forbidden patterns** and why
4. Add **common mistakes** your team has made

The goal is to help AI assistants and new team members understand how YOUR project works.

---

**Language**: All documentation should be written in **English**.
