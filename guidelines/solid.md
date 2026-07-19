# SOLID Principles

Scope: hooks, utilities, API handlers, feature logic. Skip for presentational components or one-off scripts.

- Single Responsibility: module, one job. Hook fetching data shouldn't format or transform it.
- Open/Closed: extend via new code, not modification. Prefer new handlers or strategies.
- Liskov Substitution: subtypes work wherever base type works. Don't override behavior breaking callers.
- Interface Segregation: keep signatures/types narrow. Don't force callers to depend on unused shapes.
- Dependency Inversion: depend on abstractions, not concretions. Pass clients/services as params, don't import inside logic.
