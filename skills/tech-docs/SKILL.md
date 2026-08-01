---
name: tech-docs
description: >
  Seven-document technical documentation suite — PRD, App Flow, Design Brief,
  TDD, Data Schema, API Contracts, NFR. Branch selected by the first word of
  the invocation (prd | app-flow | design-brief | tdd | data-schema |
  api-contracts | nfr).
disable-model-invocation: true
---

# Tech Docs

One skill, seven flows, dispatched by the first word of what follows `/tech-docs`. All seven share the layout and conventions in [`common/CONVENTIONS.md`](common/CONVENTIONS.md) — read it first, every run, regardless of flow. See [README.md](README.md) for what each doc covers and the order to write them in.

## Step 1 — Pick the flow from the first word

| First word | Flow |
|---|---|
| `prd` | [`prd.md`](prd.md) — problem, persona, scope, success metrics |
| `app-flow` | [`app-flow.md`](app-flow.md) — onboarding, core loops, screen map, edge logic |
| `design-brief` | [`design-brief.md`](design-brief.md) — brand, design tokens, components, layouts |
| `tdd` | [`tdd.md`](tdd.md) — architecture, stack, third-party services, ADRs |
| `data-schema` | [`data-schema.md`](data-schema.md) — tables, relationships, constraints, lifecycle |
| `api-contracts` | [`api-contracts.md`](api-contracts.md) — endpoints, schemas, errors, auth |
| `nfr` | [`nfr.md`](nfr.md) — performance, security, deployment, observability |

No first word given, or it doesn't match any of the seven: ask which flow, don't guess.

## Completion criterion

The matched flow's own completion criterion is met.
