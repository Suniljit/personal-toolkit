# INDEX.md

High-level map of this repo — what each top-level folder/file covers. Read this first when navigating; update it when you add, remove, or repurpose a folder or file.

## Folders

- `skills/` — Claude Code skills, one subfolder per skill (each has a `SKILL.md`). Covers planning (`feature-plan`, `wayfinder`, `tech-docs`), git workflow (`commit-git`, `smart-commit-git`, `create-pr`, `resolving-merge-conflicts`), review (`code-review`, `pr-review`), design/architecture (`codebase-design`, `domain-modeling`, `improve-codebase-architecture`), interviewing/sharpening (`grilling`, `grill-me`, `grill-with-docs`), explanation/teaching (`explain-code`, `teach`, `investigate-issue`), prototyping (`prototype`), execution (`implement`), docs/knowledge (`tech-docs`, `wiki`, `research`, `handoff`), slides (`slide-outline`, `slide-generate`), and meta (`writing-great-skills`).
- `commands/` — slash-command definitions (`commit.md`, `feature-plan.md`, `polish-code.md`, `pr.md`, `smart-commit.md`, `ticket.md`).
- `guidelines/` — scoped coding-standard docs referenced by `AGENTS.md`'s Code Quality table (security, architecture, backend, react-nextjs, tailwind-styling, solid, testing, code-organization, typescript-patterns, python, correctness-maintainability).

## Root files

- `AGENTS.md` — global behavioral guidelines for coding agents in this repo (process, code quality scope table, documentation, LLM API usage, sub-agents).
- `copilot-instructions.md.example` — example Copilot instructions file.
- `ghostty_config.txt` — terminal (Ghostty) config.
- `terminal_auto_approvals.json` — terminal command auto-approval rules.
