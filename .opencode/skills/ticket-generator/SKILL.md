---
name: ticket-generator
description: >
  Generate structured engineering or product tickets from user inputs — feature requests, bug reports, vague ideas, user stories, or requirements. Trigger whenever the user wants to create tickets, issues, tasks, or stories, or describes a feature/bug without explicitly saying "ticket". Interviews the user to gather precise details, checks codebase for context, and outputs each ticket as a raw markdown code block ready to copy-paste.
---

# Ticket Generator Skill

Generate well-structured engineering or product tickets from any input — vague ideas, feature requests, bug reports, user stories, or full specs. Output each ticket as a **raw markdown code block** for easy copy-paste into Jira, GitHub, Linear, Notion, etc.

---

## Workflow

### Step 1 — Understand the Input

Accept anything: a single sentence, bullet list, bug description, or brain dump. Multiple inputs → multiple tickets. One input may decompose into several tickets if scope warrants it.

### Step 2 — Check the Codebase for Context

Before asking questions, scan the codebase to reduce what you need to ask.

```bash
find . -maxdepth 3 -type f \( -name "*.md" -o -name "*.json" -o -name "*.yaml" -o -name "*.toml" \) | head -30
cat README.md 2>/dev/null
cat package.json pyproject.toml Cargo.toml 2>/dev/null
find . -name "ISSUE_TEMPLATE*" 2>/dev/null | head -5
```

Use findings to infer tech stack, affected components, and context. Don't make assumptions about behaviour or requirements from the codebase alone — that's what Step 3 is for.

### Step 3 — Interview the User

Always interview before generating. The goal is to get precise details so the ticket doesn't contain guesses. Keep it conversational — ask 2–5 questions as a grouped list, not one at a time. Skip questions the codebase or input already answers clearly.

**Always ask about:**
- What's the exact desired behaviour / expected outcome?
- Who's affected, and in what context or flow does this happen?
- Is there anything this ticket should explicitly *not* do (scope boundaries)?
- Any known constraints, dependencies, or risks worth flagging?

**Ask when relevant:**
- Is this one ticket or should it be broken up?
- What does "done" feel like — is there a specific user-facing change, metric, or signal?
- Any related tickets or prior work to be aware of?

Don't ask questions you can answer from context. Don't ask about solutions or implementation — that's for the ticket reader to figure out (see Step 4).

### Step 4 — Generate the Tickets

Wrap each ticket in a ` ```markdown ``` ` code block:

````
```markdown
---

## 🎫 [Short imperative title]

**Type:** Feature | Bug | Chore | Spike  
**Component:** [Human-readable area — e.g. "Login page", "Checkout flow"]  
**Priority:** High | Medium | Low  
**Suggested branch:** `[type]/[short-kebab-case]`

### What's this about?

[2–4 sentences in plain language. Why does this matter? Write like you're explaining it over Slack, not in a spec doc.]

### Notes *(optional — omit if nothing useful)*

[Edge cases, gotchas, related tickets. Omit if nothing genuinely useful.]

### Solution *(optional — omit unless the approach is clear and obvious)*

[Only include if there's a well-known, unambiguous way to do this. Skip if the approach needs exploration or has multiple valid paths — let the reader decide.]

### Done when...

- [ ] [High-level outcome in plain English — what changed for the user or system?]
- [ ] [Another meaningful outcome, if needed]

---
```
````

**Acceptance criteria rules:**
- Keep it high-level — describe *what* should be true, not *how* to verify it
- 2–4 items max; more than that usually means the ticket is too big
- No unit test checklists, no implementation steps, no "write tests for X"
- Each item should be something a human could verify by looking at or using the product

**Solution rules:**
- Omit the Solution section unless the approach is obvious (e.g. "add a DB index", "use the existing retry utility")
- If the solution needs discovery, experimentation, or has tradeoffs — leave it out entirely
- Never prescribe architecture, libraries, or patterns unless they're already established in the codebase and clearly the right fit

**Tone rules:**
- Casual but clear — "the login page breaks" not "the auth flow fails to complete the OAuth handshake"
- Use "the user" / "someone", not "the end-user" or "the client"
- Titles: short and imperative ("Add dark mode toggle", not "Implementation of dark mode feature")

### Step 5 — Offer to Refine

After output, offer to split tickets into subtasks, adjust priority/type/component, add detail, or generate more tickets.

> "Let me know if you'd like to tweak any of these, split them up, or add more."

---

## Quality Checklist

- [ ] User was interviewed before tickets were generated
- [ ] No assumptions were made — all details came from the user or codebase
- [ ] Each ticket is in a ` ```markdown ``` ` code block
- [ ] Title is short and imperative
- [ ] No ticket number in the title
- [ ] "What's this about?" is plain language, no unnecessary jargon
- [ ] "Done when..." is high-level (2–4 items), no unit test lists
- [ ] Solution section omitted unless the approach is obvious
- [ ] Component label is human-readable
- [ ] Branch name follows `type/short-kebab-case`
- [ ] Notes omitted if nothing meaningful to say
- [ ] No single ticket is doing too many things