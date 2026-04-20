---
name: ticket-generator
description: >
  Generate structured engineering or product tickets from one or more user inputs (feature requests, bug reports, vague ideas, user stories, or requirements). Use this skill whenever the user wants to create tickets, issues, tasks, or work items — even if they say "write a ticket", "make a Jira story", "create a GitHub issue", "draft a task", "break this into tickets", or describes a feature/bug without explicitly saying "ticket". The skill checks the codebase for context, asks clarifying questions when needed, and outputs each ticket in clean Markdown with a title and description. Always trigger this skill when ticket, issue, task, or story creation is implied.
---

# Ticket Generator Skill

Generate well-structured engineering or product tickets from user inputs. Handles vague ideas, feature requests, bug reports, user stories, and full requirement specs — and produces clean Markdown tickets with a **Title** and **Description** for each.

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

Output each ticket as a Markdown block. Use this structure:

```markdown
---

## 🎫 Ticket [N]: [Short, imperative title]

**Type:** Feature | Bug | Chore | Spike  
**Component:** [Affected module, service, or area — inferred from codebase if possible]  
**Priority:** High | Medium | Low  

### Description

[2–4 sentences. What needs to be done, why it matters, and any relevant context. Write for a developer picking this up cold.]

### Notes *(optional)*

[Edge cases, dependencies, open questions, links to related code or tickets.]

### Acceptance Criteria

- [ ] [Concrete, testable condition 1]
- [ ] [Concrete, testable condition 2]
- [ ] [Concrete, testable condition 3]

---
```

**Formatting rules:**
- Title: imperative verb phrase ("Add dark mode toggle", not "Dark mode")
- Description: clear and self-contained — no assumed context
- Acceptance criteria: specific and testable, not vague ("Users can toggle dark mode via Settings > Appearance", not "Dark mode works")
- Notes: include only if there's something genuinely useful to flag
- Omit empty sections (e.g. skip Notes if there's nothing to say)

---

### Step 5 — Offer to Refine

After outputting all tickets, offer to:
- Split a ticket into subtasks
- Add more detail to any section
- Adjust type, priority, or component
- Generate additional tickets from follow-up inputs

Example closing line:
> "Let me know if you'd like to adjust any of these, split them further, or add more inputs."

---

## Examples

### Input: "add dark mode"

→ Ask: "Is this frontend-only, or does the preference need to be stored per user?"  
→ Generate: 1–2 tickets (UI toggle + optional API/storage ticket)

### Input: "fix the login bug where users get logged out randomly"

→ Check codebase for auth module, session handling  
→ Generate: 1 bug ticket with reproduction steps as acceptance criteria

### Input: "we need search, filters, and pagination on the products page"

→ Generate: 3 tickets (one per feature), each scoped to the products page component found in codebase

### Input: "improve performance"

→ Ask: "Which part of the app? Any specific metrics or complaints?" before generating

---

## Quality Checklist

Before outputting tickets, verify:
- [ ] Title is an imperative verb phrase
- [ ] Description is self-contained (readable without prior context)
- [ ] Acceptance criteria are concrete and testable
- [ ] Component/area is accurate (cross-checked with codebase if available)
- [ ] Notes section omitted if nothing meaningful to add
- [ ] No ticket is trying to do too many things at once