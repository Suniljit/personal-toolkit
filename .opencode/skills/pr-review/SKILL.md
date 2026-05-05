---
name: pr-review
description: Reviews a pull request using git. Trigger when the user says "review PR #<number>", "review PR #<number> against <branch>", "review this PR", "review this branch", "review branch <name>", "check this PR", or just "review PR". Also trigger if the user says "review" with no further context — assume they mean the current branch. Uses git (and gh CLI if available) to fetch branch info and diff. Explains what the code does, flags any issues or bugs, and shows how behavior has changed from before.
---

# PR Review Skill

## Step 0: Resolve the PR number (if given)

If the user said "review PR #<number>", use the `gh` CLI to get the branch name:
```bash
gh pr view <number> --json headRefName,title,body
```

Extract `headRefName` as the branch to review. If `gh` isn't available or fails, ask the user for the branch name directly.

If no PR number was given, use `HEAD` (current branch).

---

## Step 1: Get the diff

Always run `git fetch origin` first to ensure you have the latest remote state.

**Determine the base branch:**
- Default: `origin/main`
- If the user said "review PR #xx against branch xyz" → use `origin/xyz`
- If the user said "diff against X" or "compare to X" → use `origin/X`

**Run the diff:**
```bash
git fetch origin
git diff origin/main...<branch-or-HEAD>
```

Also grab the commit log for context:
```bash
git log origin/main...<branch-or-HEAD> --oneline
```

If the branch doesn't exist or the diff is empty, tell the user clearly and stop.

---

## Step 2: Deliver the review

Structure your response in this order, using clean markdown headers. Do not use emoticons or icons anywhere in the review.

---

### Summary

2–3 sentences: what does this PR do and what problem does it solve?

---

### How It Works

**The approach in plain terms**
Briefly compare the implementation approach to something from everyday life or a familiar concept — one sentence that grounds the reader before diving into code.

**Data flow / structure**
ASCII diagram showing how the key changed components relate to each other — data flow, call sequence, or file relationships, whichever is most useful.

**Walkthrough**
Step-by-step explanation of the key changes, written conversationally as if explaining to a teammate.

---

### Behavioral & Functional Changes

For every meaningful change in behavior, output, or user-facing functionality, show the before and after explicitly. If there is no behavioral change (e.g., pure refactor or docs-only), say so clearly.

Format each change as:

**[Short label describing what changed]**

Before:
```
[What the old code did — be specific about inputs, outputs, side effects, or user experience]
```

After:
```
[What the new code does — same specificity]
```

Impact: one sentence explaining what this means for callers, users, or downstream systems.

---

### Issues Found

Rate each issue by severity. If nothing stands out, say "No issues found — looks good to merge." Do not invent problems.

CRITICAL   — Bug, security hole, or data loss risk. Should block merge.
WARNING    — Code smell, edge case, or performance/maintainability concern.
SUGGESTION — Minor improvement or style. Nice to have.

Quote the file name and approximate line number for each issue.

---

### Manual Review Checklist

List items that automated review cannot fully assess and that a human must personally verify. Only include items that genuinely require human judgment — do not pad this section.

For each item, use this format:

  File: path/to/file.ext (lines X–Y)
  Why it needs a human: one sentence.
  What to verify: the specific thing to check or confirm.

Categories to consider:
- Business logic whose correctness depends on context not visible in the diff
- External API or third-party integrations where provider behavior matters
- Auth, permissions, input sanitization, or anything touching credentials
- Migrations or destructive DB operations that cannot be undone
- Behavior gated on env vars or feature flags not present in the diff
- Test coverage gaps for critical paths

If nothing requires manual review, say: "Nothing flagged — automated analysis covers the full scope of this diff."

---

### Watch Out For

The one thing a reviewer could easily miss — a hidden assumption, a subtle side effect, or something that might break later. One short paragraph.

---

### Questions for the Author

1–3 questions worth raising if anything is unclear, undocumented, or seems like a deliberate trade-off. Skip this section if everything is self-explanatory.

---

## Tone & style
- Be direct and specific — cite file names and line numbers when calling out issues
- Do not pad with generic praise
- Write conversationally, like you're explaining to a teammate over a quick call
- No emoticons or icons anywhere in the output