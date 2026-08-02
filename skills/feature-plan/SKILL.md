---
name: feature-plan
description: >
  Document a feature or fix as an implementation-ready Markdown plan. 
disable-model-invocation: true
---

# Feature Plan

Save a tight **agent-ready Markdown plan** to `_specs/`.

The feature context comes from a completed `grill-with-docs` or `grill-me` session — decisions, constraints, and rationale should already be in the conversation.

---

## Step 1 — Check INDEX.md

Look for an `INDEX.md` at the project root. If it exists:
1. Read it
2. Identify which docs are affected by this feature

If no `INDEX.md` exists, note it and skip — the plan's **Docs to Update** section will be empty.

---

## Step 2 — Generate the plan

Synthesize the grilling session discussion, plus the affected docs from Step 1, into the template below.

**Brevity principle:** Every section should be as short as possible while still being useful. Prefer bullet points over prose. Cut words that don't add meaning. Extra detail is only warranted when it genuinely helps a reader understand something non-obvious — not just to be thorough.

```markdown
# [Feature Title]

> 🌿 **Branch:** `<slug>` · 📅 **Date:** YYYY-MM-DD

## What & Why
One or two sentences. What does this do, and why now?

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

## Risks & Unknowns
- ...

## Edge Cases
Only list edge cases that aren't obvious or need special handling.
- ...

## Out of Scope
- ...

## Docs to Update
- ...
- `INDEX.md` — only if this feature adds, removes, or repurposes a top-level folder or file

## Testing
What to test and why it matters — favor asserting on output over implementation calls (see `guidelines/testing.md`). Skip anything that just proves the language works.
- ...
```

---

## Step 3 — Save the file

Derive a git slug from the feature title:
- lowercase, hyphen-separated, max ~50 chars
- prefix with the right conventional type: `feat/`, `fix/`, `refactor/`, `chore/`, `spike/`, `test/`, `docs/`, `perf/`, `ci/`

Filename: strip the prefix/slash — e.g. `feat/add-csv-export` → `feat-add-csv-export.md`

Save to `_specs/`. Create it if needed.

Confirm:
> *"Saved to `_specs/feat-add-csv-export.md`. Recommended branch: `feat/add-csv-export`."*

---

## Guidelines

- **Agent-ready.** A planner agent should be able to start immediately — no open questions.
- **Brief.** Short plans get read; long plans get skimmed. Cut mercilessly.
- **Architecture diagram is mandatory.** ASCII, focused on this feature.
- **Phases = commits.** Don't invent sub-tasks if only high-level phases were discussed.
- **Out of Scope ≠ Future Work.** It just means "not here."
- **No placeholders.** Every section has real content or is explicitly noted as N/A.
- **Code Shape and Validation Rules are optional.** Include them when they add real clarity; omit them for simple CRUD or UI-only changes.
- **Logging is always included.** Even simple features should document at minimum their entry/exit and error events. DEBUG-level input/output tracing (functions, LLM calls, DB queries) should be included for non-trivial features.
- **Don't write code.** Output is a plan doc only.
- **Committed.** The plan lives in `_specs/` and is checked into git alongside the code it describes.