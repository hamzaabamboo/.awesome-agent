#!/bin/bash

set -e

SYNC_SCRIPT="./meta/sync.sh"
HOME_MOCK="$(mktemp -d "${TMPDIR:-/tmp}/awesome-agent-transform.XXXXXX")"
SHARED_DIR="$HOME_MOCK/local-skills"

trap 'rm -rf "$HOME_MOCK"' EXIT
mkdir -p "$SHARED_DIR"
cat <<'EOF' > "$SHARED_DIR/test_sync_flat.md"
---
name: wrong-name
description: Flat skill for sync test.
---

Flat skill body.
EOF

test_transform() {
    echo "Testing skill normalization..."

    export TARGET_ROOT="$HOME_MOCK"
    export SKIP_REMOTE_SKILLS_INSTALL=true
    export PROJECT_TEMP_DIR="$HOME_MOCK/.build"
    export AGENTS_MD="$HOME_MOCK/AGENTS.md"
    export LOCAL_SHARED_SKILLS="$SHARED_DIR"

    $SYNC_SCRIPT --yes

    if [ ! -f "$HOME_MOCK/.agent/skills/test_sync_flat/SKILL.md" ]; then
        echo "FAIL: Canonical skill file not created"
        exit 1
    fi

    if [ ! -f "$HOME_MOCK/.agents/skills/test_sync_flat/SKILL.md" ]; then
        echo "FAIL: Codex skill file not created"
        exit 1
    fi

    if [ "$(readlink "$HOME_MOCK/.agents/skills/test_sync_flat")" != "$HOME_MOCK/.build/skills/test_sync_flat" ]; then
        echo "FAIL: Codex skill should be a per-skill symlink"
        exit 1
    fi

    if ! grep -q "^name: test_sync_flat$" "$HOME_MOCK/.agent/skills/test_sync_flat/SKILL.md"; then
        echo "FAIL: Skill frontmatter name was not normalized"
        exit 1
    fi

    if [ -e "$HOME_MOCK/.claude/skills" ] || [ -e "$HOME_MOCK/.gemini/skills" ]; then
        echo "FAIL: Sync should not manage agent skill directories anymore"
        exit 1
    fi
}

test_transform

echo "Transformation tests passed"
