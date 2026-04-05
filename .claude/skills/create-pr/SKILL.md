---
name: create-pr
description: >
  Creates GitHub Pull Requests by analyzing branch changes and generating a concise PR summary for user approval. Use this skill whenever the user wants to open a PR, create a pull request, submit a PR, or push their branch for review. Also trigger when the user mentions "stacked branches", "PR to a specific branch", or "PR summary". The skill inspects git diffs, summarizes changes clearly, waits for user confirmation, then creates the PR via the GitHub CLI.
---

# PR Creator Skill

Creates a PR from the current branch: analyzes changes, shows a summary for approval, then creates it.

## Prerequisites

- `git` must be available and the working directory must be a git repo
- `gh` (GitHub CLI) must be installed and authenticated (`gh auth status`)

---

## Step 1: Gather context

Run these commands to understand the branch situation:

```bash
# Current branch
git branch --show-current

# Default base branch (usually main or master)
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'

# If user specified a target branch, use that. Otherwise default to main/master.

# Commits on this branch vs target
git log <target_branch>..HEAD --oneline

# Files changed
git diff <target_branch>...HEAD --name-status

# Full diff for reading (limit to avoid overwhelming context)
git diff <target_branch>...HEAD --stat
git diff <target_branch>...HEAD -- . ':(exclude)*.lock' ':(exclude)package-lock.json'
```

If the user specified a target branch (e.g. "PR to `feature/auth`"), use that. Otherwise use `main` or `master` (whichever exists on origin).

---

## Step 2: Generate PR summary

Read through the diffs and commits. Then produce a summary in this format:

---
**Branch:** `<current-branch>` → `<target-branch>`

**Title:** <one-line summary, imperative mood, ~50 chars>

**Description:**
<2-5 sentences covering: what changed, why, any notable decisions or caveats>

**Changes:**
- <file or area>: <what changed>
- <file or area>: <what changed>
...
---

Keep it concise and developer-friendly. Focus on *what* and *why*, not *how*.

Then ask: **"Does this look good? Say OK to create the PR, or let me know what to change."**

---

## Step 3: Create the PR

Once the user approves (says "ok", "yes", "looks good", "create it", etc.):

```bash
gh pr create \
  --base <target_branch> \
  --title "<title>" \
  --body "<description + change list as markdown>"
```

Print the resulting PR URL to the user.

---

## Edge cases

**No commits ahead of target:** Tell the user there's nothing to PR — the branch has no new commits vs `<target>`.

**Uncommitted changes:** Note them but proceed with committed changes only. Mention the uncommitted files to the user.

**Large diffs (500+ lines):** Summarize by directory/module rather than file-by-file. Focus on high-level areas changed.

**Stacked branches:** If the user says "PR to `feature/x`" (a non-main branch), use that as the base without question. This is intentional for stacked branch workflows.

**Draft PR:** If the user says "draft PR" or "WIP PR", add `--draft` flag to the `gh pr create` command.

**Existing PR:** If `gh pr view` shows a PR already exists for this branch, tell the user and offer to update the description instead.