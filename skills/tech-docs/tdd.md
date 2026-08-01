# Tech Docs — TDD flow

Read [`common/CONVENTIONS.md`](common/CONVENTIONS.md) first for the `docs/blueprint/` layout and shared conventions.

Write the Technical Design Document to `docs/blueprint/tdd.md`. This is the second anchor — Data Schema, API Contracts, and NFR all read it.

---

## Step 1 — Read the PRD and App Flow

Read `docs/blueprint/prd.md` and `docs/blueprint/app-flow.md`. If either is missing, stop and say so — the architecture is chosen to serve the scope and flows they define; run those flows first.

---

## Step 2 — Grill the user

Run a `/grilling` session, with `/domain-modeling` alongside it (see Grilling in CONVENTIONS.md), covering:

- **Architecture overview** — monolith, microservices, or serverless; frontend/backend layout; communication channels between them
- **Tech stack selection** — frontend framework, backend runtime, database engine(s), caching layer, hosting platform
- **Third-party tools & services** — external APIs, auth provider (e.g. Auth0, Clerk), payment gateway, email/notification service

Lead each question with your recommended answer. Check the existing codebase for a stack already in use before asking — don't relitigate a choice that's already made.

For each **key technical decision** — hard to reverse, surprising without context, a real trade-off — `/domain-modeling` records it as an ADR under `docs/adr/` as it surfaces, rather than writing decisions inline here.

When the design feels complete, confirm:
> *"I think we have the technical design. Saving to `docs/blueprint/tdd.md` — ready?"*

---

## Step 3 — Generate the doc

```markdown
---
doc_type: tdd
status: draft
depends_on: [docs/blueprint/prd.md, docs/blueprint/app-flow.md]
last_updated: YYYY-MM-DD
---

# [Product / Feature Name] — Technical Design Document

## Architecture Overview
Monolith / microservices / serverless; frontend vs. backend layout; communication channels.

```
[Client] ──► [API Gateway] ──► [Service] ──► [DB]
```

## Tech Stack Selection
| Layer | Choice |
|---|---|
| Frontend framework | |
| Backend runtime | |
| Database | |
| Caching | |
| Hosting | |

## Third-Party Tools & Services
| Service | Purpose | Provider |
|---|---|---|
| Auth | | |
| Payments | | |
| Email/notifications | | |

## Key Technical Decisions (ADRs)
| ADR | Decision |
|---|---|
| [ADR-001](../adr/0001-....md) | ... |

## Related
- [PRD](prd.md) — scope this architecture serves
- [App Flow](app-flow.md) — flows this architecture supports
```

This doc rarely needs the overflow split — ADR detail already lives in `docs/adr/` (owned by `/domain-modeling`), so the table above stays a pointer, not inline content, regardless of how many ADRs accumulate.

---

## Step 4 — Save

Save to `docs/blueprint/tdd.md`. Add or update its row in the root `INDEX.md`'s **Blueprint** table per CONVENTIONS.md.

## Completion criterion

`docs/blueprint/tdd.md` exists with every section filled (no placeholders) and `INDEX.md` has a current row for it.

Confirm:
> *"Saved to `docs/blueprint/tdd.md`. Next: `/tech-docs data-schema`, and `/tech-docs nfr` once the schema and API are settled."*
