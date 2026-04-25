---
name: azure-devops-tickets
description: >
  Creates and retrieves Azure DevOps User Story work items via the REST API using a PAT token.
  Use this skill whenever the user wants to create, generate, push, fetch, read, or look up
  a task ticket, user story, or work item in Azure DevOps — including phrases like "log a ticket",
  "create a story in ADO", "add a work item", "get ticket #1234", "fetch that story", or
  "show me work item 99". All ticket content (title, description, acceptance criteria, tags)
  is passed through exactly as provided by the user — Claude must not reword, reformat, or
  otherwise modify any field values. Config (PAT, org, project) lives in config.env.
---

# Azure DevOps Ticket Skill

Two scripts sharing one config:

| Script | What it does |
|--------|-------------|
| `scripts/create_user_story.sh` | Creates a User Story — passes all fields through verbatim |
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

3. **Install `jq`** (only dependency):

   ```bash
   # macOS
   brew install jq
   # Ubuntu/Debian
   sudo apt-get install jq
   ```

---

## Creating a User Story

### CRITICAL: Pass content through exactly as given

Claude must pass the user's title, description, acceptance criteria, and tag **verbatim** to the script — no rewording, no reformatting, no converting. Whatever the user provides is what goes into Azure DevOps.

```bash
./scripts/create_user_story.sh \
  --title "As a user, I want to reset my password" \
  --description "Users should be able to self-serve password resets via email link." \
  --acceptance-criteria "- Given the user clicks Forgot password, when they enter their email, then they receive a reset link within 60 seconds" \
  --tag "auth"
```

### Flags

| Flag | Required | Notes |
|------|----------|-------|
| `--title` | ✅ | Passed through as-is |
| `--description` | ✅ | Passed through as-is |
| `--acceptance-criteria` | ✅ | Passed through as-is |
| `--tag` | ✅ | Passed through as-is; semicolon-separated for multiple: `"auth; sprint-3"` |

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
./scripts/get_work_item.sh --id 4821
```

Fetches the work item and prints all key fields to stdout.

### Successful output

```
# [#4821] As a user, I want to reset my password

| Field        | Value          |
|--------------|----------------|
| **Type**     | User Story     |
| **State**    | Active         |
| ...          | ...            |

## Description
...

## Acceptance Criteria
...
```

---

## How Claude should use this skill

**To create:** take the user's fields exactly as given and pass them straight to `create_user_story.sh`. Do not paraphrase, clean up, reformat, or improve the content in any way.

**To fetch:** run `get_work_item.sh --id <N>` and present the output to the user.

### Passing multi-line content in bash_tool

Use a heredoc to safely pass multi-line values without shell interpretation:

```bash
DESC=$(cat << 'MARKDOWN'
Users need CSV export from the reports screen.

- Max 10,000 rows
- Comma-delimited format
MARKDOWN
)

AC=$(cat << 'MARKDOWN'
- Export button visible on all report pages
- File downloads as .csv with correct headers
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
| `jq: command not found` | `brew install jq` or `sudo apt-get install jq` |
| `401 Unauthorized` | PAT expired or missing Work Items scope — regenerate it |
| `404 Not Found` | Check org/project spelling in `config.env`; verify the work item ID exists |