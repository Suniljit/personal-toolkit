---
name: code-review
description: Review uncommitted changes on the current branch using git. Trigger on "review my changes", "review before I commit", "check my working tree", or "local review". Diffs against HEAD (and optionally staged/unstaged separately), explains the changes, flags issues, and gives a commit-readiness recommendation.
---

# Local Review Skill

## Step 1: Get the diff

```bash
git status --porcelain
git diff HEAD
git diff --stat HEAD
```

This covers staged + unstaged changes vs the last commit. Stop if there are no changes (clean tree).

## Step 2: Deliver the review

No emoticons. Be as short as possible without losing signal. Skip sections that don't apply.

### Summary
1–2 sentences: what and why.

### How It Works
**Approach** — one plain-language sentence.
**Structure** — ASCII diagram of changed components.
**Walkthrough** — key changes explained conversationally. Skip trivial ones.

### Behavioral Changes
For each meaningful change:

**[Label]**
Before: `[old behavior]`
After: `[new behavior]`
Impact: one sentence.

Pure refactor or docs-only? Say so in one sentence, skip this section.

### Issues Found
Cite file and line. If none: "No issues found."

`CRITICAL` — bug, security, data loss. Don't commit.
`WARNING` — edge case, performance, maintainability.
`SUGGESTION` — style or minor improvement.

For each issue, write the explanation so that a junior engineer can immediately understand the problem and fix it:
- **What**: State the problem in plain English. Avoid jargon unless you define it.
- **Why it matters**: One sentence on the real-world consequence (crash, data loss, slowness, etc.).
- **How to fix**: A concrete, actionable step or code snippet. Show the fix, don't just describe it.

Example of a good issue explanation:
> `WARNING` — `src/auth.js`, line 42
> **What:** The password is compared using `==` instead of a constant-time comparison function.
> **Why it matters:** Regular string comparison can leak timing information that attackers use to guess passwords byte-by-byte.
> **Fix:** Replace `password == stored` with `crypto.timingSafeEqual(Buffer.from(password), Buffer.from(stored))`.

Example of a bad issue explanation (too vague):
> `WARNING` — `src/auth.js`, line 42: Insecure comparison.

### Manual Review Checklist
Skip if nothing qualifies. For each item:

**File:** `path/to/file.ext` (lines X–Y)
**Why:** ...
**Check:** ...

Consider: business logic needing external context, third-party APIs, auth/credentials, irreversible DB ops, feature flags, test coverage gaps.

### Watch Out For
One paragraph: the thing a reviewer could easily miss.

### Questions for the Author
Skip if everything is clear. Each question should be paste-ready, with file, line, and snippet inline.

**File:** `path/to/file.ext`, line N
**Snippet:**
```lang
[relevant snippet]
```
**Question:** [Question to the author.]

### Commit Readiness

`READY` / `READY WITH NOTES` / `NOT READY`

**Safe to commit?** One sentence; call out any CRITICAL/WARNING issues.
**What could break?** Specific system or flow. "Nothing" if clean.
**Blockers:** (skip if READY) What must be fixed before committing.

---
*Direct and specific. Cite files and lines. No padding.*