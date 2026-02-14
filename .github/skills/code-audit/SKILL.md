---
name: code-audit
description: Technical hygiene check and comment scrub.
---
# Audit & Fix Workflow

1. **Fast-Track Tools:**
   - Run `uvx ruff check {file} --fix` and `uvx ruff format {file}` immediately.
   - Run `uvx ty check {file}` to catch type mismatches.

2. **One-Pass Slop Scrub:**
   - Scan and **delete** comments that:
     - Repeat code logic (e.g., `# loops through list`).
     - Act as changelogs (e.g., `# Updated on...`).
     - Are AI-generated fragments (e.g., `# Learns Expansion`).
   - **Preserve:** Naturally written intent comments and docstrings.

3. **Final Verification:**
   - Run a final `uvx ruff check {file}` and `uvx ty check {file}`.
   - If errors remain, fix them in one final pass. Do not loop more than twice.