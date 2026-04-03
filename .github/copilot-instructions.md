---
applyTo: "**"
---
# Copilot Instructions

## Core Rules
- No emojis, no meta-commentary, no filler.
- Write clean, self-explanatory code.
- All functions require docstrings.

## Code Quality
- Follow Single Responsibility Principle.
- Keep functions small and flat, prefer early returns.
- Naming:
  - PascalCase: classes/types
  - snake_case: functions/variables
  - ALL_CAPS: constants
  - `_prefix`: private members

## Typing
- Type hints required for all functions.
- Use `list[str]`, `dict[str, int]`, `str | None`.
- Use `collections.abc` where applicable.
- No `Any`. Must pass `ty`.

## Errors
- Never ignore errors.
- Fix immediately before continuing.
- Use specific exceptions.
- Use subagents for complex debugging.

## Testing & Logging
- Use `pytest`, test core logic, mock externals.
- Use `loguru` with contextual logging.

## Workflow
- Default to plan mode unless trivial.
- Break work into steps before coding.
- Use subagents liberally.
- Verify before completion, tests, behavior, outputs.
- Prefer elegant solutions.
- Fix bugs autonomously.

## Improvement
- Record lessons in `_lessons/lessons.md` after mistakes.

## Principles
- Simplicity first.
- Minimal, high-impact changes.
- No temporary fixes.
- Production-quality code only.