---
indexed_commit: 18aa35a3e91fa36bc1892e2ca607eb550a739341
last_updated: 2026-08-04
---

# INDEX.md

High-level map of this repo — what each top-level folder and root file covers. Read this first when navigating; update it when a change adds, removes, or repurposes a folder or file.

## Folders

| Folder | Description |
|---|---|
| `skills/` | Claude Code skills, one subfolder per skill (each has a `SKILL.md`). Covers planning (`feature-plan`, `wayfinder`, `tech-docs`), git workflow (`commit-git`, `smart-commit-git`, `create-pr`, `resolving-merge-conflicts`), review (`code-review`, `pr-review`), design/architecture (`codebase-design`, `domain-modeling`, `improve-codebase-architecture`), interviewing/sharpening (`grilling`, `grill-me`, `grill-with-docs`), explanation/teaching (`explain-code`, `teach`, `investigate-issue`), prototyping (`prototype`), execution (`implement`), docs/knowledge (`tech-docs`, `wiki`, `research`, `handoff`, `repo-index`), slides (`slide-outline`, `slide-generate`), and meta (`writing-great-skills`). |
| `commands/` | Slash-command definitions (`commit.md`, `feature-plan.md`, `polish-code.md`, `pr.md`, `smart-commit.md`, `ticket.md`). |
| `guidelines/` | Scoped coding-standard docs referenced by `AGENTS.md`'s Code Quality table (security, architecture, backend, react-nextjs, tailwind-styling, solid, testing, code-organization, typescript-patterns, python, correctness-maintainability, llm-prompting). |

## Root files

| File | Description |
|---|---|
| `.gitignore` | Ignored-path rules for this repo. |
| `AGENTS.md` | Global behavioral guidelines for coding agents in this repo (process, code quality scope table, documentation, LLM API usage, sub-agents). |
| `copilot-instructions.md.example` | Example Copilot instructions file. |
| `ghostty_config.txt` | Terminal (Ghostty) config. |
| `terminal_auto_approvals.json` | Terminal command auto-approval rules. |
