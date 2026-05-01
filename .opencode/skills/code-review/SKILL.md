---
name: code-review
description: >
  Conduct thorough, constructive Python code reviews that reduce review cycle time and maintain code quality.
  Use this skill whenever a user asks to review Python code, audit a script, or requests feedback
  on Python code quality, correctness, security, or design — even if they just paste code and say "thoughts?"
  or "anything wrong here?". Also trigger when the user mentions code review, code quality, or asks Claude
  to look over their Python files.
---

# Code Review Skill

A structured skill for conducting thorough, constructive code reviews that reduce cycle time and maintain quality.

---

## Review Mindset

**Goals:**
- Catch bugs and edge cases
- Ensure maintainability
- Enforce coding standards
- Improve design and architecture

**Not goals:**
- Show off knowledge
- Nitpick formatting
- Block progress unnecessarily
- Rewrite code to your preference

---

## Review Process

### Step 1: Understand Context

Before diving in, quickly assess:
- What does this code do? (read docstrings, function names, comments)
- What's the scope? (single function, module, PR, full project)

If the user hasn't shared any code yet, ask them to paste it or share the file path.

### Step 2: Manual Review

Systematically examine the code across these dimensions. Not every dimension applies to every review — use judgment.

#### 🐛 Logic & Correctness
- Does the code do what it claims?
- Are there off-by-one errors, wrong conditions, or incorrect logic?
- Are all branches handled (if/elif/else, try/except)?
- Are return values used correctly?

#### ⚠️ Edge Cases & Error Handling
- What happens with empty inputs, None, zero, very large values?
- Are exceptions caught too broadly (`except Exception`) or not at all?
- Are errors propagated or silently swallowed?
- Is cleanup guaranteed (context managers, finally blocks)?

#### 🔒 Security
- Is user input validated/sanitized?
- Any SQL injection, path traversal, or injection vulnerabilities?
- Are secrets hardcoded or exposed?
- Are file paths constructed safely?
- Is deserialization (pickle, yaml.load) from untrusted sources?

#### ⚡ Performance
- Any obvious O(n²) loops where O(n) is possible?
- Database/network calls inside loops?
- Unnecessary repeated computation (cache opportunities)?
- Large data loaded into memory unnecessarily?

#### 🧪 Tests
- Is there test coverage for the main logic?
- Are edge cases tested?
- Are tests brittle (hardcoded values, time-dependent)?
- Are mocks used appropriately?

#### 📐 Design & Architecture
- Does this follow the Single Responsibility Principle?
- Are there long functions that should be split?
- Is there unnecessary duplication (DRY)?
- Does it fit the existing codebase architecture?

#### 📝 Naming & Documentation
- Are names clear and descriptive?
- Are complex sections explained with comments?
- Are public APIs documented with docstrings?

#### 🔌 API Design
- Are function signatures intuitive?
- Is the return type consistent and predictable?
- Are there too many parameters (consider dataclass/config object)?

---

## Feedback Format

### Severity Labels

Tag every finding with a severity:

| Label | Meaning |
|-------|---------|
| `[critical]` | Bugs, security issues, data loss risk — must fix |
| `[major]` | Significant design or correctness issues — strongly recommended |
| `[minor]` | Improvements that matter but aren't blocking |
| `[nit]` | Small style/clarity suggestions — optional, non-blocking |
| `[praise]` | Explicitly call out what's done well |

### Writing Good Feedback

**Specific and actionable:**
```
❌ "This is wrong."
✅ "[critical] This could cause a race condition when multiple threads call `update_count()` 
    simultaneously. Consider using threading.Lock() or an atomic operation."
```

**Educational, not judgmental:**
```
❌ "Why didn't you use X pattern?"
✅ "[minor] The Repository pattern could make this easier to test by decoupling DB logic from 
    business logic. Example: https://..."
```

**Focused on code, not person:**
```
❌ "You forgot to handle None here."
✅ "[major] This will raise AttributeError if `user` is None (e.g., when the DB lookup fails). 
    Add a None check before accessing user.email."
```

**Nits are explicitly non-blocking:**
```
[nit] Consider `user_count` instead of `uc` — more readable. Not blocking.
```

**Balance with praise:**
```
[praise] Clean separation of concerns here — the validation logic is nicely isolated.
```

---

## Output Structure

Present findings in this order:

### 1. Summary
One short paragraph: what the code does, overall impression, and a sentence on the biggest concern.

### 2. Findings

Group by severity, highest first. For each finding:
```
**[severity] Short title** (file.py:line if known)
Description of the issue and why it matters.
Suggested fix (with code snippet if helpful).
```

Example:
```
**[critical] Unhandled None dereference** (auth.py:42)
`user.email` is accessed without checking if `user` is None. When `get_user()` returns 
None (e.g., user not found), this raises AttributeError and crashes the request.

Suggested fix:
    user = get_user(user_id)
    if user is None:
        raise ValueError(f"User {user_id} not found")
    send_email(user.email)
```

### 3. Suggested Fixes Summary

A bullet list of all changes proposed, categorized by severity. This gives the author a clear action plan.

### 4. Approval Gate

After presenting findings, always ask:

> "Would you like me to apply these suggestions? I can implement the critical/major fixes, 
> or you can choose which ones to proceed with. Let me know and I won't make any changes until confirmed."

**Do not make any changes until the user explicitly approves.**

### 5. Post-Implementation Summary (after approved changes)

Once changes are applied:
- What was changed and where
- Any assumptions made
- What was intentionally left as-is (and why)
- Recommended next steps (e.g., "add tests for the edge case in X")

---

## Scope Guidance

| Input | Approach |
|-------|---------|
| Single function/snippet | Full deep review across all dimensions |
| Single file | Full review; note if more context (imports, callers) would help |
| Full project | Ask what to prioritize; start with entry points and core logic |

---

## Quick Reference: Common Python Issues to Watch For

- Mutable default arguments: `def f(lst=[])` — classic bug
- `is` vs `==` for equality (especially with strings/ints)
- Bare `except:` catching `SystemExit`/`KeyboardInterrupt`
- `open()` without context manager
- `os.path.join` vs f-strings for paths (use `pathlib`)
- Thread-unsafe global state
- `eval()`/`exec()` on untrusted input
- Hardcoded credentials or API keys
- `pickle.loads()` from untrusted sources
- `yaml.load()` without `Loader=yaml.SafeLoader`
- Not closing DB connections/cursors
- `assert` for runtime validation (stripped in optimized mode)