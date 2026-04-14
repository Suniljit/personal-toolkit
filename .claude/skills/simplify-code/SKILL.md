---
name: simplify-code
description: >
  Ruthlessly simplify Python code by removing over-engineering and improving readability,
  without losing any functionality. Use this skill whenever the user says things like
  "simplify my code", "remove over-engineering", "clean this up", "make this more readable",
  "this code is too complex", "refactor for simplicity", or pastes Python code and asks
  for it to be cleaned up or simplified. Also trigger when the user mentions their code
  has too many abstractions, unnecessary patterns, or is hard to follow. Do NOT use for
  performance optimizations, bug fixes, or feature additions unless explicitly paired
  with a simplification request.
---

# Python Code Simplification Skill

Simplify Python code ruthlessly. The goal: code that is **immediately easy to read** while remaining fully functional. Default to deletion. When in doubt, remove it.

---

## Core Principles

**Functionality is sacred.** Never remove, break, or subtly alter behavior. If a piece of code's purpose is genuinely unclear, ask before touching it.

**Delete first, refactor second.** The best simplification is fewer lines. Always ask: can this just be removed?

**Flat is better than nested.** (This is literally in the Zen of Python.) Collapse unnecessary layers.

**Trust good names.** A well-named function or variable needs no comment. Comments explain *why*, never *what*.

**One abstraction layer at a time.** Functions that call functions that call functions — when they each do almost nothing — is complexity cosplaying as structure. Collapse them.

---

## Python-Specific Patterns to Eliminate

| Pattern | What to do |
|---|---|
| Wrapper function that just calls another function | Inline it |
| Class used only to hold one method or bundle a few values | Replace with a function or `dataclass` / `namedtuple` |
| Single-use intermediate variable | Inline it (unless the name meaningfully aids readability) |
| Nested list comprehensions beyond 2 levels | Rewrite as a plain loop |
| `__init__` that only sets attributes | Use `@dataclass` |
| `try/except Exception` that just re-raises or logs and continues | Simplify or remove |
| `if x == True` / `if x is not None and x != []` | Use `if x` |
| Helper that's only called once | Inline it |
| Redundant `return None` at end of function | Remove |
| `pass` in `except` blocks without explanation | Add a comment or handle it |
| Constants defined once and used once | Inline the value |
| Commented-out dead code | Delete it |
| `else` after a `return` | Remove the `else`, flatten |
| Over-abstracted config/options dict passed around | Flatten to plain arguments |
| Custom exception subclasses that add nothing | Replace with built-in exceptions |
| `*args/**kwargs` forwarding with no transformation | Simplify or remove the wrapper |
| Explicit `enumerate` / `zip` misuse | Use the idiomatic Python form |

---

## When to Add Comments

Write comments for a **junior engineer** — someone who can read and write Python but isn't very experienced. They understand syntax and basic patterns, but may not immediately grasp *why* something is done a particular way, what a function is really for, or how a piece fits into the bigger picture.

**Add a comment when a junior engineer would reasonably pause and wonder:**
- What does this function actually do / when would I call it?
- Why is this value what it is?
- Why is this written this way and not the more obvious way?
- What's this condition actually guarding against?
- Why is this step necessary here?

**Skip the comment if the answer is dead obvious** — if a junior engineer would read it and think "yeah, I could see that". The bar is not "could this conceivably confuse someone", it's "would a reasonable junior actually be confused".

```python
# Skip — obvious
total = price * quantity

# Skip — the function name says it all
def get_user_by_email(email): ...

# Add — not obvious why the limit exists
MAX_RETRIES = 3  # beyond this, the upstream service marks the request as failed

# Add — junior might wonder why we're not just using .remove()
# Remove by index to avoid issues with duplicate values in the list
items.pop(index)

# Add — the early return isn't immediately obvious in intent
# Skip processing if the user hasn't verified their email yet
if not user.is_verified:
    return
```

---

## Process

### Step 1 — Analyse (do NOT write any simplified code yet)

Read the full code. Identify every over-engineering pattern present. Then write a **Proposed Changes** summary in this format:

```
## Proposed Changes

**Removals**
- <what> — <why it can go>

**Simplifications**
- <what> — <what it becomes and why>

**Comments to add**
- <where> — <what the comment will say and why it's needed>

**Judgment calls** (things that look like over-engineering but might be intentional)
- <what> — <your concern> — awaiting your decision

No functionality is lost. / The following behavior changes slightly: <describe if any>
```

Be specific. Be direct. If something is useless, say it's useless.

### Step 2 — Wait for approval

Stop after the summary. Do not produce the simplified code until the user approves (or requests changes to the plan).

If the user says "yes", "go ahead", "looks good", or similar — proceed.
If the user pushes back on specific items — revise the plan and confirm again before proceeding.

### Step 3 — Simplify

Apply all approved changes. Then show the simplified code in a Python code block, followed by a short **"What changed"** bullet list matching the approved plan.

---

## Edge Cases

- **Code is already simple:** Say so. Don't manufacture changes.
- **Ambiguous intent:** Ask before removing. Don't guess.
- **Functionality would be lost:** Do not do it. Flag it clearly and let the user decide.
- **Multi-file code:** Only touch what the user shared. Don't invent changes for unseen code.