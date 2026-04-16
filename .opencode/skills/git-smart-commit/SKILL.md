---
name: git-smart-commit
description: Intelligently group changed files into multiple logical commits, generate a commit message for each group, confirm everything with the user, then execute commits sequentially. Use this skill whenever the user wants to commit multiple files intelligently, stage changes into grouped commits, auto-group files by feature or concern, or says things like "smart commit", "group my changes", "commit my changes into logical groups", "multi-commit", or "commit related files together". Also trigger when the user says "commit all my changes" or "commit everything" and there are multiple changed files — grouping is almost always better than one big commit. Always use this skill — don't try to handle multi-commit grouping from scratch without it.
---

# Git Smart Commit Skill

Stages and commits changed files across one or more logical groups, each with its own commit message. Designed for situations where a branch contains several unrelated or semi-related changes that deserve separate commits.

## Workflow

---

### Step 1: Locate the repository

Find the repo root from any provided paths, or default to the current working directory:

```bash
git rev-parse --show-toplevel
# or
git -C <dir> rev-parse --show-toplevel
```

---

### Step 2: Discover all changed files

Run the following to see everything changed, staged, or untracked:

```bash
git -C <repo-root> status --short
git -C <repo-root> diff HEAD --name-only
git -C <repo-root> ls-files --others --exclude-standard
```

If there are **no changes at all**, tell the user and stop.

---

### Step 3: Present the full file list and ask for selection

Show a numbered list of every changed file with its status:

```
I found the following changed files in your branch:

  1. src/auth/login.py          (modified)
  2. src/auth/logout.py         (modified)
  3. src/models/user.py         (modified)
  4. tests/test_auth.py         (modified)
  5. README.md                  (modified)
  6. requirements.txt           (untracked)

Which files would you like to commit? Reply with:
  • "all" — include everything
  • Numbers like "1, 3, 5" or a range like "1-4"
  • Or a mix: "1-3, 6"
```

**Wait for the user's reply** before continuing. Validate selections:
- If the user picks a number that doesn't exist, flag it and ask them to re-select.
- Accept "all" as shorthand for every listed file.

---

### Step 4: Inspect the diffs

For each selected file, read its diff to understand what changed:

```bash
# Modified/staged files
git -C <repo-root> diff HEAD -- <file>
git -C <repo-root> diff --cached -- <file>

# New untracked files
git -C <repo-root> diff --no-index /dev/null <file>
```

Read all diffs carefully before grouping. This is the most important input for generating good groups and messages.

---

### Step 5: Propose commit groups

Based on the diffs, group the selected files into **logical commits**. Each group should represent a single coherent unit of change — one reason to commit.

**Grouping heuristics:**
- Files that implement the same feature or fix belong together
- Test files belong with the source files they test
- Config/dependency updates (e.g. `requirements.txt`, `package.json`) belong with the feature that introduced them
- Documentation changes belong together, or with the feature they document
- Unrelated changes across different domains should be separate commits
- If in doubt, prefer smaller, more focused groups over large catch-all groups

**Do not commit all files in one group** unless they are genuinely all one change. The whole point of this skill is thoughtful separation.

Present the proposed grouping clearly, numbered in the order they will be committed:

```
Here's how I'd group these into commits:

┌─────────────────────────────────────────────────────────┐
│ Commit 1 of 3                                           │
│ feat(auth): add JWT refresh token support               │
│                                                         │
│ Introduces token rotation on refresh to reduce exposure │
│ window.                                                 │
│                                                         │
│ Files:                                                  │
│   • src/auth/login.py                                   │
│   • src/auth/logout.py                                  │
│   • src/models/user.py                                  │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ Commit 2 of 3                                           │
│ test(auth): add unit tests for JWT refresh flow         │
│                                                         │
│ Files:                                                  │
│   • tests/test_auth.py                                  │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ Commit 3 of 3                                           │
│ chore: update dependencies and docs for JWT support     │
│                                                         │
│ Files:                                                  │
│   • requirements.txt                                    │
│   • README.md                                           │
└─────────────────────────────────────────────────────────┘

Does this grouping look right? You can:
  • Say "ok" or "looks good" to proceed
  • Ask me to move files between groups
  • Edit a commit message
  • Split or merge groups
  • Reorder the commits
```

---

### Step 6: Iterate on feedback

> ⛔ **Do NOT run any `git add` or `git commit` commands until the user explicitly approves in Step 7.**

If the user requests changes:
- Move files between groups as requested
- Rewrite commit messages on request
- Split a group into two, or merge two groups into one
- Reorder commits if asked
- Re-present the full updated plan after every change

If the user edits a commit message, show the revised plan in full and ask for confirmation again.

Keep iterating until the user gives explicit approval.

---

### Step 7: Final confirmation

> ⛔ **This confirmation is required every time, no exceptions. Even if the user said "just go ahead" in an earlier turn.**

Before touching git, present a final summary:

```
Ready to create 3 commits in this order:

  1. feat(auth): add JWT refresh token support
     → src/auth/login.py, src/auth/logout.py, src/models/user.py

  2. test(auth): add unit tests for JWT refresh flow
     → tests/test_auth.py

  3. chore: update dependencies and docs for JWT support
     → requirements.txt, README.md

Shall I go ahead?
```

Wait for an explicit affirmative — "yes", "go ahead", "ship it", "looks good", etc. Anything ambiguous counts as a "no" — ask again.

---

### Step 8: Execute commits sequentially

Once approved, process each group **in order**, one at a time:

```bash
# Stage only the files for this group
git -C <repo-root> add -- <file1> <file2> ...

# Commit with the agreed message
git -C <repo-root> commit -m "<subject>" -m "<body>"

# Confirm the commit landed
git -C <repo-root> log --oneline -1
```

After each commit, show the one-line log confirmation before moving to the next.

After all commits are done, show a final summary:

```
All done! Created 3 commits:

  abc1234  feat(auth): add JWT refresh token support
  def5678  test(auth): add unit tests for JWT refresh flow
  ghi9012  chore: update dependencies and docs for JWT support
```

---

## Commit message format

Follow the Conventional Commits spec:

```
<type>(<optional scope>): <short summary>

<optional body — explain WHY, not WHAT, if non-obvious>
```

**Types:** `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`, `perf`, `ci`, `build`

Rules:
- Subject line ≤ 72 characters, imperative mood ("add", not "added")
- Be specific — avoid vague subjects like "update files" or "fix stuff"
- Body is optional but useful for non-obvious changes

---

## Edge cases

| Situation | How to handle |
|---|---|
| Only one logical group found | Still follow the full workflow — just one commit |
| File has no diff vs HEAD | Tell the user and exclude it from grouping |
| User selects a number out of range | Flag it and ask them to re-select |
| Binary file (image, pdf, etc.) | Note it's binary; write message based on filename/context |
| Repo is in detached HEAD state | Warn the user before committing |
| Nothing to commit after staging | Tell the user and skip that group |
| User wants to amend last commit | Note this is outside scope; suggest the git-commit skill instead |
| Files span multiple repos | Handle each repo as a separate grouping session |

---

## Important constraints

- **Never commit without explicit user confirmation in Step 7.** This is the most important rule. No exceptions.
- **Only stage the files in each group.** Never use `git add -A` — always stage files explicitly by path.
- **Commits are sequential.** Always execute in the order the user approved.
- Do not push. Local commits only unless the user explicitly asks.
- Do not modify `.gitignore` or any other file as part of this workflow.
- Do not use any third-party git libraries — use git CLI directly.