---
name: ship-pr
description: >
  Commit all changed files (grouped into one or more logical commits), push, and open a PR — fully autonomous, no confirmation prompts.
disable-model-invocation: true
metadata:
  opencode/autoinvoke: "false"
argument-hint: "Specify a target branch, else defaults to 'main'."
---

# Ship PR Skill

Runs commit → push → PR end to end with no approval gates.

## Specs (optional)

The user may hand you a spec, ticket, or plan doc alongside the request. It never replaces the diff — read it once and fold it into the Step 7 summary as context for why a change was made. No spec provided → proceed on the diff alone.

## Step 1: Discover changed files

```bash
git rev-parse --show-toplevel
git -C <root> status --short
```

All later commands run against `<root>`. Take every changed and untracked file — no subset selection. If none, tell the user and stop.

## Step 2: Inspect every change

```bash
git -C <root> diff HEAD -- <file>              # modified tracked files
git -C <root> diff --cached -- <file>          # staged files
git -C <root> diff --no-index /dev/null <file> # new untracked files
```

Read enough of each diff to state what the file changes and why. Every file from Step 1 must be accounted for before moving on.

## Step 3: Group into commits

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

Write each commit message in Conventional Commits format:

```
<type>(<scope>): <summary>          ← ≤72 chars, imperative mood

<body — why the change is made, plus any non-obvious detail>
```

Types: `feat` `fix` `refactor` `docs` `style` `test` `chore` `perf` `ci` `build`

Omit the body only when the subject is fully self-explanatory. Avoid vague summaries ("update files"). Keep filenames out of the subject unless they are the point (e.g. `docs: update README`).

## Step 4: Commit

For each commit in order:

```bash
git -C <root> add -- <file1> <file2> ...
git -C <root> commit -m "<subject>" -m "<body>"
```

No confirmation — commit directly. Then report what was committed:

```bash
git -C <root> log --oneline -<n>
```

## Step 5: Push

```bash
git branch --show-current
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null
# If upstream exists: git push
# If not:             git push -u origin <current-branch>
```

Stop and report if push fails — never force-push.

## Step 6: Resolve the target branch

**Source branch** = the current checked-out branch, already pushed in Step 5. Never ask.

**Target/base branch** = where the PR merges into: the branch the user named in their request (e.g. "PR to feature/x", "PR into develop"), otherwise default to `main`. Never ask.

## Step 7: Create the PR

```bash
git log <target>..HEAD --oneline
git diff <target>...HEAD --name-status
git diff <target>...HEAD -- . ':(exclude)*.lock' ':(exclude)package-lock.json'
gh pr create --base <target> --title "<title>" --body "<description + changes>"
```

The body is read in an agent desktop app, not a markdown renderer — no markdown syntax (no `**bold**`, `#` headers, or backticks). Use plain text with line breaks and indentation.

Focus on what changed and why from the actual code diff — not metadata like commit messages, file/line counts, or commit-by-commit breakdowns. Write the title and body in this shape:

```
Branch: <current> → <target>
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
| Nothing to commit after staging | Tell the user, stop |
| All changes are one logical unit | Single commit is fine |
| Binary file | Note it's binary; base the message on filename/context |
| Detached HEAD | Warn, then proceed |
| Unresolved merge conflicts | Warn; don't commit |
| Large diff (500+ lines) | Summarize by directory/module, functionally |
| No commits ahead of target after pushing | Tell the user, stop — nothing to PR |
| PR already exists for this branch | Update its description instead of creating a new one |
| Push rejected | Report the error, stop — do not force-push |

## Constraints

- No confirmation prompts anywhere in this flow — commit messages, grouping, and PR body are decided and executed directly.
- Stage exactly the files from Step 1 — every changed and untracked file, no subset.
- Touch only files that belong in the commit — leave `.gitignore` and everything else alone.
- Push only the current branch; never force-push.
- Use `git` and `gh` directly — no third-party libraries.
