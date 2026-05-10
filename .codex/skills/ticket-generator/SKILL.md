---
name: ticket-generator
description: >
  Generate structured engineering or product tickets from user inputs such as feature requests, bug reports, vague ideas, user stories, or requirements. Trigger whenever the user wants to create tickets, issues, tasks, or stories, or describes a feature or bug without explicitly saying "ticket". Check the codebase for context, ask minimal clarifying questions only when needed, preserve approval gates before creating or updating anything outside chat, and output each ticket as a raw markdown code block ready to copy-paste.
---

# Ticket Generator Skill

Generate well-structured engineering or product tickets from any input: vague ideas, feature requests, bug reports, user stories, or full specs. Output each ticket as a **raw markdown code block** for easy copy-paste into Jira, GitHub, Linear, Notion, etc.

Default to drafting tickets in chat. If the user asks you to create, update, or publish tickets in an external system, show the drafted ticket content first and get explicit approval before using any integration or CLI that mutates state.

---

## Workflow

### Step 1 - Understand the Input

Accept anything: a single sentence, bullet list, bug description, or brain dump. Multiple inputs can become multiple tickets. One input may decompose into several tickets if scope warrants it.

State assumptions briefly before generating tickets when they affect scope, priority, or component. If multiple reasonable interpretations exist, call them out and either ask a clarifying question or choose the safest narrow interpretation.

### Step 2 - Check the Codebase for Context

Before asking questions, scan the codebase to reduce what you need to ask. Prefer fast, low-noise commands and inspect only enough to infer the stack, components, and existing ticket conventions.

```bash
rg --files -g '*.md' -g '*.json' -g '*.yaml' -g '*.yml' -g '*.toml' -g '!*node_modules*' -g '!*.venv*'
sed -n '1,220p' README.md
sed -n '1,220p' package.json
sed -n '1,220p' pyproject.toml
sed -n '1,220p' Cargo.toml
rg --files -g 'ISSUE_TEMPLATE*' -g '.github/ISSUE_TEMPLATE/**'
```

If a file does not exist, ignore that miss and keep going. Use findings to infer tech stack, affected components, naming conventions, and acceptance criteria where obvious. Do not perform broad code archaeology unless the ticket would otherwise be vague or wrong.

### Step 3 - Ask Clarifying Questions Only If Needed

Ask only if the input is too vague to produce a useful ticket. Ask at most 1-3 questions. Do not ask what the codebase already answers.

Ask when:
- Scope is ambiguous (one ticket or several?)
- Affected component is unclear
- Desired behavior is unspecified
- Priority or release urgency materially changes the ticket

If the ticket can be useful with explicit assumptions, proceed and include those assumptions in the ticket body or Notes.

### Step 4 - Generate the Tickets

Wrap each ticket in its own fenced `markdown` code block. This is important for Codex display: the user should see a clean, copy-pasteable raw ticket rather than rendered checkboxes, headings, or horizontal rules.

In normal chat output, use this exact outer fence shape:

````
```markdown
---

## Ticket [N]: [Short imperative title]

**Type:** Feature | Bug | Chore | Spike  
**Component:** [Human-readable area, e.g. "Login page", "Checkout flow"]  
**Priority:** High | Medium | Low  
**Suggested branch:** `[type]/[short-kebab-case]`

### What's this about?

[2-4 sentences in plain language. Explain why this matters as if writing a clear Slack message, not a formal spec.]

### Notes *(optional; omit if nothing useful)*

[Edge cases, gotchas, related tickets.]

### Done when...

- [ ] [Specific, testable outcome in plain English]
- [ ] [Another concrete outcome]

---
```
````

When showing multiple tickets, put a short plain sentence before the first block, then emit each ticket as a separate `markdown` fence with no nested fences inside the ticket body. After each closing fence, leave one blank line before the next ticket.

Do not use raw HTML, tables, Mermaid, callouts, blockquotes, or nested code fences inside the ticket. If a ticket needs a command or payload, summarize it in prose or use inline code so the outer copy-paste block remains intact.

**Tone rules:**
- Casual but clear: "the login page breaks" not "the auth flow fails to complete the OAuth handshake"
- Use "the user" / "someone", not "the end-user" or "the client"
- Titles: short and imperative ("Add dark mode toggle", not "Implementation of dark mode feature")
- Omit Notes if there's nothing genuinely useful to add
- Avoid decorative symbols in headings so Codex, GitHub, Jira, Linear, and Notion display the copied ticket consistently

### Step 5 - Offer to Refine

After output, offer to split tickets into subtasks, adjust priority/type/component, add detail, or generate more tickets.

Keep the follow-up outside the ticket code block:

```text
Let me know if you'd like to tweak any of these, split them up, or add more.
```

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
- [ ] Any assumptions are explicit
- [ ] Approval is requested before creating or updating external tickets
- [ ] Output contains no nested fences, tables, raw HTML, or rendered-only formatting inside the ticket block
