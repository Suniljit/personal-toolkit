---
name: smart-commit-git
description: Group all changed files into logically sequenced commits with meaningful messages. 
disable-model-invocation: true
---

# Git Smart Commit Skill

Scans all changed files, reads each to understand its purpose, groups them into logically sequenced commits, presents the plan immediately, confirms, then executes.

---

## Step 1: Discover changed files

```bash
git rev-parse --show-toplevel
git status --short
```

**Find the branch base** (use the first that succeeds):

```bash
# 1. Upstream tracking branch
BASE=$(git merge-base HEAD @{upstream} 2>/dev/null)

# 2. Nearest ancestor branch tip
if [ -z "$BASE" ]; then
  BASE=$(git log --oneline HEAD \
    --not $(git for-each-ref --format='%(objectname)' refs/heads/ \
            | grep -v $(git rev-parse HEAD)) 2>/dev/null \
    | tail -1 | awk '{print $1}')
fi

# 3. Fallback: working tree only
[ -z "$BASE" ] && git status --short
```

Combine and deduplicate committed + uncommitted changes — every file found here goes into the plan, no selection step:

```bash
git diff --name-status $BASE HEAD   # committed on this branch
git status --short                  # uncommitted
```

If no changed files are found, tell the user and stop.

---

## Step 2: Read each changed file

```bash
git diff $BASE -- <file>          # modified tracked files
cat <file>                        # new untracked files
git diff --cached -- <file>       # staged files
```

---

## Step 3: Group into logical commits

Sequence commits in this priority ladder — lower priority number commits first, unless a Notes exception below says otherwise:

| Priority | Group | Examples | Notes |
|---|---|---|---|
| 1 | Plans / specs | `PLAN.md`, `SPEC.md`, `architecture.*`, any file under a `specs/` (or similarly named specs/plans) directory — e.g. `specs/feat-add-csv-export.md` | |
| 2 | Config / environment | `*.config.*`, `settings.*`, `pyproject.toml`, `Dockerfile` | If required by a specific feature, move with that feature's commit instead of here |
| 3 | Data models / migrations | `models/`, `migrations/`, `schema.sql` | |
| 4 | Core logic / features | Services, controllers, utilities | Grouped by sub-feature, not as one giant commit |
| 5 | API / interfaces | Routes, endpoints, views, serializers | |
| 6 | Tests | Test files for the features above | Group with the feature it covers when closely related; otherwise batch separately here |
| 7 | CI / build / tooling | `.github/`, `Makefile`, `scripts/` | |
| 8 | Docs | `docs/`, `*.md` (non-README) | |
| 9 | README | `README.md` | Always last |

---

## Step 4: Present plan and wait for approval

> ⛔ Do NOT run `git add` or `git commit` until the user explicitly approves.

Each commit block **must** show the full proposed commit message — subject line, body, and files. Use this format exactly:

```
Here's my proposed commit plan (N commits, in order):

──────────────────────────────────────
Commit 1 of N
  Subject:  chore(config): add JWT token expiry and refresh settings
  Body:     Adds JWT_EXPIRY and REFRESH_TOKEN_TTL env vars read from the
            environment. Fixes prompts_path resolution that was previously
            ignoring the PROMPTS_DIR override.
  Files:    config/settings.py
──────────────────────────────────────
Commit 2 of N
  Subject:  feat(auth): implement JWT issuance and refresh token rotation
  Body:     Issues signed JWTs on login using the HS256 algorithm.
            Refresh tokens are single-use and rotated on each redemption
            to prevent replay attacks.
  Files:    src/auth/jwt.py (new), src/auth/refresh.py (new)
──────────────────────────────────────
...

Does this look good? Say "ok" to proceed, or give feedback to adjust.
```

- `Subject:` — the single-line summary passed as the first `-m`. Conventional Commits format: `<type>(<scope>): <summary>` (≤ 72 chars, imperative mood).
- `Body:` — one short paragraph explaining *why* this change is being made and any non-obvious details. Wrap at 72 chars. Omit only if the subject is fully self-explanatory (e.g. a `.gitignore` tweak). Passed as the second `-m`.
- `Files:` — all files in this commit, with `(new)` / `(deleted)` annotations where relevant.

Wait for explicit approval. Any feedback = revise and re-present the full plan. Accept merge/split/reorder/message-change requests and re-present before proceeding.

---

## Step 5: Execute commits

```bash
git -C <repo-root> add -- <file1> <file2> ...
git -C <repo-root> commit -m "<subject>" -m "<body>"
```

After all commits:

```bash
git -C <repo-root> log --oneline -<n>
```

---

## Commit message format

Follow Conventional Commits: `<type>(<scope>): <summary>` (subject ≤ 72 chars, imperative mood). Body only when the WHY is non-obvious.

Types: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`, `perf`, `ci`, `build`

---

## Edge cases

| Situation | Action |
|---|---|
| File unchanged vs branch base | Tell user; exclude |
| No changed files found | Tell user; stop — nothing to plan |
| Single changed file | Still show plan and confirm |
| All files one logical unit | Single commit is fine |
| Binary files | Write message from filename/path |
| Detached HEAD | Warn before committing |
| Unresolved merge conflicts | Warn; don't commit |
| Stacked branches | Use `@{upstream}` or nearest ancestor — never `main` directly; only show files changed on current branch |
| Ambiguous base | Show detected base commit and ask user to confirm |

---

## Constraints

- Commit locally only — do not push unless explicitly asked.
- Do not modify `.gitignore` or any unselected file.
- Use git CLI directly — no third-party libraries.