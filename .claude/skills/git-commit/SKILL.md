---
name: git-commit
description: Create git commits on behalf of the user. Use this skill whenever the user wants to commit files, stage changes, write a commit message, or do anything involving `git add` + `git commit`. Trigger when the user says things like "commit these files", "make a commit", "git commit my changes", "stage and commit", or provides file paths and asks to commit them. Also trigger when the user says "save my changes to git" or "create a commit for me". Always use this skill — don't try to handle git commits from scratch without it.
---
 
# Git Commit Skill
 
Helps the user stage files, generate a meaningful commit message from a diff, confirm it with the user, then commit.
 
## Workflow
 
### Step 1: Locate the repository
 
Identify the git repo root from the file paths the user provided:
 
```bash
git -C <dir-containing-files> rev-parse --show-toplevel
```
 
If files span multiple repos, handle each repo separately.
 
### Step 2: Inspect the changes
 
For each file the user mentioned, get the diff relative to the repo's HEAD (or the index if already staged):
 
```bash
# Unstaged changes
git -C <repo-root> diff -- <file>
 
# New untracked files — show full content
git -C <repo-root> diff --no-index /dev/null <file>
 
# Already staged changes
git -C <repo-root> diff --cached -- <file>
```
 
Also check the current status so you understand the full picture:
 
```bash
git -C <repo-root> status --short
```
 
### Step 3: Generate a commit message
 
Read the diffs carefully and write a commit message following the Conventional Commits format:
 
```
<type>(<optional scope>): <short summary>
 
<optional body — explain WHY, not WHAT, if non-obvious>
```
 
**Types**: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`, `perf`, `ci`, `build`
 
Rules:
- Subject line ≤ 72 characters, imperative mood ("add", not "added" or "adds")
- Be specific — avoid vague messages like "update files" or "fix stuff"
- If multiple logical changes are present, note them in the body or suggest splitting into separate commits
- Do NOT mention file names in the subject unless they are the whole point (e.g., `docs: update README`)
 
### Step 4: Confirm with the user
 
Present the proposed commit message clearly and ask for approval **before touching git**:
 
```
I'll commit the following files:
  • src/auth.py
  • tests/test_auth.py
 
With this commit message:
──────────────────────────────────────
feat(auth): add JWT refresh token support
 
Introduces token rotation on refresh to reduce exposure window.
Adds corresponding unit tests for expiry and rotation edge cases.
──────────────────────────────────────
 
Shall I go ahead, or would you like to change the message?
```
 
Wait for the user to explicitly confirm (e.g. "yes", "go ahead", "looks good") or request changes.
If the user suggests edits, update the message and confirm once more before committing.
 
### Step 5: Stage and commit
 
Once confirmed:
 
```bash
# Stage only the files the user specified
git -C <repo-root> add -- <file1> <file2> ...
 
# Commit with the agreed message
git -C <repo-root> commit -m "<subject>" -m "<body>"
```
 
Then show the user the result:
 
```bash
git -C <repo-root> log --oneline -1
```
 
## Edge cases
 
| Situation | How to handle |
|---|---|
| File has no changes vs HEAD | Tell the user — don't silently skip it |
| File is untracked (new file) | Still stage and commit it; note it's a new file in the message |
| User provides a relative path | Resolve it relative to the working directory |
| Binary file (image, pdf, etc.) | Note it's a binary; write message based on filename/context |
| Repo is in detached HEAD state | Warn the user before committing |
| Nothing to commit after staging | Tell the user nothing changed |
| User wants to amend last commit | Use `git commit --amend` — still confirm the new message first |
 
## Important constraints
 
- **Never commit without explicit user confirmation of the message.**
- **Only stage the files the user specified** — do not `git add .` or add unrelated files.
- Do not push. Committing locally only unless the user explicitly asks to push.
- Do not modify `.gitignore` or any other file as part of this workflow.