---
name: git-commit
description: Stage files and create git commits. Use when the user wants to commit, stage changes, or generate a commit message — even if they just say "commit this" or "save my changes."
---

# Git Commit Skill

## Workflow

### Step 1: Identify files (skip if files are explicit in the request)

```bash
git rev-parse --show-toplevel
git status --short
```

Show a numbered list of changed/untracked files and ask the user to select by number(s), range, or "all". Wait for their reply before continuing.

### Step 2: Locate the repo root

```bash
git rev-parse --show-toplevel
```

### Step 3: Inspect the changes

```bash
# Unstaged tracked changes
git -C <root> diff -- <file>

# Staged changes
git -C <root> diff --cached -- <file>

# New untracked files
git -C <root> diff --no-index /dev/null <file>

# No files specified — diff everything
git -C <root> diff HEAD
git -C <root> ls-files --others --exclude-standard
# Then diff each untracked file with --no-index as above
```

If there are no changes, tell the user and stop.

### Step 4: Write a commit message

Use Conventional Commits format:

```
<type>(<scope>): <summary>          ← ≤72 chars, imperative mood

<body — explain WHY if non-obvious>
```

Types: `feat` `fix` `refactor` `docs` `style` `test` `chore` `perf` `ci` `build`

Avoid vague summaries ("update files"). Don't mention filenames in the subject unless they are the point (e.g. `docs: update README`). If changes span multiple logical concerns, note them in the body or suggest splitting.

### Step 5: Confirm — MANDATORY STOP ⛔

**Do not run `git add` or `git commit` until the user explicitly approves.**
This applies every time, even if they said "just commit" in a prior turn.

Present clearly:

```
Files to commit:
  • src/auth.py
  • tests/test_auth.py

Commit message:
──────────────────────────────────────
feat(auth): add JWT refresh token support

Introduces token rotation on refresh to reduce exposure window.
Adds unit tests for expiry and rotation edge cases.
──────────────────────────────────────

Go ahead?
```

Wait for an explicit yes ("yes", "ok", "go ahead", "ship it"). Ambiguous = no; show the message again after edits and re-confirm.

### Step 6: Stage and commit

```bash
# Stage specified files
git -C <root> add -- <file1> <file2> ...

# Or stage everything if no files were specified
git -C <root> add -A

git -C <root> commit -m "<subject>" -m "<body>"

git -C <root> log --oneline -1
```

## Edge cases

| Situation | Action |
|---|---|
| File has no changes vs HEAD | Tell the user; don't silently skip |
| Untracked / new file | Stage it; note "new file" in the message |
| Relative path given | Resolve relative to working directory |
| Binary file | Note it's binary; base message on filename/context |
| Detached HEAD | Warn before committing |
| Nothing to commit after staging | Tell the user |
| Amend requested | Use `--amend`; still confirm new message first |
| Invalid number selection | Point it out; ask to re-select |

## Constraints

- Never commit without explicit confirmation in Step 5.
- Stage only the files the user selected (or all changes if none specified — show the full list in Step 5).
- Commit locally only; do not push unless explicitly asked.
- Do not modify `.gitignore` or any other file as part of this workflow.
- Use `git` directly — no third-party libraries.