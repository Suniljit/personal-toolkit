---
name: py-lint-typecheck
description: >
  Lint, format, and type-check Python using ruff and ty. Trigger on: "clean up
  my code", "fix lint errors", "check types", "format my Python files", "run
  ruff/ty", or any request to improve Python code quality. Always use this
  skill — don't guess ruff/ty invocations.
---

# Python Lint & Type Check Skill

Run `ruff` (lint + format) and `ty` (type checking) on a target path, then fix remaining issues.

Use Codex-native tools: run commands with `exec_command` (prefer `uv run`), inspect files with shell reads such as `sed`, `nl`, or `rg`, and edit files with `apply_patch`. Do not use Claude Code-only tool names such as `view`, `str_replace`, or `create_file`.

## Approval Gates

Preserve these gates. Do not bypass them with alternate commands.

- Ask before adding dependencies with `uv add ruff ty --dev` if `ruff` or `ty` is missing from the project.
- Ask before running `ruff check --unsafe-fixes --fix`.
- Follow Codex sandbox escalation rules: if a required command fails because of sandboxing, network access, or install/download restrictions, retry the same command with `sandbox_permissions="require_escalated"` and a concise `justification`.
- Ask before taking any destructive action outside the normal ruff/format/manual-fix workflow.

## Workflow

### Step 1 — Confirm Target Path

If the user has not specified a file or folder, ask: *"Which folder or file should I lint?"*

If the target path does not exist, report that and stop.

### Step 2 — Locate `pyproject.toml`

Walk up from the target path until found:

```bash
path=<target_path>; while [ "$path" != "/" ]; do [ -f "$path/pyproject.toml" ] && echo "$path/pyproject.toml" && break; path=$(dirname "$path"); done
```

- **Not found**: stop and ask the user to point to their project root or create a `pyproject.toml`.
- **Found, missing `ruff` or `ty`**: ask for approval, then run `cd <project_root> && uv add ruff ty --dev`.
- **Found, already has `ruff` and `ty`**: proceed with `uv run`.

Use the project root as the working directory for all commands. Pass the target path exactly as scoped by the user, adjusted only as needed to be valid from the project root.

### Step 3 — Run Ruff

Run the normal auto-fix and formatter pass:

```bash
uv run ruff check --fix <target_path>
uv run ruff format <target_path>
```

If violations remain after the normal pass, ask for approval before trying unsafe fixes:

```bash
uv run ruff check --unsafe-fixes --fix <target_path>
```

Cap ruff at 3 rounds if fixes cycle. Collect any remaining output for Step 5.

### Step 4 — Run Ty

```bash
uv run ty check <target_path>
```

`ty` does not auto-fix. Collect errors for Step 5.

### Step 5 — Fix Remaining Issues

For each remaining ruff violation or ty error:

1. Inspect the relevant file and nearby lines.
2. Make the smallest manual edit with `apply_patch`.
3. Re-run the specific failing tool to confirm the issue is gone.

Repeat until both `ruff` and `ty` exit cleanly with code 0, or until a remaining issue is outside the target scope or requires a user decision.

## Codex Output Style

Keep user-visible output concise and useful in Codex:

- Share short progress updates while working, especially before dependency installs, unsafe fixes, and manual edits.
- Do not paste full command logs unless the user asks. Summarize the important lines: counts, failing rule codes, file paths, and final status.
- When reporting failures, include the command, exit status, and the smallest relevant excerpt.
- In the final response, include:
  - `ruff`: auto-fixed count if available, manual fixes made, and final status.
  - `ty`: errors found/fixed and final status.
  - Any skipped or unresolved issues, with the approval or user decision needed.

## Edge Cases

- `[tool.ruff]` and `[tool.ty]` config in `pyproject.toml` is picked up automatically. Do not override project config unless the user asks.
- `ty` errors inside `site-packages` are upstream issues. Note them but do not fix them.
- Keep changes surgical: do not refactor unrelated code while fixing lint or type errors.
