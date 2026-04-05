---
name: pr-review
description: Reviews a pull request from another contributor using git. Trigger whenever the user says "review this PR", "review this branch", "review branch <name>", "check this PR", or just "review PR". Also trigger if the user says "review" with no further context — assume they mean the current branch. Uses git to fetch the latest code and diff against origin/main. Explains what the code does AND flags any issues, bugs, or concerns.
---

# PR Review Skill

## Step 1: Get the diff

Always run `git fetch origin` first to ensure you have the latest remote state.

**Determine the branch to review:**
- If the user specified a branch name → use that
- If the user didn't specify → use `HEAD` (current branch)

**Determine the base branch:**
- Default: `origin/main`
- If the user says "diff against X" or "compare to X" → use `origin/X`

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

Structure your response in this order:

### 🧾 TL;DR
2-3 sentences: what does this PR do? What problem does it solve?

### 🗺️ How the code works
- **Analogy**: Compare the approach to something from everyday life
- **Diagram**: ASCII art showing data flow, structure, or relationships between changed files
- **Walkthrough**: Step-by-step explanation of the key changes

### 🔍 Issues Found
Rate each issue by severity:
- 🔴 **Critical** — Bug, security hole, data loss risk. Should block merge.
- 🟡 **Warning** — Code smell, edge case, performance or maintainability concern.
- 🟢 **Suggestion** — Minor improvement or style. Nice to have.

If nothing stands out: say "No issues found — looks good to merge." Don't invent problems.

### ⚠️ Gotcha
The one thing a reviewer could easily miss — a hidden assumption, a subtle side effect, or something that might break later.

### ❓ Questions for the Author
1–3 questions worth raising if anything is unclear, undocumented, or seems like a deliberate trade-off.

---

## Tone & style
- Be direct and specific — quote file names and line numbers when calling out issues
- Don't pad with generic praise
- Keep the walkthrough conversational, like you're explaining to a teammate over a quick call