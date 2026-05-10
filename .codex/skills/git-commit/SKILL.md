---
name: git-commit
description: Stage files and create local git commits. Use when the user wants Codex to commit, stage changes, choose files to commit, generate a commit message, amend a commit, or save current work, including requests like "commit this", "save my changes", or "make a git commit."
---

# Git Commit Skill

Commit local git changes only after inspecting the requested files and receiving explicit user approval. Preserve the approval gate every time, even when the user sounds casual or previously said to commit.

## Workflow

### 1. Identify Candidate Files

Skip this step only when the user explicitly names the files or says to commit all changes.

```bash
git rev-parse --show-toplevel
git status --short
```

Show the changed and untracked files in a numbered Markdown list. Ask the user to select by number, range, comma-separated numbers, or `all`, then stop and wait.

Codex-friendly selection display:

```markdown
Changed files:
1. `src/auth.py` - modified
2. `tests/test_auth.py` - modified
3. `docs/auth.md` - untracked

Which files should I commit? Reply with numbers, ranges like `1-2`, or `all`.
```

### 2. Locate The Repo Root

```bash
git rev-parse --show-toplevel
```

Use `git -C <root>` for every subsequent git command.

### 3. Inspect The Changes

Inspect only the selected or explicitly requested files. If the user selected `all`, inspect all tracked changes and each untracked file.

```bash
# Unstaged tracked changes
git -C <root> diff -- <file>

# Staged changes
git -C <root> diff --cached -- <file>

# New untracked files
git -C <root> diff --no-index /dev/null <file>

# All tracked changes
git -C <root> diff HEAD

# All untracked files
git -C <root> ls-files --others --exclude-standard
```

If there are no changes to commit, tell the user and stop.

### 4. Write The Commit Message

Use Conventional Commits format:

```text
<type>(<scope>): <summary>

<body>
```

Rules:

- Keep the subject at 72 characters or fewer.
- Use imperative mood.
- Use one of these types: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`, `perf`, `ci`, `build`.
- Avoid vague summaries such as `update files`.
- Avoid mentioning filenames in the subject unless the file is the point, such as `docs: update README`.
- Explain why in the body when the reason is not obvious.
- If the selected changes span multiple logical concerns, either note the concerns in the body or suggest splitting the commit before asking for approval.

### 5. Confirm Before Staging Or Committing

Mandatory stop: do not run `git add`, `git commit`, or `git commit --amend` until the user explicitly approves the exact files and exact commit message.

This applies every time, even if the user previously said "just commit", "go ahead", or similar in an earlier turn. Treat ambiguous replies as no approval.

Present the approval request in Markdown so it renders clearly in Codex:

````markdown
Files to commit:
- `src/auth.py`
- `tests/test_auth.py`

Commit message:

```text
feat(auth): add JWT refresh token support

Introduce token rotation on refresh to reduce the exposure window.
Add unit tests for expiry and rotation edge cases.
```

Reply `yes`, `ok`, `go ahead`, or `ship it` to commit these files with this message.
````

If the user requests edits to the message or file list, revise the approval display and stop for approval again.

### 6. Stage And Commit

After explicit approval, stage only the approved files unless the approved selection was all changes.

```bash
# Stage approved files
git -C <root> add -- <file1> <file2> ...

# Or stage all changes only when the user approved all changes
git -C <root> add -A

# Create the commit
git -C <root> commit -m "<subject>" -m "<body>"

# Verify the result
git -C <root> log --oneline -1
```

For amend requests, use `git -C <root> commit --amend` only after the same approval gate with the amended message.

Report the created commit hash and subject.

## Edge Cases

| Situation | Action |
|---|---|
| File has no changes vs HEAD | Tell the user and do not silently skip it. |
| Untracked or new file | Stage it only after approval; mention it as a new file when summarizing. |
| Relative path given | Resolve it relative to the current working directory before diffing or staging. |
| Binary file | Note that it is binary; base the message on filename and surrounding context. |
| Detached HEAD | Warn before requesting final approval. |
| Nothing to commit after staging | Tell the user and stop. |
| Amend requested | Use `--amend`; still confirm the new message and files first. |
| Invalid number selection | Point it out and ask the user to re-select. |

## Constraints

- Never commit without explicit confirmation in Step 5.
- Stage only the files the user selected or explicitly approved.
- Stage all changes only when the user explicitly approved all changes.
- Commit locally only; do not push unless explicitly asked.
- Do not modify `.gitignore` or any other file as part of this workflow.
- Use `git` directly; do not use third-party libraries.
