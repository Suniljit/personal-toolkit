---
doc_type: app-flow
status: draft
depends_on: [docs/design/prd.md]
related:
  - path: prd.md
    why: persona and feature scope these flows implement
last_updated: YYYY-MM-DD
---

# [Product / Feature Name] — App Flow & User Journeys

## Onboarding & Authentication Flow
Sign-up, login, password recovery, MFA, initial setup/tour — as a flow diagram plus notes.

```mermaid
flowchart LR
  Landing --> SignUp[Sign up] --> Verify[Verify email] --> Tour[Onboarding tour] --> Home
```

## Core Feature Loops
One subsection per loop.

### [Loop name]
**Implements:** `US-01`

```mermaid
flowchart LR
  A[Step 1] --> B[Step 2] --> C[Step 3]
```

## Screen-by-Screen Map
| Screen | Route | Type | Reached from | Implements | Purpose |
|---|---|---|---|---|---|
| | `/path` | view / modal / slide-over | | `US-01` | |

## State & Edge Logic
Per screen or control: loading, empty, and error states, and what each action does.

### [Screen name]
- **Loading:** ...
- **Empty:** ...
- **Error:** ...
- **[Control] click:** ...
