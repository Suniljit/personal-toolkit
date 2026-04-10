---
name: feature-plan
description: >
  Generate a concise design summary, potential architecture, and implementation plan for a
  single, smaller feature. Use this skill when the user wants a focused, task-ready document
  they can feed directly to a planner or builder agent. Trigger on phrases like "write up this
  feature", "make a plan for X", "generate a feature plan", "spec this out", "document this
  implementation", "plan this change", or whenever the scope is a single feature or fix that
  needs a structured plan before building. Output is a Markdown file saved to the repo.
---

# Feature Plan Generator

Synthesize a feature description or design discussion into a tight, **agent-ready Markdown plan**.
The primary output serves as direct input to a planner or builder agent — it should be specific
enough to act on without further clarification.

---

## Step 1: Determine save location

Save to `_docs/plans/` in the **current working directory** (the project root, not the global
`.claude/` folder where this skill is installed). Create the directory if it doesn't exist.

---

## Step 2: Derive a git slug

From the feature title, generate a branch name:
- lowercase, hyphen-separated
- max ~50 chars
- prefix with the most appropriate conventional type — common ones include `feat/`, `fix/`,
  `refactor/`, `chore/`, `spike/`, `test/`, `docs/`, `perf/`, `ci/` — but use your judgment;
  don't force a prefix that doesn't fit

Example: `feat/add-csv-export-to-reports`

Surface this slug to the user after saving.

---

## Step 3: Generate the document

Use the structure below. Every section must contain **real, specific content** — no placeholder
text in the final output. Keep it tight: this is a plan, not a PRD.

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

## 4. Implementation Plan

Break the work into phases. Each task should be small enough to become a single commit or PR.

### Phase 1: [Name]
- [ ] Task
- [ ] Task

### Phase 2: [Name]
- [ ] Task
- [ ] Task

---

## 5. Edge Cases & Error Handling

Known edge cases and how they're handled.

- ...

---

## 6. Out of Scope

Things explicitly not part of this plan. Not implied to be future work — just not in scope here.

- ...

---

## 7. Testing Guidelines

Create test file(s) under `./tests/` named after the feature (e.g., `tests/test_<feature>.py`
or `tests/<feature>.test.ts`). Write meaningful tests for the following cases — don't go heavy,
just cover what matters:

- **Happy path** — the core use case works end-to-end as expected
- **Edge cases from Section 5** — each named edge case should have at least one corresponding test
- **Invalid / bad input** — verify the feature fails gracefully (correct error type, message, or
  fallback behavior) when given malformed or unexpected input
- **Boundary conditions** — empty collections, zero values, max limits, or other boundary inputs
  relevant to this feature
- **Integration point** — if the feature touches an external service, DB, or module boundary,
  include at least one test that exercises that integration (can use a mock/stub)

Keep tests focused and readable. One assertion per test where practical. Avoid testing
implementation details — test observable behavior.
```

---

## Step 4: Save the file

Use the slug to derive the filename: strip the prefix and slash, e.g. `feat/add-csv-export`
→ `feat-add-csv-export.md`.

Confirm to the user:

> "Saved to `./_docs/plans/feat-add-csv-export-to-reports.md`.
> Recommended branch: `feat/add-csv-export-to-reports`."

---

## Guidelines

- **Agent-ready.** A planner agent receiving this doc should be able to start building
  immediately. No ambiguity, no open questions left hanging.
- **Architecture diagram is mandatory.** Use ASCII art — arrows, boxes, labels. Show what
  changes and what it touches. Keep it focused on this feature, not the whole system.
- **Implementation plan granularity.** Tasks should be commit-sized. If only phases were
  discussed, keep it at phase level — don't invent sub-tasks.
- **Out of Scope is not Future Work.** It means "not part of this plan" — it may or may not
  be picked up later. Don't frame it as planned next steps.
- **Tight, not thin.** Short sections are fine. Vague sections are not.
- **Date.** Use today's actual date.