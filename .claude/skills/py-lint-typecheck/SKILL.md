---
name: py-lint-typecheck
description: >
  Run Python linting, formatting, and type checking using ruff and ty on a specified folder or file path.
  Use this skill whenever the user asks to lint, format, type-check, fix code quality issues, or run
  ruff/ty on their Python project. Also trigger when the user says things like "clean up my code",
  "fix lint errors", "check types", "run the linter", "format my Python files", or "run taskipy tasks".
  Always use this skill — don't try to guess ruff/ty invocations from scratch.
---

# Python Lint & Type Check Skill

Runs `ruff` (lint + format) and `ty` (type checking) on a target path, then attempts to fix any remaining issues.

## Tool requirements

- `bash_tool` — required to install deps and run commands

---

## Workflow

### Step 1 — Confirm the target path

The user must specify a folder or file to run this on. If they haven't, ask:

> "Which folder or file should I run linting and type checking on?"

### Step 2 — Verify dependencies via pyproject.toml

Locate the `pyproject.toml` by searching the target path and walking up to parent directories:

```bash
# search from target path upward
path=<target_path>; while [ "$path" != "/" ]; do [ -f "$path/pyproject.toml" ] && echo "$path/pyproject.toml" && break; path=$(dirname "$path"); done
```

**Case A — No `pyproject.toml` found:**
Stop and inform the user:
> "I couldn't find a `pyproject.toml` in or near `<target_path>`. This skill relies on your project's `pyproject.toml` to manage `ruff` and `ty`. Please point me to the project root, or create a `pyproject.toml` first."

Do not proceed.

**Case B — `pyproject.toml` exists but doesn't list `ruff` and/or `ty`:**
Add the missing tools as dev dependencies using `uv`:

```bash
cd <project_root> && uv add ruff ty --dev
```

Confirm they were added before continuing.

**Case C — `pyproject.toml` exists and already includes `ruff` and `ty`:**
No installation needed. Use `uv run` in Steps 3 and 4 to invoke the project's pinned versions.

### Step 3 — Run ruff (lint + autofix + format)

```bash
cd <project_root> && uv run ruff check --fix <target_path>
cd <project_root> && uv run ruff format <target_path>
```

- `ruff check --fix` auto-fixes all safe fixable lint violations
- `ruff format` applies opinionated formatting

If violations remain after `--fix`, try a second pass with unsafe fixes:

```bash
cd <project_root> && uv run ruff check --unsafe-fixes --fix <target_path>
```

If violations still remain after both passes, collect the output and proceed to Step 5.

### Step 4 — Run ty (type checking)

```bash
cd <project_root> && uv run ty check <target_path>
```

Collect all output. ty does not auto-fix — errors must be fixed manually (Step 5).

### Step 5 — Fix remaining issues

If there are remaining ruff violations or ty errors after the automated passes:

1. Read each error carefully
2. Open the relevant file(s) with `view` or `bash_tool`
3. Apply fixes using `str_replace` or `create_file` as appropriate
4. Re-run the failing tool to confirm the fix

Repeat until both `uv run ruff check <target_path>` and `uv run ty check <target_path>` exit cleanly (exit code 0).

### Step 6 — Report results

Summarise what was done:
- How many ruff issues were auto-fixed
- How many ruff issues required manual fixes (and what they were)
- How many ty errors were found and fixed
- Confirm final clean run

---

## Tips & edge cases

- If the project has its own `pyproject.toml` with `[tool.ruff]` or `[tool.ty]` config, ruff/ty will pick it up automatically — don't override it.
- If `ruff check --fix` keeps cycling (fixes introduce new errors), cap at 3 rounds and report what's left.
- If ty reports errors in third-party packages (e.g. inside `site-packages`), note them but don't try to fix them — those are upstream issues.
- If the target path doesn't exist, report it clearly and stop.