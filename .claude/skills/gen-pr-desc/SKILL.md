---
name: gen-pr-desc
description: Generate a PR description from commit logs and diff. Reads commits since main branch, analyzes changes, and outputs a formal PR description with summary, changes, and testing sections.
---

I'll generate a PR description based on your recent commits and changes.

Let me gather the necessary information:

1. **Fetch commit history** from the current branch since it diverged from main
2. **Analyze the git diff** to understand what changed
3. **Generate a formal PR description** with three sections:
   - **Summary**: High-level overview of the changes
   - **Changes**: Detailed list of what was modified
   - **Testing**: Notes on testing approach and areas to validate

I'll run the following commands:
- `git log main...HEAD --oneline` - to see all commits since main
- `git diff main...HEAD --stat` - to see file-level changes
- `git diff main...HEAD` - to analyze the actual changes

Then I'll synthesize this into a professional PR description and output it to stdout.