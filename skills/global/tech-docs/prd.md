# Tech Docs — PRD flow

Read [`common/CONVENTIONS.md`](common/CONVENTIONS.md) first for the `docs/design/` layout and shared conventions.

Write the Product Requirement Document to `docs/design/prd.md`. This is the anchor doc — every other flow reads it.

---

## Step 1 — Gather inputs

You need a starting description: what's being built, and what problem it solves. Use a ticket, brief, or prior conversation if one already covers this; otherwise ask.

---

## Step 2 — Grill the user

Run a `/grilling` session, with `/domain-modeling` alongside it (see Grilling in CONVENTIONS.md), covering:

- **Problem statement & goals** — why this exists, the pain point, the business objective
- **Target persona** — primary users, their needs, roles/permissions (e.g. Admin vs. End User)
- **Feature scope** — must-haves (MVP), nice-to-haves (later phase), and out-of-scope (explicit, to block scope creep)
- **User stories** — `As a / I want / so that` plus `Given / When / Then` acceptance criteria, each tagged with the `FR-` feature it implements (a feature can cover several stories)
- **Success metrics (KPIs)** — concrete and measurable, tied to the goals above

**Considerations** — ground recommendations in these rather than guessing:
- **Feature scope:** sanity-check the must-have list against the categories a product like this usually needs — auth/onboarding, the core workflow itself, search/filter, notifications, admin/reporting, settings — and ask about any category conspicuously absent.
- **Success metrics:** anchor KPIs to a framework (AARRR for growth-stage products, HEART for usability-stage) rather than inventing ad hoc numbers; tie each metric back to a goal from the Problem Statement. For each one, pin down the instrumentation — the event or query that actually produces the number — since a KPI nobody can compute is the most common PRD defect.
- **Persona:** check for a role split (e.g. Admin vs. End User) even when the user describes only one persona — permissions gaps are a common PRD blind spot.
- **Scope boundary:** for every must-have, ask "what's the smallest version that ships" — an item sitting in Nice-to-haves is often a must-have's edge case in disguise, not a separate feature.

Lead each question with your recommended answer. Explore the codebase or existing docs before asking anything they'd already answer there.

When scope feels resolved, confirm:
> *"I think we have enough for the PRD. Saving to `docs/design/prd.md` — ready?"*

---

## Step 3 — Generate the doc

Read [`templates/prd.md`](templates/prd.md) and fill in every section — it's a floor, not a ceiling (see Beyond the template in CONVENTIONS.md).

Apply the overflow rule from CONVENTIONS.md if user stories exceed ~8 or the doc passes ~400 lines — keep the summary table in `prd.md`, move each `### [Story title]` section to `docs/design/prd/<story-slug>.md`.

---

## Step 4 — Save

Save to `docs/design/prd.md`. Add or update its row in the root `INDEX.md`'s **Design** table per CONVENTIONS.md.

## Completion criterion

`docs/design/prd.md` exists with every section filled (no placeholders) and `INDEX.md` has a current row for it.

Confirm:
> *"Saved to `docs/design/prd.md`."*
