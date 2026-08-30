---
name: rebase-main
description: Rebase the current branch onto a target branch (default origin/main) and force-push with lease. Use when the user wants to rebase onto main, sync a branch with upstream, or clean up history before opening a PR.
disable-model-invocation: true
metadata:
  opencode/autoinvoke: "false"
argument-hint: "Provide a target branch (default: origin/main)."
---

Target branch: the one named in the request, otherwise `origin/main`.

1. Run `git status`. If there is uncommitted work, stop and tell the user — do not stash or discard anything automatically.
2. Run `git fetch origin` to update remote refs.
3. Run `git rebase <target-branch>`.
4. If the rebase reports conflicts, invoke the `resolving-merge-conflicts` skill to resolve them — do not resolve them yourself. Once resolved, run `git rebase --continue` and repeat until the rebase completes cleanly.
5. Once the rebase is clean, confirm with the user before force-pushing: show the branch, the target it was rebased onto, and the number of commits that will be rewritten. Wait for explicit approval.
6. Run `git push --force-with-lease` to update the remote branch.
7. Report the final state: branch name, target it was rebased onto, and confirmation the push succeeded.
