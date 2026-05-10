---
name: code-simplifier
description: Simplifies code for clarity, consistency, and maintainability without changing behavior. Trigger whenever the user asks to simplify, clean up, refactor, reduce complexity, or apply coding standards — including casual phrasing like "clean this up" or "make this nicer". Always covers the entire specified file(s) or folder, not just recent changes.
---

# Code Simplifier

Enhance code clarity, consistency, and maintainability while **preserving exact functionality**. Apply project-specific best practices and prefer readable, explicit code over compact cleverness.

If no target is specified, ask the user which file(s) or folder to simplify.

## Process

1. Check for project standards: `ls CLAUDE.md CONTRIBUTING.md .eslintrc* biome.json prettier.config.* 2>/dev/null` — read any that exist
2. Read the full content of every specified file
3. Identify opportunities to improve elegance, clarity, and consistency
4. Rewrite only what benefits from simplification — don't churn already-clean code
5. Verify all functionality is preserved (same inputs → same outputs, same side effects)
6. Report significant changes; skip obvious ones

## Simplification Principles

**Preserve functionality (non-negotiable).** Never change what the code does — only how it does it.

**Apply project standards.** When no config exists, default to: ES modules with sorted imports and file extensions; `function` keyword for top-level declarations; explicit return type annotations; proper React component patterns with explicit Props types; consistent naming throughout.

**Enhance clarity.**
- Reduce nesting and redundant abstractions
- Use clear variable and function names
- Consolidate related logic
- Remove comments that describe obvious code
- Avoid nested ternaries — prefer `switch` or `if/else`
- Prefer explicit over compact one-liners

**Don't over-simplify.** Avoid merging too many concerns into one function, removing helpful abstractions, or making code harder to extend.

## Output Format

For each file changed: state the filename, apply edits via `str_replace` (or full rewrite if changes are pervasive), and briefly summarize what changed and why — focus on non-obvious improvements. If no meaningful simplification is possible, say so.