---
name: review-code
description: >
  Perform a thorough code review that checks for bugs and issues, identifies opportunities for code reuse,
  and enforces the Single Responsibility Principle (SRP) by breaking large functions into smaller focused
  ones — then applies all changes directly to the files. Use this skill whenever the user asks to "review
  my code", "check for issues", "refactor", "clean up", "find duplicate code", "apply SRP", or shares code
  and wants it improved. Trigger even for casual phrasings like "take a look at this", "what do you think
  of this code", or "can this be better". Always use this skill when code improvement of any kind is
  requested. Note: for simplification and over-engineering removal specifically, use the simplify-code skill
  instead (or suggest it as a follow-up after this review).
---

# Code Review Skill

Performs a comprehensive, opinionated code review — then **applies every change directly to the files after user confirmation**.

---

## Mode Selection

**Check how the user provided code** before starting:

| Input type | Action |
|---|---|
| File path(s) provided | Read files, review, apply changes in-place |
| Code pasted in chat | Review inline, write improved version to a file and present it |
| Directory provided | Discover all relevant source files, review each one |

Always confirm the list of files to be modified before applying if there are more than 3 files.

---

## Subagent Architecture

For any non-trivial review (more than ~100 lines of code, or more than 2 files), **spawn subagents** to keep each agent's context focused.

### When to use subagents

- **Single small file (<100 lines):** Do the full review inline, no subagents needed.
- **Single large file (100–500 lines) or 2–5 files:** Spawn one subagent per review pass.
- **Large codebase (5+ files or 500+ lines total):** Spawn one subagent per file for analysis, then a synthesis subagent to find cross-file patterns.

### Analysis subagents (run in parallel)

All three analysis subagents are independent and should be spawned **in parallel**.

#### 1. `bug-detector` subagent
**Context given:** file content + language  
**Task:** Pass 1 only — find all bugs, issues, security problems, dead code.  
**Returns:** Structured list of issues with locations and fixes.

#### 2. `reuse-analyzer` subagent
**Context given:** all file contents (for cross-file pattern matching)  
**Task:** Pass 2 only — find duplicated logic within and across files. Propose shared helpers.  
**Returns:** List of duplication sites and proposed unified implementations.

#### 3. `srp-enforcer` subagent
**Context given:** file content  
**Task:** Pass 3 only — identify SRP violations and propose function/class splits.  
**Returns:** List of violations with proposed decompositions.

### Applying changes (runs only after user confirms)

- **Small/medium codebase (<5 files, <500 lines total):** Main agent applies changes directly. It has seen the full conversation, the user's confirmation, and any nuances discussed — no handoff needed.
- **Large codebase (5+ files or 500+ lines total):** Spawn an `apply-changes` subagent per file. Give each one: the original file content + the consolidated findings relevant to that file + the apply order and rules from the "Applying Changes" section below.

### Spawning instructions

When spawning subagents, give each one:
1. The relevant section of this SKILL.md (copy the relevant Pass instructions)
2. The file content it needs
3. Its specific task and expected output format

Collect all analysis subagent outputs before presenting the summary to the user.

---

## Review Passes

---

### Pass 1 — Bug & Issue Detection

Look for:
- Logic errors (off-by-one, wrong conditionals, incorrect operator precedence)
- Unhandled edge cases (null/undefined, empty collections, division by zero)
- Error handling gaps (swallowed exceptions, missing try/catch, unhandled promise rejections)
- Race conditions or async misuse
- Security issues (injection risks, hardcoded secrets, unsafe eval/exec)
- Incorrect use of language APIs or third-party libraries
- Type mismatches or implicit coercions that could cause bugs
- Dead code that is never reached or never used

**Output format:**
```
🐛 ISSUE: <short title>
Location: <file>:<line or function name>
Problem: <what's wrong>
Fix:
<corrected code snippet>
```

---

### Pass 2 — Code Reuse Opportunities

Look for:
- Duplicated blocks (copy-pasted logic differing only in variable names)
- Repeated patterns that could be abstracted into a helper/utility
- Inline logic that already exists in the standard library or a project utility
- Multiple functions doing the same thing with slight variation — candidates for a single parameterised function

**Output format:**
```
♻️  REUSE: <short title>
Locations: <list of duplicated sites>
Suggestion: Extract into `<functionName>(params)`
Unified version:
<rewritten shared function>
```

---

### Pass 3 — SRP Violations

Look for functions or classes that do more than one thing:
- Functions longer than ~30–40 lines are a signal
- Functions whose name contains "and" or "or"
- Functions that mix data fetching + transformation + side effects
- Classes with unrelated methods grouped for convenience

For each violation, propose a breakdown into smaller, focused units.

**Output format:**
```
🔪 SRP: <function or class name>
Location: <file>:<location>
Responsibilities found:
    1. <responsibility A>
    2. <responsibility B>
    3. <responsibility C (if any)>
Proposed split:
<rewritten as separate functions/classes>
```

---

## Confirmation Before Applying

After all passes are complete, **present a summary and wait for user confirmation before making any changes**.

### Summary format

```
## Code Review Summary
Files reviewed: <list>
Language(s): <detected>

### Findings
| Category      | Count |
|---------------|-------|
| Bugs / Issues | N     |
| Reuse Opps    | N     |
| SRP Violations| N     |

### Proposed changes

**Bugs / Issues**
- <file>:<location> — <one-line description of fix>

**Reuse**
- <one-line description of extraction>

**SRP**
- <function/class> — split into: <name1>, <name2>

### Behaviour changes
- <list any fixes that alter observable runtime behaviour, or "None">

Shall I apply all of these changes?
```

Wait for explicit user approval ("yes", "go ahead", "looks good", or similar) before proceeding. If the user pushes back on specific items, revise the plan and confirm again.

---

## Applying Changes

After the user confirms, apply every approved finding as actual edits to the files.

### Apply process

1. **Order of application** (apply in this sequence to avoid patch conflicts):
    - SRP splits first (restructures the file most aggressively)
    - Reuse extractions second (moves code into shared helpers)
    - Bug fixes last

2. **Write the changes:**
    - If the file was provided as a path: overwrite it in-place using `str_replace` for targeted changes, or rewrite the whole file if changes are pervasive (>40% of lines touched).
    - If code was pasted: write the improved version to `/mnt/user-data/outputs/<original_name_or_improved.ext>` and present it.
    - If creating new shared helper files (from reuse extraction): write them alongside the modified files.

3. **Never silently change behaviour.** If a bug fix changes observable behaviour, note it explicitly in the summary.

4. **Preserve formatting style** of the original file (indentation, quote style, semicolons, etc.) unless the style itself is an issue.

---

## Output After Applying

```
## Changes Applied

### <filename>
- <short description of change 1>
- <short description of change 2>
- Lines: <before> → <after>

### New files created
- <helper file> — extracted from <source>

### Behaviour changes (bugs fixed)
- <any change that alters runtime behaviour>
```

If patterns of over-engineering or unnecessary complexity remain, suggest running the `simplify-code` skill as a follow-up.

---

## Tone & Approach

- Be direct. Don't pad with praise.
- Always apply concrete changes — never just describe what to change.
- Preserve original intent exactly when refactoring; only change behaviour when fixing a bug.
- Flag trade-offs where relevant.
- If you can't see full context (imports, types), note assumptions made.