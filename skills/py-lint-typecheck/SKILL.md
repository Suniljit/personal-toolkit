---
name: py-lint-typecheck
description: >
  Lint, format, and type-check Python using ruff and ty. Trigger on: "clean up
  my code", "fix lint errors", "check types", "format my Python files", "run
  ruff/ty", or any request to improve Python code quality. Always use this
  skill — don't guess ruff/ty invocations.
---

# Python Lint & Type Check Skill

Runs `ruff` (lint + format) and `ty` (type checking) on a target path, then fixes remaining issues.

Requires: `bash_tool`

## Workflow

### Step 1 — Confirm target path

If the user hasn't specified one, ask: *"Which folder or file should I lint?"*

### Step 2 — Locate pyproject.toml

Walk up from the target path until found:

```bash
path=<target_path>; while [ "$path" != "/" ]; do [ -f "$path/pyproject.toml" ] && echo "$path/pyproject.toml" && break; path=$(dirname "$path"); done
```

- **Not found** — stop and ask the user to point to their project root or create a `pyproject.toml`.
- **Found, missing ruff/ty** — add them: `cd <project_root> && uv add ruff ty --dev`
- **Found, already has ruff/ty** — proceed with `uv run`.

### Step 3 — Run ruff

```bash
cd <project_root> && uv run ruff check --fix <target_path>
cd <project_root> && uv run ruff format <target_path>
```

If violations remain, try one more pass with unsafe fixes:

```bash
cd <project_root> && uv run ruff check --unsafe-fixes --fix <target_path>
```

Cap at 3 rounds if fixes cycle. Collect any remaining output for Step 5.

### Step 4 — Run ty

```bash
cd <project_root> && uv run ty check <target_path>
```

ty doesn't auto-fix — collect errors for Step 5.

### Step 5 — Fix remaining issues

For each remaining ruff violation or ty error: `view` the file, fix with `str_replace` or `create_file`, re-run the tool to confirm. Repeat until both exit cleanly (exit code 0).

### Step 6 — Report

- ruff: auto-fixed count, manual-fixed count + what they were
- ty: errors found and fixed
- Confirm final clean run

## Edge cases

- `[tool.ruff]` / `[tool.ty]` config in `pyproject.toml` is picked up automatically — don't override.
- ty errors inside `site-packages` are upstream issues — note but don't fix.
- Non-existent target path → report and stop.