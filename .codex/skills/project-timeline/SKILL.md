---
name: project-timeline
description: Generate or update an ASCII sprint-grid project timeline in a Markdown file. Use this skill when the user wants to visualize a project schedule, roadmap, or sprint plan in Markdown — especially as a feature/week grid with status indicators (planned, in progress, done). Also use when the user asks to UPDATE the timeline: changing current week, marking a feature as done/in progress, or updating milestone status. Triggers on: "draw my timeline", "project timeline", "update timeline", "mark X as done", "set current week to N", "ASCII Gantt", or any request involving weekly goals + status tracking in a .md file.
---

# Project Timeline Skill

Generates (or updates) a Markdown file with:
1. A sprint-grid overview: features as rows, weeks as columns, block characters showing status
2. A `↑↑ CURRENT WEEK` indicator under the active column
3. A milestone ASCII timeline + status table

---

## Input Format

User provides:
- Weekly goals/features (not per-task, but high-level features/components)
- Week date ranges
- Milestones with dates
- Optionally: current week number, and per-feature status per week

---

## Output Structure

### 1. Header

```markdown
# Project Timeline

> **Current Week: N** — to update, tell Claude: *"set current week to 2"* or *"mark Auth Module as done"*
```

### 2. Sprint Grid (inside a fenced code block)

Rows = individual tasks, exactly as the user wrote them — never group, rename, or consolidate tasks. Columns = weeks (W1, W2, ...).

**IMPORTANT — do not use unicode block characters** (`░▒█` etc.). These are double-width in many monospace fonts and break column alignment. Use plain ASCII cell markers instead:

- `[ ]` — planned
- `[~]` — in progress
- `[x]` — done
- `   ` (3 spaces) — task not active that week

**Week-group separators:** insert a dotted line (`. . . . .` spanning full width) between each week's task group.

**Current week indicator:** place a `v` on the line immediately **above** the header row, at the column index of the active week label. Compute with Python: `header.index("W1")` gives the exact column.

```
                                        v
Task                                    W1   W2   W3   W4
----------------------------------------------------------
Build auth login flow                   [~]
Set up user database                    [~]
. . . . . . . . . . . . . . . . . . . . . . . . . . . . .
Implement API endpoints                      [ ]
Write API documentation                      [ ]
. . . . . . . . . . . . . . . . . . . . . . . . . . . . .
Build frontend components                         [ ]
Connect frontend to API                           [ ]
. . . . . . . . . . . . . . . . . . . . . . . . . . . . .
End-to-end testing                                     [ ]
Deployment & release                                   [ ]
----------------------------------------------------------

W1  1-5 Jan   W2  8-12 Jan   W3  15-19 Jan   W4  22-26 Jan
```

**Alignment rules:**
- Task label column: 40 chars wide, left-aligned
- Each week column: 5 chars wide (`W1` + space + `[ ]` cell)
- Separator lines: `-` (plain hyphens) at top and bottom only
- Dotted separators: `. . .` between each week's task group
- Date legend goes below the separator, outside the grid lines

### 3. Milestones Section

**ASCII timeline:**
```
 Jan 5      Jan 12      Jan 19      Jan 26   Feb 2     Feb 3 ─── Feb 17
   │           │           │           │        │         │           │
───●───────────●───────────●───────────●────────●─────────[═══════════]
   │           │           │           │        │         │           │
 Auth       API Live    Frontend    Dev Ends   Demo      UAT
 Done                   Done                  to Client  (2 weeks)
```

Use `●` for point milestones, `[════]` for duration blocks (like UAT).

**Milestone table:**

| Date | Milestone | Status |
|------|-----------|--------|
| 5 Jan | Auth Module Complete | 🔄 In Progress |
| 12 Jan | API Live | ⬜ Planned |

Status emoji:
- `⬜ Planned` — not started
- `🔄 In Progress` — active
- `✅ Done` — completed

---

## Updating the Timeline

When the user asks to update (e.g. "mark X as done", "set week to 3", "X is now in progress"):

1. Read the existing `/mnt/user-data/outputs/project_timeline.md`
2. Apply the change:
   - **Current week**: move `↑↑ CURRENT WEEK` to new column; update header number
   - **Feature status**: swap block characters for that feature in the relevant week column(s)
   - **Milestone status**: update emoji in the table
3. Write the full updated file back and re-present it

---

## Implementation Notes

- **Always build the grid using a Python script** (via `bash_tool`), not by writing it manually. Hand-written grids have consistent column drift errors. Use `f"{task:<40}{w1:<4} {w2:<4} ..."` style f-strings to guarantee alignment.
- Each task goes in exactly one week column — the week it was assigned to. Do not place a task in an earlier week just because it appears near the top of the output.
- When creating from scratch and statuses aren't specified: default W1 tasks to `[~]` (in progress), all others to `[ ]` (planned).
- The legend (`[ ] planned  [~] in progress  [x] done`) must appear in a separate code block directly above the grid, so it's always visible.
- All ASCII art goes inside fenced ` ``` ` blocks for guaranteed monospace rendering.
- Always write the output to a `.md` file (default filename: `project_timeline.md`) and call `present_files`. In Claude's sandbox, the output directory is `/mnt/user-data/outputs/`.