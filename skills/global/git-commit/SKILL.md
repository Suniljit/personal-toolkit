---
name: git-commit
description: Stage changes and commit them — as one commit or a logically sequenced series, decided from the content.
disable-model-invocation: true
metadata:
  opencode/autoinvoke: "false"
---

# Git Commit Skill

Stage every pending change, decide whether it is one commit or several, write Conventional Commits messages, and commit. No approval step — commit directly.

## Step 1: Locate the repo root

```bash
git rev-parse --show-toplevel
```

All later commands run against `<root>`.

## Step 2: Identify files

```bash
git -C <root> status --short
```

Take every changed and untracked file. If the request names specific files, take only those. Never ask the user to select a subset.

If there are no changes, tell the user and stop.

## Step 3: Inspect every change

```bash
git -C <root> diff HEAD -- <file>              # modified tracked files
git -C <root> diff --cached -- <file>          # staged files
git -C <root> diff --no-index /dev/null <file> # new untracked files
```

Read enough of each diff to state what the file changes and why. Every file from Step 2 must be accounted for before moving on.

## Step 4: Decide one commit or several

**One commit** when every change serves a single logical purpose — a feature and its tests, a bug fix, a doc pass.

**Several commits** when the changes span unrelated concerns, or mix setup (config, models, migrations) with the feature that needs it, or mix a refactor with a behaviour change. Sequence them by this ladder — lower number commits first:

| # | Group | Examples |
|---|---|---|
| 1 | Plans / specs | `PLAN.md`, `SPEC.md`, files under `specs/` |
| 2 | Config / environment | `*.config.*`, `pyproject.toml`, `Dockerfile` — unless a feature needs it, then commit it with that feature |
| 3 | Data models / migrations | `models/`, `migrations/`, `schema.sql` |
| 4 | Core logic / features | Services, utilities — split by sub-feature, not one giant commit |
| 5 | API / interfaces | Routes, endpoints, views, serializers |
| 6 | Tests | Commit with the feature they cover when tightly coupled; otherwise batch here |
| 7 | CI / build / tooling | `.github/`, `Makefile`, `scripts/` |
| 8 | Docs | `docs/`, non-README `*.md` |
| 9 | README | `README.md` — always last |

## Step 5: Write commit messages

Conventional Commits:

```
<type>(<scope>): <summary>          ← ≤72 chars, imperative mood

<body — why the change is made, plus any non-obvious detail>
```

Types: `feat` `fix` `refactor` `docs` `style` `test` `chore` `perf` `ci` `build`

Omit the body only when the subject is fully self-explanatory. Avoid vague summaries ("update files"). Keep filenames out of the subject unless they are the point (e.g. `docs: update README`).

## Step 6: Stage and commit

For each commit in order:

```bash
git -C <root> add -- <file1> <file2> ...
git -C <root> commit -m "<subject>" -m "<body>"
```

Then report what was committed:

```bash
git -C <root> log --oneline -<n>
```

## Edge cases

| Situation | Action |
|---|---|
| No changes vs HEAD | Tell the user and stop |
| Untracked / new file | Stage it; note "new file" in the message |
| Relative path given | Resolve against the working directory |
| Binary file | Note it's binary; base the message on filename/context |
| Detached HEAD | Warn before committing |
| Unresolved merge conflicts | Warn; don't commit |
| Nothing to commit after staging | Tell the user |
| Amend requested | Use `--amend` |

## Constraints

- Commit directly — no approval gate.
- Stage exactly the files from Step 2 (all of them, unless the request named specific files).
- Commit locally; push only when explicitly asked.
- Touch only files that belong in the commit — leave `.gitignore` and everything else alone.
- Use `git` directly — no third-party libraries.
