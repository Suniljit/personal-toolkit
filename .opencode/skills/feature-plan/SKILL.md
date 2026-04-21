---
name: feature-plan
description: >
  Discuss and generate a concise design summary, potential architecture, and implementation plan
  for a feature or fix. Use this skill when the user wants to plan something before building —
  with or without a ticket and feature brief. Triggers on phrases like "feature-plan", "make a
  plan for X", "generate a feature plan", "spec this out", "plan this change", "grill me on
  this ticket", or "/plan-ticket". Always grills the user first before generating the plan.
  Output is a Markdown file saved to a location the user specifies.
---

# Feature Plan

Discuss a feature or fix thoroughly, then synthesize the conversation into a tight,
**agent-ready Markdown plan** saved to the repo.

There are two entry points — the workflow is identical for both, just with different
amounts of upfront context:

- **With ticket + feature brief** — ticket is the implementation spec, brief is background context
- **Without ticket/brief** — user describes the feature/issue directly

---

## Step 1 — Resolve inputs

Check what the user has provided. You need three things:

**1. Feature context** — always requires a free-form description from the user, plus optionally:
- A ticket file path + feature brief file path, if this is a formal ticket
- If no description was given (with or without a ticket), ask: *"Can you describe what you're trying to implement or solve?"*

**2. Plans save location** — always required. If not provided, ask:
> *"Where should I save the plan? (e.g. `_features/schedule-generation/plans/`)"*

**3. Additional context from the user** — collected during Step 2 (the grill phase). Even
when a ticket is provided, the user will add context during discussion that isn't in the ticket.

Ask for anything missing in a single message. Don't proceed until you have items 1 and 2.

---

## Step 2 — Grill the user

Interview the user relentlessly about every aspect of the feature until you reach a shared
understanding. Walk down each branch of the decision tree, resolving dependencies between
decisions one by one.

Rules:
- Ask questions **one at a time**
- For each question, provide your **recommended answer** as a starting point
- If a question can be answered by **exploring the codebase**, do that instead of asking
- If a ticket was provided, use it as the baseline — focus questions on gaps, ambiguities,
  and decisions not yet made in the ticket
- Track all decisions made, especially any that **deviate from the ticket** (needed in Step 5)
- Always use your question tool. 

Continue until the design feels fully resolved. When ready to move on, ask:

> *"I think we have enough to write the plan. Ready to generate it and save to `<plans_dir>`?"*

Wait for an explicit confirmation before proceeding.

---

## Step 3 — Generate the plan document

Synthesize everything from the ticket (if any), feature brief (if any), and the discussion
into the following structure. Every section must contain **real, specific content** — no
placeholder text in the final output. Keep it tight: this is a plan, not a PRD.

```markdown
# [Feature Title]

> **Branch:** `<slug>`
> **Date:** YYYY-MM-DD
> **Status:** Draft

---

## 1. Summary

One paragraph. What does this feature do, and why is it being built?

---

## 2. Design Decisions

Key decisions and the reasoning behind them.

| Decision | Choice | Rationale |
|---|---|---|
| ... | ... | ... |

---

## 3. Potential Architecture

ASCII diagram showing the structure, flow, or relationships relevant to this feature.

Example patterns to use as appropriate:

```
[Trigger] ──► [Handler] ──► [Service] ──► [Store]
                                │
                          [Side Effect]
```

```
┌──────────────┐     ┌──────────────┐
│  Old Module  │────►│  New Module  │
└──────────────┘     └──────┬───────┘
                            ▼
                     ┌──────────────┐
                     │   Storage    │
                     └──────────────┘
```

Focus on: what changes, what it touches, and where data flows.

---

## 4. Key Files

Files this feature touches or introduces. Keep it to what's directly relevant.

| File | Change |
|---|---|
| `path/to/file.ts` | e.g. Add new handler |
| `path/to/file.ts` | e.g. New file |

---

## 5. Implementation Plan

Break the work into phases. Each phase should be small enough to become a single commit. All phases together form one PR.

### Phase 1: [Name]
- [ ] Task
- [ ] Task

### Phase 2: [Name]
- [ ] Task
- [ ] Task

---

## 6. Edge Cases & Error Handling

Known edge cases and how they're handled.

- ...

---

## 7. Out of Scope

Things explicitly not part of this plan. Not implied to be future work — just not in scope here.

- ...

---

## 8. Testing

- **Happy path** — core use case works end-to-end
- **Edge cases** — one test per case listed in Section 6
- **Bad input** — feature fails gracefully on malformed or unexpected input
- **Integration points** — any external service, DB, or module boundary touched by this feature
```

---

## Step 4 — Save the file

Derive a git slug from the feature title:
- lowercase, hyphen-separated, max ~50 chars
- prefix with the most appropriate conventional type: `feat/`, `fix/`, `refactor/`, `chore/`,
  `spike/`, `test/`, `docs/`, `perf/`, `ci/` — use judgment, don't force a prefix that doesn't fit

Filename: strip the prefix and slash from the slug — e.g. `feat/add-csv-export` → `feat-add-csv-export.md`.

Save to `<plans_dir>`. Create the directory if it doesn't exist.

Confirm to the user:
> *"Saved to `<plans_dir>/feat-add-csv-export.md`. Recommended branch: `feat/add-csv-export`."*

---

## Step 5 — Patch the ticket if one was provided

Review decisions tracked in Step 2. If any deviate from the ticket as written:

1. Re-read the ticket file
2. Apply targeted edits using `str_replace` — only change what was actually decided differently;
   don't rewrite the whole ticket
3. Tell the user exactly what was changed and why

If no deviations, skip this step and say so explicitly.

---

## Guidelines

- **Agent-ready.** A planner agent receiving this doc should be able to start building
  immediately. No ambiguity, no open questions left hanging.
- **Architecture diagram is mandatory.** Use ASCII art — arrows, boxes, labels. Show what
  changes and what it touches. Keep it focused on this feature, not the whole system.
- **Implementation plan granularity.** Each phase should be commit-sized. All phases together form one PR. If only high-level phases were discussed, keep it at that level — don't invent sub-tasks.
- **Out of Scope is not Future Work.** It means "not part of this plan" — it may or may not
  be picked up later. Don't frame it as planned next steps.
- **Tight, not thin.** Short sections are fine. Vague sections are not.
- **Date.** Use today's actual date.
- **Confirm before coding.** Never start writing code during this skill — the output is a plan doc only.