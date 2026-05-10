---
name: feature-plan
description: >
  Plan a feature or fix before building it. Triggers on "feature-plan", "make a plan for X",
  "spec this out", "plan this change", "grill me on this ticket", or "/plan-ticket". Works
  with or without a formal ticket. Always interviews the user first, then saves a Markdown
  plan to the repo. Use this skill any time a user wants to think through and document a
  feature before writing code.
---

# Feature Plan

Interview the user thoroughly, then save a tight **agent-ready Markdown plan** to the repo.

Two entry points, same workflow, different starting context:
- **With ticket + brief**: ticket is the spec, brief is background
- **No ticket**: user describes the feature directly

Preserve both approval gates:
- Confirm the save location before the interview proceeds.
- Confirm readiness before writing the plan file.

---

## Step 1: Gather Inputs

You need two things before starting:

**1. Feature description**: what are we building or fixing?
- If a ticket/brief path was given, read those files
- If no description exists, ask: *"What are you trying to build or fix?"*

**2. Save location**: where should the plan file go?
- If not provided, suggest: *"I'll save it to `_features/plans/` — OK with that?"*
- Wait for confirmation before proceeding

Ask for anything missing in a single message.

---

## Step 2: Grill the User

Interview the user until you have a shared, unambiguous understanding of the feature.

Rules:
- Ask every question through the best available user-input mechanism. In Codex, use `request_user_input` only when the active mode/tooling exposes it; otherwise ask directly in chat.
- Ask one question, or one tight cluster, at a time.
- Lead with your **recommended answer** and brief rationale; don't just ask open questions
- If the codebase can answer a question, **explore it** instead of asking
- If a ticket exists, focus on **gaps and unresolved decisions**; don't re-litigate what's settled
- **Track every decision**, especially deviations from the ticket (needed in Step 5)

When you feel the design is fully resolved:
> *"I think we have enough to write the plan. Ready to save to `<plans_dir>`?"*

Wait for explicit confirmation.

---

## Step 3: Generate the Plan

Synthesize the ticket (if any), brief (if any), and discussion into the template below.

**Brevity principle:** Every section should be as short as possible while still being useful. Prefer bullet points over prose. Cut words that don't add meaning. Extra detail is only warranted when it genuinely helps a reader understand something non-obvious, not just to be thorough.

Codex display rules:
- Use plain GitHub-flavored Markdown that renders cleanly in chat and files.
- Avoid emoji, box-drawing characters, and decorative blockquotes.
- Use fenced code blocks with info strings for diagrams.
- When confirming saved files in Codex, use a clickable absolute file link if the path is known.

````markdown
# [Feature Title]

**Branch:** `<slug>`
**Date:** YYYY-MM-DD

## What & Why
One or two sentences. What does this do, and why now?

## Decisions
Only include decisions that were non-obvious or had real alternatives.

| Decision | Choice | Why |
|---|---|---|
| ... | ... | ... |

## Architecture
ASCII diagram — what changes, what it touches, how data flows.

```text
[Trigger] -> [Handler] -> [Service] -> [Store]
                             |
                             v
                       [Side Effect]
```
 
```text
+------------+     +------------+
| Old Module | --> | New Module |
+------------+     +-----+------+
                         |
                         v
                    +---------+
                    | Storage |
                    +---------+
```

## Key Files

| File | What changes |
|---|---|
| `path/to/file.ts` | Add new handler |

## Implementation Plan
Phases small enough to be a single commit.

### Phase 1: [Name]
- [ ] Task

### Phase 2: [Name]
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

## Testing
What to test and why it matters — skip anything that just proves the language works.
- ...
````

---

## Step 4: Check INDEX.md

Before saving, look for an `INDEX.md` at the project root. If it exists:
1. Read it
2. Identify which docs are affected by this feature
3. Fill in the **Docs to Update** section

If no `INDEX.md` exists, note it and skip.

---

## Step 5: Save the File

Derive a git slug from the feature title:
- lowercase, hyphen-separated, max ~50 chars
- prefix with the right conventional type: `feat/`, `fix/`, `refactor/`, `chore/`, `spike/`, `test/`, `docs/`, `perf/`, `ci/`

Filename: strip the prefix/slash, e.g. `feat/add-csv-export` -> `feat-add-csv-export.md`

Save to `<plans_dir>`. Create the directory if needed.

Confirm:
> *"Saved to `<plans_dir>/feat-add-csv-export.md`. Recommended branch: `feat/add-csv-export`."*

In Codex, prefer this confirmation shape when an absolute path is available:
> Saved to [feat-add-csv-export.md](/absolute/path/_features/plans/feat-add-csv-export.md). Recommended branch: `feat/add-csv-export`.

---

## Step 6: Patch the Ticket

Review decisions from Step 2. If any deviate from the ticket:
1. Re-read the ticket file
2. Apply targeted edits with the available edit tool, preferably `apply_patch` in Codex; only change what was actually decided differently
3. Tell the user what changed and why

If no deviations, say so explicitly.

---

## Guidelines

- **Agent-ready.** A planner agent should be able to start immediately — no open questions.
- **Brief.** Short plans get read; long plans get skimmed. Cut mercilessly.
- **Architecture diagram is mandatory.** ASCII, focused on this feature.
- **Phases = commits.** Don't invent sub-tasks if only high-level phases were discussed.
- **Out of Scope ≠ Future Work.** It just means "not here."
- **No placeholders.** Every section has real content or is explicitly noted as N/A.
- **Don't write code.** Output is a plan doc only.
