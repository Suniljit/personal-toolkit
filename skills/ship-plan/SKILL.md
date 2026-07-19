---
name: ship-plan
description: Commit changes and open a PR from a saved feature plan — commit messages and the PR description come from the plan itself, not from re-reading diffs.
disable-model-invocation: true
---

# Ship Plan

Turn a finished `.specs/` plan into commits and a PR. The plan is the source of truth for commit messages and the PR description — diffs are only read for files the plan didn't anticipate.

---

## Step 1 — Load the plan

If no path was given, look in `.specs/` and list candidates for the user to pick.

Read the plan in full. Parse:
- H1 title
- Branch slug (the `🌿 **Branch:**` front-matter line)
- **Key Files** table (File / What changes / Phase)
- **Implementation Plan** phase headings
- The full raw content — needed verbatim for the PR body in Step 7

---

## Step 2 — Verify branch

```bash
git branch --show-current
```

If it doesn't match the plan's branch slug, warn the user and ask whether to proceed on the current branch or check out/create the plan's branch.

---

## Step 3 — Reconcile with existing commits

Detect the branch base the same way as `smart-commit-git`: upstream tracking branch → nearest ancestor branch tip → working tree only.

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null
git log <base>..HEAD --oneline
```

- **Branch not pushed yet** (the common case — e.g. `implement` left one lump local commit): offer to consolidate everything back to a clean slate:
  ```bash
  git reset --soft <base>
  ```
  This is safe (nothing pushed, nothing lost — just unwinds commits back to staged changes) but it does rewrite local history, so tell the user what it does and get a yes before running it. Once done, every changed file — previously committed or not — is available to classify fresh in Step 4.
- **Branch already pushed** with commits ahead of base: don't rewrite history. Only uncommitted working-tree changes get grouped into new commits in Step 5; say explicitly that the pre-existing pushed commits are being left alone.

---

## Step 4 — Discover and classify changed files

```bash
git diff <base> --name-status
git status --short
```

Combine and dedupe. The plan file itself won't appear here — it lives in gitignored `.specs/`.

For each file, match its path against the plan's Key Files table:
- **Matched** → tag it with that row's Phase. Don't read its diff — trust the plan's "What changes" text for the commit body.
- **Unmatched** → a deviation. Read its diff (`git diff <base> -- <file>`, or `cat` for new/untracked files) and work out: does it belong with an existing phase, is it a genuine deviation found during implementation, or is it noise? Write a one-line rationale for each.

---

## Step 5 — Build and present the commit plan

One commit per phase, in the plan's phase order:
- **Subject**: derived from the phase name, Conventional Commits type inferred from the branch slug prefix (`feat/` → `feat`, `fix/` → `fix`, etc.)
- **Body**: summarize that phase's Key Files "What changes" entries
- **Files**: every file tagged with that phase in Step 4

Deviation files get appended as their own commit(s) after the phase they relate to (or a final `fix:`/`chore:` commit if unrelated to any phase), with the message written from the Step 4 diff read.

Present the full plan in the same block format as `smart-commit-git`:

```
Here's my proposed commit plan (N commits, in order):

──────────────────────────────────────
Commit 1 of N
  Subject:  feat(csv): add export handler and route
  Body:     Implements Phase 1 of the plan — CSV export handler wired
            into the existing export router.
  Files:    src/export/csv.ts (new), src/export/router.ts
──────────────────────────────────────
Commit 2 of N
  Subject:  fix(csv): handle empty dataset edge case
  Body:     Deviation from plan — found during implementation that an
            empty dataset crashed the handler; added a guard.
  Files:    src/export/csv.ts
──────────────────────────────────────
...

Does this look good? Say "ok" to proceed, or give feedback to adjust.
```

Wait for explicit approval. Any feedback = revise and re-present the full plan.

---

## Step 6 — Execute commits

```bash
git add -- <file1> <file2> ...
git commit -m "<subject>" -m "<body>"
```

One `add`+`commit` pair per group, in order.

---

## Step 7 — Push and create the PR

Resolve the target/base branch the same way as `create-pr`: use the branch the user specified in their request, otherwise default to `main`.

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null
# If upstream exists: git push
# If not: git push -u origin <current-branch>
```

Stop and report if push fails — never force-push.

Build the PR body from the plan's raw content (Step 1). If Step 4 found any deviation files, append:

```markdown
## Deviations from Plan
- `path/to/file.ts`: <one-line rationale>
```

```bash
gh pr create --base <target> --title "<plan H1 title>" --body "<plan content [+ deviations]>"
```

Print the PR URL.

---

## Edge cases

| Situation | Action |
|---|---|
| No plan path given and no `.specs/` directory | Tell the user, ask for a path |
| Plan file not found | Tell the user, stop |
| Current branch doesn't match plan's branch slug | Warn, ask how to proceed (Step 2) |
| No changed files at all | Tell the user, stop — nothing to ship |
| Every changed file is a deviation (none match Key Files) | Flag that the plan may be stale or wrong — don't silently guess groupings |
| Branch already pushed | Skip the soft-reset consolidation; only group uncommitted changes (Step 3) |
| PR already exists | Tell the user, offer to update the description instead |
| Push rejected | Show the error, ask how to proceed |

---

## Constraints

- Never invent commit or PR content that isn't grounded in the plan or an actual diff read.
- Commit only after the Step 5 approval gate — every time, even if the user said "just ship it" earlier.
- Don't rewrite history on a branch that's already been pushed.
- Commit and push only what was approved — don't touch `.gitignore` or files outside the classified set.
- Use `git` and `gh` directly — no third-party libraries.
