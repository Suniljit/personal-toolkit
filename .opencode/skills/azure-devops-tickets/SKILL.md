---
name: azure-devops-tickets
description: >
  Creates and retrieves Azure DevOps User Story work items via the REST API using a PAT token.
  Use this skill whenever the user wants to create, generate, push, fetch, read, or look up
  a task ticket, user story, or work item in Azure DevOps — including phrases like "log a ticket",
  "create a story in ADO", "add a work item", "get ticket #1234", "fetch that story", or
  "show me work item 99". Title is passed through verbatim. Description and Acceptance Criteria
  are provided in Markdown and converted to HTML so Azure DevOps renders them properly.
  Config (PAT, org, project) lives in config.env.
---

# Azure DevOps Ticket Skill

Two scripts sharing one config:

| Script | What it does |
|--------|-------------|
| `scripts/create_user_story.sh` | Creates a User Story with Title, Description, Acceptance Criteria |
| `scripts/get_work_item.sh` | Fetches any work item by ID and prints it as Markdown |

## Skill file layout

```
azure-devops-tickets/
├── SKILL.md                         ← you are here
├── config.env                       ← PAT + org + project (fill in, never commit)
└── scripts/
    ├── create_user_story.sh         ← POST: create a User Story
    └── get_work_item.sh             ← GET: fetch a work item by ID
```

---

## First-time setup (one time only)

1. **Fill in `config.env`:**

   ```bash
   AZURE_DEVOPS_PAT=your_pat_token_here
   AZURE_DEVOPS_ORG=your_organization_here
   AZURE_DEVOPS_PROJECT=your_project_here
   ```

   PAT needs **Work Items (Read & Write)** scope. Add `config.env` to `.gitignore`.

2. **Make scripts executable:**

   ```bash
   chmod +x scripts/create_user_story.sh scripts/get_work_item.sh
   ```

3. **Install dependencies** (`jq` and `pandoc`):

   ```bash
   # macOS
   brew install jq pandoc
   # Ubuntu/Debian
   sudo apt-get install jq pandoc
   ```

---

## Creating a User Story

### Fields

| Flag | Required | Behaviour |
|------|----------|-----------|
| `--title` | ✅ | Passed through verbatim |
| `--description` | ✅ | Markdown → converted to HTML for rendering in ADO |
| `--acceptance-criteria` | ✅ | Markdown → converted to HTML for rendering in ADO |

### How Claude should populate fields

- **Title**: use the title exactly as provided by the user
- **Description**: everything the user provides that is not the title or acceptance criteria
- **Acceptance Criteria**: only the acceptance criteria items as provided by the user

### Example

```bash
DESC=$(cat << 'MARKDOWN'
**Type:** Feature
**Priority:** Medium

## Description
Users should be able to self-serve password resets via email link.

## Notes
* Reset link expires after 30 minutes
* Link is single-use only
MARKDOWN
)

AC=$(cat << 'MARKDOWN'
- [ ] User receives reset email within 60 seconds
- [ ] Link expires after 30 minutes
- [ ] Reusing the link shows an error
MARKDOWN
)

bash scripts/create_user_story.sh \
  --title "As a user, I want to reset my password" \
  --description "$DESC" \
  --acceptance-criteria "$AC"
```

### Successful output

```
Creating User Story in project: MyProject (org: myorg)
Title: As a user, I want to reset my password

✅ User Story created successfully!
   ID  : 4821
   URL : https://dev.azure.com/myorg/MyProject/_workitems/edit/4821
```

---

## Fetching a work item

```bash
bash scripts/get_work_item.sh --id 4821
```

Fetches the work item and prints all key fields to stdout as Markdown.

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `config.env not found` | Ensure `config.env` is in the skill root alongside `SKILL.md` |
| `AZURE_DEVOPS_PAT is not set` | Replace the placeholder in `config.env` with your actual PAT |
| `pandoc: command not found` | `brew install pandoc` or `sudo apt-get install pandoc` |
| `jq: command not found` | `brew install jq` or `sudo apt-get install jq` |
| `401 Unauthorized` | PAT expired or missing Work Items scope — regenerate it |
| `404 Not Found` | Check org/project spelling in `config.env`; verify the work item ID exists |