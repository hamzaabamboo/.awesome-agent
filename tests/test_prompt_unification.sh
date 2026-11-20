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

    if [ ! -d "$HOME_MOCK/.claude/skills" ] || [ -L "$HOME_MOCK/.claude/skills" ]; then
        echo "FAIL: .claude/skills is not a real directory of skill links"
        exit 1
    fi

    if [ ! -L "$HOME_MOCK/.claude/skills/real-testing-evidence" ] || [ ! -e "$HOME_MOCK/.claude/skills/real-testing-evidence/SKILL.md" ]; then
        echo "FAIL: .claude/skills/real-testing-evidence is not a working skill symlink"
        exit 1
    fi

    for legacy in "$HOME_MOCK/.gemini/skills" "$HOME_MOCK/.codex/skills"; do
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
    assert_contains "$AGENTS_FILE" "## GET-YOUR-SHIT-TOGETHER PROTOCOL"
    assert_contains "$AGENTS_FILE" "Inspect the actual source-of-truth artifact at full useful resolution"
    assert_contains "$AGENTS_FILE" "Distinguish the object, its boundary, and any text or annotation overlaid on it"
    assert_contains "$AGENTS_FILE" "User aggression or repeated correction means the current interpretation or evidence chain is wrong"
    assert_contains "$AGENTS_FILE" "NO REFLEXIVE AGREEMENT OR ACKNOWLEDGEMENT"
    assert_contains "$AGENTS_FILE" "CORRECTION RESPONSE GATE"
    assert_contains "$AGENTS_FILE" "perform the corrected action and verify its exact target before replying"
    assert_contains "$AGENTS_FILE" "A bounded read is never a full read"
    assert_contains "$AGENTS_FILE" "This does not authorize selecting unrelated files or expanding GYST into broad research"
    assert_contains "$AGENTS_FILE" "Every invoked skill is a full-read gate"
    assert_contains "$AGENTS_FILE" "A skill named by the user for the active task is an explicit execution obligation"
    assert_contains "$AGENTS_FILE" "compact per-skill checklist"
    assert_contains "$AGENTS_FILE" "reconcile every explicitly invoked skill against that checklist"
    assert_contains "$AGENTS_FILE" 'read its complete `SKILL.md` and every required linked instruction'
    assert_contains "$AGENTS_FILE" "Project-owned artifacts only"
    assert_contains "$AGENTS_FILE" "browser-hosted Claude/Claude in Chrome"
    assert_contains "$AGENTS_FILE" "Build the verification matrix from the affected behavior"
    assert_contains "$AGENTS_FILE" "If the user interrupts a wait or poll, stop polling immediately"
    assert_contains "$AGENTS_FILE" "Run commands one by one unless the user explicitly asks for batching"
    assert_contains "$AGENTS_FILE" "## Skill Routing Map"
    assert_contains "$AGENTS_FILE" "Resolve the artifact being designed from the active request and project before routing"
    assert_contains "$AGENTS_FILE" "Load the selected skills before producing the artifact"
    assert_contains "$AGENTS_FILE" "## Harness experiments"
    assert_contains "$AGENTS_FILE" "Keep independent task attempts separate from repeated grading of the same output"
    assert_contains "$AGENTS_FILE" 'Evaluate `redesign-existing-projects` for redesign tasks'
    assert_contains "$AGENTS_FILE" "Every design request starts with the full installed design-skill catalog"
    assert_contains "$AGENTS_FILE" "Execute all matching compatible skills"
    assert_contains "$AGENTS_FILE" "Design decisions require motivation before implementation"
    assert_contains "$AGENTS_FILE" "present 2–3 materially different viable alternatives"
    assert_contains "$AGENTS_FILE" "wait for the user's choice"
    assert_contains "$SKILLS_TARGET/trash/SKILL.md" "present them for the user to choose, combine or narrow"
    assert_contains "$SKILLS_TARGET/trash/SKILL.md" "record the motivation for each material replacement"
    assert_contains "$AGENTS_FILE" 'Severe rejection of the whole design or `/trash`: `trash`'
    assert_contains "$AGENTS_FILE" 'Every audit and redesign requires `the-council` with a separate independent agent'
    assert_contains "$AGENTS_FILE" 'UIZZE reference research is required for every UI design, redesign and visual audit'
    assert_contains "$SKILLS_TARGET/trash/SKILL.md" 'UIZZE reference research is a required stage, not optional inspiration'
    assert_contains "$SKILLS_TARGET/trash/SKILL.md" 'A wording, color or spacing patch does not satisfy this request'
    assert_contains "$SKILLS_TARGET/trash/SKILL.md" 'A self-review, multiple roles played by one agent'
    assert_contains "$AGENTS_FILE" "Resolve contradictory recipes explicitly"
    assert_contains "$AGENTS_FILE" "distinguish preview geometry from exported output"
    assert_contains "$AGENTS_FILE" "Skill recipes never authorize invented statistics, dates, brands"
    assert_contains "$AGENTS_FILE" "never read whole logs for metadata selection"
    assert_contains "$AGENTS_FILE" "Keep transient source locators until independent verification finishes"
    assert_contains "$AGENTS_FILE" "reuse verified inherited opt-outs instead of repeating them inline"
    assert_contains "$AGENTS_FILE" 'Data-bearing UI design or dogfood content stress: `break-ui`'
    assert_contains "$SKILLS_TARGET/agent-browser-dogfood/SKILL.md" '~/.awesome-agent/shared/design-data-stress.md'
    assert_contains "$SKILLS_TARGET/agent-browser-dogfood/SKILL.md" 'Keep the initial pass black-box'
    assert_contains "$AGENTS_FILE" "## Canonical Current-Task Record and Continuation Recovery"
    assert_contains "$AGENTS_FILE" 'In this repository the canonical path is `conductor/CURRENT_TASK.md`'
    assert_contains "$AGENTS_FILE" "check Goal state when available"
    assert_contains "$AGENTS_FILE" "Replace the canonical record in place"
    assert_contains "$AGENTS_FILE" "Historical receipts and full handoffs are evidence, not live task authority"
    assert_contains "$AGENTS_FILE" "Do not inspect other sessions merely because a skill was invoked"
    assert_contains "$AGENTS_FILE" "Keep that read inside the current project unless the user explicitly names a broader scope"
    assert_not_contains "$AGENTS_FILE" "Read every direct user message from all Codex and Claude sessions covering the previous two weeks"
    assert_contains "$AGENTS_FILE" '$what-did-i-say` is current-session-only and never authorizes prior-session or cross-project history reads.'
    assert_not_contains "$AGENTS_FILE" "previous two weeks of current-project Codex and Claude sessions"
    assert_contains "$AGENTS_FILE" "real-testing-evidence"
    assert_contains "$AGENTS_FILE" "handing-off-pro-max"
    assert_not_contains "$AGENTS_FILE" "Do NOT run commands one by one"
    assert_not_contains "$AGENTS_FILE" "CHAIN"
    assert_not_contains "$AGENTS_FILE" 'Use `sleep` loops'
    assert_contains "$SKILLS_TARGET/real-testing-evidence/SKILL.md" "Do not rely on hidden assistant memory as the source of truth"
    assert_contains "$SKILLS_TARGET/real-testing-evidence/SKILL.md" "Repo-specific evidence paths, harness docs, dogfood scripts, and PR verifier scripts override the generic matrix"
    assert_contains "$SKILLS_TARGET/real-testing-evidence/SKILL.md" "## No Passive Waiting"
    assert_contains "$SKILLS_TARGET/real-testing-evidence/SKILL.md" "Do not use sleep loops as a substitute for work"
    assert_contains "$SKILLS_TARGET/real-testing-evidence/SKILL.md" "Run repo evidence, dogfood, screenshot, PR-body, task-plan, or UI-coverage verifier scripts"
    assert_contains "$SKILLS_TARGET/handing-off-pro-max/SKILL.md" "## Handoff quality gate"
    assert_contains "$SKILLS_TARGET/handing-off-pro-max/SKILL.md" "Read the canonical current-task record first"
    assert_contains "$SKILLS_TARGET/get-your-shit-together/SKILL.md" "Fast correction loop. Fix latest failure; do not excavate history."
    assert_contains "$SKILLS_TARGET/get-your-shit-together/SKILL.md" 'use `$what-did-i-say`.'
    assert_contains "$SKILLS_TARGET/get-your-shit-together/SKILL.md" "GYST reads none of those broader corpora itself"
    assert_contains "$SKILLS_TARGET/get-your-shit-together/SKILL.md" "Replace the canonical receipt"
    assert_contains "$SKILLS_TARGET/un-dumb-yourself/SKILL.md" "Check Goal state when available"
    assert_contains "$SKILLS_TARGET/what-did-i-say/SKILL.md" "This skill never reads prior sessions, Codex or Claude history, or another project's chats."
    assert_contains "$SKILLS_TARGET/what-did-i-say/SKILL.md" "Read every direct user message in the current session"
    assert_not_contains "$SKILLS_TARGET/what-did-i-say/SKILL.md" "previous two weeks"
    assert_not_contains "$SKILLS_TARGET/what-did-i-say/SKILL.md" "current-project Codex and Claude sessions"
    for skill_file in "$SKILLS_TARGET"/*/SKILL.md; do
        assert_not_contains "$skill_file" "previous two weeks"
        assert_not_contains "$skill_file" "previous two-week"
    done
    if [ ! -L "$CODEX_SKILLS_TARGET/handing-off-pro-max" ] || [ ! -e "$CODEX_SKILLS_TARGET/handing-off-pro-max/SKILL.md" ]; then
        echo "FAIL: handing-off-pro-max was not linked into global skills"
        exit 1
    fi
}

test_prompt_unification

echo "Prompt unification tests passed"
