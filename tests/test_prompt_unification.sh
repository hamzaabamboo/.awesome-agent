#!/bin/bash

set -e

SYNC_SCRIPT="./meta/sync.sh"
HOME_MOCK="$(mktemp -d "${TMPDIR:-/tmp}/awesome-agent-prompt.XXXXXX")"
SKILLS_TARGET="$HOME_MOCK/.agent/skills"
CODEX_SKILLS_TARGET="$HOME_MOCK/.agents/skills"
AGENTS_FILE="$HOME_MOCK/AGENTS.md"

trap 'rm -rf "$HOME_MOCK"' EXIT
mkdir -p "$HOME_MOCK"

assert_contains() {
    local file="$1"
    local text="$2"
    if ! grep -Fq "$text" "$file"; then
        echo "FAIL: $file missing: $text"
        exit 1
    fi
}

assert_not_contains() {
    local file="$1"
    local text="$2"
    if grep -Fq "$text" "$file"; then
        echo "FAIL: $file still contains: $text"
        exit 1
    fi
}

test_prompt_unification() {
    echo "Testing prompt unification..."

    export TARGET_ROOT="$HOME_MOCK"
    export SKIP_REMOTE_SKILLS_INSTALL=true
    export PROJECT_TEMP_DIR="$HOME_MOCK/.build"
    export AGENTS_MD="$AGENTS_FILE"

    $SYNC_SCRIPT --yes

    if [ ! -L "$HOME_MOCK/.claude/CLAUDE.md" ]; then
        echo "FAIL: Claude prompt is not a symlink"
        exit 1
    fi

    if [ ! -L "$HOME_MOCK/.gemini/GEMINI.md" ]; then
        echo "FAIL: Gemini prompt is not a symlink"
        exit 1
    fi

    if [ ! -L "$HOME_MOCK/.codex/AGENTS.md" ]; then
        echo "FAIL: Codex prompt is not a symlink"
        exit 1
    fi

    if [ "$(readlink "$HOME_MOCK/.claude/CLAUDE.md")" != "$AGENTS_FILE" ]; then
        echo "FAIL: Claude prompt does not point to shared AGENTS"
        exit 1
    fi

    if [ "$(readlink "$HOME_MOCK/.gemini/GEMINI.md")" != "$AGENTS_FILE" ]; then
        echo "FAIL: Gemini prompt does not point to shared AGENTS"
        exit 1
    fi

    if [ "$(readlink "$HOME_MOCK/.codex/AGENTS.md")" != "$AGENTS_FILE" ]; then
        echo "FAIL: Codex prompt does not point to shared AGENTS"
        exit 1
    fi

    if [ "$(readlink "$SKILLS_TARGET")" != "$HOME_MOCK/.build/skills" ]; then
        echo "FAIL: canonical skills target does not point to build skills"
        exit 1
    fi

    if [ ! -d "$CODEX_SKILLS_TARGET" ] || [ -L "$CODEX_SKILLS_TARGET" ]; then
        echo "FAIL: Global skills target should be a directory"
        exit 1
    fi

    if [ "$(readlink "$CODEX_SKILLS_TARGET/real-testing-evidence")" != "$HOME_MOCK/.build/skills/real-testing-evidence" ]; then
        echo "FAIL: real-testing-evidence was not linked into global skills"
        exit 1
    fi

    for legacy in "$HOME_MOCK/.claude/skills" "$HOME_MOCK/.gemini/skills" "$HOME_MOCK/.codex/skills"; do
        if [ -e "$legacy" ]; then
            echo "FAIL: legacy skill path exists: $legacy"
            exit 1
        fi
    done

    if ! grep -q "npx skills add" "$HOME_MOCK/.claude/CLAUDE.md"; then
        echo "FAIL: Unified prompt does not reference skills.sh installs"
        exit 1
    fi

    if [ ! -d "$HOME_MOCK/.claude/commands" ]; then
        echo "FAIL: Claude commands directory was not created"
        exit 1
    fi

    if [ ! -f "$HOME_MOCK/.gemini/extensions/init-repo/commands/repo-setup.toml" ]; then
        echo "FAIL: Gemini repo setup command was not generated"
        exit 1
    fi

    assert_contains "$HOME_MOCK/.gemini/extensions/init-repo/commands/repo-setup.toml" 'description = "Agent command"'
    assert_contains "$HOME_MOCK/.gemini/extensions/init-repo/commands/repo-setup.toml" "# Repo Setup"
    assert_contains "$AGENTS_FILE" "## REAL TESTING, PR EVIDENCE, AND SUBAGENTS"
    assert_contains "$AGENTS_FILE" "Build the verification matrix from the affected behavior"
    assert_contains "$AGENTS_FILE" "If the user interrupts a wait or poll, stop polling immediately"
    assert_contains "$AGENTS_FILE" "Run commands one by one unless the user explicitly asks for batching"
    assert_contains "$AGENTS_FILE" "real-testing-evidence"
    assert_not_contains "$AGENTS_FILE" "Do NOT run commands one by one"
    assert_not_contains "$AGENTS_FILE" "CHAIN"
    assert_not_contains "$AGENTS_FILE" 'Use `sleep` loops'
    assert_contains "$SKILLS_TARGET/real-testing-evidence/SKILL.md" "Do not rely on hidden assistant memory as the source of truth"
    assert_contains "$SKILLS_TARGET/real-testing-evidence/SKILL.md" "Repo-specific evidence paths, harness docs, dogfood scripts, and PR verifier scripts override the generic matrix"
    assert_contains "$SKILLS_TARGET/real-testing-evidence/SKILL.md" "## No Passive Waiting"
    assert_contains "$SKILLS_TARGET/real-testing-evidence/SKILL.md" "Do not use sleep loops as a substitute for work"
    assert_contains "$SKILLS_TARGET/real-testing-evidence/SKILL.md" "Run repo evidence, dogfood, screenshot, PR-body, task-plan, or UI-coverage verifier scripts"
}

test_prompt_unification

echo "Prompt unification tests passed"
