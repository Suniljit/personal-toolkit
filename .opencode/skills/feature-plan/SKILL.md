---
name: feature-plan
description: >
  Plan a feature or fix before building it. Triggers on "feature-plan", "make a plan for X",
  "spec this out", "plan this change", "grill me on this ticket", or "/plan-ticket". Works
  with or without a formal ticket. Always interviews the user first, then saves a Markdown
  plan to the repo. Use this skill any time a user wants to think through and document a
  feature before writing code.
---

# Feature Plan

Interview the user thoroughly, then save a tight **agent-ready Markdown plan** to the repo.

Two entry points — same workflow, different starting context:
- **With ticket + brief** — ticket is the spec, brief is background
- **No ticket** — user describes the feature directly

---

## Step 1 — Gather inputs

You need one thing before starting:

**Feature description** — what are we building or fixing?
- If a ticket/brief path was given, read those files
- If no description exists, ask: *"What are you trying to build or fix?"*

Don't ask about save location yet — that's resolved in Step 5.

---

## Step 2 — Grill the user

Interview the user relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Rules:
- Use the question tool for every question. One question (or tight cluster) at a time.
- Lead with your **recommended answer** with brief rationale — don't just ask open questions
- If the codebase can answer a question, **explore it** instead of asking
- If a ticket exists, focus on **gaps and unresolved decisions** — don't re-litigate what's settled
- **Track every decision**, especially deviations from the ticket (needed in Step 5)

When you feel the design is fully resolved:
> *"I think we have enough to write the plan. Ready to save to `<plans_dir>`?"*

Wait for explicit confirmation.

---

## Step 3 — Generate the plan

Synthesize the ticket (if any), brief (if any), and discussion into the template below.

**Brevity principle:** Every section should be as short as possible while still being useful. Prefer bullet points over prose. Cut words that don't add meaning. Extra detail is only warranted when it genuinely helps a reader understand something non-obvious — not just to be thorough.

```markdown
# [Feature Title]

> 🌿 **Branch:** `<slug>` · 📅 **Date:** YYYY-MM-DD

## What & Why
One or two sentences. What does this do, and why now?

## Decisions
Two-tier table. **Constraints** are pre-existing and non-negotiable (ticket requirements, infra
limits, existing conventions). **Choices** were made during planning and had real alternatives.
Omit rows that are obvious from the codebase.

| Type | Decision | Choice | Why |
|---|---|---|---|
| Constraint | ... | ... | ... |
| Choice | ... | ... | ... |

## Architecture
ASCII diagram — what changes, what it touches, how data flows.

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

## Key Files

| File | What changes |
|---|---|
| `path/to/file.ts` | Add new handler |

## Code Shape
_Optional — include only when interface design is non-obvious or worth locking in early._

Key types, interfaces, or function signatures. Sketch-level only — not full implementation.

```ts
// Example: port interface
export interface MyRepository {
  findById(id: string): Promise<MyRecord | null>;
}

// Example: request/response shape
type MyRequest = { id: string };
type MyResponse = { result: string | null };
```

## Validation Rules
_Optional — include only when there are non-trivial input constraints._

- `fieldName`: constraint (e.g. non-empty string, integer 2000–2100, valid ISO code)
- Normalize: trim, uppercase, deduplicate before processing
- Reject: what invalid input looks like and the expected error response

## Implementation Plan
Phases small enough to be a single commit.

### Phase 1: [Name]
- [ ] Task

### Phase 2: [Name]
- [ ] Task

## Risks & Unknowns
- ...

## Edge Cases
Only list edge cases that aren't obvious or need special handling.
- ...

## Out of Scope
- ...

## Docs to Update
- ...

## Testing
What to test and why it matters — skip anything that just proves the language works.
- ...
```

---

## Step 4 — Check INDEX.md

Before saving, look for an `INDEX.md` at the project root. If it exists:
1. Read it
2. Identify which docs are affected by this feature
3. Fill in the **Docs to Update** section

If no `INDEX.md` exists, note it and skip.

---

## Step 5 — Save the file

**Resolve save location first** — explore the repo before asking:
- Look for an existing plans directory (e.g. `_features/plans/`, `docs/plans/`, `.plans/`)
- If found, use it without asking
- If not found, propose `_features/plans/` and confirm with the user before creating it

Derive a git slug from the feature title:
- lowercase, hyphen-separated, max ~50 chars
- prefix with the right conventional type: `feat/`, `fix/`, `refactor/`, `chore/`, `spike/`, `test/`, `docs/`, `perf/`, `ci/`

Filename: strip the prefix/slash — e.g. `feat/add-csv-export` → `feat-add-csv-export.md`

Save to the resolved directory. Create it if needed.

Confirm:
> *"Saved to `<plans_dir>/feat-add-csv-export.md`. Recommended branch: `feat/add-csv-export`."*

---

## Step 6 — Patch the ticket (if one was provided)

Review decisions from Step 2. If any deviate from the ticket:
1. Re-read the ticket file
2. Apply targeted edits via `str_replace` — only change what was actually decided differently
3. Tell the user what changed and why

If no deviations, say so explicitly.

---

## Guidelines

- **Agent-ready.** A planner agent should be able to start immediately — no open questions.
- **Brief.** Short plans get read; long plans get skimmed. Cut mercilessly.
- **Architecture diagram is mandatory.** ASCII, focused on this feature.
- **Phases = commits.** Don't invent sub-tasks if only high-level phases were discussed.
- **Out of Scope ≠ Future Work.** It just means "not here."
- **No placeholders.** Every section has real content or is explicitly noted as N/A.
- **Code Shape and Validation Rules are optional.** Include them when they add real clarity; omit them for simple CRUD or UI-only changes.
- **Don't write code.** Output is a plan doc only.