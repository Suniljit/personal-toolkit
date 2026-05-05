---
name: ticket-generator
description: >
  Generate structured engineering or product tickets from one or more user inputs (feature requests, bug reports, vague ideas, user stories, or requirements). Use this skill whenever the user wants to create tickets, issues, tasks, or work items — even if they say "write a ticket", "make a Jira story", "create a GitHub issue", "draft a task", "break this into tickets", or describes a feature/bug without explicitly saying "ticket". The skill checks the codebase for context, asks clarifying questions when needed, and outputs each ticket as a raw markdown code block ready to copy-paste. Always trigger this skill when ticket, issue, task, or story creation is implied.
---

# Ticket Generator Skill

Generate well-structured engineering or product tickets from user inputs. Handles vague ideas, feature requests, bug reports, user stories, and full requirement specs — and outputs each ticket as a **raw markdown code block** so you can copy-paste it and it renders properly wherever you paste it.

Tickets use plain, friendly language — clear enough for anyone on the team to understand, not just engineers.

---

## Workflow

### Step 1 — Understand the Input(s)

The user may give you:
- A single sentence ("add dark mode")
- A bullet list of features
- A bug description
- A user story
- A rough idea or brain dump

Accept all of these. Multiple inputs → multiple tickets. One input may also decompose into several tickets if the scope warrants it.

---

### Step 2 — Check the Codebase for Context

Before asking the user anything, **scan the codebase** (if available) to gather context that shapes the tickets. This reduces the number of questions you need to ask.

```bash
# Look for project structure
find . -maxdepth 3 -type f \( -name "*.md" -o -name "*.json" -o -name "*.yaml" -o -name "*.toml" \) | head -30

# Check README for project overview
cat README.md 2>/dev/null || cat readme.md 2>/dev/null

# Identify tech stack
cat package.json 2>/dev/null
cat pyproject.toml 2>/dev/null
cat Cargo.toml 2>/dev/null

# Look for existing ticket/issue templates
find . -name "ISSUE_TEMPLATE*" -o -name ".github" -type d 2>/dev/null | head -10
```

Use what you find to:
- Infer the tech stack and affected components
- Identify relevant existing files, modules, or services
- Pre-fill acceptance criteria where obvious
- Avoid asking questions already answered by the code

---

### Step 3 — Ask Clarifying Questions (When Needed)

Only ask if the input is too vague to generate a useful ticket. Keep it to **1–3 focused questions**. Do not ask for information you can infer from the codebase.

Good reasons to ask:
- The scope is ambiguous (one ticket vs. many?)
- The affected system/component is unclear and not in the codebase
- The desired behaviour is not specified
- Priority or ticket type matters for their workflow

Example clarifications:
- "Is this a frontend-only change, or does it touch the API too?"
- "Should this block authentication entirely, or just show a warning?"
- "Are you thinking one ticket per endpoint, or one ticket for the whole flow?"

---

### Step 4 — Generate the Tickets

Output each ticket as a **raw markdown code block** (wrapped in triple backticks with `markdown` syntax hint). This way the user can copy-paste the contents and it will render as formatted markdown in Jira, GitHub, Notion, Linear, etc.

Use this structure inside the code block:

````
```markdown
---

## 🎫 Ticket [N]: [Short, imperative title]

**Type:** Feature | Bug | Chore | Spike  
**Component:** [Affected area — e.g. "Login page", "User settings", "Checkout flow"]  
**Priority:** High | Medium | Low  
**Suggested branch:** `[type]/[short-kebab-case-description]`

### What's this about?

[2–4 sentences written in plain language. Explain what needs to happen and why it matters — like you're describing it to a teammate over Slack, not writing a spec doc. Avoid jargon where possible.]

### Notes *(optional)*

[Anything worth flagging — edge cases, things to watch out for, related tickets. Skip this section if there's nothing useful to say.]

### Done when...

- [ ] [Specific, testable thing that must be true — written in plain English]
- [ ] [Another concrete outcome]
- [ ] [And another]

---
```
````

**Tone and language rules:**
- Write like a human, not a robot. Casual but clear.
- Avoid overly technical phrasing unless it's genuinely necessary (e.g. "the login page breaks" instead of "authentication flow fails to complete the OAuth handshake")
- Use "you", "the user", "someone" — not "the end-user" or "the client"
- "Done when..." replaces "Acceptance Criteria" — it's friendlier and just as clear
- "What's this about?" replaces "Description" — more conversational
- Keep titles short and action-oriented ("Add dark mode toggle", not "Implementation of dark mode feature")
- Notes section: only include if there's something genuinely useful to flag — skip it otherwise

---

### Step 5 — Offer to Refine

After outputting all tickets, offer to:
- Split a ticket into subtasks
- Add more detail to any section
- Adjust type, priority, or component
- Generate additional tickets from follow-up inputs

Example closing line:
> "Let me know if you'd like to tweak any of these, split them up further, or add more."

---

## Examples

### Input: "add dark mode"

→ Ask: "Is this frontend-only, or does the preference need to be stored per user?"  
→ Generate: 1–2 tickets (UI toggle + optional storage ticket)

### Input: "fix the login bug where users get logged out randomly"

→ Check codebase for auth/session handling  
→ Generate: 1 bug ticket written in plain language, with "done when..." conditions framed around what the user actually experiences

### Input: "we need search, filters, and pagination on the products page"

→ Generate: 3 tickets (one per feature), scoped to the products page, written conversationally

### Input: "improve performance"

→ Ask: "Which part of the app feels slow? Any specific pages or actions?" before generating

---

## Quality Checklist

Before outputting tickets, verify:
- [ ] Each ticket is wrapped in a ` ```markdown ``` ` code block so it can be copy-pasted
- [ ] Title is short and action-oriented (imperative verb phrase)
- [ ] "What's this about?" is written in plain, friendly language — no unnecessary jargon
- [ ] "Done when..." items are concrete and testable, written in plain English
- [ ] Component/area label is human-readable (e.g. "Checkout page", not "checkout_service_v2")
- [ ] Suggested branch follows `type/short-kebab-case` convention
- [ ] Notes section is omitted if there's nothing meaningful to add
- [ ] No single ticket is trying to do too many things at once