---
name: fix-issue
description: >
  Fix bugs, errors, and issues in Python code without increasing complexity or over-engineering.
  Use this skill whenever the user wants to fix errors, bugs, or problems in their Python code — especially
  when they say things like "fix this error", "why is this broken", "help me fix", "there's a bug",
  "something's wrong with my code", or pastes an error message alongside code. Also trigger when
  the user uploads or shares code and asks what's wrong. Always use this skill when the goal is
  correction rather than improvement or refactoring. The fixed code must be no more complex than
  the original — ideally simpler.
---

# Fix Issue Skill

Fix Python code issues without increasing complexity. The fix should be easy to understand and as small as possible.

## The #1 Rule: Don't Add Complexity

The fixed code must be **no more complex** than the original. Ideally it's simpler.

Complexity means: more abstractions, more indirection, more lines, more concepts to hold in your head, more dependencies. A fix that introduces any of these things without necessity is a bad fix — even if it's technically correct.

Ask yourself before presenting a fix: *"Is the code harder to understand now than before?"* If yes, find a simpler way.

## Other Principles

- **Change as little as possible.** Fix only what's broken. Leave everything else exactly as it is.
- **Same style, same patterns.** Match the existing code's conventions — naming, spacing, structure.
- **No new abstractions.** Don't introduce helper functions, classes, or utilities to make the fix "cleaner."
- **No new dependencies.** Don't pull in a library to fix something that can be fixed inline.
- **Don't improve, just fix.** Refactoring, optimizing, and "cleaning up while I'm here" is a separate job. Don't do it.
- **Plain explanations.** One or two sentences, no jargon unless the user clearly knows it.

## What Over-Engineering Looks Like (Avoid These)

- Adding a helper function to fix a one-liner bug
- Introducing try/except blocks, logging, or retries that weren't there before
- Splitting a function into smaller functions to "make the fix cleaner"
- Using a more sophisticated algorithm when a simple one would work
- Adding dataclasses, ABCs, or extra classes to structure a fix
- Wrapping values in properties or descriptors to handle an edge case
- Suggesting design pattern changes (factory, observer, etc.) as part of the fix

## Process

### 1. Find the root cause
- Read the error message carefully (if provided)
- Identify *why* it's broken, not just where
- Ask: what is the smallest possible change that fixes the root cause?

### 2. Explain and ask for confirmation — DO NOT apply the fix yet
Present the proposed fix clearly, then wait for the user to confirm before touching any code:

```
**What's wrong:** [1–2 sentences, plain language]

**Proposed fix:** [show only the changed lines / short diff]

**Why this works:** [1 sentence, only if non-obvious]

Should I go ahead and apply this fix?
```

Do not output the updated file or full corrected code at this stage. Just show the change itself (the diff or the specific lines).

### 3. Apply only after confirmation
Once the user says yes (or "go ahead", "looks good", "do it", etc.), apply the fix — changing only those lines, nothing else.

If the user pushes back or asks for a different approach, revise the proposal and confirm again before applying.

If there are multiple issues, propose a fix for the most critical one first. After it's confirmed and applied, list the remaining issues and ask if they want to continue.

## Examples

**Bug:** `TypeError: 'NoneType' object is not subscriptable`
```python
def get_first(items):
    return items[0]

get_first(None)
```

✅ **Good fix** — same complexity, fix the call site:
```python
get_first([])
```
*What was wrong: `None` was passed instead of a list.*

❌ **Bad fix** — adds complexity, over-engineered:
```python
def get_first(items):
    if items is None:
        return None
    if not isinstance(items, list):
        raise TypeError("Expected a list")
    return items[0] if items else None
```
*(Adds guard clauses, type checking, and empty-list handling — none of which were part of the original design.)*