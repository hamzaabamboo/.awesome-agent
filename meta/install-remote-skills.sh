#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REMOTE_SKILLS_FILE="$PROJECT_ROOT/shared/remote-skills.txt"
DRY_RUN=false

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -d|--dry-run)
            DRY_RUN=true
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
    shift
done

while IFS= read -r entry <&3; do
    if [ -z "$entry" ]; then
        continue
    fi

    skill=""
    agent=""
    IFS='|' read -r repo skill agent <<< "$entry"

    if [ "$DRY_RUN" = true ]; then
        cmd=("npx" "skills" "add" "$repo")
        if [ -n "$skill" ]; then
            cmd+=("--skill" "$skill")
        fi
        if [ -n "$agent" ]; then
            cmd+=("-a" "$agent")
        fi
        cmd+=("--yes" "--global")
        if [ -n "$skill" ]; then
            cmd+=("--full-depth")
        fi
        printf '%s\n' "${cmd[*]}"
        continue
    fi

    args=("$repo")
    if [ -n "$skill" ]; then
        args+=("--skill" "$skill")
    fi
    if [ -n "$agent" ]; then
        args+=("-a" "$agent")
    fi
    args+=("--yes" "--global")
    if [ -n "$skill" ]; then
        args+=("--full-depth")
    fi
    npx skills add "${args[@]}"
done 3< "$REMOTE_SKILLS_FILE"
