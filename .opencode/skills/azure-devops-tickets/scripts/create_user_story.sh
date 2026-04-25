#!/usr/bin/env bash
# create_user_story.sh
# Creates an Azure DevOps User Story via REST API using a PAT token.
# Config is loaded from config.env in the skill root directory.
#
# Description and Acceptance Criteria are written in Markdown and
# automatically converted to HTML before sending to Azure DevOps.
#
# Usage:
#   ./scripts/create_user_story.sh \
#     --title "Your story title" \
#     --description "Story description in **Markdown**" \
#     --acceptance-criteria "- [ ] Criterion one\n- [ ] Criterion two" \
#     --tag "your-tag"
#
# All four flags are required.

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
TITLE=""
DESCRIPTION=""
ACCEPTANCE_CRITERIA=""
TAG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)               TITLE="$2";               shift 2 ;;
    --description)         DESCRIPTION="$2";         shift 2 ;;
    --acceptance-criteria) ACCEPTANCE_CRITERIA="$2"; shift 2 ;;
    --tag)                 TAG="$2";                 shift 2 ;;
    *)
      echo "Unknown argument: $1"
      echo "Usage: $0 --title '...' --description '...' --acceptance-criteria '...' --tag '...'"
      exit 1
      ;;
  esac
done

# ── Validate required arguments ──────────────────────────────────────────────
for arg_name in TITLE DESCRIPTION ACCEPTANCE_CRITERIA TAG; do
  if [[ -z "${!arg_name}" ]]; then
    echo "ERROR: --$(echo "${arg_name}" | tr '[:upper:]_' '[:lower:]-') is required"
    echo "Usage: $0 --title '...' --description '...' --acceptance-criteria '...' --tag '...'"
    exit 1
  fi
done

# ── Convert Markdown → HTML (pandoc, no wrapping document) ──────────────────
md_to_html() {
  printf '%s' "$1" | pandoc --from=markdown --to=html --no-highlight 2>/dev/null
}

DESCRIPTION_HTML=$(md_to_html "$DESCRIPTION")
AC_HTML=$(md_to_html "$ACCEPTANCE_CRITERIA")

# ── Build the API URL ────────────────────────────────────────────────────────
# URL-encode the project name (replace spaces with %20)
ENCODED_PROJECT="${AZURE_DEVOPS_PROJECT// /%20}"
API_URL="https://dev.azure.com/${AZURE_DEVOPS_ORG}/${ENCODED_PROJECT}/_apis/wit/workitems/\$User%20Story?api-version=7.1"

# ── Build the Basic Auth header ──────────────────────────────────────────────
# Azure DevOps PAT auth: empty username, PAT as password, Base64-encoded
AUTH_HEADER=$(printf '%s' ":${AZURE_DEVOPS_PAT}" | base64)

# ── Build the JSON patch document ────────────────────────────────────────────
# Tags use semicolons as separator for multiple tags.
PAYLOAD=$(jq -n \
  --arg title "$TITLE" \
  --arg desc  "$DESCRIPTION_HTML" \
  --arg ac    "$AC_HTML" \
  --arg tag   "$TAG" \
  '[
    {"op": "add", "path": "/fields/System.Title",                             "value": $title},
    {"op": "add", "path": "/fields/System.Description",                       "value": $desc},
    {"op": "add", "path": "/fields/Microsoft.VSTS.Common.AcceptanceCriteria", "value": $ac},
    {"op": "add", "path": "/fields/System.Tags",                              "value": $tag}
  ]')

# ── Make the API call ────────────────────────────────────────────────────────
echo "Creating User Story in project: ${AZURE_DEVOPS_PROJECT} (org: ${AZURE_DEVOPS_ORG})"
echo "Title: $TITLE"
echo ""

RESPONSE=$(curl --silent --show-error \
  --request POST \
  --url "$API_URL" \
  --header "Authorization: Basic $AUTH_HEADER" \
  --header "Content-Type: application/json-patch+json" \
  --header "Accept: application/json" \
  --data "$PAYLOAD")

# ── Parse and display the result ─────────────────────────────────────────────
if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
  WORK_ITEM_ID=$(echo "$RESPONSE" | jq -r '.id')
  WORK_ITEM_URL=$(echo "$RESPONSE" | jq -r '._links.html.href')
  echo "✅ User Story created successfully!"
  echo "   ID  : $WORK_ITEM_ID"
  echo "   URL : $WORK_ITEM_URL"
else
  echo "❌ Failed to create User Story."
  echo "Response:"
  echo "$RESPONSE" | jq . 2>/dev/null || echo "$RESPONSE"
  exit 1
fi