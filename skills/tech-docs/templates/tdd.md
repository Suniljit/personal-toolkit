---
doc_type: tdd
status: draft
depends_on: [docs/design/prd.md, docs/design/app-flow.md]
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
