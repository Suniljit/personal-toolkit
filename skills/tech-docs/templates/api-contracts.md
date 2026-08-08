---
doc_type: api-contracts
status: draft
depends_on: [docs/design/data-schema.md, docs/design/tdd.md]
related:
  - path: data-schema.md
    why: entities these payloads serialize
  - path: tdd.md
    why: protocol and auth provider this contract implements
last_updated: YYYY-MM-DD
---

# [Product / Feature Name] — API Interface Contracts

The machine-readable contract is [`api-contracts/openapi.yaml`](api-contracts/openapi.yaml) (OpenAPI 3.1) — the source of truth for paths, schemas, and status codes. This document carries what a spec holds poorly: the auth model, error taxonomy, and the cross-cutting policies below. When the two disagree, the spec wins and this document is corrected.

## Authentication & Headers
Mechanism, header names, token format. Token lifetime, refresh flow, and expiry behavior.

## Versioning & Deprecation
Version carrier (URL path vs. header), what counts as a breaking change, deprecation notice period and headers.

## Conventions
Applied by every endpoint unless its own section says otherwise.

- **Pagination:** style (cursor / offset), params, response envelope
- **Filtering & sorting:** param format
- **Idempotency:** which methods accept an idempotency key, and its retention
- **Rate limits:** limits and the headers that report them

## Error Format
Standard error payload shape (e.g. RFC 9457 `application/problem+json`) and the status codes used across all endpoints. One envelope for every endpoint.

## Endpoints
| Endpoint | Method | Implements | Summary |
|---|---|---|---|
| `/resource` | GET | `FR-01` | List resources |

### `[METHOD] /path`
**Implements:** `FR-01`
**Request:** query params / path variables / body schema
**Response:** payload schema
**Errors:** status codes specific to this endpoint
