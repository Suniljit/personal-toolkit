---
name: review-code
description: >
  Perform a thorough code review that checks for bugs and issues, identifies opportunities for code reuse,
  simplifies over-engineered logic, enforces the Single Responsibility Principle (SRP) by breaking large
  functions into smaller focused ones, and reduces overall code volume — then applies all changes directly
  to the files. Use this skill whenever the user asks to "review my code", "check for issues", "refactor",
  "simplify", "clean up", "reduce code", "apply SRP", "find duplicate code", or shares code and wants it
  improved. Trigger even for casual phrasings like "take a look at this", "what do you think of this code",
  or "can this be better". Always use this skill when code improvement of any kind is requested.
---

# Code Review Skill

Performs a comprehensive, opinionated code review — then **applies every change directly to the files**.

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

For any non-trivial review (more than ~100 lines of code, or more than 2 files), **spawn subagents** to keep each agent's context focused. This produces higher-quality findings than a single agent trying to hold everything at once.

### When to use subagents

- **Single small file (<100 lines):** Do the full review inline, no subagents needed.
- **Single large file (100–500 lines) or 2–5 files:** Spawn one subagent per review pass (see below).
- **Large codebase (5+ files or 500+ lines total):** Spawn one subagent per file for analysis, then a synthesis subagent to find cross-file patterns (reuse, SRP across modules).

### Subagent roles

Spawn these as parallel subagents when applicable. Each receives only what it needs.

#### 1. `bug-detector` subagent
**Context given:** file content + language  
**Task:** Pass 1 only — find all bugs, issues, security problems, dead code.  
**Returns:** Structured list of issues with locations and fixes.

#### 2. `reuse-analyzer` subagent
**Context given:** all file contents (for cross-file pattern matching)  
**Task:** Pass 2 only — find duplicated logic within and across files. Propose shared helpers.  
**Returns:** List of duplication sites and proposed unified implementations.

#### 3. `simplifier` subagent
**Context given:** file content + language  
**Task:** Passes 3 & 5 — simplification + code reduction. These are closely related so one agent handles both.  
**Returns:** Before/after pairs for every simplification and reduction opportunity.

#### 4. `srp-enforcer` subagent
**Context given:** file content  
**Task:** Pass 4 only — identify SRP violations and propose function/class splits.  
**Returns:** List of violations with proposed decompositions.

#### 5. `apply-changes` subagent (final step — runs after all analysis is complete)
**Context given:** original file content + consolidated findings from all analysis subagents  
**Task:** Apply every approved change to produce the final rewritten file(s).  
**Returns:** Rewritten file(s).

### Spawning instructions

When spawning subagents, give each one:
1. The relevant section of this SKILL.md (copy the relevant Pass instructions)
2. The file content it needs
3. Its specific task and expected output format
4. The language-specific notes for the detected language

Collect all subagent outputs before proceeding to the apply step.

---

## Review Passes

Each subagent (or inline review pass) follows these instructions:

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

### Pass 3 — Simplification

Look for:
- Over-engineered abstractions (factory-of-factory, unnecessary generics, premature abstraction)
- Unnecessarily verbose code (manual loops replaceable with map/filter/reduce, verbose conditionals)
- Boolean logic that can be simplified
- Nested conditionals that can be flattened (early returns, guard clauses)
- Redundant variables or intermediate values that add no clarity
- Unnecessary class hierarchies or design patterns for simple tasks

**Output format:**
```
✂️  SIMPLIFY: <short title>
Location: <file>:<location>
Before:
<original code>
After:
<simplified code>
Reason: <one-line explanation>
```

---

### Pass 4 — SRP Violations

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

### Pass 5 — Code Reduction

Look for ways to reduce total line count without losing clarity:
- Verbose `if/else` replaceable with ternary or nullish coalescing
- Manual implementations of things the stdlib provides
- Unnecessary wrapper functions or pass-through layers
- Comments that restate what the code already says clearly (remove them)
- Boilerplate that can be collapsed

**Output format:**
```
📉 REDUCE: <short title>
Location: <file>:<location>
Before (N lines):
<original>
After (M lines):
<reduced version>
```

---

## Applying Changes

After all passes are complete, **apply every finding as actual edits to the files**.

### Apply process

1. **Consolidate findings** — merge all subagent outputs. Resolve conflicts (e.g., if both `simplifier` and `srp-enforcer` want to rewrite the same function, the SRP split takes precedence and simplification is applied within the split functions).

2. **Order of application** (apply in this sequence to avoid patch conflicts):
    - SRP splits first (restructures the file most aggressively)
    - Reuse extractions second (moves code into shared helpers)
    - Bug fixes third
    - Simplifications and reductions last (line-level changes)

3. **Write the changes:**
    - If the file was provided as a path: overwrite it in-place using `str_replace` for targeted changes, or rewrite the whole file if changes are pervasive (>40% of lines touched).
    - If code was pasted: write the improved version to `/mnt/user-data/outputs/<original_name_or_improved.ext>` and present it.
    - If creating new shared helper files (from reuse extraction): write them alongside the modified files.

4. **Never silently change behaviour.** If a bug fix changes observable behaviour, note it explicitly in the summary.

5. **Preserve formatting style** of the original file (indentation, quote style, semicolons, etc.) unless the style itself is an issue.

---

## Output Structure

### Before applying changes — show the summary first

```
## Code Review Summary
Files reviewed: <list>
Language(s): <detected>

### Findings at a glance
| Category        | Count |
|-----------------|-------|
| Bugs / Issues   | N     |
| Reuse Opps      | N     |
| Simplifications | N     |
| SRP Violations  | N     |
| Reductions      | N     |

### Top priorities
1. <most critical>
2. <second>
3. <third>

Applying all changes now...
```

Then apply changes. Then show:

```
## Changes Applied

### <filename>
- <short description of change 1>
- <short description of change 2>
- Lines: <before> → <after> (saved N lines)

### New files created
- <helper file> — extracted from <source>

### Behaviour changes (bugs fixed)
- <any change that alters runtime behaviour>
```

---

## Tone & Approach

- Be direct. Don't pad with praise.
- Always apply concrete changes — never just describe what to change.
- Preserve original intent exactly when refactoring; only change behaviour when fixing a bug.
- Flag trade-offs (e.g., if a simplification reduces explicitness, say so).
- If you can't see full context (imports, types), note assumptions made.

---

## Language-Specific Notes

### Python
- List/dict comprehensions over manual loops where readable
- `dataclasses` or `NamedTuple` over plain dicts for structured data
- Context managers (`with`) for resources
- f-strings over `.format()` or `%`
- Flag mutable default arguments

### General
- Magic numbers → named constants
- Flag deeply nested code (> 3 levels)
- Flag functions with > 4–5 parameters (suggest config struct/object)