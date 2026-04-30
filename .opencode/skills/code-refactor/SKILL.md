---
name: code-refactor
description: >
  Refactor a Python codebase for readability, clean code, and maintainability — without changing any functionality or behavior.
  Use this skill whenever the user asks to refactor, clean up, restructure, or reorganize Python code. Trigger on phrases like
  "refactor my code", "make my code more readable", "clean up this codebase", "restructure my files", "apply clean code
  principles", "too many lines in one file", "nested functions", "hard to read code", "simplify my code", "split into
  modules", "apply SRP", "apply DRY", or any request to improve Python code quality without changing what the code does.
  Always use this skill — do NOT attempt refactoring from scratch without it. This skill is Python-only.
---

# Code Refactor Skill (Python)

Refactor a Python codebase to be more readable and maintainable, with **zero functional change**.

> **Always present the refactor plan to the user and wait for explicit approval before making any file changes.**

## Core Principles

1. **Readability first** — A human reviewer should be able to understand each file quickly
2. **No nested functions** — Functions must never be defined inside other functions
3. **Single Responsibility (SRP)** — Each function, class, and file does one clear thing
4. **Don't Repeat Yourself (DRY)** — Duplicated logic must be extracted into a shared helper; the same logic should exist in exactly one place
5. **File size limits** — No file should feel overwhelming; split when a file exceeds ~500 lines or mixes concerns
6. **Simplification** — Flatten unnecessary nesting, clarify variable names, remove noise
7. **Zero functional change** — Behavior, inputs, outputs, and side effects must remain identical

---

## Step 0: Understand the Codebase

Before touching any file:

1. **List all files** in the project
2. **Read every file** completely — do not skim
3. **Map the structure**: note what each file does, which functions exist, how they call each other, what's exported/imported
4. **Identify problems** using the checklist below
5. **Plan the refactor**: list which files will be split, what will move where, what will be renamed

Document your plan briefly before making changes. If there are many files, do this file by file.

---

## Step 1: Identify Refactor Targets

For each file, check:

### Structural Issues
- [ ] File exceeds ~500 lines and mixes multiple concerns
- [ ] Functions defined inside other functions (always fix)
- [ ] Classes doing more than one job
- [ ] Deeply nested logic (3+ levels of if/for/while) that can be extracted

### Naming Issues
- [ ] Single-letter or cryptic variable names (except loop counters like `i`, `j`)
- [ ] Function names that don't describe what they do (e.g., `handle`, `process`, `do_thing`)
- [ ] Inconsistent naming conventions

### DRY Violations
- [ ] The same logic (even slightly varied) copy-pasted in two or more places — extract into one shared helper
- [ ] Identical conditionals or validation checks scattered across functions — consolidate
- [ ] Similar functions that differ only in one parameter — consider merging with a parameter

### Complexity
- [ ] Long functions (>40 lines) that can be split
- [ ] Unnecessary intermediate variables or overly clever one-liners that hurt readability
- [ ] Dead code or commented-out blocks

---

## Step 2: Present the Plan to the User

**Before making any changes**, write out the full refactor plan in a clear, human-readable format and send it to the user. Wait for explicit approval ("yes", "go ahead", "looks good", etc.) before touching any file.

The plan must cover:

```
Refactor Plan
=============

Files to split:
  utils.py (320 lines) → string_utils.py, file_utils.py
    - string_utils.py: format_name(), truncate(), slugify()
    - file_utils.py: read_json(), write_json(), ensure_dir()

Nested functions to extract:
  processor.py: _parse_row() is nested inside process_data() → move to module level

Functions to rename:
  handle()    → process_incoming_webhook()   (in api.py)
  do_stuff()  → aggregate_daily_metrics()    (in reports.py)

DRY fixes:
  validate_email() is duplicated in auth.py and signup.py → consolidate in validators.py

Long functions to split:
  pipeline.py: run() is 95 lines → split into load_data(), transform(), export()

New files to create:
  helpers/validators.py   — consolidated validation helpers
  helpers/formatters.py   — formatting utilities (moved from main.py)

Import updates needed:
  main.py, api.py, tests/test_utils.py
```

If anything is unclear or the user wants to adjust the plan, revise it before proceeding.

**Do not start editing files until the user confirms.**

---

## Step 3: Execute the Refactor

Work **file by file**. For each file:

1. Apply all changes for that file in one pass
2. Update all import statements in all affected files immediately — never leave broken imports
3. Verify the logic is preserved — re-read the original and the refactored version side by side mentally

### Rules

**Nested functions — always extract:**
```python
# BEFORE
def process_order(order):
    def calculate_tax(amount):       # ← nested, must move
        return amount * 0.08
    return calculate_tax(order.total)

# AFTER
def calculate_tax(amount):           # ← now top-level
    return amount * 0.08

def process_order(order):
    return calculate_tax(order.total)
```

**Long files — split by concern:**
```
# BEFORE: api.py (400 lines mixing auth, routing, DB, formatting)

# AFTER:
api/
  __init__.py
  routes.py       # URL handlers only
  auth.py         # Authentication logic
  db.py           # Database queries
  formatters.py   # Response formatting
```

**Long functions — extract sub-steps:**
```python
# BEFORE: one 80-line function doing 4 things

# AFTER: orchestrator calls 4 focused helpers
def run_pipeline(data):
    validated = validate_input(data)
    normalized = normalize_records(validated)
    results = compute_scores(normalized)
    return format_output(results)
```

**Clarify names:**
```python
# BEFORE
def p(u, l):
    return db.get(u, l)

# AFTER
def fetch_user_posts(user_id, limit):
    return db.get(user_id, limit)
```

---

## Step 4: Verify

After completing all changes:

1. **Trace key execution paths** through the refactored code — confirm logic is identical
2. **Check all imports** — nothing should be missing or circular
3. **Confirm no functions are nested** in the final output
4. **Check each file feels focused** — a reader should immediately understand its purpose
5. **Run existing tests** if any exist (`pytest`, `npm test`, etc.) and report results

If tests fail or you find a logic discrepancy, fix it immediately and note it to the user.

---

## Step 5: Summarize Changes

Provide the user with a clear summary:

```
Refactor Summary
================
Files modified: 4
Files created: 2
Files deleted: 0

Changes:
- utils.py split into string_utils.py and file_utils.py (was 320 lines)
- Extracted 3 nested functions to module level in processor.py
- Renamed 5 functions for clarity (see below)
- Simplified nested conditionals in validator.py (3→1 level deep)

Renamed:
  handle_it()     → process_incoming_webhook()
  do_stuff()      → aggregate_daily_metrics()

New files:
  helpers/string_utils.py   — string formatting helpers (moved from utils.py)
  helpers/file_utils.py     — file I/O helpers (moved from utils.py)

Functional change: NONE
```

---

## Python-Specific Notes

- Extract nested functions to module level or as methods on a class
- Group related functions in the same module; split by domain when a module mixes concerns
- Use `_underscore` prefix for private helpers not meant to be imported elsewhere
- Prefer `pathlib.Path` over `os.path` string manipulation where you see it
- Use `with` statements for all file I/O (never bare `open`/`close`)
- Replace `== True` / `== False` comparisons with plain boolean expressions

---

## Important Constraints

- **No logic changes.** If you're unsure whether a change is safe, leave it and note it for the user.
- **No dependency changes.** Don't add or remove libraries.
- **No test changes** unless tests themselves contain the anti-patterns (nested functions, etc.).
- **Preserve comments** that explain business logic. Remove only obvious noise comments (e.g., `# increment i`).
- **Match existing style** — don't mix conventions within a file.