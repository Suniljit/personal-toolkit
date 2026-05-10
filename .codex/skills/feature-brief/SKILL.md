---
name: feature-brief
description: >
  Plan a feature, feature set, or new project by generating a structured Markdown brief with
  architecture, user stories, and requirements - backlog-ready. Trigger on: "write a feature
  brief", "brief this", "plan this project", "help me plan X", or any description of scope
  larger than a single implementation task.
---

# Feature Brief Generator

Turn a conversation or feature description into a structured, backlog-ready Markdown brief.
Save the approved brief to `_features/<kebab-case-name>/feature-brief.md` in the current working directory.

## Workflow

1. Clarify only what blocks a useful brief.
   - State assumptions explicitly when the request is ambiguous but still workable.
   - Ask concise questions when missing information would materially change scope, users, architecture, or success criteria.
   - Surface meaningful tradeoffs before drafting instead of silently choosing.
2. Draft the brief in chat for user review.
   - Do not write the file before the user approves the draft.
   - Keep the draft readable in Codex: use Markdown headings, fenced ASCII diagrams, and compact tables.
   - Avoid huge uninterrupted blocks. If the brief is long, show the full draft with clear section headings rather than wrapping it in another container.
3. Ask for approval.
   - Preserve the approval gate: request explicit confirmation before saving.
   - Accept direct approvals such as "approved", "save it", "looks good", or equivalent.
   - If the user requests changes, revise the draft and ask again.
4. Save only after approval.
   - Create `_features/<kebab-case-name>/feature-brief.md`.
   - Use the same approved content unless the user asks for final edits.
5. Confirm with a Codex-friendly final response.
   - Include the saved path as a clickable Markdown file link when possible.
   - Also include the exact confirmation text: `Saved to ./_features/<name>/feature-brief.md`.
   - Briefly note any assumptions that remain embedded in the brief.

## Output Display

When displaying the draft in Codex:

- Put a short note before the draft naming the assumptions and asking for review.
- Render the draft as normal Markdown, not as one giant fenced code block.
- Fence only the architecture diagram and any literal code/config snippets.
- Keep tables narrow enough to scan; use bullets instead of wide tables when content would wrap badly.
- Do not use Claude-specific artifacts, XML tags, hidden comments, or instructions that rely on a side panel.
- Do not claim the file was saved until it has actually been written.

---

## Template

```markdown
# [Feature / Project Title]

> **Date:** YYYY-MM-DD  
> **Status:** Draft

---

## 1. Overview

One paragraph. What is this, why does it exist, what problem does it solve?

---

## 2. Goals & Non-Goals

**Goals:**
- ...

**Non-Goals:**
- ...

---

## 3. Background & Context

What led to this? Relevant constraints, prior art, dependencies, stakeholders.

---

## 4. Architecture

ASCII diagram showing key components, data flow, and where state lives.

```
[Client] ──► [API Gateway] ──► [Service A]
                                    │
                              [Service B] ──► [DB]
```

---

## 5. User Stories

| As a        | I want               | So that                 |
|-------------|----------------------|-------------------------|
| [user type] | [goal or action]     | [benefit or outcome]    |

---

## 6. Functional Requirements

- FR-1: ...

---

## 7. Non-Functional Requirements

- NFR-1: Performance: ...
- NFR-2: Security: ...
- NFR-3: Scalability: ...

---

## 8. Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| ...      | ...    | ...       |

---

## 9. Out of Scope

Things explicitly not part of this brief.

- ...

---

## 10. References

Links, docs, tickets, prior discussions.
```

---

## Guidelines

- Replace every `...` with real content - no placeholders.
- Architecture diagram is mandatory; match style to content (flow, layered boxes, tree).
- Design decisions must capture tradeoffs discussed, not just choices made.
- Out of Scope is not Future Work - it means "not in this brief", full stop.
- Use today's date.
- After saving, confirm: `"Saved to ./_features/<name>/feature-brief.md"`
