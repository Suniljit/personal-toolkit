---
name: ticketize
description: Break a feature brief into tracer-bullet vertical slice tickets for Codex execution. Use when the user says "ticketize", "create tickets", "break into tickets", "generate tickets", or when a feature-brief.md exists and the user wants actionable work items with an approval gate before ticket files are written.
---

# Ticketize

Break a feature brief into independently-grabbable tickets using vertical slices (tracer bullets).

## Ground Rules

- Preserve the approval gate: do not create or modify ticket files until the user approves the proposed breakdown.
- Do not modify the parent feature brief.
- Keep output concise and Codex-friendly: use Markdown tables for summaries, numbered lists for review questions, and clickable file links when reporting created local files.
- Make assumptions explicit. If the feature brief location or intended feature folder is ambiguous, ask before proceeding.
- Prefer the smallest complete vertical slices that are independently demoable or verifiable.

## Process

### 1. Locate the feature brief

Ask the user for the location if it is not obvious. Otherwise, look for `_features/<feature-name>/feature-brief.md`.

State the selected brief path before using it.

### 2. Explore the codebase

If unfamiliar with the codebase, inspect the minimum useful context before slicing:

- Read the feature brief.
- Check `INDEX.md` and relevant docs if the repository has them.
- Skim the directories likely touched by the feature.

Summarize only the assumptions that affect ticket slicing.

### 3. Draft vertical slices

Each ticket is a thin vertical slice cutting through all required integration layers end-to-end. Do not create horizontal layer slices such as "schema only", "API only", or "UI only" unless that slice is independently demoable and intentionally unblocks later vertical work.

Keep slices small: reviewable in a single focused PR (5-10 min). Prefer many thin slices over a few thick ones. When in doubt, split.

Each slice is either:

- **HITL** - requires human interaction, such as an architectural decision, design review, external approval, credential provisioning, or policy/business confirmation.
- **AFK** - can be implemented, tested, and merged autonomously.

Prefer AFK. Each slice must be demoable or verifiable on its own. Reference FR numbers and user stories from the brief rather than duplicating content.

### 4. Present the breakdown and get approval

Show the proposed breakdown in this Codex-friendly table:

| # | Title | Type | Blocked by | Coverage | Why this slice |
|---|-------|------|------------|----------|----------------|
| 01 | Short title | AFK | - | FR-1; US-2 | One concise reason this is independently useful. |

Use `-` for no blockers during proposal. Use tentative ticket numbers in dependency order so blockers are easy to inspect.

Then ask these approval questions:

1. Is the granularity right?
2. Are dependencies correct?
3. Should any slices be merged or split?
4. Are HITL/AFK labels correct?

Iterate until the user explicitly approves the breakdown. Do not write files before approval.

If the user asks for changes, revise the table and ask for approval again.

### 5. Create tickets

For each approved slice, create `_features/<feature-name>/tickets/<NN>-ticket-slug.md` with zero-padded numbers: `01`, `02`, and so on. Create tickets in dependency order so blockers have real ticket numbers.

```markdown
# [Short Ticket Title]

## Summary
One or two sentences: what this slice delivers end-to-end. Observable behaviour, not implementation details.

## Branch name
`feat/<slug>`

## What to build
End-to-end behaviour of this vertical slice. Reference the feature brief rather than duplicating it.

**Layers touched:** e.g. `schema · API · UI`

## Acceptance criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Implementation notes
Optional: brief pointers on where in the codebase this lives, gotchas, or relevant prior decisions.

## Feature brief coverage
**Functional requirements:** FR-1, FR-3
**User stories:** US-2, US-5

## Blocked by
- #02 - [Ticket title]

Or: _None - can start immediately._

## Status
`todo`
```

### 6. Create ticket_summary.md

Create `_features/<feature-name>/tickets/ticket_summary.md`:

```markdown
# <Feature Name> — Ticket Summary

| # | Ticket | Type | Blocked by | Status |
|---|--------|------|------------|--------|
| 01 | [Title](01-slug.md) | AFK | - | `todo` |
| 02 | [Title](02-slug.md) | HITL | #01 | `todo` |

## Execution order

- **Start immediately (parallel):** #01, #02
- **Unblocked after #01:** #03
- **Unblocked after #01 + #02:** #04, #05
```

Group execution order by dependency wave, not ticket number. Use `-` for tickets with no blockers.

## Final Response

After creating files, report:

- The feature brief used.
- The number of tickets created.
- A compact table with ticket number, title, type, blockers, and status.
- Clickable links to `ticket_summary.md` and the ticket directory when possible.
- Any validation that was run, or a short note if validation was not applicable.
