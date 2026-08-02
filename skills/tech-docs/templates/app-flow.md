---
doc_type: app-flow
status: draft
depends_on: [docs/design/prd.md]
last_updated: YYYY-MM-DD
---

# [Product / Feature Name] — App Flow & User Journeys

## Onboarding & Authentication Flow
Sign-up, login, password recovery, MFA, initial setup/tour — as a flow diagram plus notes.

```
[Landing] ──► [Sign up] ──► [Verify email] ──► [Onboarding tour] ──► [Home]
```

## Core Feature Loops
One subsection per loop.

### [Loop name]
```
[Step 1] ──► [Step 2] ──► [Step 3]
```

## Screen-by-Screen Map
| Screen | Type | Reached from | Purpose |
|---|---|---|---|
| | view / modal / slide-over | | |

## State & Edge Logic
Per screen or control: loading, empty, and error states, and what each action does.

### [Screen name]
- **Loading:** ...
- **Empty:** ...
- **Error:** ...
- **[Control] click:** ...

## Related
- [PRD](prd.md) — persona and feature scope these flows implement
