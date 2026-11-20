#!/bin/bash

set -e

SYNC_SCRIPT="./meta/sync.sh"
HOME_MOCK="$(mktemp -d "${TMPDIR:-/tmp}/awesome-agent-args.XXXXXX")"
trap 'rm -rf "$HOME_MOCK"' EXIT
export TARGET_ROOT="$HOME_MOCK"
export SKIP_REMOTE_SKILLS_INSTALL=true
export PROJECT_TEMP_DIR="$HOME_MOCK/.build"
export AGENTS_MD="$HOME_MOCK/AGENTS.md"
export REMOTE_SKILLS_LOCK="$HOME_MOCK/skill-lock.json"

test_flag() {
    local flag=$1
    local expected_output=$2
    echo "Testing flag: $flag"
    output=$($SYNC_SCRIPT "$flag" --yes)
    if [[ "$output" == *"$expected_output"* ]]; then
        echo "PASS"
    else
        echo "FAIL: Expected '$expected_output' in output, but got:"
        echo "$output"
        exit 1
    fi
}

test_flag "-v" "Verbose mode enabled."
test_flag "--verbose" "Verbose mode enabled."
test_flag "-d" "Dry run mode enabled."
test_flag "--dry-run" "Dry run mode enabled."
test_flag "-c" "Clean mode enabled."
test_flag "--clean" "Clean mode enabled."

output=$(SKIP_REMOTE_SKILLS_INSTALL=false $SYNC_SCRIPT --dry-run --yes)
if [[ "$output" != *"npx skills add "* ]]; then
    echo "FAIL: dry run did not delegate to remote skill installer dry run"
    echo "$output"
    exit 1
fi

mkdir -p "$HOME_MOCK/.claude/commands" "$HOME_MOCK/.claude/rules" "$HOME_MOCK/.gemini/extensions/init-repo/commands"
printf '%s\n' 'keep command' > "$HOME_MOCK/.claude/commands/keep.md"
printf '%s\n' 'keep rule' > "$HOME_MOCK/.claude/rules/keep.md"
printf '%s\n' 'keep gemini' > "$HOME_MOCK/.gemini/extensions/init-repo/commands/keep.toml"

$SYNC_SCRIPT --skills-only --yes
for file in \
    "$HOME_MOCK/.claude/commands/keep.md" \
    "$HOME_MOCK/.claude/rules/keep.md" \
    "$HOME_MOCK/.gemini/extensions/init-repo/commands/keep.toml"
do
    if [ ! -f "$file" ]; then
        echo "FAIL: skills-only removed $file"
        exit 1
    fi
done

if [ ! -e "$HOME_MOCK/.agents/skills/real-testing-evidence/SKILL.md" ] || [ ! -L "$HOME_MOCK/.codex/AGENTS.md" ]; then
    echo "FAIL: skills-only did not sync skills and prompt"
    exit 1
fi

cp "$AGENTS_MD" "$HOME_MOCK/prompt-before.md"
$SYNC_SCRIPT --skills-only --yes
cmp "$AGENTS_MD" "$HOME_MOCK/prompt-before.md"

if $SYNC_SCRIPT --skills-only --clean --yes; then
    echo "FAIL: skills-only accepted destructive cleanup"
    exit 1
fi

for legacy_kind in canonical external; do
    legacy_root="$HOME_MOCK/legacy-$legacy_kind"
    legacy_target="$legacy_root/.agents/skills"
    if [ "$legacy_kind" = external ]; then
        legacy_target="$legacy_root/external-skills"
    fi
    mkdir -p "$legacy_root/.claude" "$legacy_root/.build/skills" "$legacy_target"
    ln -s "$legacy_target" "$legacy_root/.claude/skills"
    printf '%s\n' 'keep target' > "$legacy_target/keep.md"
    printf '%s\n' 'keep build' > "$legacy_root/.build/skills/keep.md"
    if TARGET_ROOT="$legacy_root" PROJECT_TEMP_DIR="$legacy_root/.build" AGENTS_MD="$legacy_root/AGENTS.md" $SYNC_SCRIPT --skills-only --yes; then
        echo "FAIL: skills-only accepted legacy $legacy_kind skill root"
        exit 1
    fi
    if [ ! -L "$legacy_root/.claude/skills" ] || [ -e "$legacy_root/AGENTS.md" ] || [ "$(cat "$legacy_target/keep.md")" != 'keep target' ] || [ "$(cat "$legacy_root/.build/skills/keep.md")" != 'keep build' ]; then
        echo "FAIL: legacy skill root rejection changed existing state"
        exit 1
    fi
done

echo "All argument parsing and skills-only preservation tests passed!"
