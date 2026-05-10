---
name: code-review
description: >
  Structured Python code review skill. Trigger whenever a user pastes Python code and asks for
  feedback, says "thoughts?", "anything wrong here?", "review this", or mentions code quality,
  correctness, security, or design — even casually. Also trigger for "look over my files" or
  any request to audit a Python script.
---

# Code Review Skill

## Review Process

### Step 1: Understand Context
- What does the code do? (docstrings, function names, comments)
- What's the scope? (snippet, file, project)

If no code has been shared, ask for it.

### Step 2: Review Dimensions

Examine across these areas — skip any that don't apply:

**🐛 Logic & Correctness** — Does it do what it claims? Off-by-one errors, wrong conditions, unhandled branches, misused return values?

**⚠️ Edge Cases & Error Handling** — Empty inputs, None, zero, large values? Exceptions caught too broadly or swallowed silently? Cleanup guaranteed (context managers, finally)?

**🔒 Security** — Input validated? SQL injection, path traversal, hardcoded secrets? Unsafe deserialization (pickle, yaml.load)?

**⚡ Performance** — O(n²) where O(n) is possible? DB/network calls in loops? Unnecessary repeated computation? Large data in memory?

**🧪 Tests** — Coverage for main logic and edge cases? Brittle tests (hardcoded values, time-dependent)? Mocks appropriate?

**📐 Design** — Single Responsibility? Long functions that should split? DRY violations? Fits existing architecture?

**📝 Naming & Docs** — Names clear? Complex sections commented? Public APIs have docstrings?

**🔌 API Design** — Intuitive signatures? Consistent return types? Too many parameters (consider dataclass)?

## Feedback Format

### Severity Labels
| Label | Meaning |
|---|---|
| `[critical]` | Bugs, security issues, data loss — must fix |
| `[major]` | Significant correctness/design issues — strongly recommended |
| `[minor]` | Worth fixing, not blocking |
| `[nit]` | Style/clarity — optional |
| `[praise]` | Call out what's done well |

### Writing Good Feedback
Be specific, actionable, and code-focused (not person-focused). Always explain *why* something matters and suggest a fix. Mark nits as non-blocking. Balance criticism with `[praise]`.

Bad: `"You forgot to handle None here."`  
Good: `"[major] Raises AttributeError if user is None (e.g., DB lookup fails). Add a None check before accessing user.email."`

## Output Structure

1. **Summary** — One paragraph: what the code does, overall impression, biggest concern.
2. **Findings** — Grouped by severity (highest first). Each finding: `**[severity] Title** (file:line)` → why it matters → suggested fix with code snippet.
3. **Fix Summary** — Bullet list of all proposed changes by severity, as a clear action plan.
4. **Approval Gate** — Ask: *"Would you like me to apply these? I can do critical/major fixes, or you can pick. I won't change anything until you confirm."* Do not make changes until explicitly approved.
5. **Post-Implementation Summary** (after changes) — What changed, assumptions made, what was left as-is and why, recommended next steps.

## Scope Guidance
- **Snippet/function** — Full deep review across all dimensions
- **Single file** — Full review; note if imports/callers would help
- **Full project** — Ask what to prioritize; start with entry points and core logic