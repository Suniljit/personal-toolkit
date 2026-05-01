---
name: diagnose
description: >
  Use this skill to diagnose and fix bugs, errors, or unexpected behavior in code.
  Trigger whenever a user reports something is broken, not working, throwing an error,
  behaving unexpectedly, or when they say things like "help me debug", "fix this bug",
  "something's wrong with my code", "why is this failing", "it's broken", "I'm getting
  an error", or "this isn't working". Also trigger when the user pastes a stack trace,
  error message, or describes incorrect output. Always use this skill — don't try to
  diagnose and fix ad hoc without it, even for seemingly simple bugs.
---

# Diagnose Skill

A structured workflow for diagnosing and fixing bugs. Follow all phases in order.
Never apply code changes without explicit user approval.

---

## Phase 1: Explore the Codebase

Before asking any questions, build context independently:

1. **Locate relevant files** — identify entry points, configs, the file mentioned in the error, and its dependencies.
2. **Read the code** — understand structure, data flow, and recent changes if discernible.
3. **Check for obvious red flags** — typos, wrong imports, missing awaits, off-by-one errors, mismatched types.
4. **Note what you still don't know** — gaps that only the user can fill (reproduction steps, environment, what changed recently).

Use `bash_tool` freely to explore: `find`, `grep`, `cat`, `ls`, `git log`, `git diff`, etc. Be thorough — the more context you gather here, the better your hypotheses.

---

## Phase 2: Interview the User

After exploring, use the `ask_user_input_v0` tool to ask targeted questions. Keep it to 1–3 questions maximum — don't overwhelm. Prioritize the highest-value unknowns first.

**Good questions to consider:**
- When did this start? (after a specific change, always, randomly?)
- Is it reproducible 100% of the time or intermittent?
- What's the expected vs. actual behavior?
- What environment / OS / version?
- What was the last thing changed before this broke?

**After each round of questions**, reassess whether you need more info or can proceed. Max 2 rounds of questions — don't over-interview.

For each question where you have a strong opinion, **state your best guess first**, then ask for confirmation. Example:
> "My guess is this started after the recent auth refactor — does that match?"

---

## Phase 3: Generate Ranked Hypotheses

Present **3–5 hypotheses**, ranked by likelihood. For each:

```
## Hypothesis [N] — [Short Title] (Confidence: High/Medium/Low)
**What**: [What is going wrong]
**Why**: [Evidence from the code that supports this]
**Smoking gun**: [The specific line/pattern that makes this suspicious]
```

End with: **"My top hypothesis is [N]."**

---

## Phase 4: Build the Fix Plan

Design a concrete fix for your top hypothesis (and note alternative fixes for lower-ranked ones if the top hypothesis turns out to be wrong).

Present the fix plan clearly:

```
## Fix Plan

**Target**: [File(s) and line(s) to change]

**Changes**:
1. [Describe change 1 — be specific about what replaces what]
2. [Describe change 2]
...

**Cleanup**:
- [Any dead code, unused imports, stale configs to remove]

**Why this works**: [Brief explanation]

**Risk**: [Low/Medium/High — and why]
```

Then ask:

> "Does this fix plan look right to you? Say **yes** to proceed, or let me know what to adjust."

**Do not touch any files until the user approves.**

---

## Phase 5: Implement the Fix

Only after explicit approval ("yes", "go ahead", "looks good", "proceed", etc.):

1. Apply all changes from the fix plan using `str_replace` (preferred for surgical edits) or `create_file`.
2. **Clean up** — remove any dead code, commented-out blocks, unused imports, or obsolete logic that the fix made redundant.
3. After all changes, do a final review pass of the modified files to check for obvious issues introduced.

---

## Phase 6: Report

After implementing, give the user a concise summary:

```
## Done ✓

**Fixed**: [What was changed and why it fixes the bug]
**Files modified**: [List]
**Cleaned up**: [What was removed, if anything]

**To verify**: [How the user can confirm the fix works — a command to run, a test to check, etc.]

**If this doesn't fix it**: [What to try next — the next hypothesis to investigate]
```

---

## Key Principles

- **Never guess blindly** — explore first, then hypothesize.
- **Never make changes without approval** — even small ones. Always show the plan first.
- **State your confidence** — don't present guesses as certainties.
- **Prefer surgical edits** — change the minimum necessary to fix the bug.
- **Clean up as you go** — don't leave dead code behind.
- **Offer a path forward** — if the fix doesn't work, say what to try next.