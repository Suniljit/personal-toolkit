---
name: improve-codebase-architecture
description: >
  Refactor, clean up, and improve a codebase or specific folder. Use when the user asks
  to improve code architecture, clean up AI-generated slop, refactor for readability,
  make code more testable, reduce complexity, improve folder structure, apply clean
  architecture principles, separate concerns, increase modularity, add comments, apply
  DRY principles, split large files, or generally improve code quality. Also trigger for:
  "clean up my code", "review my codebase", "make this more readable", "reduce complexity",
  "refactor this", "improve my project structure", "audit my code", "restructure this
  project", "make this more modular". Conducts a structured interview, produces a
  PR-ready plan for approval, then delivers fully refactored code.
---

# Improve Codebase Architecture

A structured, interview-driven skill to improve a codebase's architecture, readability,
testability, and maintainability without breaking behavior.

**Core philosophy**: Think like a senior engineer. Separate concerns. Increase modularity.
Make the code easy for a human to read and navigate — this is always in scope, even if
not explicitly requested. Never assume — explore first, interview second, plan third,
execute last.

**Outputs**: (1) a PR-ready plan the user approves, (2) refactored code per the plan.

---

## Phase 1: Codebase Exploration

Explore silently before asking anything. Answer what you can from the code.

```bash
find <target_dir> -type f | sort
wc -l <target_dir>/**/*.* 2>/dev/null | sort -rn | head -40
```

Read all files if <30 files; otherwise read entry points, shared utilities, config, and
largest files first. Also check for `INDEX.md` at the project root — note what
documentation exists so you can flag what needs updating in the plan.

**What to identify:**
- Separation of concerns violations (business logic mixed with I/O, config scattered)
- Modularity issues (tight coupling, unclear interfaces)
- Large files (>300 lines — split candidates)
- Code duplication, long functions (>40 lines), inconsistent naming
- Dead code, silent exception swallowing, hardcoded magic values
- AI slop: unnecessary wrappers, pointless type aliases, over-commented obvious lines
- Existing test structure

> Read `references/ai-slop-patterns.md` now for a catalog of patterns to watch for.

---

## Phase 2: Interview

Use the question tool for every question. One question (or tight cluster) at a time.
Always give your recommended answer with brief rationale. Never ask what you can read.

**A. Scope & Goals**
- Which files/folders are in scope? Any that must not be touched?
- Primary pain points: readability? testability? size? separation of concerns? all?

**B. Behavior Contract**
- Confirm your understanding of what the codebase does.
- Existing tests? Any behavior changes wanted, or purely structural?

**C. Architecture & Layering**
- Walk through the concern violations you found. For each: how should it be separated?
- Propose a layering model (e.g., API → service → data → models → config) with rationale.
- Propose a folder structure if restructuring is warranted (show visually, get approval).

**D. Module Boundaries**
- Public vs. private interfaces per module? Circular dependencies to break?
- Any modules to merge (too granular) or split (too broad)?

**E. Code Quality & Readability**
- Human readability: are file/function names, structure, and flow easy to navigate?
- Constants/config: consolidate? Validate env vars at startup?
- Naming: anything inconsistent or unclear?
- Functions over 40 lines: extract sub-steps?
- Duplicated logic: extract to shared module?
- AI slop found: confirm removal/simplification for each instance.

**F. Comments & Testing**
- Where are comments missing (explain *why*)? Where are they obvious (remove)?
- Should the refactor improve testability (pure functions, dependency injection)?

---

## Phase 3: Plan

After the interview, present a plan for explicit approval. Use this template exactly.
**Keep it brief** — one line per item is the target. Add extra detail only where it
genuinely aids understanding (a non-obvious rationale, a risky change). The plan should
be fast to scan, not exhaustive.

---

```markdown
## Refactoring Plan

### Architecture Description
[2–4 paragraphs: what layers/modules exist, what each owns, why this is better,
how concerns are now separated. Should onboard a new engineer from scratch.]

### New Folder Structure (if changed)
project/
├── module/     # [purpose]
│   └── ...

### Documentation Updates
[Check INDEX.md and list any docs that describe the affected code and need updating.
If no INDEX.md exists or no docs are affected, state that explicitly.]
- `docs/foo.md` — needs update because [reason]

### Files to Modify
- `path/to/file.py` — [what changes and why]

### Files to Create
- `path/to/new.py` — [what it contains and why]

### Files to Delete
- `path/to/dead.py` — [why safe to remove]

### Change Breakdown
For each file, specific changes:
1. [Change] — [rationale]

### Behavior Changes (requires explicit approval)
- [Any observable behavior changes, or "None"]

### What Will Not Change
- [Reassure the user about preserved behavior and interfaces]
```

---

**Wait for explicit approval before editing anything.**
If the user wants modifications, revise and re-present before proceeding.

---

## Phase 4: Execution

> Read `references/language-conventions.md` now for import ordering, naming, and
> layering conventions to apply during execution.

Execute in dependency order: shared utilities and types before files that import them.

- **Preserve behavior**: If in doubt, restructure only — keep logic identical.
- **Human readability first**: Choose names, structure, and ordering that a reader can navigate without a map.
- **One file at a time**: Complete all changes to a file before moving to the next.
- **Only implement what was approved.**
- **Comments**: Explain *why* and non-obvious *what*. Never restate what the code says.
- **Target**: Files under 500 lines. Imports: stdlib → third-party → local.

Narrate briefly as you go: "Now creating `services/user_service.py` — extracting
business logic from `api/handlers.py` as agreed."

---

## Phase 5: Summary

```markdown
## Changes Summary

### Architecture Description
[Full description suitable as onboarding documentation — layers, modules, responsibilities,
interactions, and rationale for the structure.]

### New Folder Structure
[Visual tree with one-line descriptions per folder]

### Documentation Updates Made
- [Which docs were updated, or "None required"]

### Files Modified (N)
- `file.py`: [one-line summary]

### Files Created (N) / Deleted (N)

### Key Improvements
- Architecture: [concern separation, layers introduced]
- Readability / Testability / DRY / Complexity: [what improved]

### Line Count
- Before: ~X lines across N files → After: ~Y lines across M files

### Behavior Preserved
All original behavior intact. Approved behavior changes: [list or "None"]
```

---

## Reference Files

- `references/ai-slop-patterns.md` — Read during **Phase 1** exploration. Catalog of
  over-engineering patterns to identify and how to fix them.
- `references/language-conventions.md` — Read during **Phase 4** execution. Python
  conventions, import ordering, layering patterns, and the separation of concerns checklist.