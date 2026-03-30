---
name: gen-pr-desc
description: Generate a PR description from commit logs and diff. Reads commits since main branch, analyzes changes, and outputs a formal PR description with summary, changes, and testing sections.
---

I'll generate a concise PR description based on your recent commits and changes.

Let me gather the necessary information and produce a formal PR description with:
- **Summary**: Brief, high-level overview of the changes (1-2 sentences)
- **Changes**: Concise list of modified components/files (bullet points, no detail)
- **Testing**: Key areas to validate (bullet points only, no lengthy explanations)

I'll run:
- `git log main...HEAD --oneline` - to see all commits
- `git diff main...HEAD --stat` - to see file-level changes
- `git diff main...HEAD` - to understand what changed

Then output a tight, professional PR description to stdout.