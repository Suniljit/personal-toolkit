# [Feature Title]

> 🌿 **Branch:** `<slug>` · 📅 **Date:** YYYY-MM-DD

## Problem & Solution
**Problem:** What's broken or missing today, and its impact. For a fix, describe the bug's actual observed behavior — not just "X doesn't work."
**Solution:** What this plan does about it, in one or two sentences. Mechanism detail belongs in Architecture, not here.

## Decisions
Two-tier table. **Constraints** are pre-existing and non-negotiable (infra limits, existing
conventions, prior decisions). **Choices** were made during planning and had real alternatives.
Omit rows that are obvious from the codebase.

| Type | Decision | Choice | Why |
|---|---|---|---|
| Constraint | ... | ... | ... |
| Choice | ... | ... | ... |

## Architecture
ASCII diagram — what changes, what it touches, how data flows.

```
[Trigger] ──► [Handler] ──► [Service] ──► [Store]
                                │
                          [Side Effect]
```

```
┌──────────────┐     ┌──────────────┐
│  Old Module  │────►│  New Module  │
└──────────────┘     └──────┬───────┘
                            ▼
                     ┌──────────────┐
                     │   Storage    │
                     └──────────────┘
```

## Code Shape
_Optional — include only when interface design is non-obvious or worth locking in early._

Key types, interfaces, or function signatures. Sketch-level only — not full implementation.

```ts
// Example: port interface
export interface MyRepository {
  findById(id: string): Promise<MyRecord | null>;
}

// Example: request/response shape
type MyRequest = { id: string };
type MyResponse = { result: string | null };
```

## Validation Rules
_Optional — include only when there are non-trivial input constraints._

- `fieldName`: constraint (e.g. non-empty string, integer 2000–2100, valid ISO code)
- Normalize: trim, uppercase, deduplicate before processing
- Reject: what invalid input looks like and the expected error response

## Implementation Plan
Phases small enough to be a single commit. Each phase lists the files it touches, then its tasks — keeps commit grouping unambiguous later, without needing to re-read diffs.

### Phase 1: [Name]
| File | What changes |
|---|---|
| `path/to/file.ts` | Add new handler |

- [ ] Task

### Phase 2: [Name]
| File | What changes |
|---|---|

- [ ] Task

## Acceptance Criteria
Checkable, observable statements that define "done" for the whole feature — what a reviewer (human or agent) verifies against, independent of the phase checklists above.
- ...

## Testing
What to test and why it matters — favor asserting on output over implementation calls (see `guidelines/testing.md`). Skip anything that just proves the language works.
- ...

## Logging
What to capture and why — skip anything that doesn't help with observability, debugging, or auditing.

| Event | Level | Fields | Example |
|---|---|---|---|
| Feature started | `info` | `userId`, `featureId`, `timestamp` | `{userId: "u123", featureId: "feat-export", timestamp: "2026-08-30T14:32Z"}` |
| Validation failed | `warn` | `field`, `reason`, `input` | `{field: "email", reason: "invalid format", input: "user@"}` |
| External call failed | `error` | `service`, `statusCode`, `duration`, `error` | `{service: "payment-api", statusCode: 502, duration: 5000, error: "timeout"}` |
| Function entry | `debug` | `functionName`, `args` | `{functionName: "processOrder", args: {orderId: "ord-456", qty: 3}}` |
| Function exit | `debug` | `functionName`, `returnValue`, `duration` | `{functionName: "processOrder", returnValue: {status: "approved"}, duration: 45}` |
| LLM call request | `debug` | `model`, `prompt`, `tokens` | `{model: "gpt-4", tokens: 512, prompt: "summarize the following..."}` |
| LLM call response | `debug` | `model`, `completion`, `tokens` | `{model: "gpt-4", tokens: 245, completion: "The summary is..."}` |
| DB query | `debug` | `query`, `params`, `duration` | `{query: "SELECT * FROM orders WHERE user_id = ?", params: ["u123"], duration: 12}` |
| DB result | `debug` | `query`, `rowCount`, `sample` | `{query: "SELECT * FROM orders...", rowCount: 5, sample: {orderId: "ord-1", total: 99.99}}` |

**Anti-patterns to avoid:**
- ❌ Logging a count: `{processed: 42}` — useless for debugging
- ❌ Logging presence only: `{validated: true}` — doesn't help trace the data
- ❌ Logging without values: `{result: "success"}` — what was the actual result?
- ❌ Logging redacted data: `{email: "***"}` — defeats the purpose of logs

**Notes:**
- Prefer structured logs (JSON) over interpolated strings — makes grepping and filtering easier
- Include a `correlationId` / `traceId` on every log line where possible to link related logs
- Never log PII, secrets, or raw request bodies unless explicitly scrubbed and approved for the environment
- DEBUG-level input/output logs (function args/returns, LLM calls, DB queries) must also be scrubbed of PII/secrets
- DEBUG logs can be disabled or sampled in production if volume/cost is a concern — but in development/staging, they must be fully verbose
- Flag any log lines that should feed an alert or dashboard metric (e.g., "External call failed" → alert oncall)

## Edge Cases
Only list edge cases that aren't obvious or need special handling.
- ...

## Risks & Unknowns
- ...

## Out of Scope
- ...

## Docs to Update
- ...
- `INDEX.md` — only if this feature adds, removes, or repurposes a top-level folder or file
