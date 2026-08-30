---
name: create-pr
description: >
  Creates GitHub Pull Requests via the GitHub CLI. 
disable-model-invocation: true
metadata:
  opencode/autoinvoke: "false"
argument-hint: "Specify a target branch, else defaults to 'main'."
---

# PR Creator Skill

## Specs (optional)

The user may hand you a spec, ticket, or plan doc alongside the PR request. This never replaces the diff — it's read once and folded in as extra context when writing the Step 2 summary (why a change was made, what decision it implements). No spec provided → proceed on the diff alone.

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

## Step 2: Compose the PR content

From the diff (and spec, if provided), write:
- Title: imperative, ~50 chars
- Body: 2–5 sentences on what changed, why, and notable decisions, then a "Changes" list of `<file/area>: <what changed, functionally>`. Markdown is fine — GitHub renders it.

Focus on what changed and why from the actual code diff — not metadata like commit messages, file/line counts, or commit-by-commit breakdowns. If a spec was provided, use it to explain the why behind changes the diff shows; the diff still governs what's listed under Changes.

Proceed straight to Step 3 — do not wait for approval.

---

## Step 3: Push the branch

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