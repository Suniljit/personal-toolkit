---
doc_type: data-schema
status: draft
depends_on: [docs/design/prd.md, docs/design/tdd.md]
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
