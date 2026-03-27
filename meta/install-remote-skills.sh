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

    repo="${entry%%|*}"
    skill=""
    if [[ "$entry" == *"|"* ]]; then
        skill="${entry#*|}"
    fi

    if [ "$DRY_RUN" = true ]; then
        if [ -n "$skill" ]; then
            echo "npx skills add $repo --skill $skill --yes --global"
        else
            echo "npx skills add $repo --yes --global"
        fi
        continue
    fi

    if [ -n "$skill" ]; then
        npx skills add "$repo" --skill "$skill" --yes --global
    else
        npx skills add "$repo" --yes --global
    fi
done 3< "$REMOTE_SKILLS_FILE"
