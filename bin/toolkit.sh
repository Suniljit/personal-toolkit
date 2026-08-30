#!/usr/bin/env bash
set -eo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
STATE_DIR="${PERSONAL_TOOLKIT_STATE_DIR:-$HOME/.personal-toolkit}"
MANIFEST="$STATE_DIR/installs.json"
BACKUP_ROOT="$STATE_DIR/backups"

AGENTS=(claude opencode codex)

SCOPE=""
SCOPE_SOURCE=""
SELECTED_AGENTS=()
SELECTED_SKILLS=()
ASSUME_YES=0
BASE_DIR=""

INSTALLED=()
ALREADY=()
BACKED_UP=()
REMOVED=()

BOLD=""; DIM=""; RESET=""; GREEN=""; CYAN=""; YELLOW=""; RED=""

init_colors() {
  if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    BOLD="$(tput bold || true)"; DIM="$(tput dim || true)"; RESET="$(tput sgr0 || true)"
    GREEN="$(tput setaf 2 || true)"; CYAN="$(tput setaf 6 || true)"
    YELLOW="$(tput setaf 3 || true)"; RED="$(tput setaf 1 || true)"
  fi
}

die() { printf '%sError:%s %s\n' "$RED" "$RESET" "$1" >&2; exit 1; }

contains() {
  local needle="$1"; shift
  local item
  for item in "$@"; do [[ "$item" == "$needle" ]] && return 0; done
  return 1
}

print_banner() {
  printf '\n%spersonal-toolkit%s\n' "$BOLD$CYAN" "$RESET"
  printf '%sSync AGENTS.md, guidelines, and skills into your AI coding agents.%s\n\n' "$DIM" "$RESET"
}

usage() {
  cat <<'EOF'
Usage: bin/toolkit.sh <command> [options]

Commands:
  install     Guided install of skills/ (--global also installs AGENTS.md/CLAUDE.md and guidelines/)
  update      git pull + re-run install for every previously-installed target

Options:
  --global               Install into $HOME (AGENTS.md/CLAUDE.md, guidelines/, skills/)
  --project               Install into the current directory (skills/ only)
  --agent NAME            Select an agent host (claude, opencode, codex); repeatable
  --skill NAME             Select one skill; repeatable (default: all)
  -y                        Confirm without prompting
  --help                    Show this help
EOF
}

validate_agent() { contains "$1" "${AGENTS[@]}"; }

parse_args() {
  COMMAND="${1:-}"
  [[ "$COMMAND" == "--help" || "$COMMAND" == "-h" ]] && { usage; exit 0; }
  [[ "$COMMAND" == "install" || "$COMMAND" == "update" ]] || { usage; exit 1; }
  shift || true
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --global) SCOPE="global"; SCOPE_SOURCE="--global" ;;
      --project) SCOPE="project"; SCOPE_SOURCE="--project" ;;
      --agent)
        [[ $# -ge 2 ]] || die "--agent requires a name"
        validate_agent "$2" || die "unknown agent: $2 (expected: ${AGENTS[*]})"
        SELECTED_AGENTS+=("$2"); shift ;;
      --skill)
        [[ $# -ge 2 ]] || die "--skill requires a name"
        SELECTED_SKILLS+=("$2"); shift ;;
      -y) ASSUME_YES=1 ;;
      --help|-h) usage; exit 0 ;;
      *) die "unknown option: $1" ;;
    esac
    shift
  done
}

discover_skills() {
  local scope="$1"
  local file name
  DISCOVERED_SKILLS=()
  while IFS= read -r file; do
    name="${file#"$REPO_DIR"/skills/"$scope"/}"
    name="${name%/SKILL.md}"
    DISCOVERED_SKILLS+=("$name")
  done < <(find "$REPO_DIR/skills/$scope" -mindepth 2 -maxdepth 2 -name SKILL.md -type f | sort)
  [[ ${#DISCOVERED_SKILLS[@]} -gt 0 ]] || die "no skills found in $REPO_DIR/skills/$scope"
}

read_key() {
  local key byte seq
  IFS= read -rsn1 key || return 1
  if [[ "$key" == $'\033' ]]; then
    seq="$key"
    local i
    for ((i = 0; i < 5; i++)); do
      IFS= read -rsn1 -t 1 byte || break
      seq="$seq$byte"
      [[ "$byte" =~ [A-Za-z~] ]] && break
    done
    case "$seq" in
      $'\033[A'|$'\033[B'|$'\033[C'|$'\033[D') key="$seq" ;;
      *) key="" ;;
    esac
  fi
  printf '%s' "$key"
}

tui_clear() {
  if command -v tput >/dev/null 2>&1; then tput clear || true; else printf '\033[2J\033[H'; fi
}

tui_select_one() {
  local output_var="$1" title="$2" help="$3"
  shift 3
  local options=("$@")
  local cursor=0 key i marker pointer

  while true; do
    tui_clear
    print_banner
    printf '%s%s%s\n' "$BOLD" "$title" "$RESET"
    [[ -n "$help" ]] && printf '%s%s%s\n\n' "$DIM" "$help" "$RESET"
    for ((i = 0; i < ${#options[@]}; i++)); do
      if [[ "$i" -eq "$cursor" ]]; then
        pointer="${CYAN}>${RESET}"; marker="${GREEN}●${RESET}"
        printf '%s %s %s%s%s\n' "$pointer" "$marker" "$BOLD" "${options[$i]}" "$RESET"
      else
        printf '    ○ %s\n' "${options[$i]}"
      fi
    done
    printf '\n%sUse arrow keys, Enter to select.%s\n' "$DIM" "$RESET"
    key="$(read_key)"
    case "$key" in
      $'\033[A') cursor=$((cursor - 1)) ;;
      $'\033[B') cursor=$((cursor + 1)) ;;
      ''|$'\n'|$'\r') eval "$output_var=\"\${options[$cursor]}\""; return 0 ;;
    esac
    [[ "$cursor" -lt 0 ]] && cursor=$((${#options[@]} - 1))
    [[ "$cursor" -ge "${#options[@]}" ]] && cursor=0
  done
}

tui_multiselect() {
  local output_var="$1" title="$2" help="$3"
  shift 3
  local options=("$@")
  local selected=() cursor=0 key i box pointer

  for ((i = 0; i < ${#options[@]}; i++)); do selected[$i]=1; done

  while true; do
    tui_clear
    print_banner
    printf '%s%s%s\n' "$BOLD" "$title" "$RESET"
    [[ -n "$help" ]] && printf '%s%s%s\n\n' "$DIM" "$help" "$RESET"
    for ((i = 0; i < ${#options[@]}; i++)); do
      if [[ "${selected[$i]}" -eq 1 ]]; then box="${GREEN}[x]${RESET}"; else box="[ ]"; fi
      if [[ "$i" -eq "$cursor" ]]; then
        pointer="${CYAN}>${RESET}"
        printf '%s %s %s%s%s\n' "$pointer" "$box" "$BOLD" "${options[$i]}" "$RESET"
      else
        printf '  %s %s\n' "$box" "${options[$i]}"
      fi
    done
    printf '\n%sUse arrow keys, Space to toggle, Enter to continue.%s\n' "$DIM" "$RESET"
    key="$(read_key)"
    case "$key" in
      $'\033[A') cursor=$((cursor - 1)) ;;
      $'\033[B') cursor=$((cursor + 1)) ;;
      ' ') selected[$cursor]=$((1 - selected[$cursor])) ;;
      ''|$'\n'|$'\r') break ;;
    esac
    [[ "$cursor" -lt 0 ]] && cursor=$((${#options[@]} - 1))
    [[ "$cursor" -ge "${#options[@]}" ]] && cursor=0
  done

  local out=()
  for ((i = 0; i < ${#options[@]}; i++)); do
    [[ "${selected[$i]}" -eq 1 ]] && out+=("${options[$i]}")
  done
  eval "$output_var=(\"\${out[@]}\")"
}

prompt_scope() {
  [[ -n "$SCOPE" ]] && return 0
  if [[ -t 0 ]]; then
    local choice
    tui_select_one choice "Installation scope" "Where should AGENTS.md/CLAUDE.md, guidelines, and skills be installed?" \
      "Global - $HOME" "Project - $PWD"
    case "$choice" in
      Global*) SCOPE="global" ;;
      Project*) SCOPE="project" ;;
    esac
  else
    die "no TTY and no --global/--project given"
  fi
}

prompt_agents() {
  [[ ${#SELECTED_AGENTS[@]} -gt 0 ]] && return 0
  if [[ -t 0 ]]; then
    tui_multiselect SELECTED_AGENTS "Choose agent hosts" "Tick every AI coding tool that should get the toolkit." "${AGENTS[@]}"
  else
    SELECTED_AGENTS=("${AGENTS[@]}")
  fi
  [[ ${#SELECTED_AGENTS[@]} -gt 0 ]] || die "select at least one agent host"
}

agent_base_dir() {
  case "$1" in
    claude) printf '%s/.claude\n' "$BASE_DIR" ;;
    opencode) printf '%s/.opencode\n' "$BASE_DIR" ;;
    codex) printf '%s/.codex\n' "$BASE_DIR" ;;
  esac
}

agent_agents_file() {
  case "$1" in
    claude) printf '%s/CLAUDE.md\n' "$(agent_base_dir "$1")" ;;
    opencode|codex) printf '%s/AGENTS.md\n' "$(agent_base_dir "$1")" ;;
  esac
}

same_symlink_target() {
  local path="$1" expected="$2"
  [[ -L "$path" ]] || return 1
  [[ "$(readlink "$path")" == "$expected" ]]
}

backup_and_link() {
  local source="$1" target="$2"
  local parent; parent="$(dirname "$target")"

  if same_symlink_target "$target" "$source"; then
    ALREADY+=("$target")
    return 0
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    local rel backup_dest
    rel="${target#"$HOME"/}"
    [[ "$rel" == "$target" ]] && rel="${target#/}"
    backup_dest="$BACKUP_TS_DIR/$rel"
    mkdir -p "$(dirname "$backup_dest")"
    mv "$target" "$backup_dest"
    BACKED_UP+=("$target -> $backup_dest")
  fi

  mkdir -p "$parent"
  ln -s "$source" "$target"
  INSTALLED+=("$target")
}

do_install_for_agent() {
  local agent="$1"
  local base; base="$(agent_base_dir "$agent")"

  if [[ "$SCOPE" == "global" ]]; then
    local agents_file; agents_file="$(agent_agents_file "$agent")"
    backup_and_link "$REPO_DIR/AGENTS.md" "$agents_file"
    backup_and_link "$REPO_DIR/guidelines" "$base/guidelines"
    case "$agent" in
      claude)   backup_and_link "$REPO_DIR/agents/claude" "$base/agents" ;;
      opencode) backup_and_link "$REPO_DIR/agents/opencode" "$base/agent" ;;
    esac
  fi

  local skill
  local skills=("${SELECTED_SKILLS[@]}")
  [[ ${#skills[@]} -eq 0 ]] && skills=("${DISCOVERED_SKILLS[@]}")
  for skill in "${skills[@]}"; do
    contains "$skill" "${DISCOVERED_SKILLS[@]}" || die "unknown skill: $skill"
    backup_and_link "$REPO_DIR/skills/$SCOPE/$skill" "$base/skills/$skill"
  done
}

prune_stale_skills() {
  local agent="$1"
  local base; base="$(agent_base_dir "$agent")"
  local skills_dir="$base/skills"
  [[ -d "$skills_dir" ]] || return 0

  local entry name target rel backup_dest
  while IFS= read -r entry; do
    name="$(basename "$entry")"
    target="$(readlink "$entry")"
    [[ "$target" == "$REPO_DIR/skills/$SCOPE/"* ]] || continue
    contains "$name" "${DISCOVERED_SKILLS[@]}" && continue

    rel="${entry#"$HOME"/}"
    [[ "$rel" == "$entry" ]] && rel="${entry#/}"
    backup_dest="$BACKUP_TS_DIR/$rel"
    mkdir -p "$(dirname "$backup_dest")"
    mv "$entry" "$backup_dest"
    REMOVED+=("$entry -> $backup_dest")
  done < <(find "$skills_dir" -mindepth 1 -maxdepth 1 -type l 2>/dev/null)
}

print_summary() {
  printf '\n%sSummary%s\n' "$BOLD$CYAN" "$RESET"
  printf '\n%sInstalled/updated (%d)%s\n' "$BOLD" "${#INSTALLED[@]}" "$RESET"
  local item
  for item in "${INSTALLED[@]:-}"; do [[ -n "$item" ]] && printf '  - %s\n' "$item"; done
  printf '\n%sAlready correct (%d)%s\n' "$BOLD" "${#ALREADY[@]}" "$RESET"
  for item in "${ALREADY[@]:-}"; do [[ -n "$item" ]] && printf '  - %s\n' "$item"; done
  if [[ ${#BACKED_UP[@]} -gt 0 ]]; then
    printf '\n%sBacked up (%d)%s\n' "$YELLOW" "${#BACKED_UP[@]}" "$RESET"
    for item in "${BACKED_UP[@]}"; do printf '  - %s\n' "$item"; done
  fi
  if [[ ${#REMOVED[@]} -gt 0 ]]; then
    printf '\n%sRemoved (stale) (%d)%s\n' "$YELLOW" "${#REMOVED[@]}" "$RESET"
    for item in "${REMOVED[@]}"; do printf '  - %s\n' "$item"; done
  fi
}

confirm_plan() {
  [[ "$ASSUME_YES" -eq 1 ]] && return 0
  printf '\nScope: %s (%s)\n' "$SCOPE" "$BASE_DIR"
  printf 'Agents: %s\n' "${SELECTED_AGENTS[*]}"
  printf '\nProceed? [y/N]: '
  local answer
  read -r answer
  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    *) die "cancelled" ;;
  esac
}

record_manifest() {
  mkdir -p "$STATE_DIR"
  [[ -f "$MANIFEST" ]] || printf '{"installs": []}\n' > "$MANIFEST"

  python3 - "$MANIFEST" "$SCOPE" "$BASE_DIR" "${SELECTED_AGENTS[@]}" <<'PYEOF'
import json, sys
manifest_path, scope, base = sys.argv[1], sys.argv[2], sys.argv[3]
agents = sys.argv[4:]

with open(manifest_path) as f:
    data = json.load(f)

installs = data.get("installs", [])
entry = next((e for e in installs if e["scope"] == scope and e["base"] == base), None)
if entry is None:
    installs.append({"scope": scope, "base": base, "agents": sorted(agents)})
else:
    entry["agents"] = sorted(set(entry["agents"]) | set(agents))

data["installs"] = installs
with open(manifest_path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PYEOF
}

cmd_install() {
  prompt_scope
  discover_skills "$SCOPE"
  prompt_agents
  BASE_DIR="$([[ "$SCOPE" == "global" ]] && printf '%s' "$HOME" || printf '%s' "$PWD")"
  BACKUP_TS_DIR="$BACKUP_ROOT/$(date -u +%Y%m%dT%H%M%SZ)"

  confirm_plan

  local agent
  for agent in "${SELECTED_AGENTS[@]}"; do
    do_install_for_agent "$agent"
  done

  record_manifest
  print_summary
}

cmd_update() {
  printf '%sUpdating toolkit:%s %s\n' "$CYAN" "$RESET" "$REPO_DIR"
  git -C "$REPO_DIR" pull --ff-only

  BACKUP_TS_DIR="$BACKUP_ROOT/$(date -u +%Y%m%dT%H%M%SZ)"

  [[ -f "$MANIFEST" ]] || { printf 'No prior installs recorded in %s\n' "$MANIFEST"; return 0; }

  local entries
  entries="$(python3 - "$MANIFEST" <<'PYEOF'
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
for e in data.get("installs", []):
    print(e["scope"] + "\t" + e["base"] + "\t" + ",".join(e["agents"]))
PYEOF
)"

  [[ -n "$entries" ]] || { printf 'No prior installs recorded in %s\n' "$MANIFEST"; return 0; }

  local line scope base agents_csv
  while IFS=$'\t' read -r scope base agents_csv; do
    SCOPE="$scope"
    BASE_DIR="$base"
    IFS=',' read -r -a SELECTED_AGENTS <<< "$agents_csv"
    SELECTED_SKILLS=()
    discover_skills "$SCOPE"
    printf '\n%sRe-syncing%s %s (%s)\n' "$BOLD" "$RESET" "$BASE_DIR" "$SCOPE"
    local agent
    for agent in "${SELECTED_AGENTS[@]}"; do
      do_install_for_agent "$agent"
      prune_stale_skills "$agent"
    done
  done <<< "$entries"

  print_summary
}

main() {
  init_colors
  parse_args "$@"
  case "$COMMAND" in
    install) cmd_install ;;
    update) cmd_update ;;
  esac
}

main "$@"
