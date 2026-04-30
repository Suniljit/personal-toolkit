---
name: smart-git-commit
description: Intelligently group all changed files in a branch into logically sequenced commits, each with a meaningful commit message. Use this skill when the user wants to commit multiple files at once with smart grouping, says things like "smart commit", "group my changes into commits", "git-smart-commit", "batch commit my changes", "commit everything intelligently", or "organise my changes into commits". Also trigger when the user has many changed files and wants them committed in a logical order following developer workflow conventions (plans → config → core logic → tests → docs). Always use this skill — don't try to handle multi-file grouped commits from scratch without it.
---

# Git Smart Commit Skill

Scans all changed files in the current branch, presents them for selection, reads each file to understand its purpose, groups them into logically sequenced commits, confirms the full plan with the user, then executes the commits one by one.

---

## Workflow

### Step 1: Discover changed files

Find the repo root and list all changed/untracked files relative to HEAD (or the branch base):

```bash
git rev-parse --show-toplevel
git status --short
```

Also check for changes vs the branch base (files changed since branching off):

```bash
git diff --name-status $(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null || echo HEAD) 2>/dev/null || git status --short
```

Present a **numbered list** of all changed/untracked files to the user:

```
I found the following changed files:

  1. src/auth/jwt.py              (modified)
  2. src/auth/refresh.py          (new file)
  3. src/models/user.py           (modified)
  4. tests/test_auth.py           (new file)
  5. config/settings.py           (modified)
  6. docs/auth.md                 (new file)
  7. README.md                    (modified)

Which files would you like to include? Reply with numbers (e.g. "1, 3"), "all", or a range like "1-3".
```

Wait for the user's selection. Accept:
- `all` → include every file listed
- `1, 3, 5` or `1 3 5` → specific items
- `1-5` → a range
- `2` → just one file

If a number doesn't exist, point it out and ask the user to re-select.

---

### Step 2: Read and understand each selected file

For each selected file, read its content to understand what it does:

```bash
# For modified tracked files — show the diff
git -C <repo-root> diff HEAD -- <file>

# For new untracked files — show full content
cat <file>

# For staged files
git -C <repo-root> diff --cached -- <file>
```

Also check file paths and names for context (e.g. `migrations/`, `tests/`, `*.config.js`, `README.md`).

---

### Step 3: Group files into logical commits

Using the file content and paths, group files into commits following this **sequencing convention** (order from first to last commit):

| Priority | Group type | Examples |
|---|---|---|
| 1 | **Plans / specs / scaffolding** | `PLAN.md`, `SPEC.md`, `TODO.md`, `architecture.*`, `schema.*` |
| 2 | **Configuration & environment** | `*.config.*`, `.env.*`, `settings.*`, `constants.*`, `pyproject.toml`, `package.json`, `Dockerfile`, `*.yaml`/`*.yml` (non-CI) |
| 3 | **Database / data models** | `models/`, `migrations/`, `schema.sql`, ORM model files |
| 4 | **Core logic / features** | Business logic, services, controllers, utilities — grouped by sub-feature |
| 5 | **API / interfaces** | Routes, endpoints, views, serializers — grouped by sub-feature |
| 6 | **Tests** | Unit tests, integration tests — grouped with the feature they test if closely related, otherwise as a batch |
| 7 | **CI / build / tooling** | `.github/`, `Makefile`, `scripts/`, `*.sh` |
| 8 | **Documentation** | `docs/`, `*.md` (non-README) |
| 9 | **README** | `README.md` always last |

**Grouping rules:**
- Files that belong to the **same sub-feature or task** go in the **same commit** (e.g. `auth/jwt.py` + `auth/refresh.py` are both auth features)
- **Configuration changes** that are required by a feature should be committed just before or alongside that feature, not lumped with all other config
- **Tests** for a specific feature can be grouped with that feature's commit, or batched together if they span multiple features
- **Plans and specs** always go first — they describe intent before implementation
- **README** always goes last — it documents the finished state

If a file doesn't obviously fit a group, use its path and content to make the best judgment call.

---

### Step 4: Present the full commit plan — MANDATORY STOP

> ⛔ **DO NOT run any `git add` or `git commit` commands until the user explicitly approves the plan in this step.**

Present the proposed commit sequence clearly:

```
Here's my proposed commit plan (6 commits, in order):

──────────────────────────────────────
Commit 1 of 6
  Files: config/settings.py
  
  chore(config): add JWT token expiry and refresh settings
──────────────────────────────────────
Commit 2 of 6
  Files: src/models/user.py

  feat(models): add refresh_token field to User model
──────────────────────────────────────
Commit 3 of 6
  Files: src/auth/jwt.py, src/auth/refresh.py

  feat(auth): implement JWT issuance and refresh token rotation

  Introduces stateless JWT auth with short-lived access tokens.
  Refresh tokens rotate on use to limit exposure window.
──────────────────────────────────────
Commit 4 of 6
  Files: tests/test_auth.py

  test(auth): add unit tests for JWT issuance and token rotation
──────────────────────────────────────
Commit 5 of 6
  Files: docs/auth.md

  docs: add authentication flow documentation
──────────────────────────────────────
Commit 6 of 6
  Files: README.md

  docs: update README with auth setup instructions
──────────────────────────────────────

Does this plan look good? You can say "ok" to proceed, or give me feedback to adjust the groupings or messages.
```

**Wait for an explicit "ok" or clear approval** before proceeding. Any feedback, questions, or partial responses count as a "no" — update the plan and show it again.

If the user asks to:
- **Merge commits** → combine the files and write a new message covering both
- **Split a commit** → separate into two entries with distinct messages
- **Reorder commits** → renumber and re-present
- **Change a message** → update and re-present the full plan

Always re-present the **full updated plan** and wait for fresh approval after any change.

---

### Step 5: Execute commits sequentially

Once the user says "ok":

For each commit in order, without pausing between them:

```bash
# Stage only the specific files for this commit
git -C <repo-root> add -- <file1> <file2> ...

# Commit with the agreed message
git -C <repo-root> commit -m "<subject>" -m "<body>"
```

After all commits are done, show a summary:

```bash
git -C <repo-root> log --oneline -<n>   # show all commits just made
```

---

## Commit message format

Follow Conventional Commits:

```
<type>(<optional scope>): <short summary>

<optional body — explain WHY, not WHAT, if non-obvious>
```

**Types**: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`, `perf`, `ci`, `build`

Rules:
- Subject line ≤ 72 characters, imperative mood ("add", not "added")
- Be specific — avoid vague messages like "update files"
- Body only when the WHY is non-obvious

---

## Edge cases

| Situation | How to handle |
|---|---|
| File has no diff vs HEAD | Tell the user, don't include it silently |
| Only one file selected | Still present the plan with a single commit for confirmation |
| All files belong to one logical unit | Single commit is fine — say so |
| Binary files (images, pdfs) | Note it's binary; write message from filename/context |
| Repo in detached HEAD state | Warn the user before committing |
| File appears in multiple logical groups | Use its content to assign it to the most dominant group |
| User selects a number that doesn't exist | Point out the invalid selection and ask to re-select |
| Merge conflict markers present | Warn the user — don't commit files with unresolved conflicts |

---

## Important constraints

- **Never commit without explicit user "ok" in Step 4.** This is the most important rule. Do not skip or abbreviate the confirmation step.
- **Only stage the files the user selected.** Never stage additional files not in the plan.
- Do not push. Commit locally only unless the user explicitly asks to push.
- Do not modify `.gitignore` or any other file as part of this workflow.
- Do not use any third-party git libraries — interact with git directly via the command line.