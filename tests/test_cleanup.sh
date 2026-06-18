#!/bin/bash

set -e

SYNC_SCRIPT="./meta/sync.sh"
HOME_MOCK="$(mktemp -d "${TMPDIR:-/tmp}/awesome-agent-cleanup.XXXXXX")"

trap 'rm -rf "$HOME_MOCK"' EXIT
mkdir -p "$HOME_MOCK/.gemini" "$HOME_MOCK/.claude"
ln -s "/tmp/non_existent_file_12345" "$HOME_MOCK/.gemini/broken_link"
ln -s "/tmp/mock-claude-rules" "$HOME_MOCK/.claude/rules"
ln -s "/tmp/mock-claude-commands" "$HOME_MOCK/.claude/commands"
mkdir -p "$HOME_MOCK/.claude/plugins"
ln -s "$HOME_MOCK/.agent/skills" "$HOME_MOCK/.claude/skills"
ln -s "$HOME_MOCK/.agent/skills" "$HOME_MOCK/.gemini/skills"
mkdir -p "$HOME_MOCK/.gemini/antigravity" "$HOME_MOCK/.codex"
ln -s "$HOME_MOCK/.agent/skills" "$HOME_MOCK/.gemini/antigravity/skills"
ln -s "$HOME_MOCK/.agent/skills" "$HOME_MOCK/.codex/skills"
mkdir -p "$HOME_MOCK/.agents"
ln -s "$HOME_MOCK/.agent/skills" "$HOME_MOCK/.agents/skills"

test_cleanup() {
    echo "Testing cleanup logic..."

    export TARGET_ROOT="$HOME_MOCK"
    export SKIP_REMOTE_SKILLS_INSTALL=true
    export PROJECT_TEMP_DIR="$HOME_MOCK/.build"
    export AGENTS_MD="$HOME_MOCK/AGENTS.md"

    $SYNC_SCRIPT --clean --yes

    if [ -L "$HOME_MOCK/.gemini/broken_link" ]; then
        echo "FAIL: Broken symlink still exists"
        exit 1
    fi

    if [ -L "$HOME_MOCK/.claude/rules" ]; then
        echo "FAIL: Claude rules symlink still exists"
        exit 1
    fi

    if [ -L "$HOME_MOCK/.claude/commands" ]; then
        echo "FAIL: Claude commands symlink still exists"
        exit 1
    fi

    if [ ! -d "$HOME_MOCK/.claude/rules" ]; then
        echo "FAIL: Claude rules directory not recreated"
        exit 1
    fi

    if [ ! -d "$HOME_MOCK/.claude/commands" ]; then
        echo "FAIL: Claude commands directory not recreated"
        exit 1
    fi

    if [ ! -d "$HOME_MOCK/.claude/plugins" ]; then
        echo "FAIL: Existing Claude plugins directory should be preserved"
        exit 1
    fi

    if [ -e "$HOME_MOCK/.claude/skills" ] || [ -e "$HOME_MOCK/.gemini/skills" ] || [ -e "$HOME_MOCK/.gemini/antigravity/skills" ] || [ -e "$HOME_MOCK/.codex/skills" ]; then
        echo "FAIL: Legacy agent skill links were not removed"
        exit 1
    fi

    if [ ! -d "$HOME_MOCK/.agents/skills" ] || [ -L "$HOME_MOCK/.agents/skills" ]; then
        echo "FAIL: Global skill root should be a directory"
        exit 1
    fi

    if [ "$(readlink "$HOME_MOCK/.agents/skills/real-testing-evidence")" != "$HOME_MOCK/.build/skills/real-testing-evidence" ]; then
        echo "FAIL: Repo-local skill was not linked into global skill root"
        exit 1
    fi
}

test_cleanup

echo "Cleanup tests passed"
