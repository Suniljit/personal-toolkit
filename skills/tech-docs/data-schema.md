# Tech Docs — Data Schema flow

Read [`common/CONVENTIONS.md`](common/CONVENTIONS.md) first for the `docs/blueprint/` layout and shared conventions.

Write the Data Schema & Model Specification to `docs/blueprint/data-schema.md`.

---

## Step 1 — Read the PRD and TDD

Read `docs/blueprint/prd.md` (for the entities implied by feature scope) and `docs/blueprint/tdd.md` (for the database engine chosen). If the TDD is missing, stop and say so — the schema depends on the engine it names; run `/tech-docs tdd` first.

---

## Step 2 — Grill the user

Run a `/grilling` session, with `/domain-modeling` alongside it (see Grilling in CONVENTIONS.md), covering, per entity:

- **Data models & tables** — entity names, fields/attributes, data types, nullability, defaults
- **Relationships** — foreign keys, cardinality (1:1, 1:N, N:M), cascading rules
- **Indexes & constraints** — primary keys, unique indexes, composite indexes for known query patterns, check constraints
- **Data lifecycle strategy** — soft vs. hard deletes, auditing fields (`created_at`, `updated_at`, `deleted_at`), migration strategy

Lead each question with your recommended answer. Derive the entity list from the PRD's must-haves first, then ask what's missing — don't ask the user to enumerate from scratch.

When the schema feels complete, confirm:
> *"I think we have the schema. Saving to `docs/blueprint/data-schema.md` — ready?"*

---

## Step 3 — Generate the doc

```markdown
---
doc_type: data-schema
status: draft
depends_on: [docs/blueprint/prd.md, docs/blueprint/tdd.md]
last_updated: YYYY-MM-DD
---

# [Product / Feature Name] — Data Schema & Model Specification

## Entity-Relationship Overview
```
[User] 1───N [Order] N───1 [Product]
```

## Tables
| Table | Summary |
|---|---|
| `users` | ... |

### `[table_name]`
| Field | Type | Nullable | Default | Notes |
|---|---|---|---|---|

**Relationships:** FK, cardinality, cascade rule.
**Indexes & constraints:** PK, unique, composite, check.

## Data Lifecycle Strategy
Soft vs. hard deletes, auditing fields, migration strategy.

## Related
- [PRD](prd.md) — feature scope these entities support
- [TDD](tdd.md) — database engine this schema targets
```

Apply the overflow rule from CONVENTIONS.md once there are more than ~8 tables — keep the ER diagram and the table-of-tables in `data-schema.md`, move each `### [table_name]` section to `docs/blueprint/data-schema/<table>.md`.

---

## Step 4 — Save

Save to `docs/blueprint/data-schema.md`. Add or update its row in the root `INDEX.md`'s **Blueprint** table per CONVENTIONS.md.

## Completion criterion

`docs/blueprint/data-schema.md` exists with every section filled (no placeholders) and `INDEX.md` has a current row for it.

Confirm:
> *"Saved to `docs/blueprint/data-schema.md`. Next: `/tech-docs api-contracts`."*
