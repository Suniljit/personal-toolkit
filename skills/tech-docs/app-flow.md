# Tech Docs — App Flow flow

Read [`common/CONVENTIONS.md`](common/CONVENTIONS.md) first for the `docs/design/` layout and shared conventions.

Write the App Flow & User Journeys document to `docs/design/app-flow.md`.

---

## Step 1 — Read the PRD

Read `docs/design/prd.md`. If it doesn't exist, stop and say so — this doc maps flows for the persona and feature scope the PRD defines; run `/tech-docs prd` first.

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
> *"I think we have the flows mapped. Saving to `docs/design/app-flow.md` — ready?"*

---

## Step 3 — Generate the doc

Read [`templates/app-flow.md`](templates/app-flow.md) and fill in every section — it's a floor, not a ceiling (see Beyond the template in CONVENTIONS.md).

Apply the overflow rule from CONVENTIONS.md once there are more than ~8 screens or loops carrying real state/edge detail — split each into `docs/design/app-flow/<flow-slug>.md`, keep the summary table and diagrams in `app-flow.md`.

---

## Step 4 — Save

Save to `docs/design/app-flow.md`. Add or update its row in the root `INDEX.md`'s **Design** table per CONVENTIONS.md.

## Completion criterion

`docs/design/app-flow.md` exists with every section filled (no placeholders) and `INDEX.md` has a current row for it.

Confirm:
> *"Saved to `docs/design/app-flow.md`."*
