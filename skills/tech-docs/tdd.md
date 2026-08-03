# Tech Docs — TDD flow

Read [`common/CONVENTIONS.md`](common/CONVENTIONS.md) first for the `docs/design/` layout and shared conventions.

Write the Technical Design Document to `docs/design/tdd.md`. This is the second anchor — Data Schema, API Contracts, and NFR all read it.

---

## Step 1 — Read the PRD and App Flow

Read `docs/design/prd.md` and `docs/design/app-flow.md`. If either is missing, stop and say so — the architecture is chosen to serve the scope and flows they define; run those flows first.

---

## Step 2 — Grill the user

Run a `/grilling` session, with `/domain-modeling` alongside it (see Grilling in CONVENTIONS.md), covering:

- **Architecture overview** — monolith, microservices, or serverless; frontend/backend layout; communication channels between them
- **Tech stack selection** — frontend framework, backend runtime, database engine(s), caching layer, hosting platform
- **Third-party tools & services** — external APIs, auth provider (e.g. Auth0, Clerk), payment gateway, email/notification service

**Considerations** — ground recommendations in these rather than guessing:
- **Architecture:** let expected scale (traffic, team size, release cadence) drive monolith-vs-microservices — recommend a monolith by default unless the PRD's scope or team structure argues otherwise.
- **Tech stack:** favor what the existing codebase or team already knows over a "better" unfamiliar choice, unless the user explicitly wants to introduce something new.
- **Third-party services:** for each vendor considered, flag lock-in risk, cost at the scale implied by the PRD's success metrics, and data residency if the app handles regulated data.

Lead each question with your recommended answer. Check the existing codebase for a stack already in use before asking — don't relitigate a choice that's already made.

For each **key technical decision** — hard to reverse, surprising without context, a real trade-off — `/domain-modeling` records it as an ADR under `docs/adr/` as it surfaces, rather than writing decisions inline here.

When the design feels complete, confirm:
> *"I think we have the technical design. Saving to `docs/design/tdd.md` — ready?"*

---

## Step 3 — Generate the doc

Read [`templates/tdd.md`](templates/tdd.md) and fill in every section — it's a floor, not a ceiling (see Beyond the template in CONVENTIONS.md).

This doc rarely needs the overflow split — ADR detail already lives in `docs/adr/` (owned by `/domain-modeling`), so the table above stays a pointer, not inline content, regardless of how many ADRs accumulate.

---

## Step 4 — Save

Save to `docs/design/tdd.md`. Add or update its row in the root `INDEX.md`'s **Design** table per CONVENTIONS.md.

## Completion criterion

`docs/design/tdd.md` exists with every section filled (no placeholders) and `INDEX.md` has a current row for it.

Confirm:
> *"Saved to `docs/design/tdd.md`."*
