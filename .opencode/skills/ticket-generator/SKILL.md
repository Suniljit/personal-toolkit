---
name: ticket-generator
description: >
  Generate structured engineering or product tickets from user inputs — feature requests, bug reports, vague ideas, user stories, or requirements. Trigger whenever the user wants to create tickets, issues, tasks, or stories, or describes a feature/bug without explicitly saying "ticket". Checks codebase for context, asks minimal clarifying questions, and outputs each ticket as a raw markdown code block ready to copy-paste.
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

Use findings to infer tech stack, affected components, and pre-fill acceptance criteria where obvious.

### Step 3 — Ask Clarifying Questions (Only If Needed)

Ask only if the input is too vague to produce a useful ticket. Max 1–3 questions. Don't ask what the codebase already answers.

Ask when:
- Scope is ambiguous (one ticket or several?)
- Affected component is unclear
- Desired behaviour is unspecified

### Step 4 — Generate the Tickets

Wrap each ticket in a ` ```markdown ``` ` code block:

````
```markdown
---

## 🎫 Ticket [N]: [Short imperative title]

**Type:** Feature | Bug | Chore | Spike  
**Component:** [Human-readable area — e.g. "Login page", "Checkout flow"]  
**Priority:** High | Medium | Low  
**Suggested branch:** `[type]/[short-kebab-case]`

### What's this about?

[2–4 sentences in plain language. Why does this matter? Write like you're explaining it over Slack, not in a spec doc.]

### Notes *(optional — omit if nothing useful)*

[Edge cases, gotchas, related tickets.]

### Done when...

- [ ] [Specific, testable outcome in plain English]
- [ ] [Another concrete outcome]

---
```
````

**Tone rules:**
- Casual but clear — "the login page breaks" not "the auth flow fails to complete the OAuth handshake"
- Use "the user" / "someone", not "the end-user" or "the client"
- Titles: short and imperative ("Add dark mode toggle", not "Implementation of dark mode feature")
- Omit Notes if there's nothing genuinely useful to add

### Step 5 — Offer to Refine

After output, offer to split tickets into subtasks, adjust priority/type/component, add detail, or generate more tickets.

> "Let me know if you'd like to tweak any of these, split them up, or add more."

---

## Quality Checklist

- [ ] Each ticket is in a ` ```markdown ``` ` code block
- [ ] Title is short and imperative
- [ ] "What's this about?" is plain language, no unnecessary jargon
- [ ] "Done when..." items are concrete and testable
- [ ] Component label is human-readable
- [ ] Branch name follows `type/short-kebab-case`
- [ ] Notes omitted if nothing meaningful to say
- [ ] No single ticket is doing too many things