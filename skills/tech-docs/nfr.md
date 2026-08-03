# Tech Docs — NFR flow

Read [`common/CONVENTIONS.md`](common/CONVENTIONS.md) first for the `docs/design/` layout and shared conventions.

Write the Non-Functional Requirements & Operational Strategy document to `docs/design/nfr.md`. Last doc in the suite.

---

## Step 1 — Read the TDD

Read `docs/design/tdd.md`. If it's missing, stop and say so — targets and pipeline steps are set against the architecture and stack it names; run `/tech-docs tdd` first. Read `docs/design/data-schema.md` and `docs/design/api-contracts.md` too if they exist — they sharpen performance targets and compliance scope (e.g. what data is stored, what's exposed over the API).

---

## Step 2 — Grill the user

Run a `/grilling` session, with `/domain-modeling` alongside it (see Grilling in CONVENTIONS.md), covering:

- **Performance targets** — latency limits (e.g. API response time < 200ms), throughput, initial load time
- **Security & compliance** — encryption (in-transit, at-rest), authentication rules, access control (RBAC), compliance mandates (e.g. SOC 2, GDPR, HIPAA)
- **DevOps & deployment pipeline** — local/staging/production setup, CI/CD steps, testing gates (unit, integration, e2e), rollback procedure
- **Observability & reliability** — structured logging strategy, error reporting target, telemetry, uptime expectation

**Considerations** — ground recommendations in these rather than guessing:
- **Performance targets:** set numbers relative to the expected user count and traffic pattern from the PRD, not generic industry defaults.
- **Security & compliance:** derive compliance scope from what `data-schema.md` actually stores (PII, payment, health data) rather than asking in the abstract.
- **DevOps:** confirm how many environments (local/staging/prod, or more) and whether feature flags are in scope before designing the pipeline.
- **Observability:** tie alerting thresholds back to the performance targets above — an alert with no corresponding target is noise.

Lead each question with your recommended answer. Ground targets in the architecture from the TDD — don't propose a caching-layer SLA if the TDD names no cache.

When the strategy feels complete, confirm:
> *"I think we have the operational strategy. Saving to `docs/design/nfr.md` — ready?"*

---

## Step 3 — Generate the doc

Read [`templates/nfr.md`](templates/nfr.md) and fill in every section — it's a floor, not a ceiling (see Beyond the template in CONVENTIONS.md).

This doc rarely needs the overflow split from CONVENTIONS.md — apply it only if a section (e.g. per-environment pipeline detail) genuinely passes ~400 lines.

---

## Step 4 — Save

Save to `docs/design/nfr.md`. Add or update its row in the root `INDEX.md`'s **Design** table per CONVENTIONS.md.

## Completion criterion

`docs/design/nfr.md` exists with every section filled (no placeholders) and `INDEX.md` has a current row for it — suite complete once all seven rows exist.

Confirm:
> *"Saved to `docs/design/nfr.md`."*
