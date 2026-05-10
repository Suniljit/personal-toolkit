---
name: code-simplifier
description: Simplifies code for clarity, consistency, and maintainability without changing behavior. Trigger whenever the user asks to simplify, clean up, refactor, reduce complexity, or apply coding standards — including casual phrasing like "clean this up" or "make this nicer". Always covers the entire specified file(s) or folder, not just recent changes.
---

# Code Simplifier

Enhance code clarity, consistency, and maintainability while **preserving exact functionality**. Apply project-specific best practices and prefer readable, explicit code over compact cleverness. Work well in GPT/Codex-style coding agents: inspect first, make surgical edits, verify locally, and report results in concise Markdown.

If no target is specified, ask the user which file(s) or folder to simplify.

## Process

1. Check for project and agent standards. Look for files such as `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `README.md`, `pyproject.toml`, `.eslintrc*`, `biome.json`, and `prettier.config.*`; read the relevant ones that exist.
2. Read the full content of every specified file before editing.
3. Identify opportunities to improve elegance, clarity, and consistency.
4. State assumptions and a brief plan for multi-file, risky, or behavior-sensitive work. Preserve any user, project, or tool approval gates; do not bypass them.
5. Rewrite only what benefits from simplification — don't churn already-clean code.
6. Verify all functionality is preserved (same inputs → same outputs, same side effects).
7. Report significant changes; skip obvious ones.

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

## Codex Tooling

- Prefer `rg`/`rg --files` for discovery.
- Use the repo's existing formatter, linter, type checker, and tests when practical.
- In Codex, use `apply_patch` for manual edits. If another host provides an equivalent safe edit tool, use that host's normal edit mechanism.
- Do not make speculative improvements outside the requested target. Mention unrelated issues instead of fixing them.
- If a change needs approval under the current environment, stop and ask for approval before proceeding.

## Output Format

While working, show short progress updates that render cleanly in Codex:

- `Inspecting:` what context you are reading and why.
- `Editing:` what file or concern you are changing before edits.
- `Verifying:` what check you are running.

Final response:

- Start with what changed, in one short paragraph.
- List changed files only when there is more than one or the file names matter.
- Include verification performed, or say exactly what was not run.
- If no meaningful simplification is possible, say so clearly and mention the files inspected.
