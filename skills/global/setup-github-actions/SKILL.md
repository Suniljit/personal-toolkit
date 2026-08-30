---
name: setup-github-actions
description: Set up a GitHub Actions workflow that lints, type-checks, and tests every PR.
disable-model-invocation: true
metadata:
  opencode/autoinvoke: "false"
---

# Setup GitHub Actions CI

One workflow, triggered on `pull_request`, with one job per language found in the repo. Each job lints, type-checks, and tests only its own directory, so a monorepo doesn't rebuild languages it didn't touch. "Before the PR can be approved" is a branch protection setting, not something the workflow file itself can do — step 4 handles it.

## Steps

### 1. Map the repo's languages

Scan the repo for language markers, per directory — a monorepo with `frontend/` (JS/TS) and `backend/` (Python) needs a separate job for each. Look for:

- `package.json` → JS/TS
- `pyproject.toml`, `requirements.txt`, `setup.py` → Python
- `Cargo.toml` → Rust
- `go.mod` → Go

Check the repo root and one level into any `frontend/`, `backend/`, `apps/*`, `packages/*`, `services/*`-style directories. A directory with no marker for a listed language may still use another language; note it and ask the user rather than silently skipping it.

Done when you have a map of `directory → language(s)` covering every top-level source directory.

### 2. Write the workflow

Create `.github/workflows/ci.yml` (if one already exists with PR-triggered checks, extend it rather than adding a duplicate). Set:

```yaml
name: CI
on:
  pull_request:
```

Add one job per `directory → language` pair from step 1, named `<dir>-<language>` (e.g. `backend-python`), each with `defaults.run.working-directory: <dir>`. Read [`reference/languages.md`](reference/languages.md) for the setup action, cache config, and lint/typecheck/test steps per language — don't guess action versions or commands from memory. Omit the typecheck step for a language/directory that has none (e.g. plain JS with no `tsconfig.json`) rather than inventing one.

### 3. Verify

Push the workflow on a branch and open (or update) a PR, then confirm every job appears and goes green:

```bash
gh pr checks --watch
```

Fix any job that fails before proceeding — a red check means the workflow is wrong, not that the check should be skipped.

### 4. Require the checks before merge

This is what makes the checks block approval — without it, the workflow runs but a PR can still merge with red checks. It edits the repo's branch protection, a shared setting, so confirm with the user before applying and tell them which branch and which checks you're about to require:

```bash
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --field required_status_checks[strict]=true \
  --field 'required_status_checks[contexts][]=<job-name-1>' \
  --field 'required_status_checks[contexts][]=<job-name-2>' \
  --field enforce_admins=true \
  --field required_pull_request_reviews[required_approving_review_count]=1 \
  --field restrictions=null
```

Replace `main` with the repo's default branch and `<job-name-*>` with the job names from step 2 (must match exactly — GitHub matches required checks by job name). If the repo already has branch protection configured, merge these fields into the existing rule (`gh api repos/{owner}/{repo}/branches/main/protection` to read it first) instead of overwriting it.

### 5. Commit

Stage `.github/workflows/ci.yml` and commit with message: `Add GitHub Actions CI (lint, typecheck, test on PR)`.
