---
name: grill-to-doc
description: "After a grill-me session ends, generate a structured Markdown document containing a PRD, design summary, and implementation plan — then save it to the repo. This is the second step in the grill-me/grill-to-doc workflow: all questions should already be resolved. Trigger whenever the user says 'generate the doc', 'write up the PRD', 'document this', 'save the plan', 'grill to doc', or after a grill-me session concludes and the user wants a written artifact."
---

# Grill-Me Document Generator

After a thorough design interview (e.g. a `grill-me` session), synthesize everything discussed into a single Markdown file saved to the repository. The file serves three purposes in one: PRD, design summary, and implementation plan.

## Step 1: Confirm the save location

Check if a repo/project directory is already known from context (e.g. the user mentioned a path or the codebase was explored during the grilling). If not, ask:

> "Where should I save this document? (e.g. `./docs/` or the project root)"

If the user says "here" or doesn't specify, default to `./docs/` and create it if needed.

## Step 2: Derive the git slug

From the feature/plan title discussed, generate a recommended git branch name:
- lowercase, hyphen-separated
- prefix with `feat/`, `fix/`, `chore/`, or `spike/` as appropriate
- max ~50 chars
- Example: `feat/user-auth-oauth-google-integration`

Include this slug prominently at the top of the document and also mention it to the user in chat after saving.

## Step 3: Generate the document

Synthesize the full conversation into the following Markdown structure. Be specific — use the actual decisions reached during the grilling, not placeholders.

```markdown
# [Feature/Plan Title]

> **Branch:** `feat/your-slug-here`  
> **Date:** YYYY-MM-DD  
> **Status:** Draft

---

## 1. Overview

One paragraph. What is this? Why does it exist? What problem does it solve?

---

## 2. Goals & Non-Goals

**Goals:**
- ...

**Non-Goals:**
- ...

---

## 3. Background & Context

What led to this? Relevant constraints, prior art, dependencies.

---

## 4. Design Summary

Key design decisions made, and the reasoning behind each. For each decision, note if there were meaningful alternatives considered.

| Decision | Choice Made | Rationale |
|---|---|---|
| ... | ... | ... |

---

## 5. Product Requirements (PRD)

### User Stories / Use Cases
- As a [user], I want [goal] so that [benefit].

### Functional Requirements
- FR-1: ...
- FR-2: ...

### Non-Functional Requirements
- NFR-1: Performance: ...
- NFR-2: Security: ...
- NFR-3: Scalability: ...

---

## 6. Technical Design

### Architecture Overview
Describe the high-level architecture. Include components, data flow, and interfaces.

### Data Model
Key entities and their relationships (can be prose or a simple schema).

### API / Interface Changes
Any new or modified endpoints, events, or contracts.

### Edge Cases & Error Handling
Known edge cases and how they're handled.

---

## 7. Implementation Plan

Break the work into phases or milestones. For each, list the key tasks.

### Phase 1: [Name]
- [ ] Task 1
- [ ] Task 2

### Phase 2: [Name]
- [ ] Task 1
- [ ] Task 2

### Out of Scope (Future Work)
- ...

---

## 8. References

Links, docs, tickets, or prior discussions referenced.
```

## Step 4: Save the file

Choose a filename derived from the slug: e.g. `feat-user-auth-oauth.md` (strip the prefix slash, replace `/` with `-`).

Save to the confirmed path. Confirm to the user:

> "Saved to `./docs/feat-user-auth-oauth.md`. Recommended branch name: `feat/user-auth-oauth-google-integration`."

## Guidelines

- **Be concrete.** Replace every `...` with real content from the discussion. No placeholder text in the final doc.
- **Decisions first.** If the grilling resolved a tricky tradeoff, make sure it appears in the Design Summary table.
- **Implementation plan depth.** Match depth to what was discussed. If only high-level phases were covered, keep the plan high-level. Don't invent tasks that weren't discussed.
- **Date.** Use today's actual date (available from context or system).