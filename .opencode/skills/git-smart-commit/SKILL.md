---
name: git-smart-commit
description: "Intelligently group changed file hunks into multiple logical commits by sub-feature, generate a commit message for each group, confirm with the user, then execute commits sequentially using hunk-level staging. Use this skill whenever the user wants to commit multiple files intelligently, stage changes into grouped commits, auto-group files by feature or concern, or says things like \"smart commit\", \"group my changes\", \"commit my changes into logical groups\", \"multi-commit\", or \"commit related files together\". Also trigger when the user says \"commit all my changes\" or \"commit everything\" and there are multiple changed files — grouping is almost always better than one big commit. Always use this skill — don't try to handle multi-commit grouping from scratch without it. IMPORTANT: When this skill triggers, do NOT ask the user what they want to do or request clarification — immediately begin Step 1 by locating the repository and discovering changed files. The skill is self-directing; jump straight in."
---

# Git Smart Commit Skill

Stages and commits changed hunks across one or more logical sub-feature commits, each with its own commit message. Designed for AI-agent-generated codebases where a single file is often modified for multiple independent reasons, making file-level grouping insufficient — hunk-level staging is the default.

## Key concept: hunk-level staging

A single file may appear in multiple commits. For example, `config.py` touched by both a database sub-feature and an auth sub-feature will contribute different hunks to each commit. This is done using `git apply --cached` with filtered patch files — not interactive `git add -p`.

---

## Workflow

> **Start immediately.** When this skill is invoked, do not ask the user what they want — go straight to Step 1.

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
- Shared utility changes that serve multiple sub-features: assign to the most dominant sub-feature, or make a separate `refactor`/`chore` commit
- Documentation belongs with the feature it documents, or grouped together if generic

**Commit ordering — follow this sequence strictly:**

```
1. Planning / spec docs     (plan.md, DESIGN.md, spec files, ADRs, etc.)
2. Sub-feature 1            (implementation + its config/deps)
3. Sub-feature 2            (implementation + its config/deps)
   ... (additional sub-features in logical dependency order)
N-1. Tests                  (all test files, regardless of which sub-feature they cover)
N.   README / docs          (README.md and other doc-only changes, always last)
```

If no planning doc or README is present, simply omit those slots. Never place tests before the implementation they test, and never place README changes before tests.

**First, generate a commit message for each group** before showing the proposal. Apply Conventional Commits format (see below) to every group, then present the full plan as a compact, scannable list:

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

### Step 6: Confirm or iterate

> ⛔ Do NOT run any `git add`, `git apply`, or `git commit` commands until Step 7.

The user should review the full list of commit messages and their associated files before anything is executed. Wait for explicit approval or edit requests.

Accept and apply these requests:
- Move a hunk from one commit to another ("move the config.py hunk to #1")
- Rewrite a commit message
- Split a commit into two
- Merge two commits into one
- Reorder commits
- Remove a hunk from all commits (exclude it)

Re-present the **complete updated list** (all commits, all messages, all files) after every change. Keep iterating until the user approves with "go ahead", "yes", "ship it", or equivalent.

---

### Step 7: Execute commits sequentially

Once the user approves in Step 6 — that is the confirmation. Do not ask again.

Process each commit **in order**:

#### For each commit:

**1. Determine staging strategy per file:**

For each file contributing to this commit, check whether **all** of that file's hunks are assigned to this commit (i.e. none of its hunks appear in other commits).

- **Whole-file staging** (all hunks belong to this commit):
  ```bash
  git -C <repo-root> add -- <file>
  ```
  Use this whenever possible — it's simpler and less error-prone.

- **Hunk-level staging** (only some hunks belong to this commit):
  ```bash
  # Extract the full diff for this file
  git -C <repo-root> diff HEAD -- <file> > /tmp/full_<file_slug>.patch

  # Filter to only the hunks assigned to this commit,
  # preserving the file header lines (---, +++)
  # Write to: /tmp/commit_<n>_<file_slug>.patch

  git -C <repo-root> apply --cached /tmp/commit_<n>_<file_slug>.patch
  ```
  Only use patch filtering when the file genuinely splits across commits.

**2. For entirely new (untracked) files assigned to this commit:**

```bash
git -C <repo-root> add -- <file>
```

**3. Commit:**

```bash
git -C <repo-root> commit -m "<subject>" -m "<body if any>"
```

**4. Confirm:**

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