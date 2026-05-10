---
name: ticketize
description: Break a feature brief into tracer-bullet vertical slice tickets. Trigger on "ticketize", "create tickets", "break into tickets", "generate tickets", or whenever a feature-brief.md exists and the user wants actionable work items.
---

# Ticketize

Break a feature brief into independently-grabbable tickets using vertical slices (tracer bullets).

## Process

### 1. Locate the feature brief

Ask the user for the location, or look for `_features/<feature-name>/feature-brief.md`.

### 2. Explore the codebase (optional)

If unfamiliar with the codebase, explore it to understand current state before slicing.

### 3. Draft vertical slices

Each ticket is a thin vertical slice cutting through ALL integration layers end-to-end — not a horizontal layer slice.

**Keep slices small**: reviewable in a single focused PR (5–10 min). Prefer many thin slices over few thick ones. When in doubt, split.

Each slice is either:
- **HITL** — requires human interaction (architectural decision, design review, external approval)
- **AFK** — can be implemented and merged autonomously

Prefer AFK. Each slice must be demoable or verifiable on its own. Reference FR numbers and user stories from the brief rather than duplicating content.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each slice:

- **Title**, **Type** (HITL/AFK), **Blocked by**, **Feature brief coverage** (FRs + user stories)

Ask: Is the granularity right? Are dependencies correct? Should any slices be merged or split? Are HITL/AFK labels correct?

Iterate until approved.

### 5. Create tickets

For each approved slice, create `_features/<feature-name>/tickets/<NN>-ticket-slug.md` (zero-padded: `01`, `02`, …). Create in dependency order so blockers have real ticket numbers.

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
- #02 — [Ticket title]

Or: _None — can start immediately._

## Status
`todo`
```

Do NOT modify the parent feature brief.

### 6. Create ticket_summary.md

Create `_features/<feature-name>/tickets/ticket_summary.md`:

```markdown
# <Feature Name> — Ticket Summary

| # | Ticket | Type | Blocked by | Status |
|---|--------|------|------------|--------|
| 01 | [Title](01-slug.md) | AFK | — | `todo` |
| 02 | [Title](02-slug.md) | HITL | #01 | `todo` |

## Execution order

- **Start immediately (parallel):** #01, #02
- **Unblocked after #01:** #03
- **Unblocked after #01 + #02:** #04, #05
```

Group execution order by dependency wave, not ticket number. Use `—` for tickets with no blockers.