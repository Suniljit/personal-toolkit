---
name: python-polish
description: >
  Run a full 3-stage Python code quality pipeline: bug/SRP review, simplification, then lint + type-check.
  Use this skill whenever the user wants to fully clean up or polish Python code end-to-end, says things
  like "polish my code", "full cleanup", "run the full pipeline", "clean everything up", "make this
  production-ready", or wants all quality checks run in one go. Also trigger when the user says
  "review and simplify", "fix and clean", or "run all the checks". Each stage pauses for your approval
  before applying changes — you stay in control throughout.
disable-model-invocation: true
---

# Python Polish Pipeline

Runs three skills back-to-back on your code. Each stage that makes changes pauses for your approval before touching any files.

**Pipeline:**
```
review-code  →  simplify-code  →  py-lint-typecheck
```

| Stage | What it does | Approval gate? |
|---|---|---|
| 1. `review-code` | Finds bugs, logic errors, SRP violations — applies fixes | ✅ Yes |
| 2. `simplify-code` | Removes over-engineering, flattens unnecessary abstractions | ✅ Yes |
| 3. `py-lint-typecheck` | Runs ruff + ty, auto-fixes what it can, fixes the rest manually | ❌ No |

---

## Before starting

Confirm the target with the user if it wasn't provided with the invocation:

> "Which file or folder should I run the pipeline on?"

Once confirmed, tell the user:

> "Starting the Python Polish pipeline on `<target>`. I'll run three stages — review, simplify, then lint. Each of the first two will pause for your approval before making changes."

---

## Stage 1 — review-code

Invoke `/review-code` on the target.

Let it run its full process:
- It will analyse the code and present a **Code Review Summary**
- It will wait for the user to approve before applying changes
- After the user approves and changes are applied, it will report what changed

Do not proceed to Stage 2 until Stage 1 has fully completed (changes applied or explicitly skipped by the user).

If the user skips Stage 1 (says "skip" or "move on"), note it and proceed.

---

## Stage 2 — simplify-code

After Stage 1 is done, announce:

> "Stage 1 complete. Moving on to simplification."

Invoke `/simplify-code` on the target (the same file(s), now updated by Stage 1).

Let it run its full process:
- It will analyse and present a **Proposed Changes** summary
- It will wait for the user to approve before applying changes
- After the user approves and changes are applied, it will report what changed

Do not proceed to Stage 3 until Stage 2 has fully completed.

If the user skips Stage 2, note it and proceed.

---

## Stage 3 — py-lint-typecheck

After Stage 2 is done, announce:

> "Stage 2 complete. Running lint and type checks — this one applies fixes automatically."

Invoke `/py-lint-typecheck` on the target (the same file(s), now updated by Stages 1 and 2).

Let it run to completion. It will report its own results.

---

## Pipeline complete

After all three stages finish, print a brief summary:

```
## ✅ Python Polish Complete

| Stage              | Outcome                        |
|--------------------|--------------------------------|
| 1. review-code     | <Applied N changes / Skipped>  |
| 2. simplify-code   | <Applied N changes / Skipped>  |
| 3. py-lint-typecheck | <N issues fixed>             |
```

Then offer the user next steps:

> "Your code has been reviewed, simplified, and linted. If you're about to open a PR, consider running `/self-review` to check your implementation against your feature plan."