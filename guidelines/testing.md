# Testing

Scope: any test file, or any change that adds or modifies tests.

Avoid:

- Asserting on internal implementation calls (spying on a DB write, an internal function call) instead of on return values or observable output. This couples the test to *how* the code works, not *what* it does — the inner function gets its own test with its own output assertions; the outer function's test should not know the inner one exists.
- Tests that need a full rewrite when an implementation detail changes (e.g. swapping Postgres for MySQL). A well-written test only needs updating when the public interface/contract itself changes — e.g. adding a new field to the output. If a refactor with no interface change still forces rewrites, the test is too tightly coupled to the implementation.
- Hitting a live external service from an e2e test. E2e tests should mock external services to stay cheap and fast — verify the real service separately with a contract test, never by routing e2e traffic to it.
- Mocking an external service in tests with no contract test to back it up. Mocks drift from the real service's behavior over time, leaving two variants (mock, real) to maintain in sync — the contract test is what catches that drift.
- Having only one tier of integration test when the real service is slow or costly to hit (e.g. minutes-long cold starts, per-invocation billing). Split into two sets instead:
  - A fast, cheap integration test built from mocked/small components (backed by a contract test per the point above) that runs on every PR.
  - A slower, occasional test that wires up the real, live components end-to-end, run on a schedule (e.g. weekly, or after a batch of PRs) or a manual trigger — not on every PR — so its cost is shared instead of paid repeatedly.

  Don't treat the first tier as a replacement for the second: integrating with a mock is not the same as integrating with the real thing, and there are always nuances in the real components that mocks won't capture. The occasional live test is what catches those.
