# Tech Docs — Data Schema flow

Read [`common/CONVENTIONS.md`](common/CONVENTIONS.md) first for the `docs/design/` layout and shared conventions.

Write the Data Schema & Model Specification to `docs/design/data-schema.md`.

---

## Step 1 — Read the PRD and TDD

Read `docs/design/prd.md` (for the entities implied by feature scope) and `docs/design/tdd.md` (for the database engine chosen). If the TDD is missing, stop and say so — the schema depends on the engine it names; run `/tech-docs tdd` first.

---

## Step 2 — Grill the user

Run a `/grilling` session, with `/domain-modeling` alongside it (see Grilling in CONVENTIONS.md), covering, per entity:

- **Data models & tables** — entity names, fields/attributes, data types, nullability, defaults
- **Relationships** — foreign keys, cardinality (1:1, 1:N, N:M), cascading rules
- **Indexes & constraints** — primary keys, unique indexes, composite indexes for known query patterns, check constraints
- **Data lifecycle strategy** — soft vs. hard deletes, auditing fields (`created_at`, `updated_at`, `deleted_at`), migration strategy

**Considerations** — ground recommendations in these rather than guessing:
- **Entities:** derive the initial list from nouns in the PRD's must-haves and user stories, then ask what's implied but unnamed (e.g. an "Order" implies an "OrderItem").
- **Relationships:** for every N:M relationship, confirm a junction table rather than modeling it as two 1:N's; for every FK, decide the cascade rule (cascade / restrict / set-null) explicitly rather than defaulting.
- **Indexes:** derive candidate indexes from the query patterns in `app-flow.md`'s core loops, not just from primary/foreign keys.
- **Lifecycle:** if the data includes PII or payment info, flag soft-delete and audit-trail requirements now — they're expensive to retrofit.

Lead each question with your recommended answer. Derive the entity list from the PRD's must-haves first, then ask what's missing — don't ask the user to enumerate from scratch.

When the schema feels complete, confirm:
> *"I think we have the schema. Saving to `docs/design/data-schema.md` — ready?"*

---

## Step 3 — Generate the doc

Read [`templates/data-schema.md`](templates/data-schema.md) and fill in every section — it's a floor, not a ceiling (see Beyond the template in CONVENTIONS.md).

Apply the overflow rule from CONVENTIONS.md once there are more than ~8 tables — keep the ER diagram and the table-of-tables in `data-schema.md`, move each `### [table_name]` section to `docs/design/data-schema/<table>.md`.

---

## Step 4 — Save

Save to `docs/design/data-schema.md`. Add or update its row in the root `INDEX.md`'s **Design** table per CONVENTIONS.md.

## Completion criterion

`docs/design/data-schema.md` exists with every section filled (no placeholders) and `INDEX.md` has a current row for it.

Confirm:
> *"Saved to `docs/design/data-schema.md`."*
