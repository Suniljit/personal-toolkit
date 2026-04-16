---
name: pr-review
description: Reviews a pull request using git. Trigger when the user says "review PR /#<number>", "review PR /#<number> against <branch>", "review this PR", "review this branch", "review branch <name>", "check this PR", or just "review PR". Also trigger if the user says "review" with no further context — assume they mean the current branch. Uses git (and gh CLI if available) to fetch branch info and diff. Explains what the code does AND flags any issues, bugs, or concerns.
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

### 👁️ Manual Review Required
Flag specific code that automated review cannot fully assess and that the human reviewer must personally inspect. Use this section for:
- **Business logic** — Rules or calculations that only make sense in context (e.g. pricing formulas, eligibility checks, access control rules). Quote the exact lines and explain what assumption you can't verify.
- **External integrations** — API calls, webhooks, or third-party SDKs where correctness depends on provider-specific behaviour or contracts not visible in this diff.
- **Security-sensitive paths** — Auth checks, permission gates, input sanitisation, or anything touching credentials/secrets. Even if it looks right, flag it for a human to confirm.
- **Migrations & data mutations** — Schema migrations, backfill scripts, or destructive DB operations that cannot be undone. State what data could be affected and what to verify before running in production.
- **Environment/config dependencies** — Code whose behaviour changes based on env vars, feature flags, or config values that aren't in the diff.
- **Tests that need human judgement** — Test coverage gaps for critical paths, or tests that pass but may not actually validate the right thing.

Format each item as:
> 📍 `path/to/file.ext` line X–Y
> **Why**: one sentence on why this needs a human eye.
> **What to check**: the specific thing the reviewer should verify or confirm.

If there's nothing requiring manual review, say so explicitly: "Nothing flagged for manual review — automated analysis covers the full scope of this diff."

### ⚠️ Gotcha
The one thing a reviewer could easily miss — a hidden assumption, a subtle side effect, or something that might break later.

### ❓ Questions for the Author
1–3 questions worth raising if anything is unclear, undocumented, or seems like a deliberate trade-off.

---

## Tone & style
- Be direct and specific — quote file names and line numbers when calling out issues
- Don't pad with generic praise
- Keep the walkthrough conversational, like you're explaining to a teammate over a quick call