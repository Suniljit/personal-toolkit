---
name: feature-plan
description: >
  Document a feature or fix as an implementation-ready Markdown plan. 
disable-model-invocation: true
---

# Feature Plan

Save a tight **agent-ready Markdown plan** to `_specs/`.

The feature context comes from a completed `grill-with-docs` or `grill-me` session — decisions, constraints, and rationale should already be in the conversation.

---

## Step 1 — Check INDEX.md

Look for an `INDEX.md` at the project root. If it exists:
1. Read it
2. Identify which docs are affected by this feature

If no `INDEX.md` exists, note it and skip — the plan's **Docs to Update** section will be empty.

---

## Step 2 — Generate the plan

Synthesize the grilling session discussion, plus the affected docs from Step 1, into every section of [template.md](template.md), in order.

**Brevity principle:** Every section should be as short as possible while still being useful. Prefer bullet points over prose. Cut words that don't add meaning. Extra detail is only warranted when it genuinely helps a reader understand something non-obvious — not just to be thorough.

**No guessing.** A fresh agent picks up the saved plan with no memory of the grilling session. If a detail needed to implement isn't nailed down in the conversation — a file path, a type shape, a config value — resolve it before writing the section, don't leave it implicit or write around it.

---

## Step 3 — Save the file

Derive a git slug from the feature title:
- lowercase, hyphen-separated, max ~50 chars
- prefix with the right conventional type: `feat/`, `fix/`, `refactor/`, `chore/`, `spike/`, `test/`, `docs/`, `perf/`, `ci/`

Filename: strip the prefix/slash — e.g. `feat/add-csv-export` → `feat-add-csv-export.md`

Save to `_specs/`. Create it if needed.

Confirm:
> *"Saved to `_specs/feat-add-csv-export.md`. Recommended branch: `feat/add-csv-export`."*

---

## Guidelines

- **Agent-ready.** A planner agent should be able to start immediately — no open questions.
- **Brief.** Short plans get read; long plans get skimmed. Cut mercilessly.
- **Problem before Solution.** State what's broken or missing before what fixes it — lets a human reviewer sanity-check the diagnosis before reading the plan.
- **Architecture diagram is mandatory.** ASCII, focused on this feature.
- **Phases = commits.** Don't invent sub-tasks if only high-level phases were discussed.
- **Acceptance Criteria is mandatory and checkable.** It's the target state a reviewer or fresh agent verifies against — distinct from the per-phase task checklists, which are steps, not outcomes.
- **Out of Scope ≠ Future Work.** It just means "not here."
- **No placeholders.** Every section has real content or is explicitly noted as N/A.
- **Code Shape and Validation Rules are optional.** Include them when they add real clarity; omit them for simple CRUD or UI-only changes.
- **Logging is always included.** Even simple features should document at minimum their entry/exit and error events. DEBUG-level input/output tracing (functions, LLM calls, DB queries) should be included for non-trivial features.
- **Don't write code.** Output is a plan doc only.
- **Committed.** The plan lives in `_specs/` and is checked into git alongside the code it describes.