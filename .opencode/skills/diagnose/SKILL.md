---
name: diagnose
description: >
  Debug and fix broken code. Use when a user reports errors, unexpected behavior,
  or pastes a stack trace — including "fix this bug", "why is this failing",
  "something's wrong", "help me debug", or "it's broken". Always use this skill
  rather than debugging ad hoc.
---

# Diagnose Skill

Structured workflow for diagnosing and fixing bugs. Follow phases in order. Never apply changes without user approval.

---

## Phase 1: Explore

Before asking anything, build context independently:

1. Locate relevant files — entry points, configs, the file in the error, its dependencies.
2. Read the code — structure, data flow, recent changes.
3. Flag obvious red flags — wrong imports, missing awaits, type mismatches, off-by-ones.
4. Note remaining unknowns — gaps only the user can fill.

Use `bash_tool` freely: `find`, `grep`, `cat`, `git log`, `git diff`, etc.

---

## Phase 2: Interview

Use `ask_user_input_v0` to ask 1–3 targeted questions. Prioritize highest-value unknowns. Max 2 rounds.

For each question, **state your best guess first**, then ask for confirmation:
> "My guess is this started after the auth refactor — does that match?"

Good questions: when did it start? reproducible or intermittent? expected vs. actual behavior? last change made?

---

## Phase 3: Hypotheses

Present **3–5 hypotheses**, ranked by likelihood:

```
## Hypothesis [N] — [Title] (Confidence: High/Medium/Low)
**What**: [What's going wrong]
**Why**: [Supporting evidence]
**Smoking gun**: [Specific suspicious line/pattern]
```

End with: **"My top hypothesis is [N]."**

---

## Phase 4: Fix Plan

Design a concrete fix for the top hypothesis; note alternatives for lower-ranked ones.

```
## Fix Plan
**Target**: [File(s) and line(s)]
**Changes**:
1. [Specific change — what replaces what]
2. ...
**Cleanup**: [Dead code, unused imports to remove]
**Why this works**: [Brief explanation]
**Risk**: [Low/Medium/High — why]
```

Ask: > "Does this look right? Say **yes** to proceed, or let me know what to adjust."

**Do not touch files until approved.**

---

## Phase 5: Implement

Only after explicit approval ("yes", "go ahead", "looks good"):

1. Apply changes using `str_replace` (preferred) or `create_file`.
2. Remove dead code, commented-out blocks, unused imports made redundant by the fix.
3. Do a final review pass of modified files.

---

## Phase 6: Report

```
## Done ✓
**Fixed**: [What changed and why it works]
**Files modified**: [List]
**Cleaned up**: [What was removed]
**To verify**: [Command or test to confirm]
**If this doesn't fix it**: [Next hypothesis to investigate]
```

---

## Key Principles

- Explore first, then hypothesize — never guess blindly.
- Always show the plan before touching files.
- State confidence; don't present guesses as certainties.
- Prefer surgical edits — minimum change to fix the bug.
- Clean up as you go.
- Always offer a path forward if the fix doesn't work.