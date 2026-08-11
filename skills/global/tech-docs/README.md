# Tech Docs

Seven documents, one concern each, generated in sequence via `/tech-docs <flow>`:

1. **PRD** — `/tech-docs prd` — problem, personas, scope, success metrics. The anchor; everything else depends on it.
2. **App Flow & User Journeys** — `/tech-docs app-flow` — onboarding, core loops, screen map, edge logic. Depends on PRD.
3. **Design Brief & UI System** — `/tech-docs design-brief` — brand, design tokens, components, layouts. Depends on PRD, App Flow.
4. **Technical Design Document** — `/tech-docs tdd` — architecture, stack, third-party services, ADRs. Depends on PRD, App Flow.
5. **Data Schema & Model Spec** — `/tech-docs data-schema` — tables, relationships, constraints, lifecycle. Depends on TDD.
6. **API Interface Contracts** — `/tech-docs api-contracts` — an OpenAPI 3.1 spec plus the auth, versioning, and error policy around it. Depends on Data Schema, TDD.
7. **NFRs & Operational Strategy** — `/tech-docs nfr` — performance, security, deploy pipeline, observability. Depends on TDD.

## Sequence

```
1 PRD ──► 2 App Flow ──┬──► 3 Design Brief
                        └──► 4 TDD ──► 5 Data Schema ──► 6 API Contracts
                                    └──────────────────► 7 NFR
```

3 and 4 can run in either order, or as separate sessions, once App Flow is done — neither reads the other. Everything past 4 needs the TDD's architecture and stack decisions.

## Where the docs live

All seven are written to `docs/design/`, indexed from the project root's `INDEX.md`. See [common/CONVENTIONS.md](common/CONVENTIONS.md) for the exact layout, frontmatter, traceability IDs, diagram conventions, and how large docs split into overflow files.

## Picking where to start

- Nothing exists yet → start at 1, `/tech-docs prd`.
- `docs/design/` already has some docs → check the root `INDEX.md`'s **Design** table, find the first doc in the sequence above that isn't written yet whose dependencies already exist, and run that flow.
- You know which doc you want → run its flow directly. If its dependencies don't exist yet, the flow says so and points you at the right one to start with instead.
