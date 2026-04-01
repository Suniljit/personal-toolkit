---
name: lint
description: Runs Ruff and ty on a specified file or folder in a uv-managed Python project, fixes issues, and reruns until clean. Use when the user wants formatting, linting, and type checking for a target path.
---

When running Python quality checks, always follow this workflow:

1. Use the project environment: Run everything through `uv run` so the pinned versions from `pyproject.toml` and `uv.lock` are used
2. Require or infer a target path: Run checks against the file or folder the user specifies. If no path is given, default to `.`
3. Run Ruff first: Execute lint autofixes and formatting before type checking
4. Fix and rerun Ruff: If Ruff still reports issues after autofix/formatting, fix them and rerun until clean
5. Run ty next: Execute type checking only after Ruff passes
6. Fix and rerun ty: If ty reports issues, fix them and rerun until clean
7. Keep commands centralized: Prefer calling taskipy tasks from `pyproject.toml` instead of duplicating raw commands in multiple places

Project setup expectations:

```toml
[dependency-groups]
dev = [
  "ruff",
  "ty",
  "taskipy",
]

[tool.taskipy.tasks]
format = "ruff check --fix {args} && ruff format {args}"
typecheck = "ty check {args}"
```

Execution rules:

- Run `uv sync` before checks if dependencies may not be installed
- For Ruff, use:
  - `uv run task format -- {path}`
- For ty, use:
  - `uv run task typecheck -- {path}`
- The `--` is required so taskipy passes the target path into `{args}`
- Do not rely on globally installed `ruff` or `ty`
- Do not nest `uv run` inside the task definitions if the task itself is already invoked via `uv run task ...`

Expected behavior:

- If the user says `/skill src/feature_x`, run the workflow on `src/feature_x`
- If the user says `/skill app/main.py`, run the workflow on `app/main.py`
- If the user provides no target, run the workflow on `.`

When reporting back:

- State which path was checked
- Summarize what Ruff fixed
- Summarize any manual fixes needed after Ruff
- Summarize ty errors found and fixed
- Confirm whether the final Ruff and ty runs passed cleanly

Keep the workflow practical, deterministic, and scoped only to the requested path.
