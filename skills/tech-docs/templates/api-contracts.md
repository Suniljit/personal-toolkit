---
doc_type: api-contracts
status: draft
depends_on: [docs/design/data-schema.md, docs/design/tdd.md]
last_updated: YYYY-MM-DD
---

# [Product / Feature Name] — API Interface Contracts

## Authentication & Headers
Mechanism, header names, token format.

## Error Format
Standard error payload shape (e.g. RFC 7807) and the status codes used across all endpoints.

## Endpoints
| Endpoint | Method | Summary |
|---|---|---|
| `/resource` | GET | List resources |

### `[METHOD] /path`
**Request:** query params / path variables / body schema
**Response:** payload schema
**Errors:** status codes specific to this endpoint

## Related
- [Data Schema](data-schema.md) — entities these payloads serialize
- [TDD](tdd.md) — protocol and auth provider this contract implements
