# Architecture

Scope: API route handlers.

Avoid architecture boundary violations:

- API route handlers should depend on feature-level ports for external data access and side effects. Do not let exported route handlers close over module-level concrete repositories, raw DB clients, BigQuery clients, or HTTP clients. Prefer handler factories that accept the port, then export the route handler by manually injecting the concrete adapter.
