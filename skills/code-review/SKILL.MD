---
name: code-review
description: Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes — Standards (does the code follow this repo's documented coding standards, plus a baseline smell check?) and Spec (does the code match what the originating plan/ticket asked for, checked against a per-section checklist covering decisions, architecture, key files, code shape, validation, logging, and scope?). Runs both as parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, asks to "review since X", or wants to audit code against a plan/spec ("audit against the plan", "did we implement the spec"). Also invoked automatically after /implement.
---

# Code Review Skill

Two-axis review of the diff between `HEAD` and a fixed point:

- **Standards** — does the code conform to this repo's documented standards (plus the smell baseline in [SMELLS.md](SMELLS.md))?
- **Spec** — does the code faithfully implement the originating plan/ticket?

Both axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings into the report below.

## Step 1: Pin the fixed point

A fixed point is required before anything else runs:

- If the user (or the invoking skill) supplied one — a SHA, branch, tag, `main`, `HEAD~5` — use it.
- If invoked from `/implement` with none given, default to the merge-base between the current branch and the repo's default branch:
  `git merge-base HEAD $(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')`, falling back to `main` or `master` if `origin/HEAD` isn't set. This reviews everything done since branching, committed or not.
- Otherwise, ask the user for one. Don't guess.

Confirm the point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff fails here — not inside the sub-agents.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, against the merge-base). Also note `git log <fixed-point>..HEAD --oneline`.

## Step 2: Identify the spec source

Check what's already present in context — a path passed as an argument, the spec/ticket path `/implement` was given, or a spec already discussed earlier in the conversation. If none of that is present, ask the user where the spec is. If they say there isn't one, the **Spec** sub-agent is skipped and the report notes "no spec available".

## Step 3: Identify the standards sources

Anything in the repo that documents how code should be written (e.g. `CODING_STANDARDS.md`, `CONTRIBUTING.md`). If none exist, note that and rely on the smell baseline alone.

The Standards axis always also carries the smell baseline in [SMELLS.md](SMELLS.md) — read it now if you haven't already this session; it's pasted in full into the Standards sub-agent's prompt in Step 4, since that sub-agent has no other access to it.

## Step 4: Spawn both sub-agents in parallel

Send a single message with two `Agent` tool calls. Use the `general-purpose` subagent for both.

**Standards sub-agent prompt** — include:

- The full diff command and commit list.
- Any repo standards-source files found in Step 3, **plus the full contents of [SMELLS.md](SMELLS.md)** pasted in — the sub-agent has no other access to it.
- The brief: "Report — per file/hunk where relevant — (a) every place the diff violates a documented standard: cite the standard (file + rule), using `CRITICAL`/`WARNING`/`SUGGESTION` severity; and (b) any baseline smell you spot: name it and quote the hunk. For each finding give **What** (the problem, plain English), **Why it matters** (one sentence, real-world consequence), and **Fix** (a concrete step or snippet). Documented-standard breaches can be hard violations; baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Under 400 words."

**Spec sub-agent prompt** — include:

- The diff command and commit list.
- The full contents of the spec from Step 2.
- The checklist table below, plus the brief.

Checklist — build an internal checklist from whichever of these sections the plan actually has (skip absent sections, don't invent checks):

| Plan section | What to check |
|---|---|
| **What & Why** | The core capability exists and is reachable |
| **Decisions** | Each Choice/Constraint is reflected in the code |
| **Architecture** | Data flow and component relationships match the diagram |
| **Key Files** | Each listed file exists and the stated change is present |
| **Code Shape** | Interfaces, types, function signatures match the sketches |
| **Validation Rules** | Input constraints are enforced where described |
| **Logging** | Each listed log event exists at the right level with the right fields |
| **Implementation Plan** | Each phase's tasks appear to be done |
| **Out of Scope** | Nothing in scope-exclusions was accidentally implemented |

Brief: "Read the full plan before judging anything. For each checklist target, inspect the code touched in the diff (and, if the plan implies a file outside the diff should also have changed, flag that too) and confirm it matches the plan or record a discrepancy. Report each discrepancy as its own `[D-N]` block: **What** (one sentence, labeled Missing or Wrong — Missing means the thing isn't there at all, Wrong means it's there but diverges), **Plan says** (quote or paraphrase the requirement), **Code does** (file + line), **Why it matters** (impact), **Fix** (name the function/field/block to change and what it should become). Order discrepancies missing-required-behaviour first, wrong-behaviour second, cosmetic/logging last — no grouping by category. Only flag what the plan actually requires — don't gold-plate. If one root cause produces several symptoms, report it once with all symptoms under 'Why it matters'. Never report a finding without a file + line reference."

If the spec is missing, skip the Spec sub-agent and note this in the final report.

## Step 5: Deliver the review

No emoticons. Be as short as possible without losing signal. Skip sections that don't apply.

### Summary
1–2 sentences: what and why.

### How It Works
**Approach** — one plain-language sentence.
**Structure** — ASCII diagram of changed components.
**Walkthrough** — key changes explained conversationally. Skip trivial ones.

### Behavioral Changes
For each meaningful change:

**[Label]**
Before: `[old behavior]`
After: `[new behavior]`
Impact: one sentence.

Pure refactor or docs-only? Say so in one sentence, skip this section.

### Standards
The Standards sub-agent's report, verbatim or lightly cleaned. Cite file and line. If none: "No issues found."

### Spec
The Spec sub-agent's `[D-N]` blocks, verbatim, or "No spec available" if Step 2 found none. Don't merge or rerank this against Standards findings — the two axes are deliberately separate (see _Why two axes_).

### Manual Review Checklist
Skip if nothing qualifies. For each item:

**File:** `path/to/file.ext` (lines X–Y)
**Why:** ...
**Check:** ...

Consider: business logic needing external context, third-party APIs, auth/credentials, irreversible DB ops, feature flags, test coverage gaps.

### Watch Out For
One paragraph: the thing a reviewer could easily miss.

### Questions for the Author
Skip if everything is clear. Each question should be paste-ready, with file, line, and snippet inline.

**File:** `path/to/file.ext`, line N
**Snippet:**
```lang
[relevant snippet]
```
**Question:** [Question to the author.]

### Commit Readiness

`READY` / `READY WITH NOTES` / `NOT READY`

**Safe to commit?** One sentence; call out any CRITICAL/WARNING Standards issues *and* any Spec-axis failures — a change that doesn't match its spec is still not ready, even with clean code.
**What could break?** Specific system or flow. "Nothing" if clean.
**Blockers:** (skip if READY) What must be fixed before committing.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the plan asked but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.

---
*Direct and specific. Cite files and lines. No padding.*
