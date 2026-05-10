---
name: pr-review
description: 'Review a pull request or branch using git. Trigger on "review PR #N", "review this PR/branch", "check this PR", or just "review" with no context (assume current branch). Fetches diff via git + gh CLI, explains the changes, flags issues, and gives a merge recommendation.'
---

# PR Review Skill

Use this skill to perform a code-review style assessment of a pull request, branch, or the current `HEAD`. Prioritize correctness, security, regressions, missing tests, and merge risk over summarizing every changed file.

## Step 0: Resolve Review Target

Resolve the review target before inspecting code.

- If the user gives a PR number, run `gh pr view <number> --json headRefName,baseRefName,title,body` and review `headRefName` against `baseRefName` when available.
- If `gh pr view` fails or the PR cannot be found, stop and ask for the PR/branch details.
- If the user gives a branch name, use that branch.
- If the user says only "review" or gives no target, use `HEAD`.
- Default the base to `origin/main` unless the PR metadata or user specifies another base.

## Step 1: Collect Evidence

Use git and `gh` directly from the repository. Prefer non-interactive commands and keep the fetched data focused on the review.

```bash
git fetch origin
git diff --stat <base>...<branch-or-HEAD>
git diff <base>...<branch-or-HEAD>
git log --oneline <base>...<branch-or-HEAD>
```

Stop and report the blocker if the branch is missing, the base is missing, or the diff is empty. For large diffs, inspect high-risk files first, then representative supporting files. Use line-oriented reads such as `nl -ba`, `sed`, or `rg` when you need exact line numbers.

## Step 2: Review Standard

Review as a gatekeeper, not a changelog writer.

- Preserve the user's approval gates: never approve around unresolved `CRITICAL` issues, and do not remove the `REQUEST CHANGES` or `BLOCK` recommendations.
- Cite concrete files and lines for every issue. In Codex, prefer clickable Markdown links with absolute paths when available: `[path/to/file.ext](/absolute/path/to/file.ext:123)`.
- Do not use emoticons.
- Be short without hiding material risk.
- Skip sections that do not apply.
- Do not invent test results. If tests were not run, say so only when it matters to risk or recommendation.

## Step 3: Deliver The Review

Use this order. Keep headings short and exactly named so the output scans well in Codex.

### Summary

Give 1-2 sentences explaining what changed and why.

### How It Works

**Approach:** One plain-language sentence.

**Structure:** Use a compact ASCII diagram or bullet list of changed components. Keep it readable in proportional Markdown rendering; avoid wide diagrams.

**Walkthrough:** Explain the key changes conversationally. Skip trivial file edits.

### Behavioral Changes

For each meaningful behavior change, use this format:

**[Label]**
Before: `[old behavior]`
After: `[new behavior]`
Impact: One sentence.

For pure refactors or docs-only changes, say that in one sentence and skip this section.

### Issues Found

Lead with findings. If none, write `No issues found.`

For each finding, use this format:

**`SEVERITY` - Short title**  
File: `[path/to/file.ext](/absolute/path/to/file.ext:123)` line N  
Problem: One concise explanation of the bug or risk.  
Fix: The smallest change that would address it.

Severity meanings:

- `CRITICAL` - Bug, security issue, or data loss risk. Blocks merge.
- `WARNING` - Edge case, performance risk, maintainability issue, or missing coverage that can affect behavior.
- `SUGGESTION` - Style, clarity, or minor improvement.

### Manual Review Checklist

Skip if nothing qualifies. Include only checks that require human or environment context.

```text
File: path/to/file.ext (lines X-Y)
Why: ...
Check: ...
```

Consider business logic needing external context, third-party APIs, auth or credentials, irreversible database operations, feature flags, and test coverage gaps.

### Watch Out For

Write one paragraph naming the thing a reviewer could easily miss. Skip if there is nothing useful to add.

### Questions For The Author

Skip if everything is clear. Each question must be paste-ready and addressed to the author.

Use this Codex-friendly format:

**Question:** `[path/to/file.ext](/absolute/path/to/file.ext:123)` line N  
```lang
[relevant snippet]
```
[Question to the author.]

Keep snippets short enough to avoid drowning out the question.

### Merge Recommendation

Choose exactly one:

`APPROVE` / `APPROVE WITH NOTES` / `REQUEST CHANGES` / `BLOCK`

**Safe to approve?** One sentence; call out any `CRITICAL` or `WARNING` issues.

**What could break?** Name the specific system or flow. Write `Nothing obvious from this diff.` if clean.

**Blockers:** Skip for `APPROVE`. For all other recommendations, state what must be fixed or verified before merge.

---

Direct and specific. Cite files and lines. No padding.
