---
name: pr-review
description: Review a GitHub pull request by number via `gh` — runs a Standards sub-agent against this repo's coding standards and smell baseline, and a Spec sub-agent that reverse-engineers a spec from the diff for human review, then aggregates both into a merge recommendation. Diffs against the PR's own target branch. Use when the user wants a PR reviewed, gives a PR number, or asks "review PR #X".
disable-model-invocation: true
metadata:
  opencode/autoinvoke: "false"
argument-hint: "Provide a PR number."
---

Two-axis review of a pull request, identified by number via `gh`:

- **Standards** — does the diff conform to this repo's documented coding standards and the smell baseline below?
- **Spec** — reverse-engineered from the diff itself: what was this PR trying to do, and does the code actually do it?

Both axes run as **parallel sub-agents**. The two reports feed a single **merge recommendation** at the end — the reason to review a PR is to decide whether to merge it, so the axes converge instead of staying separate.

This is a review, not a fix or a test run: read the diff, report findings, recommend a merge decision. Never run the test suite, never edit files, never check out the PR branch — the review will not modify the working tree or switch branches.

## Process

### 1. Resolve PR metadata and refs

This step needs network access. In a sandboxed environment, request network escalation before the first `gh` or `git fetch` command below. The fetch may update local remote-tracking refs but must not check out, edit, stage, or commit anything.

Run these as separate commands, stopping on failure. Target branch is always the PR's own `baseRefName` — never ask the user for a base or default to `main`. Fetch only the two refs needed, and pull the head via `pull/<number>/head` into a dedicated remote-tracking ref — this is what makes fork PRs work, since `origin/<headRefName>` doesn't resolve when the PR originates from a fork:

```bash
gh pr view <number> --json headRefName,baseRefName,title,body,url,headRepositoryOwner
git fetch origin <baseRefName> pull/<number>/head:refs/remotes/origin/pr-<number>
git rev-parse --verify origin/<baseRefName>
git rev-parse --verify refs/remotes/origin/pr-<number>
```

```bash
git diff origin/<baseRefName>...refs/remotes/origin/pr-<number>
git log origin/<baseRefName>..refs/remotes/origin/pr-<number> --oneline
```

Never check out or switch the current branch — work entirely off remote refs. If GitHub access or fetching is unavailable, stop and report that the review is blocked by network access or unresolved remote refs — do not retry the same command in a lower-permission context. Also stop if the PR, branch, or diff can't be resolved for another reason (bad number, empty diff).

### 2. Identify the standards sources

Anything in the repo that documents how code should be written (`CODING_STANDARDS.md`, `CONTRIBUTING.md`, etc.), plus the Smell Baseline below — always in force, repo docs override it where they conflict.

### 3. Spawn both sub-agents in parallel

Send a single message with two `Agent` tool calls, `general-purpose` subagent for both.

**Standards sub-agent prompt** — include:

- The diff command, commit list, and PR number (with the `pr-<number>` ref, so it can rerun the diff itself if needed).
- The standards-source files from step 2, plus the full Smell Baseline text below (paste it in — the sub-agent has no access to this skill file).
- The brief: "Report — per file/hunk where relevant — (a) every place the diff violates a documented standard: cite the standard (file + rule); and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations (documented-standard breaches) from judgement calls (baseline smells are always judgement calls). Skip anything tooling enforces. Under 400 words."

**Spec sub-agent prompt** — include:

- The diff command and commit list (not the PR title/body yet).
- The brief: "Read the diff and reverse-engineer the spec this PR is implementing, before looking at the PR title or description — infer intent from the code itself so the spec isn't just a restatement of the author's framing. Write it in the structure of the Spec Template below, filling in only what the diff supports and omitting sections the template marks optional when nothing applies. This output is read in an agent desktop app, not a markdown file — follow the template's plain-text formatting, no markdown syntax. Then compare against the actual PR title/body [supplied below] and flag any mismatch between stated intent and what the code does. Mark anything you inferred rather than observed directly with `[inferred]`. Under 500 words." Paste the full Spec Template text below into the prompt.
- The fetched `title` and `body` from step 1.

### 4. Aggregate

Present under `## Reverse-Engineered Spec`, `## Standards`, and `## Findings` headings — spec first, so the reader knows what the PR is trying to do before weighing the code against it. The first two are the sub-agent reports near-verbatim; `## Findings` is your own synthesis across both (a Standards violation and a Spec mismatch can be the same underlying bug, and this is where that connection gets made).

For each finding in `## Findings`, use the format: file + line range, what's wrong, why it breaks something (concrete failure mode, not "could be an issue"), and a recommended fix concrete enough to hand directly to a PR that fixes it.

### 5. Merge recommendation

`APPROVE` / `APPROVE WITH NOTES` / `REQUEST CHANGES` / `BLOCK`

`APPROVE` requires certainty — only use it when you can state affirmatively that nothing in the diff breaks, not merely that you found no issues. If any finding leaves a real doubt about behavior, correctness, or scope, that's `APPROVE WITH NOTES` at best.

- **APPROVE** — nothing breaks. State why you're sure, in one sentence.
- **APPROVE WITH NOTES** — safe to merge, but list what to watch or clean up later.
- **REQUEST CHANGES** — one or more findings must be fixed first. List them (reuse the `## Findings` entries), each specific enough to be the whole brief for a follow-up PR.
- **BLOCK** — the PR shouldn't merge as-is even after minor fixes (wrong approach, missing scope, breaks something structurally). State what's fundamentally wrong.

## Smell Baseline

A fixed set of Fowler code smells (_Refactoring_, ch.3) that the Standards axis always carries, even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation — and, like any standard, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name** — a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code** — the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy** — a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps** — the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession** — a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches** — the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery** — one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change** — one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality** — abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains** — long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man** — a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest** — a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

## Spec Template

Plain text output, not markdown — this renders in an agent desktop app, not a markdown file. No `#`, `**`, `|`, or `_` syntax. Use the section labels below as-is, on their own line, followed by their content. Every section must trace to a specific hunk in the diff. If a section would require guessing intent the diff doesn't show, omit the section rather than infer — the aggregator's Findings section is where judgment calls belong, not this spec.

```
REVERSE-ENGINEERED SPEC

PROBLEM & SOLUTION
Problem: what's broken or missing, as evidenced by what the diff fixes or adds.
Solution: what the diff does about it, in one or two sentences.

DECISIONS
Choices visible in the diff itself — a chosen library, data shape, algorithm, or pattern. One line per decision, omit any you can't point to a hunk for:
Constraint: <decision> — <choice> (why, if evidenced)
Choice: <decision> — <choice> (why, if evidenced)

ARCHITECTURE
Optional — include only when the diff spans multiple modules/components and a plain-text description of how they connect adds clarity. Omit for single-file or trivial diffs.

CODE SHAPE
Optional — include only when the diff adds or changes a non-trivial public interface (types, function signatures, API contracts). Describe signatures inline as plain text, not in a code block.

VALIDATION RULES
Optional — include only when the diff adds input validation.

TESTING
What tests the diff adds or changes, and what behavior they assert. Omit this section if the diff has no test changes — that absence is a finding for the aggregator, not something to note here.

EDGE CASES
Edge cases the diff explicitly handles — a branch, a guard, a comment. Omit speculative cases the diff doesn't address.

OUT OF SCOPE
Optional — only when the diff itself signals deferral (a TODO, a comment, a stubbed branch).
```
