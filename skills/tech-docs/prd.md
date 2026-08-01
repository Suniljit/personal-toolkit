# Tech Docs — PRD flow

Read [`common/CONVENTIONS.md`](common/CONVENTIONS.md) first for the `docs/blueprint/` layout and shared conventions.

Write the Product Requirement Document to `docs/blueprint/prd.md`. This is the anchor doc — every other flow reads it.

---

## Step 1 — Gather inputs

You need a starting description: what's being built, and what problem it solves. Use a ticket, brief, or prior conversation if one already covers this; otherwise ask.

---

## Step 2 — Grill the user

Run a `/grilling` session, with `/domain-modeling` alongside it (see Grilling in CONVENTIONS.md), covering:

- **Problem statement & goals** — why this exists, the pain point, the business objective
- **Target persona** — primary users, their needs, roles/permissions (e.g. Admin vs. End User)
- **Feature scope** — must-haves (MVP), nice-to-haves (later phase), and out-of-scope (explicit, to block scope creep)
- **User stories** — one per must-have feature, as `Given / When / Then`
- **Success metrics (KPIs)** — concrete and measurable, tied to the goals above

Lead each question with your recommended answer. Explore the codebase or existing docs before asking anything they'd already answer there.

When scope feels resolved, confirm:
> *"I think we have enough for the PRD. Saving to `docs/blueprint/prd.md` — ready?"*

---

## Step 3 — Generate the doc

```markdown
---
doc_type: prd
status: draft
depends_on: []
last_updated: YYYY-MM-DD
---

# [Product / Feature Name] — PRD

## Problem Statement & Goals
Why this exists, the pain point, the business objective.

## Target Persona
| Persona | Needs | Role / Permissions |
|---|---|---|

## Feature Scope

### Must-haves (MVP)
- ...

### Nice-to-haves
- ...

### Out-of-scope
- ...

## User Stories & Acceptance Criteria
### [Story title]
**Given** ... **When** ... **Then** ...

## Success Metrics (KPIs)
| Metric | Target | How measured |
|---|---|---|

## Related
```

Apply the overflow rule from CONVENTIONS.md if user stories exceed ~8 or the doc passes ~400 lines — split stories out to `docs/blueprint/prd/<story-slug>.md`, one-line summary + link in the table above.

---

## Step 4 — Save

Save to `docs/blueprint/prd.md`. Add or update its row in the root `INDEX.md`'s **Blueprint** table per CONVENTIONS.md.

## Completion criterion

`docs/blueprint/prd.md` exists with every section filled (no placeholders) and `INDEX.md` has a current row for it.

Confirm:
> *"Saved to `docs/blueprint/prd.md`. Next: `/tech-docs app-flow`."*
