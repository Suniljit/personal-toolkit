# Tech Docs — API Contracts flow

Read [`common/CONVENTIONS.md`](common/CONVENTIONS.md) first for the `docs/blueprint/` layout and shared conventions.

Write the API Interface Contracts document to `docs/blueprint/api-contracts.md`.

---

## Step 1 — Read the Data Schema and TDD

Read `docs/blueprint/data-schema.md` (entities and fields feed request/response shapes) and `docs/blueprint/tdd.md` (protocol, auth provider). If the schema is missing, stop and say so; run `/tech-docs data-schema` first.

---

## Step 2 — Grill the user

Run a `/grilling` session, with `/domain-modeling` alongside it (see Grilling in CONVENTIONS.md), covering, per resource from the data schema:

- **Endpoint specifications** — HTTP method, URL structure, resource path
- **Request & response schemas** — body shape, query params, path variables, response payload (derive fields from `data-schema.md` rather than re-deriving them)
- **Status codes & error handling** — standard error payload shape (e.g. RFC 7807), status codes used, validation error layout
- **Authentication & headers** — mechanism (Bearer token, API key, cookie), custom headers

**Considerations** — ground recommendations in these rather than guessing:
- **Endpoints:** for every list endpoint, confirm pagination, filtering, and sorting params up front — retrofitting them later is a breaking change.
- **Request/response schemas:** decide a versioning strategy (URL path, header) before the first endpoint ships, even if v1 is the only version today.
- **Errors:** use one consistent error envelope across every endpoint — don't let the shape vary by resource.
- **Auth:** cover token refresh/expiry behavior and rate-limit headers, not just the initial auth mechanism.

Lead each question with your recommended answer. Walk the data schema's tables one at a time — each table typically becomes a resource's CRUD set — rather than asking the user to list endpoints cold.

When the contract feels complete, confirm:
> *"I think we have the API surface. Saving to `docs/blueprint/api-contracts.md` — ready?"*

---

## Step 3 — Generate the doc

```markdown
---
doc_type: api-contracts
status: draft
depends_on: [docs/blueprint/data-schema.md, docs/blueprint/tdd.md]
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
```

Apply the overflow rule from CONVENTIONS.md once there are more than ~8 endpoints — keep the summary table, error format, and auth section in `api-contracts.md`, move each `### [METHOD] /path` section to `docs/blueprint/api-contracts/<resource>.md`.

---

## Step 4 — Save

Save to `docs/blueprint/api-contracts.md`. Add or update its row in the root `INDEX.md`'s **Blueprint** table per CONVENTIONS.md.

## Completion criterion

`docs/blueprint/api-contracts.md` exists with every section filled (no placeholders) and `INDEX.md` has a current row for it.

Confirm:
> *"Saved to `docs/blueprint/api-contracts.md`."*
