#!/bin/bash

set -e

SYNC_SCRIPT="./meta/sync.sh"
HOME_MOCK="$(pwd)/tests/mock_home"
SHARED_DIR="./shared/local-skills"

rm -rf "$HOME_MOCK"
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

    $SYNC_SCRIPT --yes

    if [ ! -f "$HOME_MOCK/.agent/skills/test_sync_flat/SKILL.md" ]; then
        echo "FAIL: Canonical skill file not created"
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
