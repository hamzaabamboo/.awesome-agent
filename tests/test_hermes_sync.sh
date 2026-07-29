#!/bin/bash

set -e

SYNC_SCRIPT="./meta/sync.sh"
HOME_MOCK="$(mktemp -d "${TMPDIR:-/tmp}/awesome-agent-hermes.XXXXXX")"
BIN_MOCK="$HOME_MOCK/bin"
SKILLS_CAPTURE="$HOME_MOCK/hermes-skills"
PROMPT_CAPTURE="$HOME_MOCK/hermes-prompt"
EXPECTED_PROMPT="$HOME_MOCK/expected-prompt"
trap 'rm -rf "$HOME_MOCK"' EXIT

mkdir -p "$BIN_MOCK"

cat > "$BIN_MOCK/hermes" <<'SH'
#!/bin/bash
case "$3" in
    skills.external_dirs)
        printf '%s' "$4" > "$HERMES_SKILLS_CAPTURE"
        ;;
    agent.system_prompt)
        printf '%s' "$4" > "$HERMES_PROMPT_CAPTURE"
        ;;
    *)
        echo "Unexpected Hermes config key: $3" >&2
        exit 1
        ;;
esac
SH
chmod +x "$BIN_MOCK/hermes"

HOME="$HOME_MOCK" \
TARGET_ROOT="$HOME_MOCK" \
PROJECT_TEMP_DIR="$HOME_MOCK/.build" \
SKIP_REMOTE_SKILLS_INSTALL=true \
HERMES_SKILLS_CAPTURE="$SKILLS_CAPTURE" \
HERMES_PROMPT_CAPTURE="$PROMPT_CAPTURE" \
PATH="$BIN_MOCK:$PATH" \
    $SYNC_SCRIPT --yes

expected="$HOME_MOCK/.agents/skills"
actual="$(cat "$SKILLS_CAPTURE")"

if [ "$actual" != "$expected" ]; then
    echo "FAIL: Hermes external skill registration mismatch"
    echo "Expected: $expected"
    echo "Actual:   $actual"
    exit 1
fi

if [ ! -f "$HOME_MOCK/.agents/skills/agent-browser-dogfood/SKILL.md" ]; then
    echo "FAIL: Repo-local agent-browser-dogfood skill was not exposed to Hermes"
    exit 1
fi

printf '%s' "$(cat shared/AGENTS.md)" > "$EXPECTED_PROMPT"

if ! cmp -s "$PROMPT_CAPTURE" "$EXPECTED_PROMPT"; then
    echo "FAIL: Hermes system prompt differs from shared/AGENTS.md"
    exit 1
fi

if ! grep -Fq "## GET-YOUR-SHIT-TOGETHER PROTOCOL" "$PROMPT_CAPTURE"; then
    echo "FAIL: Hermes system prompt is missing the operating protocol"
    exit 1
fi

echo "Hermes skill and prompt sync test passed."
