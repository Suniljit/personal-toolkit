# Tech Docs — NFR flow

Read [`common/CONVENTIONS.md`](common/CONVENTIONS.md) first for the `docs/blueprint/` layout and shared conventions.

Write the Non-Functional Requirements & Operational Strategy document to `docs/blueprint/nfr.md`. Last doc in the suite.

---

## Step 1 — Read the TDD

Read `docs/blueprint/tdd.md`. If it's missing, stop and say so — targets and pipeline steps are set against the architecture and stack it names; run `/tech-docs tdd` first. Read `docs/blueprint/data-schema.md` and `docs/blueprint/api-contracts.md` too if they exist — they sharpen performance targets and compliance scope (e.g. what data is stored, what's exposed over the API).

---

## Step 2 — Grill the user

Run a `/grilling` session, with `/domain-modeling` alongside it (see Grilling in CONVENTIONS.md), covering:

- **Performance targets** — latency limits (e.g. API response time < 200ms), throughput, initial load time
- **Security & compliance** — encryption (in-transit, at-rest), authentication rules, access control (RBAC), compliance mandates (e.g. SOC 2, GDPR, HIPAA)
- **DevOps & deployment pipeline** — local/staging/production setup, CI/CD steps, testing gates (unit, integration, e2e), rollback procedure
- **Observability & reliability** — structured logging strategy, error reporting target, telemetry, uptime expectation

Lead each question with your recommended answer. Ground targets in the architecture from the TDD — don't propose a caching-layer SLA if the TDD names no cache.

When the strategy feels complete, confirm:
> *"I think we have the operational strategy. Saving to `docs/blueprint/nfr.md` — ready?"*

---

## Step 3 — Generate the doc

```markdown
---
doc_type: nfr
status: draft
depends_on: [docs/blueprint/tdd.md]
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
```

This doc rarely needs the overflow split from CONVENTIONS.md — apply it only if a section (e.g. per-environment pipeline detail) genuinely passes ~400 lines.

---

## Step 4 — Save

Save to `docs/blueprint/nfr.md`. Add or update its row in the root `INDEX.md`'s **Blueprint** table per CONVENTIONS.md.

## Completion criterion

`docs/blueprint/nfr.md` exists with every section filled (no placeholders) and `INDEX.md` has a current row for it — suite complete once all seven rows exist.

Confirm:
> *"Saved to `docs/blueprint/nfr.md`. Suite complete — all seven docs are in `docs/blueprint/`."*
