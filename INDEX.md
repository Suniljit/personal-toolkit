---
indexed_commit: 770372151077ea1d62061cec41a1f7a3a3025183
last_updated: 2026-08-08
---

# INDEX.md

High-level map of this repo — what each top-level folder and root file covers. Read this first when navigating; update it when a change adds, removes, or repurposes a folder or file.

## Folders

- `skills/` — Claude Code skills, one subfolder per skill (each has a `SKILL.md`). Covers planning (`feature-plan`, `wayfinder`, `tech-docs`), git workflow (`commit-git`, `smart-commit-git`, `create-pr`, `resolving-merge-conflicts`, `rebase-main`), review (`code-review`, `pr-review`), design/architecture (`codebase-design`, `domain-modeling`, `improve-codebase-architecture`), interviewing/sharpening (`grilling`, `grill-me`, `grill-with-docs`), explanation/teaching (`explain-code`, `teach`, `investigate-issue`), prototyping (`prototype`), execution (`implement`), docs/knowledge (`tech-docs`, `wiki`, `research`, `handoff`, `repo-index`), slides (`slide-outline`, `slide-generate`), and meta (`writing-great-skills`).
- `guidelines/` — Scoped coding-standard docs referenced by `AGENTS.md`'s Code Quality table (security, architecture, backend, react-nextjs, tailwind-styling, solid, testing, code-organization, typescript-patterns, python, correctness-maintainability, llm-prompting).
- `bin/` — `toolkit.sh` symlinks this repo's `AGENTS.md`/`guidelines/`/`skills/` into Claude Code, opencode, and Codex (global or per-project) and keeps them in sync via `update`. See `bin/README.md`.

## Root files

| File | Description |
|---|---|
| `.gitignore` | Ignored-path rules for this repo. |
| `AGENTS.md` | Global behavioral guidelines for coding agents in this repo (process, code quality scope table, documentation, LLM API usage, sub-agents). |
| `ghostty_config.txt` | Terminal (Ghostty) config. |
