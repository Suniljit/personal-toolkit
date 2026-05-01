---
name: improve-codebase-architecture
description: >
  Use this skill to refactor, clean up, and improve a codebase or specific folder.
  Trigger when the user asks to: improve code architecture, clean up AI-generated slop,
  refactor for readability, make code more testable, reduce complexity, improve folder
  structure, add helpful comments, apply DRY principles, split large files, or generally
  improve code quality. Also trigger for phrases like "clean up my code", "review my
  codebase", "make this more readable", "reduce complexity", "refactor this", "improve
  my project structure", or "audit my code". The skill conducts a structured interview
  with the user before making any changes, exploring every design decision collaboratively.
  Always use this skill rather than ad-hoc refactoring when the user wants systematic
  improvements to their code.
---

# Improve Codebase Architecture

A structured, interview-driven skill to systematically improve a codebase's readability,
testability, AI-navigability, and maintainability — without breaking behavior.

**Core philosophy**: Never make assumptions. Explore the codebase first, then interview
the user on every meaningful decision before touching a single file. The user approves
a full plan before any edits begin.

---

## Phase 1: Codebase Exploration (Before Asking Anything)

Before interviewing the user, explore the codebase yourself. Answer as many questions
as possible by reading the code directly — don't ask the user what you can discover.

### Exploration checklist

Run these explorations silently and build up a mental model:

```bash
# Get the full folder structure
find <target_dir> -type f | sort

# Count lines per file
wc -l <target_dir>/**/*.* 2>/dev/null | sort -rn | head -40

# Identify large files (>300 lines — candidates for splitting)
find <target_dir> -type f | xargs wc -l 2>/dev/null | awk '$1 > 300' | sort -rn

# Identify duplicate/near-duplicate patterns (DRY violations)
# Read key files to understand the codebase structure
```

Read every file fully if the codebase is small (<30 files). For larger codebases,
read entry points, shared utilities, config files, and the largest files first.

### What to discover before the interview

- **Entry points**: What runs first? What's the main flow?
- **File sizes**: Which files are over 300–500 lines?
- **Import patterns**: Are imports grouped/sorted? Any circular dependencies? Unused imports?
- **Variable naming**: Consistent? Descriptive? Any cryptic abbreviations?
- **Config/constants**: Hardcoded values that should be constants? Config scattered across files?
- **Code duplication**: Copy-pasted logic that should be a shared function?
- **Comment quality**: Missing where needed? Obvious/useless where present?
- **Function length**: Functions doing too many things?
- **Error handling**: Consistent? Missing?
- **Dead code**: Unused functions, variables, commented-out blocks?
- **AI slop signals**: Over-engineered abstractions, unnecessary wrapper classes, verbose
  boilerplate that adds no value, pointless type aliases, over-commented obvious lines?
- **Test structure**: Are there tests? What's the coverage strategy?
- **Folder structure**: Does it follow language/framework conventions?

---

## Phase 2: The Interview

After exploration, begin the interview. The goal is to reach **shared understanding**
of every meaningful design decision before proposing changes.

### Ground rules for the interview

1. **Use the question tool for every question** — never ask in plain prose.
2. **One question at a time** (or a tightly related cluster of 2–3).
3. **Always provide your recommended answer** with a brief rationale before asking.
4. **If a question can be answered by reading the code, read the code instead.**
5. **Walk down each branch of the design tree** — resolve dependencies between decisions
   before moving on (e.g., decide on file structure before deciding what goes in each file).
6. **Approve behavior changes explicitly** — if a refactor would change observable behavior,
   flag it clearly and get explicit user approval.
7. **Never batch everything at once** — go question by question, waiting for answers.

### Interview track

Work through these topic areas in order, skipping any that aren't relevant:

#### A. Scope & Goals
- Which folder/files are in scope?
- Are there any files that should NOT be touched? (e.g., auto-generated, vendored)
- What's the primary pain point: readability? testability? size? duplication? all of the above?

#### B. Behavior Contract
- What is this codebase supposed to do? (Confirm your understanding from exploration)
- Are there existing tests? Should we add any?
- Is there any behavior you've been wanting to change — or is this purely structural?

#### C. File Structure & Module Organization
- Does the current folder structure make sense?
- Are there files that are too large and should be split? (Flag specific files with line counts)
- Are there files that are too small and should be merged?
- Does the naming convention for files match the language/framework norm?

#### D. Imports & Dependencies
- Should imports be grouped and sorted (stdlib → third-party → local)?
- Are there any circular imports to break?
- Are there unused imports to remove?
- Should any modules be reorganized to reduce coupling?

#### E. Constants & Configuration
- Are there hardcoded values (magic numbers, strings) that should be named constants?
- Should config be consolidated into one place (e.g., a `config.py` or `constants.ts`)?
- Should environment variables be validated/typed at startup?

#### F. Naming & Readability
- Are variable/function names clear and consistent?
- Are there any abbreviations that should be spelled out?
- Does naming follow language conventions (snake_case, camelCase, etc.)?

#### G. Functions & Complexity
- Are there functions that are too long (>40–50 lines) and should be broken up?
- Are there functions doing too many things (should follow single responsibility)?
- Are there complex conditionals that could be simplified or extracted?

#### H. Comments & Documentation
- Where are comments missing and would help a novice understand what/why?
- Where are comments obvious/useless and should be removed?
- Should there be module-level docstrings? Function docstrings?
- The bar: comment the *why* and non-obvious *what*, never the obvious.

#### I. DRY & Duplication
- Walk through any duplicated logic found during exploration.
- For each: should it be extracted to a shared function/module?
- Confirm the proposed shared location and signature.

#### J. AI Slop Cleanup
- Walk through specific over-engineered patterns found (unnecessary wrappers,
  pointless abstractions, bloated boilerplate).
- For each: confirm removal or simplification.

#### K. Error Handling
- Is error handling consistent?
- Are there places where errors are silently swallowed?
- Should errors be standardized?

#### L. Testing Strategy (if applicable)
- Should the refactor improve testability (e.g., dependency injection, pure functions)?
- Are there specific pieces that are hard to test right now?

---

## Phase 3: The Plan

After the interview is complete, generate a structured plan for the user to approve.

### Plan format

```
## Refactoring Plan

### Files to be modified
- `path/to/file.py` — [brief reason]

### Files to be created
- `path/to/new_module.py` — [what it contains and why]

### Files to be deleted
- `path/to/dead_code.py` — [why it's safe to remove]

### Folder structure changes
- [Describe any moves/renames]

### Change-by-change breakdown
For each file, list specific changes:
  1. [Change description] — [rationale]
  2. ...

### Behavior changes (requires explicit approval)
- [List any changes that alter observable behavior]

### What will NOT change
- [Reassure the user about what stays the same]
```

**Wait for explicit approval before making any edits.**
If the user requests modifications to the plan, revise and re-present before proceeding.

---

## Phase 4: Execution

Execute changes in dependency order — shared utilities before files that import them,
new files before files that reference them.

### Execution principles

- **Preserve behavior**: If in doubt, keep the logic identical and only restructure.
- **One file at a time**: Make all changes to a file, then move to the next.
- **Do not invent features**: Only implement what was approved in the plan.
- **Comments**: Add helpful comments as agreed. Follow the rule: explain *why* and
  non-obvious *what*. Never explain things a competent reader already knows.
  - Good: `# Retry up to 3 times — the API is flaky under load`
  - Bad: `# increment counter` above `i += 1`
- **Line length target**: Aim for files under 500 lines. If a file must stay longer,
  that's fine — but flag it.
- **Import ordering** (if agreed): stdlib → third-party → local, with blank lines between groups.

### During execution

Narrate briefly as you go: "Now editing `utils/helpers.py` — extracting `format_date`
into `utils/date_utils.py` as agreed." Keep the user informed without being verbose.

---

## Phase 5: Summary

After all edits are complete, provide a summary:

```
## Changes Summary

### Files modified (N)
- `file.py`: [one-line description of what changed]

### Files created (N)
- `new_file.py`: [what it contains]

### Files deleted (N)
- `old_file.py`: [why it was safe to remove]

### Key improvements
- Readability: [what got better]
- Testability: [what got better]
- DRY: [duplications eliminated]
- Complexity: [simplifications made]
- Comments: [what was added/removed]

### Line count changes
- Before: ~X total lines across N files
- After: ~Y total lines across M files

### Behavior preserved
All original behavior is intact. The following behavior changes were explicitly approved:
- [list any]
```

---

## Reference: Common AI Slop Patterns to Eliminate

See `references/ai-slop-patterns.md` for a catalog of common over-engineering patterns
to watch for and how to simplify them.

## Reference: Python Conventions

See `references/language-conventions.md` for Python import ordering, naming, file structure, and commenting conventions.