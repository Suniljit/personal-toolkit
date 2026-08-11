REVERSE-ENGINEERED SPEC

Plain text output, not markdown — this renders in an agent desktop app, not a markdown file. No #, **, |, or _ syntax. Use the section labels below as-is, on their own line, followed by their content. Every section must trace to a specific hunk in the diff. If a section would require guessing intent the diff doesn't show, omit the section rather than infer — the aggregator's Findings section is where judgment calls belong, not this spec.

PROBLEM & SOLUTION
Problem: what's broken or missing, as evidenced by what the diff fixes or adds.
Solution: what the diff does about it, in one or two sentences.

DECISIONS
Choices visible in the diff itself — a chosen library, data shape, algorithm, or pattern. One line per decision, omit any you can't point to a hunk for:
Constraint: <decision> — <choice> (why, if evidenced)
Choice: <decision> — <choice> (why, if evidenced)

ARCHITECTURE
Optional — include only when the diff spans multiple modules/components and a plain-text description of how they connect adds clarity. Omit for single-file or trivial diffs.

CODE SHAPE
Optional — include only when the diff adds or changes a non-trivial public interface (types, function signatures, API contracts). Describe signatures inline as plain text, not in a code block.

VALIDATION RULES
Optional — include only when the diff adds input validation.

TESTING
What tests the diff adds or changes, and what behavior they assert. Omit this section if the diff has no test changes — that absence is a finding for the aggregator, not something to note here.

EDGE CASES
Edge cases the diff explicitly handles — a branch, a guard, a comment. Omit speculative cases the diff doesn't address.

OUT OF SCOPE
Optional — only when the diff itself signals deferral (a TODO, a comment, a stubbed branch).
