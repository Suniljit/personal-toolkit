---
name: git-commit
description: Stage files and create git commits.
disable-model-invocation: true
---

# Git Commit Skill

## Workflow

### Step 1: Locate the repo root

```bash
git rev-parse --show-toplevel
```

All later commands run against `<root>`.

### Step 2: Identify files

```bash
git -C <root> status --short
```

Take every changed and untracked file — do not ask the user to select a subset. If the request names specific files, use those instead.

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

Stage and commit only after the user explicitly approves the message below — every time, even if they said "just commit" earlier in the conversation.

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
# Stage the files identified in Step 2
git -C <root> add -- <file1> <file2> ...

# Or, if no files were named in the request, stage everything
git -C <root> add -A

git -C <root> commit -m "<subject>" -m "<body>"

git -C <root> log --oneline -1
```

## Edge cases

| Situation | Action |
|---|---|
| File has no changes vs HEAD | Tell the user |
| Untracked / new file | Stage it; note "new file" in the message |
| Relative path given | Resolve relative to working directory |
| Binary file | Note it's binary; base message on filename/context |
| Detached HEAD | Warn before committing |
| Nothing to commit after staging | Tell the user |
| Amend requested | Use `--amend`; still confirm new message first |

## Constraints

- Commit only after the explicit approval gated in Step 5.
- Stage exactly the files identified in Step 2 (all changes, unless the request named specific files).
- Commit locally; push only when explicitly asked.
- Touch only files that are part of the commit — leave `.gitignore` and anything else untouched.
- Use `git` directly — no third-party libraries.