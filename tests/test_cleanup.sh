#!/bin/bash

set -e

SYNC_SCRIPT="./meta/sync.sh"
HOME_MOCK="$(pwd)/tests/mock_home"

rm -rf "$HOME_MOCK"
mkdir -p "$HOME_MOCK/.gemini" "$HOME_MOCK/.claude"
ln -s "/tmp/non_existent_file_12345" "$HOME_MOCK/.gemini/broken_link"
ln -s "/Users/vittayapalotai.tanyawat/work/shinkijigyousitu/new-business-claude-rules/rules" "$HOME_MOCK/.claude/rules"
ln -s "/Users/vittayapalotai.tanyawat/work/shinkijigyousitu/new-business-claude-rules/commands" "$HOME_MOCK/.claude/commands"
mkdir -p "$HOME_MOCK/.claude/plugins"
ln -s "$HOME_MOCK/.agent/skills" "$HOME_MOCK/.claude/skills"
ln -s "$HOME_MOCK/.agent/skills" "$HOME_MOCK/.gemini/skills"

test_cleanup() {
    echo "Testing cleanup logic..."

    export TARGET_ROOT="$HOME_MOCK"

    $SYNC_SCRIPT --clean --yes

    if [ -L "$HOME_MOCK/.gemini/broken_link" ]; then
        echo "FAIL: Broken symlink still exists"
        exit 1
    fi

    if [ -L "$HOME_MOCK/.claude/rules" ]; then
        echo "FAIL: Foreign Claude rules symlink still exists"
        exit 1
    fi

    if [ -L "$HOME_MOCK/.claude/commands" ]; then
        echo "FAIL: Foreign Claude commands symlink still exists"
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

    if [ -e "$HOME_MOCK/.claude/skills" ] || [ -e "$HOME_MOCK/.gemini/skills" ]; then
        echo "FAIL: Legacy agent skill links were not removed"
        exit 1
    fi
}

test_cleanup

echo "Cleanup tests passed"
