---
name: setup-pre-commit
description: Set up git hooks with the pre-commit framework — commit-time linting and push-time type checking/tests.
disable-model-invocation: true
---

# Setup Pre-Commit Hooks

Uses the [pre-commit](https://pre-commit.com) framework (not Husky), so hooks work across languages, not just JS. Lint hooks run at the `pre-commit` stage (fast, staged-files-only); typecheck and test hooks run at the `pre-push` stage (slower, whole-repo).

## Steps

### 1. Map the repo's languages

Scan the repo for language markers, per directory — a monorepo with `frontend/` (JS/TS) and `backend/` (Python) needs different hooks in each. Look for:

- `package.json` → JS/TS
- `pyproject.toml`, `requirements.txt`, `setup.py` → Python
- `Cargo.toml` → Rust
- `go.mod` → Go

Check the repo root and one level into any `frontend/`, `backend/`, `apps/*`, `packages/*`, `services/*`-style directories. Don't assume a single-language repo — a directory with no marker for a listed language may still use another language; note it and ask the user rather than silently skipping it.

Done when you have a map of `directory → language(s)` covering every top-level source directory.

### 2. Install pre-commit

Check if `pre-commit` is already on PATH (`pre-commit --version`). If not, install it — prefer `pipx install pre-commit`, falling back to `pip install pre-commit` or `brew install pre-commit` if `pipx` isn't available.

### 3. Write `.pre-commit-config.yaml`

If one already exists, extend it rather than overwriting. Set:

```yaml
default_install_hook_types: [pre-commit, pre-push]
```

For each language found in step 1, add its lint hook (`pre-commit` stage, the default) scoped to its directory with `files:`. Read [`reference/languages.md`](reference/languages.md) for the hook `repo`/`id` per language — don't guess hook repos or IDs from memory. Pin `rev` to any tag for now; run `pre-commit autoupdate` after step 4 to bump every `rev` to its real latest release instead of hand-picking versions.

### 4. Add pre-push hooks for typecheck and test

For each language, add `local` hooks with `stages: [pre-push]` that run its typecheck and test command, scoped to its directory (`files:` + `cd`-ing into the directory in `entry`). [`reference/languages.md`](reference/languages.md) has the typecheck/test command per language — this covers pytest for Python and the equivalent per other language (`cargo test`, `go test`, the repo's configured JS test runner, etc). If a language has no typecheck step (e.g. plain JS with no `tsconfig.json`), omit that hook rather than inventing one.

### 5. Pin versions and install the git hooks

```bash
pre-commit autoupdate
pre-commit install --install-hooks
pre-commit install --hook-type pre-push
```

`autoupdate` rewrites every `rev` in the config to that hook's real latest release.

### 6. Verify

- `pre-commit run --all-files` succeeds (pre-commit stage: lint hooks)
- `pre-commit run --hook-stage pre-push --all-files` succeeds (pre-push stage: typecheck + test hooks)

Fix any hook that fails before proceeding — a red verify step means the config is wrong, not that the check should be skipped.

### 7. Commit

Stage `.pre-commit-config.yaml` and any created language configs (e.g. a default `pyproject.toml` `[tool.ruff]` section if one didn't exist). Commit with message: `Add pre-commit hooks (lint on commit, typecheck+test on push)`.
