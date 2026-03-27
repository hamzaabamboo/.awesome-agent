#!/bin/bash

set -e

SYNC_SCRIPT="./meta/sync.sh"
HOME_MOCK="$(pwd)/tests/mock_home"

rm -rf "$HOME_MOCK"
mkdir -p "$HOME_MOCK"

test_prompt_unification() {
    echo "Testing prompt unification..."

    export TARGET_ROOT="$HOME_MOCK"

    $SYNC_SCRIPT --yes

    if [ ! -L "$HOME_MOCK/.claude/CLAUDE.md" ]; then
        echo "FAIL: Claude prompt is not a symlink"
        exit 1
    fi

    if [ ! -L "$HOME_MOCK/.gemini/GEMINI.md" ]; then
        echo "FAIL: Gemini prompt is not a symlink"
        exit 1
    fi

    if [ "$(readlink "$HOME_MOCK/.claude/CLAUDE.md")" != "$(pwd)/shared/AGENTS.md" ]; then
        echo "FAIL: Claude prompt does not point to shared AGENTS"
        exit 1
    fi

    if [ "$(readlink "$HOME_MOCK/.gemini/GEMINI.md")" != "$(pwd)/shared/AGENTS.md" ]; then
        echo "FAIL: Gemini prompt does not point to shared AGENTS"
        exit 1
    fi

    if ! grep -q "npx skills add" "$HOME_MOCK/.claude/CLAUDE.md"; then
        echo "FAIL: Unified prompt does not reference skills.sh installs"
        exit 1
    fi
}

test_prompt_unification

echo "Prompt unification tests passed"
