# Tech Docs — App Flow flow

Read [`common/CONVENTIONS.md`](common/CONVENTIONS.md) first for the `docs/blueprint/` layout and shared conventions.

Write the App Flow & User Journeys document to `docs/blueprint/app-flow.md`.

---

## Step 1 — Read the PRD

Read `docs/blueprint/prd.md`. If it doesn't exist, stop and say so — this doc maps flows for the persona and feature scope the PRD defines; run `/tech-docs prd` first.

---

## Step 2 — Grill the user

Run a `/grilling` session, with `/domain-modeling` alongside it (see Grilling in CONVENTIONS.md), covering:

- **Onboarding & authentication flow** — sign-up, login, password recovery, MFA, initial setup/tour
- **Core feature loops** — the primary workflows step by step, one loop per must-have feature from the PRD (e.g. browse → checkout → confirmation)
- **Screen-by-screen map** — every view, modal, slide-over, and contextual action reachable from the loops above
- **State & edge logic** — what each interactive control does, loading states, empty states, error states

**Considerations** — ground recommendations in these rather than guessing:
- **Onboarding:** check whether social auth, guest/anonymous mode, or invite-only signup fits the persona from the PRD — don't default to email/password if the persona suggests otherwise.
- **Core loops:** note each loop's frequency (daily habit vs. one-time setup) — high-frequency loops deserve shortcuts (quick actions, keyboard shortcuts) that low-frequency ones don't need.
- **Screen map:** cross-check against commonly-missed screens — settings/profile, notifications center, help/support, search results, empty-account first-run — before declaring the map complete.
- **Edge logic:** cover first-use empty states, error recovery (retry vs. dead-end), and concurrent-edit conflicts, not just the loading/empty/error triad per screen.

Lead each question with your recommended answer. Walk the PRD's must-haves one at a time rather than asking about the whole app at once.

When the map feels complete, confirm:
> *"I think we have the flows mapped. Saving to `docs/blueprint/app-flow.md` — ready?"*

---

## Step 3 — Generate the doc

```markdown
---
doc_type: app-flow
status: draft
depends_on: [docs/blueprint/prd.md]
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
```

Apply the overflow rule from CONVENTIONS.md once there are more than ~8 screens or loops carrying real state/edge detail — split each into `docs/blueprint/app-flow/<flow-slug>.md`, keep the summary table and diagrams in `app-flow.md`.

---

## Step 4 — Save

Save to `docs/blueprint/app-flow.md`. Add or update its row in the root `INDEX.md`'s **Blueprint** table per CONVENTIONS.md.

## Completion criterion

`docs/blueprint/app-flow.md` exists with every section filled (no placeholders) and `INDEX.md` has a current row for it.

Confirm:
> *"Saved to `docs/blueprint/app-flow.md`."*
