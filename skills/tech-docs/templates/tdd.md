---
doc_type: tdd
status: draft
depends_on: [docs/design/prd.md, docs/design/app-flow.md]
related:
  - path: prd.md
    why: scope this architecture serves
  - path: app-flow.md
    why: flows this architecture supports
last_updated: YYYY-MM-DD
---

# [Product / Feature Name] — Technical Design Document

## Architecture Overview
Monolith / microservices / serverless; frontend vs. backend layout; communication channels.

```mermaid
flowchart LR
  Client --> Gateway[API Gateway] --> Service --> DB[(Database)]
```

### Key Flows
One `sequenceDiagram` per flow whose ordering across components isn't obvious from the diagram above (auth handshake, payment capture, async job).

```mermaid
sequenceDiagram
  Client->>Service: request
  Service->>DB: query
  DB-->>Service: rows
  Service-->>Client: response
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
