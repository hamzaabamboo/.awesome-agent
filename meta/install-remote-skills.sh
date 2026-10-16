#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REMOTE_SKILLS_FILE="$PROJECT_ROOT/shared/remote-skills.txt"
SKILL_LOCK="${REMOTE_SKILLS_LOCK:-$HOME/.agents/.skill-lock.json}"
DRY_RUN=false
REINSTALL=false
read -r -a DEFAULT_AGENTS <<< "${REMOTE_SKILLS_AGENTS:-claude-code codex antigravity antigravity-cli gemini-cli github-copilot opencode zed}"

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -d|--dry-run)
            DRY_RUN=true
            ;;
        -r|--reinstall)
            REINSTALL=true
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
    shift
done

is_installed() {
    [ -f "$SKILL_LOCK" ] || return 1
    python3 - "$SKILL_LOCK" "$1" "$2" <<'PY'
import json
import sys

lock_path, repo, skill = sys.argv[1:4]
skills = json.load(open(lock_path)).get("skills", {})
normalize = lambda source: source.lower().removeprefix("https://").removeprefix("http://").rstrip("/")
repo = normalize(repo)
if skill and skill != "*":
    names = skill.split(",")
    sys.exit(0 if all(normalize(skills.get(name, {}).get("source", "")) == repo for name in names) else 1)
sys.exit(0 if any(normalize(entry.get("source", "")) == repo for entry in skills.values()) else 1)
PY
}

while IFS= read -r entry <&3; do
    if [ -z "$entry" ]; then
        continue
    fi

    skill=""
    agent=""
    IFS='|' read -r repo skill agent <<< "$entry"

    if [ "$REINSTALL" = false ] && is_installed "$repo" "$skill"; then
        printf '%s\n' "skip installed: $entry"
        continue
    fi

    args=("$repo")
    if [ -n "$skill" ]; then
        IFS=',' read -r -a skill_names <<< "$skill"
        args+=("--skill" "${skill_names[@]}")
    fi
    if [ -n "$agent" ]; then
        args+=("-a" "$agent")
    else
        args+=("-a" "${DEFAULT_AGENTS[@]}")
    fi
    args+=("--yes" "--global")
    if [ -n "$skill" ]; then
        args+=("--full-depth")
    fi

    if [ "$DRY_RUN" = true ]; then
        printf '%s\n' "npx skills add ${args[*]}"
        continue
    fi

    npx skills add "${args[@]}"
done 3< "$REMOTE_SKILLS_FILE"
