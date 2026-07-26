# Testing

Scope: any test file, or any change that adds or modifies tests.

Avoid:

- Asserting on internal implementation calls (spying on a DB write, an internal function call) instead of on return values or observable output. This couples the test to *how* the code works, not *what* it does — the inner function gets its own test with its own output assertions; the outer function's test should not know the inner one exists.
- Tests that need a full rewrite when an implementation detail changes (e.g. swapping Postgres for MySQL). A well-written test only needs updating when the public interface/contract itself changes — e.g. adding a new field to the output. If a refactor with no interface change still forces rewrites, the test is too tightly coupled to the implementation.
- Hitting a live external service from an e2e test. E2e tests should mock external services to stay cheap and fast — verify the real service separately with a contract test, never by routing e2e traffic to it.
- Mocking an external service in tests with no contract test to back it up. Mocks drift from the real service's behavior over time, leaving two variants (mock, real) to maintain in sync — the contract test is what catches that drift.
