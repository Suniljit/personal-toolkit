# Reverse-Engineered Spec

Every section below must trace to a specific hunk in the diff. If a section would require guessing intent the diff doesn't show, omit the section rather than infer — the aggregator's `## Findings` is where judgment calls belong, not this spec.

## Problem & Solution
**Problem:** what's broken or missing, as evidenced by what the diff fixes or adds.
**Solution:** what the diff does about it, in one or two sentences.

## Decisions
Choices visible in the diff itself — a chosen library, data shape, algorithm, or pattern. Two-tier table; omit rows you can't point to a hunk for.

| Type | Decision | Choice | Why (if evidenced) |
|---|---|---|---|
| Constraint | ... | ... | ... |
| Choice | ... | ... | ... |

## Architecture
_Optional — include only when the diff spans multiple modules/components and a diagram clarifies how they connect. Omit for single-file or trivial diffs._

## Code Shape
_Optional — include only when the diff adds or changes a non-trivial public interface (types, function signatures, API contracts)._

## Validation Rules
_Optional — include only when the diff adds input validation._

## Testing
What tests the diff adds or changes, and what behavior they assert. Omit this section if the diff has no test changes — that absence is a finding for the aggregator, not something to note here.

## Edge Cases
Edge cases the diff explicitly handles — a branch, a guard, a comment. Omit speculative cases the diff doesn't address.

## Out of Scope
_Optional — only when the diff itself signals deferral (a TODO, a comment, a stubbed branch)._
