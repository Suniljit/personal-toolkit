# Backend

Scope: API routes, server actions, database queries, external calls, server-side code.

Avoid:

- Unvalidated request input or unchecked params.
- Missing rate limiting on public endpoints.
- Unbounded queries on user-facing paths.
- N+1 query patterns, including per-item DB or permission lookups in shared render paths.
- External HTTP calls without timeout or retry discipline.
- Internal error leakage to clients.
- Missing or overly broad CORS configuration.
