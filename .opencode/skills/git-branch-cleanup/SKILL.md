---
name: git-branch-cleanup
description: >
  Switches from the current Git branch to main, pulls latest changes with rebase,
  then deletes the original branch. Use this skill whenever the user says things like
  "clean up my branch", "merge done, delete my branch", "switch to main and delete
  this branch", "done with this branch", "cleanup after PR merged", or any variant of
  wanting to return to main and remove a feature/working branch. Also trigger when the
  user invokes this as a custom command (e.g. "/git-cleanup-branch", "run cleanup branch").
---

# Git Cleanup Branch

Safely return to `main` and delete the branch you came from — stopping immediately on any error.

## Steps

Execute each step only after the previous one succeeds. Stop and report the error if any command fails.

### 1. Capture current branch

```bash
git rev-parse --abbrev-ref HEAD
```

- Save this as `ORIGINAL_BRANCH`.
- If the result is `HEAD` (detached HEAD state), stop and tell the user they are in a detached HEAD state — the skill cannot proceed.
- If the result is already `main`, stop and tell the user they are already on `main` — nothing to do.

### 2. Switch to main

```bash
git checkout main
```

- If this fails (e.g. uncommitted changes, branch does not exist), stop and report the exact error message.
- Common cause: uncommitted or staged changes. Tell the user to stash or commit them first.

### 3. Pull with rebase

```bash
git pull --rebase
```

- If this fails (e.g. rebase conflict, no upstream configured), stop and report the exact error.
- Do NOT attempt to resolve conflicts automatically.

### 4. Delete the original branch

```bash
git branch -d <ORIGINAL_BRANCH>
```

- Use `-d` (safe delete) — it refuses to delete if the branch has unmerged commits.
- If `-d` fails because of unmerged commits, **do not retry with `-D`**. Stop and tell the user the branch has unmerged commits and ask them to confirm before force-deleting.
- Only use `-D` if the user explicitly asks to force-delete after seeing the warning.

## Output

After all steps succeed, confirm with a short summary:

```
✓ Was on:     <ORIGINAL_BRANCH>
✓ Now on:     main (rebased)
✓ Deleted:    <ORIGINAL_BRANCH>
```

If anything fails, show:
```
✗ Failed at step <N>: <command>
  Error: <exact error output>
  Stopped. No further changes were made.
```