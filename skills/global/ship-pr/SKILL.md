---
name: ship-pr
description: >
  Commit all changed files (grouped into one or more logical commits), push, and open a PR — fully autonomous, no confirmation prompts.
disable-model-invocation: true
argument-hint: "Specify a target branch, else defaults to 'main'."
---

# Ship PR Skill

Runs commit → push → PR end to end with no approval gates.

## Step 1: Discover changed files

```bash
git rev-parse --show-toplevel
git status --short
```

Take every changed and untracked file — no subset selection. If none, tell the user and stop.

## Step 2: Read each changed file

```bash
git diff -- <file>                # unstaged tracked changes
git diff --cached -- <file>       # staged changes
cat <file>                        # new untracked files
```

Read enough of each to know what it does and why it changed.

## Step 3: Group into commits

Decide for yourself whether one commit or several is right — don't default to either. Group by logical concern, not by file type alone. When multiple commits are needed, sequence by this priority ladder (lower number first):

| Priority | Group | Examples |
|---|---|---|
| 1 | Plans / specs | `PLAN.md`, `specs/*.md`, architecture docs |
| 2 | Config / environment | `*.config.*`, `pyproject.toml`, `Dockerfile` — move into a feature's commit instead if the config exists only for that feature |
| 3 | Data models / migrations | `models/`, `migrations/`, `schema.sql` |
| 4 | Core logic / features | Services, controllers, utilities — split by sub-feature, not one giant commit |
| 5 | API / interfaces | Routes, endpoints, views, serializers |
| 6 | Tests | Group with the feature they cover when closely related, otherwise batch here |
| 7 | CI / build / tooling | `.github/`, `Makefile`, `scripts/` |
| 8 | Docs | `docs/`, `*.md` (non-README) |
| 9 | README | Always last |

Write each commit message in Conventional Commits format:

```
<type>(<scope>): <summary>          ← ≤72 chars, imperative mood

<body — explain WHY if non-obvious>
```

Types: `feat` `fix` `refactor` `docs` `style` `test` `chore` `perf` `ci` `build`

Avoid vague summaries ("update files"). Don't mention filenames in the subject unless they are the point (e.g. `docs: update README`). Add a body only when the WHY is non-obvious.

## Step 4: Commit

```bash
git -C <root> add -- <file1> <file2> ...
git -C <root> commit -m "<subject>" -m "<body>"
```

Repeat per group from Step 3. No confirmation — commit directly.

## Step 5: Push

```bash
git branch --show-current
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null
# upstream exists: git push
# no upstream:     git push -u origin <current-branch>
```

If push fails, report the error and stop — never force-push.

## Step 6: Resolve the PR target branch

Use the branch the user named in their request (e.g. "PR to feature/x"). Otherwise default to `main`. Never ask.

## Step 7: Create the PR

```bash
git log <target>..HEAD --oneline
git diff <target>...HEAD --name-status
gh pr create --base <target> --title "<title>" --body "<description>"
```

Focus on what changed and why from the actual diff — not metadata like commit messages, file/line counts, or commit-by-commit breakdowns. Write the title and body in this shape:

```
Title: <imperative, ~50 chars>

Description:
<2–5 sentences: what changed, why, notable decisions>

Changes:
  <file/area>: <what changed, functionally>
  <file/area>: <what changed, functionally>
```

Same standard as a human-reviewed PR, just without pausing for approval. Print the PR URL when done.

## Edge cases

| Situation | Action |
|---|---|
| No changed files | Tell the user, stop |
| File unchanged vs HEAD | Exclude it |
| All changes are one logical unit | Single commit is fine |
| Binary file | Base message on filename/path |
| Detached HEAD | Warn, then proceed |
| Unresolved merge conflicts | Warn, do not commit |
| No commits ahead of target after pushing | Tell the user, stop — nothing to PR |
| PR already exists for this branch | Update its description instead of creating a new one |
| Push rejected | Report the error, stop — do not force-push |

## Constraints

- No confirmation prompts anywhere in this flow — commit messages, grouping, and PR body are decided and executed directly.
- Stage exactly the files identified in Step 1; leave everything else (`.gitignore`, untouched files) alone.
- Push only the current branch; never force-push.
- Use `git` and `gh` directly — no third-party libraries.
