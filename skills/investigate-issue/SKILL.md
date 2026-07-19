---
name: investigate-issue
description: Investigates a bug or issue and explains it simply - what's wrong, why it's an issue, and what fix would help. Use when the user is debugging, hits an error, or asks "why is this happening?" or "what's wrong with this?"
---

When investigating an issue, always include:

1. **Start with an analogy**: Compare the bug's behavior to something from everyday life, so the failure mode feels intuitive before diving into code.

2. **Draw a diagram**: Use ASCII art to show what's happening - the flow of data/control, where it goes wrong, and what the correct flow should look like.

3. **What is the issue**: Explain in plain language what's actually happening, pointing to the specific file(s) and line(s) involved.

4. **Why it is an issue**: Explain the cause-and-effect chain - what triggers it, what breaks downstream, and what impact it has (crash, wrong output, silent data loss, etc).

5. **What fix would help**: Propose the fix and explain *why* it works - don't just show the diff, explain how it addresses the root cause from step 4.

6. **Highlight a gotcha**: Any edge case, related risk, or common mistake to watch for when applying the fix.

Keep explanations conversational and avoid unexplained jargon. For complex issues, use multiple analogies. Investigate using available tools (reading code, logs, error messages, git history) before explaining - don't guess.
