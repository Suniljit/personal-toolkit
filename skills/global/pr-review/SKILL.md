---
name: pr-review
description: Review a GitHub pull request by number via `gh` — runs a Standards sub-agent against this repo's coding standards and smell baseline, and a Spec sub-agent that reverse-engineers a spec from the diff for human review, then aggregates both into a merge recommendation. Use when the user wants a PR reviewed, gives a PR number, or asks "review PR #X".
disable-model-invocation: true
argument-hint: "Provide a PR number and a base branch (default: main)."
---

Two-axis review of a pull request, identified by number via `gh`:

- **Standards** — does the diff conform to this repo's documented coding standards and the smell baseline?
- **Spec** — reverse-engineered from the diff itself: what was this PR trying to do, and does the code actually do it?

Both axes run as **parallel sub-agents**. The two reports feed a single **merge recommendation** at the end — the reason to review a PR is to decide whether to merge it, so the axes converge instead of staying separate.

## Process

### 1. Resolve the PR and diff

```bash
gh pr view <number> --json headRefName,baseRefName,title,body,url
git fetch origin
```

Base branch: whatever the user specified, else `main`. This may differ from the PR's own declared base — the user's stated base wins.

```bash
git diff origin/<base>...origin/<headRefName>
git log origin/<base>..origin/<headRefName> --oneline
```

Never check out or switch the current branch — work entirely off remote refs. Stop and tell the user if the PR, branch, or diff can't be resolved (bad number, `gh` not authenticated, empty diff).

### 2. Identify the standards sources

Anything in the repo that documents how code should be written (`CODING_STANDARDS.md`, `CONTRIBUTING.md`, etc.), plus the smell baseline at [`../code-review/SMELLS.md`](../code-review/SMELLS.md) — always in force, repo docs override it where they conflict.

### 3. Spawn both sub-agents in parallel

Send a single message with two `Agent` tool calls, `general-purpose` subagent for both.

**Standards sub-agent prompt** — include:

- The diff command, commit list, and PR number.
- The standards-source files from step 2, plus the path `skills/code-review/SMELLS.md`.
- The brief: "Report — per file/hunk where relevant — (a) every place the diff violates a documented standard: cite the standard (file + rule); and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations (documented-standard breaches) from judgement calls (baseline smells are always judgement calls). Skip anything tooling enforces. Under 400 words."

**Spec sub-agent prompt** — include:

- The diff command and commit list (not the PR title/body yet).
- The brief: "Read the diff and reverse-engineer the spec this PR is implementing, before looking at the PR title or description — infer intent from the code itself so the spec isn't just a restatement of the author's framing. Write it in the structure of `skills/pr-review/spec-template.md` (read that file first), filling in only what the diff supports and omitting sections the template marks optional when nothing applies. This output is read in an agent desktop app, not a markdown file — follow the template's plain-text formatting, no markdown syntax. Then compare against the actual PR title/body [supplied below] and flag any mismatch between stated intent and what the code does. Mark anything you inferred rather than observed directly with `[inferred]`. Under 500 words."
- The fetched `title` and `body` from step 1.

### 4. Aggregate

Present under `## Standards`, `## Reverse-Engineered Spec`, and `## Findings` headings — the first two are the sub-agent reports near-verbatim; `## Findings` is your own synthesis across both (a Standards violation and a Spec mismatch can be the same underlying bug, and this is where that connection gets made).

For each finding in `## Findings`, use the format: file + line range, what's wrong, why it breaks something (concrete failure mode, not "could be an issue"), and a recommended fix concrete enough to hand directly to a PR that fixes it.

### 5. Merge recommendation

`APPROVE` / `APPROVE WITH NOTES` / `REQUEST CHANGES` / `BLOCK`

`APPROVE` requires certainty — only use it when you can state affirmatively that nothing in the diff breaks, not merely that you found no issues. If any finding leaves a real doubt about behavior, correctness, or scope, that's `APPROVE WITH NOTES` at best.

- **APPROVE** — nothing breaks. State why you're sure, in one sentence.
- **APPROVE WITH NOTES** — safe to merge, but list what to watch or clean up later.
- **REQUEST CHANGES** — one or more findings must be fixed first. List them (reuse the `## Findings` entries), each specific enough to be the whole brief for a follow-up PR.
- **BLOCK** — the PR shouldn't merge as-is even after minor fixes (wrong approach, missing scope, breaks something structurally). State what's fundamentally wrong.
