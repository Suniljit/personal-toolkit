# Tech Docs — API Contracts flow

Read [`common/CONVENTIONS.md`](common/CONVENTIONS.md) first for the `docs/design/` layout and shared conventions.

Write the API Interface Contracts document to `docs/design/api-contracts.md`.

---

## Step 1 — Read the Data Schema and TDD

Read `docs/design/data-schema.md` (entities and fields feed request/response shapes) and `docs/design/tdd.md` (protocol, auth provider). If the schema is missing, stop and say so; run `/tech-docs data-schema` first.

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
> *"I think we have the API surface. Saving to `docs/design/api-contracts.md` — ready?"*

---

## Step 3 — Write the OpenAPI spec

Write `docs/design/api-contracts/openapi.yaml` — OpenAPI 3.1, covering every endpoint agreed in Step 2: paths, operations, parameters, request and response schemas, status codes, and security schemes. Model shared shapes (the error envelope, pagination envelope, each resource) as `components/schemas` entries and `$ref` them rather than repeating shapes per operation.

This is the contract's source of truth — it's what tooling reads and what code is generated or validated against. The markdown doc in Step 4 describes it; it doesn't duplicate it.

---

## Step 4 — Generate the doc

Read [`templates/api-contracts.md`](templates/api-contracts.md) and fill in every section — it's a floor, not a ceiling (see Beyond the template in CONVENTIONS.md).

Keep it to what the spec holds poorly: auth model, versioning and deprecation policy, cross-cutting conventions, error taxonomy, and the endpoint summary table. Per-endpoint request and response schemas stay in `openapi.yaml` — the `### [METHOD] /path` sections carry the intent and the non-obvious behavior, not a second copy of the field lists.

Apply the overflow rule from CONVENTIONS.md once there are more than ~8 endpoints — keep the summary table, error format, and auth section in `api-contracts.md`, move each `### [METHOD] /path` section to `docs/design/api-contracts/<resource>.md`.

---

## Step 5 — Save

Save to `docs/design/api-contracts.md`. Add or update its row in the root `INDEX.md`'s **Design** table per CONVENTIONS.md.

## Completion criterion

`docs/design/api-contracts.md` and `docs/design/api-contracts/openapi.yaml` both exist, every endpoint in the doc's summary table has a matching path in the spec, every section is filled (no placeholders), and `INDEX.md` has a current row for the doc.

Confirm:
> *"Saved to `docs/design/api-contracts.md`."*
