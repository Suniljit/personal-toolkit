#!/usr/bin/env bash
# get_work_item.sh
# Fetches an Azure DevOps work item by ID and prints its fields as Markdown.
# Config is loaded from config.env in the skill root directory.
#
# Usage:
#   ./scripts/get_work_item.sh --id 4821
#
# Output: Markdown-formatted summary of the work item, printed to stdout.
# HTML fields (Description, Acceptance Criteria) are converted to Markdown via pandoc.

set -euo pipefail

# ── Resolve config.env relative to this script's directory ──────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config.env"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: config.env not found at $CONFIG_FILE"
  echo "Open config.env and fill in your credentials."
  exit 1
fi

# shellcheck source=/dev/null
source "$CONFIG_FILE"

# ── Validate config values ───────────────────────────────────────────────────
for var in AZURE_DEVOPS_PAT AZURE_DEVOPS_ORG AZURE_DEVOPS_PROJECT; do
  if [[ -z "${!var:-}" || "${!var}" == *"your_"* ]]; then
    echo "ERROR: $var is not set or still contains placeholder value in config.env"
    exit 1
  fi
done

# ── Check required tools ─────────────────────────────────────────────────────
for tool in jq pandoc; do
  if ! command -v "$tool" &>/dev/null; then
    echo "ERROR: '$tool' is required but not installed."
    case "$tool" in
      jq)     echo "  macOS: brew install jq      | Linux: sudo apt-get install jq" ;;
      pandoc) echo "  macOS: brew install pandoc  | Linux: sudo apt-get install pandoc" ;;
    esac
    exit 1
  fi
done

# ── Parse arguments ──────────────────────────────────────────────────────────
WORK_ITEM_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --id) WORK_ITEM_ID="$2"; shift 2 ;;
    *)
      echo "Unknown argument: $1"
      echo "Usage: $0 --id <work_item_id>"
      exit 1
      ;;
  esac
done

if [[ -z "$WORK_ITEM_ID" ]]; then
  echo "ERROR: --id is required"
  echo "Usage: $0 --id <work_item_id>"
  exit 1
fi

if ! [[ "$WORK_ITEM_ID" =~ ^[0-9]+$ ]]; then
  echo "ERROR: --id must be a numeric work item ID (e.g. 4821)"
  exit 1
fi

# ── Build the API URL ────────────────────────────────────────────────────────
# Request specific fields to keep the response focused.
ENCODED_PROJECT="${AZURE_DEVOPS_PROJECT// /%20}"
FIELDS="System.Id,System.Title,System.WorkItemType,System.State,System.AssignedTo,System.CreatedBy,System.CreatedDate,System.ChangedDate,System.Tags,System.Description,Microsoft.VSTS.Common.AcceptanceCriteria,System.IterationPath,System.AreaPath"
API_URL="https://dev.azure.com/${AZURE_DEVOPS_ORG}/${ENCODED_PROJECT}/_apis/wit/workitems/${WORK_ITEM_ID}?fields=${FIELDS}&api-version=7.1"

# ── Build the Basic Auth header ──────────────────────────────────────────────
AUTH_HEADER=$(printf '%s' ":${AZURE_DEVOPS_PAT}" | base64)

# ── Make the API call ────────────────────────────────────────────────────────
RESPONSE=$(curl --silent --show-error \
  --request GET \
  --url "$API_URL" \
  --header "Authorization: Basic $AUTH_HEADER" \
  --header "Accept: application/json")

# ── Check for errors ─────────────────────────────────────────────────────────
if ! echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
  echo "❌ Failed to fetch work item #${WORK_ITEM_ID}."
  echo "Response:"
  echo "$RESPONSE" | jq . 2>/dev/null || echo "$RESPONSE"
  exit 1
fi

# ── Extract fields ───────────────────────────────────────────────────────────
html_to_md() {
  # Convert HTML to Markdown; fall back to raw value if pandoc fails or input is empty
  local input="$1"
  if [[ -z "$input" || "$input" == "null" ]]; then
    echo "_not set_"
    return
  fi
  printf '%s' "$input" | pandoc --from=html --to=markdown --no-highlight 2>/dev/null || printf '%s' "$input"
}

get_field() {
  echo "$RESPONSE" | jq -r ".fields[\"$1\"] // \"null\""
}

ID=$(echo "$RESPONSE" | jq -r '.id')
ITEM_URL=$(echo "$RESPONSE" | jq -r '._links.html.href // empty' 2>/dev/null || \
  echo "https://dev.azure.com/${AZURE_DEVOPS_ORG}/${ENCODED_PROJECT}/_workitems/edit/${ID}")

TITLE=$(get_field "System.Title")
TYPE=$(get_field "System.WorkItemType")
STATE=$(get_field "System.State")
ITERATION=$(get_field "System.IterationPath")
AREA=$(get_field "System.AreaPath")
TAGS=$(get_field "System.Tags")
CREATED_DATE=$(get_field "System.CreatedDate")
CHANGED_DATE=$(get_field "System.ChangedDate")

# AssignedTo and CreatedBy are objects — extract displayName
ASSIGNED_TO=$(echo "$RESPONSE" | jq -r '.fields["System.AssignedTo"].displayName // "Unassigned"')
CREATED_BY=$(echo "$RESPONSE" | jq -r '.fields["System.CreatedBy"].displayName // "Unknown"')

DESC_HTML=$(get_field "System.Description")
AC_HTML=$(get_field "Microsoft.VSTS.Common.AcceptanceCriteria")

DESC_MD=$(html_to_md "$DESC_HTML")
AC_MD=$(html_to_md "$AC_HTML")

# ── Print as Markdown ─────────────────────────────────────────────────────────
cat << MARKDOWN
# [#${ID}] ${TITLE}

| Field | Value |
|-------|-------|
| **Type** | ${TYPE} |
| **State** | ${STATE} |
| **Assigned To** | ${ASSIGNED_TO} |
| **Created By** | ${CREATED_BY} |
| **Created** | ${CREATED_DATE} |
| **Last Updated** | ${CHANGED_DATE} |
| **Iteration** | ${ITERATION} |
| **Area** | ${AREA} |
| **Tags** | ${TAGS} |
| **URL** | ${ITEM_URL} |

## Description

${DESC_MD}

## Acceptance Criteria

${AC_MD}
MARKDOWN