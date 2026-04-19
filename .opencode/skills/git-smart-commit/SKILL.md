---
name: git-smart-commit
description: Intelligently group changed file hunks into multiple logical commits by sub-feature, generate a commit message for each group, confirm with the user, then execute commits sequentially using hunk-level staging. Use this skill whenever the user wants to commit multiple files intelligently, stage changes into grouped commits, auto-group files by feature or concern, or says things like "smart commit", "group my changes", "commit my changes into logical groups", "multi-commit", or "commit related files together". Also trigger when the user says "commit all my changes" or "commit everything" and there are multiple changed files — grouping is almost always better than one big commit. Always use this skill — don't try to handle multi-commit grouping from scratch without it.
---

# Git Smart Commit Skill

Stages and commits changed hunks across one or more logical sub-feature commits, each with its own commit message. Designed for AI-agent-generated codebases where a single file is often modified for multiple independent reasons, making file-level grouping insufficient — hunk-level staging is the default.

## Key concept: hunk-level staging

A single file may appear in multiple commits. For example, `config.py` touched by both a database sub-feature and an auth sub-feature will contribute different hunks to each commit. This is done using `git apply --cached` with filtered patch files — not interactive `git add -p`.

---

## Workflow

### Step 1: Locate the repository

```bash
git rev-parse --show-toplevel
# or
git -C <dir> rev-parse --show-toplevel
```

---

### Step 2: Discover all changed files

```bash
git -C <repo-root> status --short
git -C <repo-root> diff HEAD --name-only
git -C <repo-root> ls-files --others --exclude-standard
```

If there are no changes, tell the user and stop.

---

### Step 3: Present the file list and ask for selection

Show a numbered list with status:

```
Changed files:

  1. src/auth/login.py          (modified)
  2. src/auth/logout.py         (modified)
  3. src/config.py              (modified)
  4. src/models/user.py         (modified)
  5. tests/test_auth.py         (modified)
  6. pyproject.toml             (modified)

Which files to include? Reply with "all", numbers like "1, 3, 5", or a range like "1-4".
```

Wait for reply. Validate selections — flag out-of-range numbers and re-ask.

---

### Step 4: Extract and parse diffs into hunks

For each selected file, extract the full diff and parse it into individual hunks:

```bash
# Modified files
git -C <repo-root> diff HEAD -- <file>

# Staged files
git -C <repo-root> diff --cached -- <file>

# New untracked files (treat entire file as one hunk)
git -C <repo-root> diff --no-index /dev/null <file>
```

Parse each diff into hunks using the `@@` markers. Each hunk should be understood in terms of:
- What it does (read the actual lines changed)
- Which sub-feature or concern it likely belongs to

**Flagging mixed hunks:** If a hunk appears to touch two unrelated concerns within the same block of lines (e.g., an AI agent interleaved two features in one function), flag it explicitly to the user:

```
⚠️  src/config.py hunk @@ -45,12 +45,18 @@ appears to mix database config
    and logging config changes. I'll assign it to the most dominant concern,
    but you may want to review it manually.
```

---

### Step 5: Propose commit groups

Group hunks (not files) into logical sub-feature commits. Each commit should represent one coherent unit of change.

**Grouping heuristics:**
- Group by sub-feature: all hunks implementing the same behaviour belong together, even across files
- Configuration/dependency changes (e.g. `pyproject.toml`, `config.py`) belong with the sub-feature that introduced them
- Tests belong with the source they test
- Shared utility changes that serve multiple sub-features: assign to the most dominant sub-feature, or make a separate `refactor`/`chore` commit
- Documentation belongs with the feature it documents, or grouped together if generic

**Present the proposal as a compact, scannable list:**

```
Proposed commits (3):

  #1  feat(auth): add JWT refresh token support
      src/auth/login.py        add refresh() method
      src/auth/logout.py       invalidate refresh token on logout
      src/models/user.py       add refresh_token field
      src/config.py            add JWT_REFRESH_SECRET config
      pyproject.toml           add PyJWT dependency

  #2  test(auth): add unit tests for JWT refresh flow
      tests/test_auth.py       new test class for refresh flow

  #3  chore: update project metadata
      pyproject.toml           bump version
      README.md                update auth section

Edit a commit, move a hunk, split or merge groups, or say "go ahead" to commit.
```

Note: a file appearing in multiple commits is expected and correct.

---

### Step 6: Iterate on feedback

> ⛔ Do NOT run any `git add`, `git apply`, or `git commit` commands until Step 7.

Accept and apply these requests:
- Move a hunk from one commit to another ("move the config.py hunk to #1")
- Rewrite a commit message
- Split a commit into two
- Merge two commits into one
- Reorder commits
- Remove a hunk from all commits (exclude it)

Re-present the full updated plan after every change. Keep iterating until the user approves.

---

### Step 7: Execute commits sequentially

Once the user says "go ahead" / "yes" / "ship it" or equivalent — that is the confirmation. Do not ask again.

Process each commit **in order**:

#### For each commit:

**1. Build a patch file containing only the approved hunks for this commit:**

```bash
# Start from the full diff of each involved file
git -C <repo-root> diff HEAD -- <file> > /tmp/full_<file_slug>.patch

# Then filter to only the hunks assigned to this commit.
# Write the filtered patch to a temp file:
# /tmp/commit_<n>_<file_slug>.patch
```

To filter hunks, parse the patch file and extract only the `@@` blocks assigned to this commit, preserving the file header lines (`---`, `+++`). Reconstruct a valid unified diff.

**2. Stage the filtered patch:**

```bash
git -C <repo-root> apply --cached /tmp/commit_<n>_<file_slug>.patch
```

Do this for each file contributing hunks to this commit.

**3. For entirely new (untracked) files assigned to this commit:**

```bash
git -C <repo-root> add -- <file>
```

**4. Commit:**

```bash
git -C <repo-root> commit -m "<subject>" -m "<body if any>"
```

**5. Confirm:**

```bash
git -C <repo-root> log --oneline -1
```

Show the one-line confirmation before moving to the next commit.

---

### Step 8: Final summary

After all commits:

```
Done! Created 3 commits:

  a1b2c3d  feat(auth): add JWT refresh token support
  e4f5g6h  test(auth): add unit tests for JWT refresh flow
  i7j8k9l  chore: update project metadata
```

---

## Commit message format

Follow Conventional Commits:

```
<type>(<optional scope>): <short summary>

<optional body — explain WHY, not WHAT>
```

**Types:** `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`, `perf`, `ci`, `build`

Rules:
- Subject ≤ 72 characters, imperative mood ("add", not "added")
- Be specific — avoid "update files" or "fix stuff"
- Body is optional but useful for non-obvious changes

---

## Edge cases

| Situation | How to handle |
|---|---|
| A hunk spans two concerns | Flag it to the user; assign to dominant concern |
| Entire new file | Treat as a single hunk; assign to the sub-feature that introduced it |
| Only one logical group | Still follow the full workflow — one commit |
| Binary file | Note it's binary; write message based on filename/context; stage with `git add` |
| File has no diff vs HEAD | Exclude it; tell the user |
| Repo in detached HEAD state | Warn the user before proceeding |
| Nothing staged after apply | Tell the user and skip that commit |
| `git apply --cached` fails | Show the error; ask user whether to skip this hunk or assign it elsewhere |
| User wants to amend last commit | Out of scope; suggest `git commit --amend` manually |
| Files span multiple repos | Handle each repo as a separate session |

---

## Important constraints

- **Never commit without explicit user approval at Step 7.** No exceptions.
- **Never use `git add -A` or `git add .`** — always stage explicitly by patch or path.
- **Commits execute in the approved order.** Do not reorder during execution.
- Do not push. Local commits only unless the user explicitly asks.
- Do not modify `.gitignore` or any file outside the user's selected set.
- Do not use third-party git libraries — use git CLI directly.
- Clean up all `/tmp/` patch files after execution completes.