---
doc_type: nfr
status: draft
depends_on: [docs/design/tdd.md]
last_updated: YYYY-MM-DD
---

# [Product / Feature Name] — NFRs & Operational Strategy

## Performance Targets
| Metric | Target |
|---|---|
| API p95 latency | |
| Throughput | |
| Initial load | |

## Security & Compliance
- Encryption in-transit / at-rest: ...
- Authentication rules: ...
- Access control (RBAC): ...
- Compliance mandates: ...

## DevOps & Deployment Pipeline
Local → staging → production setup; CI/CD steps; testing gates; rollback procedure.

```
[Commit] ──► [CI: lint/test] ──► [Staging deploy] ──► [E2E gate] ──► [Prod deploy]
```

## Observability & Reliability
- Structured logging strategy: ...
- Error reporting target: ...
- Telemetry: ...
- Uptime expectation: ...

## Related
- [TDD](tdd.md) — architecture these targets and controls apply to
