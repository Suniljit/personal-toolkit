---
name: improve-codebase-architecture
description: >
  Use this skill to refactor, clean up, and improve a codebase or specific folder.
  Trigger when the user asks to: improve code architecture, clean up AI-generated slop,
  refactor for readability, make code more testable, reduce complexity, improve folder
  structure, apply clean architecture principles, separate concerns, increase modularity,
  add helpful comments, apply DRY principles, split large files, or generally improve
  code quality. Also trigger for phrases like "clean up my code", "review my codebase",
  "make this more readable", "reduce complexity", "refactor this", "improve my project
  structure", "audit my code", "restructure this project", "separate concerns",
  "make this more modular", or "apply clean architecture". The skill conducts a structured
  interview before making any changes, exploring every design decision collaboratively,
  then delivers both an architecture description and fully refactored code (including a
  new folder structure if warranted). Always use this skill rather than ad-hoc refactoring.
---

# Improve Codebase Architecture

A structured, interview-driven skill to systematically improve a codebase's architecture,
readability, testability, and maintainability — without breaking behavior.

**Core philosophy**: Think like a senior engineer applying clean architecture principles.
Separate concerns. Increase modularity. Improve structure. Never make assumptions — explore
the codebase first, interview the user on every meaningful decision, then deliver an
architecture description and fully refactored code. The user approves a full plan before
any edits begin.

**Key outputs**:
1. **Architecture description** — a written explanation of the new structure and why
2. **Refactored code** — all files rewritten and reorganized per the agreed plan
3. **New folder structure** (if warranted) — restructured project layout

---

## Phase 1: Codebase Exploration (Before Asking Anything)

Before interviewing the user, explore the codebase yourself. Answer as many questions
as possible by reading the code — don't ask the user what you can discover.

### Exploration checklist

Run these explorations silently and build up a mental model:

```bash
# Get the full folder structure
find <target_dir> -type f | sort

# Count lines per file
wc -l <target_dir>/**/*.* 2>/dev/null | sort -rn | head -40

# Identify large files (>300 lines — candidates for splitting)
find <target_dir> -type f | xargs wc -l 2>/dev/null | awk '$1 > 300' | sort -rn
```

Read every file fully if the codebase is small (<30 files). For larger codebases,
read entry points, shared utilities, config files, and the largest files first.

### What to discover before the interview

**Architecture concerns (senior engineer lens)**:
- **Separation of concerns**: Are different responsibilities mixed in the same file or
  function? (e.g., business logic alongside I/O, config mixed with runtime state)
- **Modularity**: Are modules self-contained with clear interfaces? Or tightly coupled?
- **Layering**: Is there a recognizable structure (e.g., API → service → data layer)?
  Is logic bleeding across layers?
- **Entry points**: What runs first? What's the main flow?
- **Dependency direction**: Do lower layers depend on higher ones? (Should be inverted)
- **Cohesion**: Do files/modules contain things that naturally belong together?

**Code quality concerns**:
- **File sizes**: Which files are over 300–500 lines? (Split candidates)
- **Import patterns**: Grouped/sorted? Circular dependencies? Unused imports?
- **Code duplication**: Copy-pasted logic that should be a shared module?
- **Function length**: Functions over 40 lines doing too many things?
- **Naming**: Consistent? Descriptive? Follows language conventions?
- **Config/constants**: Hardcoded values scattered? Should be consolidated?
- **Error handling**: Consistent? Missing? Swallowing exceptions silently?
- **Dead code**: Unused functions, variables, commented-out blocks?
- **AI slop signals**: Unnecessary wrapper classes, pointless type aliases,
  over-commented obvious lines, verbose boilerplate with no value?
- **Test structure**: Are there tests? What's the coverage strategy?

---

## Phase 2: The Interview

After exploration, begin the interview. Reach **shared understanding** of every
meaningful design decision before proposing changes.

### Ground rules

1. **Use the question tool for every question** — never ask in plain prose.
2. **One question at a time** (or a tightly related cluster of 2–3).
3. **Always provide your recommended answer** with brief rationale before asking.
4. **If a question can be answered by reading the code, read the code instead.**
5. **Walk down each branch of the design tree** — resolve dependencies between
   decisions before moving on.
6. **Approve behavior changes explicitly** — if a refactor would change observable
   behavior, flag it clearly and get explicit user approval.
7. **Never batch everything at once** — go question by question, waiting for answers.

### Interview track

#### A. Scope & Goals
- Which folder/files are in scope?
- Any files that should NOT be touched? (auto-generated, vendored, etc.)
- Primary pain points: readability? testability? size? separation of concerns? all?

#### B. Behavior Contract
- Confirm your understanding of what the codebase does.
- Are there existing tests? Should we add any?
- Any behavior you've been wanting to change — or is this purely structural?

#### C. Architecture & Separation of Concerns
- Walk through the concerns you identified (e.g., "business logic is mixed with I/O
  in `main.py`"). For each: how should it be separated?
- Is there a natural layering for this project? (e.g., API → service → repository,
  or CLI → core logic → storage)
- Should the project adopt a recognized architecture pattern? (e.g., layered,
  hexagonal/ports-and-adapters, feature-based organization)
- Recommend your preferred structure with rationale; ask for confirmation.

#### D. Folder Structure
- Does the current folder structure reflect the module/concern boundaries?
- Walk through a proposed new folder structure if restructuring is warranted.
  Present it visually:
  ```
  src/
  ├── api/         # HTTP handlers — thin, no business logic
  ├── services/    # Business logic — no I/O dependencies
  ├── models/      # Data types and validation
  ├── config/      # All configuration and constants
  └── utils/       # Shared pure utilities
  ```
- Confirm every folder: its purpose, what belongs in it, what doesn't.
- Get explicit approval before proposing a new layout — folder restructuring is
  a significant change.

#### E. Module Boundaries & Interfaces
- For each module/layer: what's the public interface? What should be private?
- Are there circular dependencies to break?
- Should any modules be merged (too granular) or split (too broad)?

#### F. Imports & Dependencies
- Should imports be grouped and sorted (stdlib → third-party → local)?
- Any unused imports to remove?

#### G. Constants & Configuration
- Are there hardcoded values that should be named constants?
- Should config be consolidated into one place?
- Should environment variables be validated/typed at startup?

#### H. Naming & Readability
- Are variable/function names clear and consistent?
- Any abbreviations to spell out?
- Does naming follow language conventions?

#### I. Functions & Complexity
- Are there functions over 40 lines doing too many things?
- Complex conditionals that could be simplified or extracted?

#### J. Comments & Documentation
- Where are comments missing and would help a reader understand *why*?
- Where are comments obvious and should be removed?
- Should there be module-level docstrings? Function docstrings?

#### K. DRY & Duplication
- Walk through duplicated logic found during exploration.
- For each: extract to a shared function/module? Confirm location and signature.

#### L. AI Slop Cleanup
- Walk through over-engineered patterns found (unnecessary wrappers, pointless
  abstractions, verbose boilerplate).
- For each: confirm removal or simplification.

#### M. Error Handling
- Is error handling consistent?
- Errors silently swallowed anywhere?
- Should errors be standardized?

#### N. Testing Strategy (if applicable)
- Should the refactor improve testability (dependency injection, pure functions)?
- Specific pieces that are hard to test right now?

---

## Phase 3: The Plan

After the interview, generate a structured plan for the user to approve. The plan
must include an architecture description alongside the file-change breakdown.

### Plan format

```
## Refactoring Plan

### Architecture Description
[2–4 paragraphs describing the new structure: what layers/modules exist, what each is
responsible for, why this organization is better, and how concerns are now separated.
Write this so a new engineer could understand the project structure from it alone.]

### New Folder Structure (if changed)
```
project/
├── new_module/     # [what lives here and why]
│   ├── ...
├── ...
```

### Files to be modified
- `path/to/file.py` — [brief reason]

### Files to be created
- `path/to/new_module.py` — [what it contains and why]

### Files to be deleted
- `path/to/dead_code.py` — [why it's safe to remove]

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

Execute changes in dependency order — shared utilities and types before files that
import them, new files before files that reference them.

### Execution principles

- **Preserve behavior**: If in doubt, keep the logic identical and only restructure.
- **One file at a time**: Make all changes to a file, then move to the next.
- **Do not invent features**: Only implement what was approved in the plan.
- **Separation of concerns**: Each file should have one clear responsibility.
  No mixing of I/O with business logic, no config scattered across modules.
- **Modularity**: Modules should export clean interfaces; internals stay private.
- **Comments**: Add helpful comments as agreed. Explain *why* and non-obvious *what*.
  Never explain things a competent reader already knows.
  - Good: `# Retry up to 3 times — the API is flaky under load`
  - Bad: `# increment counter` above `i += 1`
- **Line length target**: Aim for files under 500 lines.
- **Import ordering** (if agreed): stdlib → third-party → local, blank lines between groups.

### During execution

Narrate briefly as you go: "Now creating `services/user_service.py` — extracting business
logic out of `api/handlers.py` as agreed." Keep the user informed without being verbose.

---

## Phase 5: Summary

After all edits, provide a complete summary including the architecture description.

```
## Changes Summary

### Architecture Description
[Full written description of the new architecture: layers, modules, their responsibilities,
and how they interact. Should be detailed enough to serve as onboarding documentation
for a new engineer. Include the rationale for why this structure was chosen.]

### New Folder Structure
[Visual tree of the final project layout, with one-line descriptions per folder]

### Files modified (N)
- `file.py`: [one-line description of what changed]

### Files created (N)
- `new_file.py`: [what it contains]

### Files deleted (N)
- `old_file.py`: [why it was safe to remove]

### Key improvements
- Architecture: [how concerns are now separated, what layers were introduced]
- Modularity: [what was split, decoupled, or given cleaner interfaces]
- Readability: [what got better]
- Testability: [what got better]
- DRY: [duplications eliminated]
- Complexity: [simplifications made]

### Line count changes
- Before: ~X total lines across N files
- After: ~Y total lines across M files

### Behavior preserved
All original behavior is intact. The following behavior changes were explicitly approved:
- [list any]
```

---

## Reference Files

See `references/ai-slop-patterns.md` for a catalog of common over-engineering patterns
to watch for and how to simplify them.

See `references/language-conventions.md` for Python import ordering, naming, file
structure, and commenting conventions.