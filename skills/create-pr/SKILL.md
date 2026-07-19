---
name: create-pr
description: >
  Creates GitHub Pull Requests via the GitHub CLI. Trigger when the user wants to open/create/submit a PR, push a branch for review, or mentions "stacked branches", "PR to a specific branch", or "PR summary". Analyzes git diffs, shows a summary for approval, pushes the branch, then creates the PR.
---

# PR Creator Skill

## Branch resolution

**Source branch** = always the current checked-out branch (`git branch --show-current`). Never ask — just detect it.

**Target/base branch** = where the PR will merge into:
- If the user specified a branch in their message (e.g. "PR to feature/x", "PR into develop") → use that branch
- Otherwise → default to `main`

Do not ask the user to clarify which branch to use. Detect the current branch automatically and apply the rule above.

---

## Step 1: Gather context

```bash
# Detect source (current) branch
git branch --show-current

# Determine target branch from user message, or default to main
# (use the resolved target branch in all commands below)

git log <target>..HEAD --oneline
git diff <target>...HEAD --name-status
git diff <target>...HEAD -- . ':(exclude)*.lock' ':(exclude)package-lock.json'
```

---

## Step 2: Generate PR summary

Show this and ask: **"Does this look good? Say OK to create the PR, or tell me what to change."**

Focus on **what changed and why** from the actual code diff — not metadata like commit messages, file/line counts, or commit-by-commit breakdowns.

```
**Branch:** `<current>` → `<target>`
**Title:** <imperative, ~50 chars>
**Description:** <2–5 sentences: what changed, why, notable decisions>
**Changes:**
- <file/area>: <what changed, functionally>
```

---

## Step 3: Push the branch

On user approval ("ok", "yes", "looks good", "create it"):

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null
# If upstream exists: git push
# If not: git push -u origin <current-branch>
```

Stop and report if push fails — never force-push.

---

## Step 4: Create the PR

```bash
gh pr create --base <target> --title "<title>" --body "<description + changes>"
```

Print the PR URL.

---

## Edge cases

| Situation | Action |
|---|---|
| No commits ahead of target | Tell user, stop |
| Uncommitted changes | Note them, proceed with committed only |
| Large diff (500+ lines) | Summarize by directory/module, functionally |
| Stacked branch (`PR to feature/x`) | Use specified branch as base |
| Draft PR | Add `--draft` to `gh pr create` |
| PR already exists | Tell user, offer to update description |
| Push rejected | Show error, ask how to proceed |