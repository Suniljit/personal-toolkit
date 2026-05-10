---
name: feature-brief
description: >
  Plan a feature, feature set, or new project by generating a structured Markdown brief with
  architecture, user stories, and requirements — backlog-ready. Trigger on: "write a feature
  brief", "brief this", "plan this project", "help me plan X", or any description of scope
  larger than a single implementation task.
---

# Feature Brief Generator

Synthesize a conversation or feature description into a structured, backlog-ready Markdown brief.
Save to `_features/<kebab-case-name>/feature-brief.md` in the current working directory.

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

- Replace every `...` with real content — no placeholders.
- Architecture diagram is mandatory; match style to content (flow, layered boxes, tree).
- Design decisions must capture tradeoffs discussed, not just choices made.
- Out of Scope ≠ Future Work — it means "not in this brief", full stop.
- Use today's date.
- After saving, confirm: `"Saved to ./_features/<name>/feature-brief.md"`