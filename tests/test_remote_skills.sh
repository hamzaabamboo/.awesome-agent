#!/bin/bash

set -e

output="$(REMOTE_SKILLS_LOCK=/nonexistent ./meta/install-remote-skills.sh --dry-run)"
expected_count="$(grep -Ev '^[[:space:]]*(#|$)' shared/remote-skills.txt | wc -l | tr -d ' ')"
actual_count="$(grep -c '^npx skills add ' <<<"$output")"

if [ "$actual_count" != "$expected_count" ]; then
    echo "FAIL: remote skill installer emitted $actual_count install commands for $expected_count entries"
    exit 1
fi

while IFS= read -r entry; do
    skill=""
    agent=""
    IFS='|' read -r repo skill agent <<< "$entry"
    expected="npx skills add $repo"
    if [ -n "$skill" ]; then
        expected="$expected --skill ${skill//,/ }"
    fi
    if [ -n "$agent" ]; then
        expected="$expected -a $agent"
    else
        expected="$expected -a claude-code codex antigravity antigravity-cli gemini-cli github-copilot opencode zed"
    fi
    expected="$expected --yes --global"
    if [ -n "$skill" ]; then
        expected="$expected --full-depth"
    fi

    if ! grep -Fxq "$expected" <<<"$output"; then
        echo "FAIL: missing dry-run command: $expected"
        exit 1
    fi
done < <(grep -Ev '^[[:space:]]*(#|$)' shared/remote-skills.txt)

if grep -q 'promptscript' <<<"$output"; then
    echo "FAIL: PromptScript does not support global skill installs"
    exit 1
fi

if grep -Eq '^google-labs-code/stitch-skills\|' shared/remote-skills.txt; then
    echo "FAIL: Stitch skills package must be installed as a whole repo"
    exit 1
fi

lock_file="$(mktemp)"
trap 'rm -f "$lock_file"' EXIT
printf '%s\n' '{"skills":{"find-skills":{"source":"vercel-labs/skills"},"hyperframes":{"source":"heygen-com/hyperframes"}}}' > "$lock_file"
skip_output="$(REMOTE_SKILLS_LOCK="$lock_file" ./meta/install-remote-skills.sh --dry-run)"
for entry in 'vercel-labs/skills|find-skills' 'heygen-com/hyperframes'; do
    if ! grep -Fxq "skip installed: $entry" <<<"$skip_output"; then
        echo "FAIL: installed entry not skipped: $entry"
        exit 1
    fi
done
if ! grep -Fxq "npx skills add backnotprop/pstack --skill sharpen -a claude-code codex antigravity antigravity-cli gemini-cli github-copilot opencode zed --yes --global --full-depth" <<<"$skip_output"; then
    echo "FAIL: missing entry was skipped"
    exit 1
fi
if grep -Fxq "skip installed: $entry" <<<"$(REMOTE_SKILLS_LOCK="$lock_file" ./meta/install-remote-skills.sh --dry-run --reinstall)"; then
    echo "FAIL: --reinstall still skipped installed entries"
    exit 1
fi

echo "Remote skill installer tests passed"
