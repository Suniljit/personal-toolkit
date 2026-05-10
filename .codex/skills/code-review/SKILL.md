---
name: code-review
description: >
  Structured Python code review skill for Codex/GPT agents. Trigger whenever a user pastes
  Python code and asks for feedback, says "thoughts?", "anything wrong here?", "review this",
  or mentions code quality, correctness, security, or design - even casually. Also trigger for
  "look over my files" or any request to audit a Python script.
---

# Code Review Skill

Use this skill to review Python code and report findings. Default to review-only mode: do not
edit files during the initial review unless the user explicitly asks for fixes before the review.
Preserve the approval gate before any implementation work.

## Review Process

### Step 1: Understand Context
- Identify what the code does from names, docstrings, comments, tests, and call sites.
- Identify the scope: snippet, single file, or project.
- If reviewing files in a repository, inspect only the context needed to validate findings.

If no code has been shared, ask for it.

### Step 2: Review Dimensions

Examine across these areas. Skip any that do not apply.

**Logic & Correctness** - Does it do what it claims? Off-by-one errors, wrong conditions, unhandled branches, misused return values?

**Edge Cases & Error Handling** - Empty inputs, None, zero, large values? Exceptions caught too broadly or swallowed silently? Cleanup guaranteed with context managers or finally?

**Security** - Input validated? SQL injection, path traversal, hardcoded secrets? Unsafe deserialization with pickle or yaml.load?

**Performance** - O(n^2) where O(n) is possible? DB/network calls in loops? Unnecessary repeated computation? Large data in memory?

**Tests** - Coverage for main logic and edge cases? Brittle tests with hardcoded values or time dependence? Mocks appropriate?

**Design** - Single Responsibility? Long functions that should split? DRY violations? Fits existing architecture?

**Naming & Docs** - Names clear? Complex sections commented? Public APIs have docstrings?

**API Design** - Intuitive signatures? Consistent return types? Too many parameters where a dataclass would clarify?

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
Be specific, actionable, and code-focused, not person-focused. Always explain why something matters and suggest a fix. Mark nits as non-blocking. Balance criticism with `[praise]`.

Bad: `"You forgot to handle None here."`  
Good: `"[major] Raises AttributeError if user is None (e.g., DB lookup fails). Add a None check before accessing user.email."`

### Codex Display Guidance
- Use GitHub-flavored Markdown with short sections and compact bullets.
- When citing local files, use Codex-friendly absolute links when available: `[file.py](/absolute/path/file.py:42)`.
- For pasted snippets or unknown paths, cite the most precise location available, such as `(snippet:12)` or `(function_name)`.
- Keep code snippets minimal and directly tied to the suggested fix.
- If the app supports inline comments and the user asked for comments or review annotations, emit `::code-comment{...}` directives only for actionable findings. Keep each directive tightly scoped to the affected line range.
- Do not use emoji as status markers; rely on severity labels so output renders cleanly in Codex and terminals.

## Output Structure

1. **Summary** - One paragraph: what the code does, overall impression, biggest concern.
2. **Findings** - Group by severity, highest first. Each finding: `**[severity] Title** ([file.py](/absolute/path/file.py:42))` followed by why it matters and a suggested fix with a minimal code snippet when useful.
3. **Fix Summary** - Bullet list of proposed changes by severity, as a clear action plan.
4. **Approval Gate** - Ask: "Would you like me to apply these? I can do critical/major fixes, or you can pick. I won't change anything until you confirm." Do not make changes until explicitly approved.
5. **Post-Implementation Summary** - After approved changes, state what changed, assumptions made, what was left as-is and why, verification run, and recommended next steps.

## Scope Guidance
- **Snippet/function** - Full deep review across all dimensions.
- **Single file** - Full review; note if imports or callers would help.
- **Full project** - Ask what to prioritize; start with entry points and core logic.
