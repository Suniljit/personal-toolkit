---
name: azure-devops-tickets
description: >
  Creates and retrieves Azure DevOps User Story work items via the REST API using a PAT token.
  Use this skill whenever the user wants to create, generate, push, fetch, read, or look up
  a task ticket, user story, or work item in Azure DevOps — including phrases like "log a ticket",
  "create a story in ADO", "add a work item", "get ticket #1234", "fetch that story", "show me
  work item 99", or "what does ticket X say". Description and Acceptance Criteria are written in
  Markdown (auto-converted to HTML on create; HTML auto-converted back to Markdown on fetch).
  Config (PAT, org, project) lives in a separate config.env file so secrets are never hardcoded.
---

# Azure DevOps Ticket Skill

Two scripts sharing one config:

| Script | What it does |
|--------|-------------|
| `scripts/create_user_story.sh` | Creates a User Story with Title, Description, Acceptance Criteria, Tags |
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

Write `--description` and `--acceptance-criteria` in **Markdown** — converted to HTML automatically.

```bash
./scripts/create_user_story.sh \
  --title "As a user, I want to reset my password" \
  --description "## Overview

Users should be able to self-serve password resets via email link.

- Reset link expires after **30 minutes**
- Link is single-use only" \
  --acceptance-criteria "- [ ] User receives reset email within 60 seconds
- [ ] Link expires after 30 minutes
- [ ] Reusing the link shows an error" \
  --tag "auth"
```

### Create flags

| Flag | Required | Notes |
|------|----------|-------|
| `--title` | ✅ | Plain text |
| `--description` | ✅ | Markdown → converted to HTML |
| `--acceptance-criteria` | ✅ | Markdown → converted to HTML |
| `--tag` | ✅ | Semicolon-separated for multiple: `"auth; sprint-3"` |

### Successful create output

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
./scripts/get_work_item.sh --id 4821
```

Returns a Markdown-formatted summary with all key fields. HTML in Description and Acceptance Criteria is **converted back to Markdown** automatically.

### Example output

```markdown
# [#4821] As a user, I want to reset my password

| Field | Value |
|-------|-------|
| **Type** | User Story |
| **State** | Active |
| **Assigned To** | Jane Smith |
| **Created By** | John Doe |
| **Created** | 2025-04-25T10:30:00Z |
| **Last Updated** | 2025-04-25T11:00:00Z |
| **Iteration** | MyProject\Sprint 5 |
| **Area** | MyProject\Backend |
| **Tags** | auth |
| **URL** | https://dev.azure.com/... |

## Description

## Overview

Users should be able to self-serve password resets via email link.

- Reset link expires after **30 minutes**
- Link is single-use only

## Acceptance Criteria

- [ ] User receives reset email within 60 seconds
- [ ] Link expires after 30 minutes
- [ ] Reusing the link shows an error
```

---

## How Claude should use this skill

**To create a ticket:** collect title, description, acceptance criteria, and tag from the user, then run `create_user_story.sh`. Write description and AC in Markdown — do not pre-convert to HTML.

**To fetch a ticket:** run `get_work_item.sh --id <N>`. The Markdown output can be read directly, summarised, or used as context for follow-up tasks (e.g. updating the ticket, writing tests, reviewing AC).

### Multi-line content in bash_tool

Use a heredoc to safely pass multi-line Markdown:

```bash
DESC=$(cat << 'MARKDOWN'
## Overview
Users need **CSV export** from the reports screen.

- Max 10,000 rows
MARKDOWN
)

AC=$(cat << 'MARKDOWN'
- [ ] Export button visible on all report pages
- [ ] File downloads as `.csv` with correct headers
MARKDOWN
)

bash scripts/create_user_story.sh \
  --title "Export reports to CSV" \
  --description "$DESC" \
  --acceptance-criteria "$AC" \
  --tag "reports; export"
```

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