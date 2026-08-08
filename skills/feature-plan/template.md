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

| Event | Level | Fields | Why |
|---|---|---|---|
| Feature started | `info` | `userId`, `featureId` | Trace entry point |
| Validation failed | `warn` | `field`, `reason`, `input` | Debug bad requests |
| External call failed | `error` | `service`, `statusCode`, `duration` | Alert on degradation |
| Function entry/exit | `debug` | `functionName`, `args`, `returnValue` | Trace data flow through key functions |
| LLM call request/response | `debug` | `model`, `prompt`, `completion`, `tokens` | Debug prompt/output issues |
| DB query/result | `debug` | `query`, `params`, `rowCount`/`result` | Debug data access issues |

Notes:
- Prefer structured logs (JSON) over interpolated strings
- Include a `correlationId` / `traceId` on every log line where possible
- Never log PII, secrets, or raw request bodies unless explicitly scrubbed
- DEBUG-level input/output logs (function args/returns, LLM calls, DB queries) must also be scrubbed of PII/secrets, and should be disabled or sampled in production if volume/cost is a concern
- Flag any log lines that should feed an alert or dashboard metric

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
