---
doc_type: data-schema
status: draft
depends_on: [docs/design/prd.md, docs/design/tdd.md]
related:
  - path: prd.md
    why: feature scope these entities support
  - path: tdd.md
    why: database engine this schema targets
last_updated: YYYY-MM-DD
---

# [Product / Feature Name] — Data Schema & Model Specification

## Entity-Relationship Overview
```mermaid
erDiagram
  USER ||--o{ ORDER : places
  PRODUCT ||--o{ ORDER : "appears in"
```

## Tables
| Table | Implements | Summary |
|---|---|---|
| `users` | `FR-01` | ... |

### `[table_name]`
| Field | Type | Nullable | Default | Notes |
|---|---|---|---|---|

**Relationships:** FK, cardinality, cascade rule.
**Indexes & constraints:** PK, unique, composite, check.

## Data Lifecycle Strategy
Soft vs. hard deletes, auditing fields, migration strategy.
