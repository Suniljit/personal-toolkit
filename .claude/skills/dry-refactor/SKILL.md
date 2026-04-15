---
name: dry-refactor
description: >
  Scans Python codebases to identify duplication and reuse opportunities, then makes
  approved changes to reduce code and complexity. Use this skill whenever the user
  wants to find repeated patterns in their Python code, reduce duplication, DRY up
  their code, identify candidates for shared helpers or abstractions, or refactor for
  less complexity. Trigger on phrases like: "find patterns for reuse", "reduce
  duplication", "DRY this up", "refactor my code", "look for reuse", "identify
  repeated code", "make my code less complex", "find shared patterns", "consolidate
  my code". Do NOT trigger for general code fixes, bug fixes, or style improvements
  unrelated to duplication — and do NOT trigger on "simplify" (that belongs to a
  separate skill).
---

# Code Reuse Refactor Skill

**Primary goal: end up with less code and less complexity.** Every suggestion must
reduce the total amount of code and make the codebase easier to understand — not just
rearrange it. If a proposed abstraction adds more moving parts than it removes, it
should not be suggested.

Scans Python code for duplication and reuse opportunities, presents all findings to
the user for approval, then applies approved changes.

## Workflow

### Step 1 — Locate files

If the user specified a path, use it. Otherwise ask which directory or files to scan.
Then inventory all `.py` files:

```bash
find <path> -name "*.py" | sort
```

Read each file before analysis.

---

### Step 2 — Analyse for patterns

Look across all files for the following categories (roughly in priority order):

#### A. Duplicate / near-duplicate logic blocks
Repeated sequences of statements (3+ lines) doing the same thing, possibly with minor
variation (different variable names, different literals). These are the highest-value
targets.

#### B. Copy-pasted functions or methods
Functions with identical or near-identical bodies that differ only in a parameter or
a constant. Candidates for a single parameterised function.

#### C. Parallel structure / boilerplate
Multiple classes or functions that follow the same structural template (same
try/except shell, same argument validation, same logging pattern). Candidates for a
base class, decorator, or helper.

#### D. Repeated expressions or magic values
The same expression computed in multiple places, or the same literal appearing many
times. Candidates for a named constant or a small utility function.

#### E. Redundant imports or utility re-implementations
Standard-library or third-party functionality reimplemented locally, or the same
utility imported and reimplemented in several modules.

#### Exclusion rule
Flag a pattern as "coincidental similarity — do not merge" when:
- The code looks similar but serves semantically distinct purposes
- Merging would require a confusing number of parameters or flags
- The abstraction would be longer or harder to understand than the duplication it replaces
- The similarity is in test code that intentionally mirrors production structure

**The bar for suggesting a change is: the result must have fewer lines of code AND
be easier to understand than the original. If either condition is not met, do not
suggest it.**

---

### Step 3 — Build the suggestion list

For each finding, produce a concise entry:

```
[N] <SHORT TITLE>
Files: <file:line references>
Pattern: <one sentence describing what repeats>
Suggestion: <one sentence describing the proposed abstraction>
Lines saved: ~X  (net lines removed after the abstraction is added)
Complexity change: simpler / same  (never suggest if more complex)
Estimated effort: trivial / small / medium
Risk: low / medium  (medium = touches call sites in multiple files)
--- before (representative snippet, ≤ 15 lines) ---
<code>
--- after ---
<code>
```

Group by category (A–E above). Within each group, order by estimated value (most
duplication removed first).

Present ALL findings at once as a numbered list. End with:

> **Please reply with the numbers you'd like me to apply (e.g. "1 3 5"), "all", or
> "none". I won't touch any files until you confirm.**

---

### Step 4 — Wait for approval

Do not edit any files. Wait for the user's reply.

If the user asks questions or wants to discuss a specific suggestion, answer and
re-ask for their final selection before proceeding.

---

### Step 5 — Apply approved changes

For each approved suggestion, in dependency order (shared helpers created before
call-site updates):

1. Create or update the target file using `str_replace` (preferred for surgical edits)
   or `create_file` (for new helper modules).
2. Update every call site identified in the finding.
3. After all edits for a suggestion are complete, move to the next.

Keep changes minimal and literal — do not rename variables beyond what is needed,
do not reformat unrelated code, do not add comments unless they aid understanding of
the new abstraction.

---

### Step 6 — Summary

After all changes are applied, output a brief summary:

```
Applied N suggestions:
  [1] <title> — <what was created/changed, e.g. "extracted helper `parse_date()` in utils.py, updated 4 call sites">
  [3] <title> — ...
  ...

Lines removed: ~X   (rough estimate)
Files modified: <list>
Files created: <list>  (if any)
```

Then offer to run a quick sanity check:

```bash
python -m py_compile <each modified file>
```

Report any syntax errors immediately.

---

## Principles

- **Less code, less complexity — always.** A suggestion is only valid if it produces
  a net reduction in lines of code AND leaves the codebase easier to follow. Neither
  condition alone is enough; both must be true.
- **Approval gates everything.** Never edit a file before the user approves.
- **Smallest abstraction that works.** Prefer a plain function over a class; prefer
  a module-level constant over a config object. If the abstraction requires more
  explanation than the duplication it removes, don't suggest it.
- **One concern per suggestion.** Don't bundle unrelated patterns into one item;
  let the user accept or reject each independently.
- **Preserve behaviour exactly.** No logic changes, no renaming beyond the new
  abstraction, no reformatting of unrelated code.
- **Coincidental similarity is noted, not merged.** Always call it out so the user
  knows you saw it and made a deliberate choice not to suggest a merge.