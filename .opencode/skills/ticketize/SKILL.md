---
name: ticketize
description: Break a feature brief into independently-grabbable tickets using tracer-bullet vertical slices. Use when the user wants to convert a feature brief to tickets, create implementation tickets, or break down a feature brief into work items. Trigger on phrases like "ticketize", "create tickets", "break into tickets", "generate tickets from brief", "turn brief into tasks", or whenever a feature-brief.md exists and the user wants actionable work items from it.
---

# Feature Brief to Tickets

Break a feature brief into independently-grabbable tickets using vertical slices (tracer bullets).

## Process

### 1. Locate the Feature Brief

Ask the user for the feature brief location, or look for `_features/<feature-name>/feature-brief.md` in the project root.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code.

### 3. Draft vertical slices

Break the feature brief into **tracer bullet** tickets. Each ticket is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal layer slice.

**Keep slices small**: each ticket should represent a change set that can be reviewed in a single, focused PR — reviewable in 5–10 minutes. Prefer many thin slices over few thick ones. When in doubt, split.

Slices may be 'HITL' or 'AFK':
- **HITL** — requires human interaction (architectural decision, design review, external approval)
- **AFK** — can be implemented and merged without human interaction

Prefer AFK over HITL where possible.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer it touches (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones — small PRs merge faster and are easier to review
- Reference FR numbers and user stories from the feature brief rather than duplicating content
</vertical-slice-rules>

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices (if any) must complete first
- **Feature brief coverage**: which FRs and user stories this addresses

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL and AFK?

Iterate until the user approves the breakdown.

### 5. Create the tickets

For each approved slice, create a ticket as a Markdown file in `_features/<feature-name>/tickets/`. Use zero-padded two-digit filenames: `01-ticket-slug.md`, `02-ticket-slug.md`, etc.

Create tickets in dependency order (blockers first) so you can reference real ticket numbers in the "Blocked by" field.

<ticket-template>
# [Short Ticket Title]

## Summary

One or two sentences describing what this slice delivers end-to-end. Focus on observable behaviour, not implementation details.

## Branch name

`feature/<slug>` — e.g. `feature/add-user-invite-api`

## What to build

A concise description of this vertical slice. Describe the end-to-end behaviour, not layer-by-layer implementation. Reference the parent feature brief for context rather than duplicating it.

**Layers touched:** e.g. `schema · API · UI` or `API · tests` — list only what this ticket changes.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Implementation notes

Optional: brief pointers on *where* in the codebase or architecture this change lives, any gotchas, or relevant prior decisions from the feature brief. Keep it short — this is a hint, not a design doc.

## Feature brief coverage

**Functional requirements:** FR-1, FR-3
**User stories:** US-2, US-5

## Blocked by

- #02 — [Ticket title] (if any)

Or: _None — can start immediately._

## Status

`todo` <!-- Change to: in-progress | in-review | done -->
</ticket-template>

Do NOT modify the parent feature brief.

### 6. Create ticket_summary.md

After all tickets are created, generate `_features/<feature-name>/tickets/ticket_summary.md`.

Use this template:

```markdown
# <Feature Name> — Ticket Summary

| # | Ticket | Type | Blocked by | Status |
|---|--------|------|------------|--------|
| 01 | [Ticket Title](01-ticket-slug.md) | HITL/AFK | — | `todo` |
| 02 | [Ticket Title](02-ticket-slug.md) | AFK | #01 | `todo` |
...

## Execution order

- **Start immediately (parallel):** #01, #02
- **Unblocked after #01:** #03
- **Unblocked after #01 + #02:** #04, #05
...
```

**Status values:** `todo` · `in-progress` · `in-review` · `done`

Use zero-padded two-digit ticket numbers (01, 02, …). Use `—` for tickets with no blockers. Group the execution order section by dependency wave, not by ticket number.

---

## Folder structure

```
_features/
└── <feature-name>/
    ├── feature-brief.md
    └── tickets/
        ├── ticket_summary.md
        ├── 01-ticket-slug.md
        ├── 02-ticket-slug.md
        └── ...
```