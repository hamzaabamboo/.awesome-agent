#!/bin/bash

set -e

output="$(./meta/install-remote-skills.sh --dry-run)"
expected_count="$(grep -Ev '^[[:space:]]*(#|$)' shared/remote-skills.txt | wc -l | tr -d ' ')"
actual_count="$(grep -c '^npx skills add ' <<<"$output")"

if [ "$actual_count" != "$expected_count" ]; then
    echo "FAIL: remote skill installer emitted $actual_count install commands for $expected_count entries"
    exit 1
fi

while IFS= read -r entry; do
    if [[ "$entry" == *"|"* ]]; then
        repo="${entry%%|*}"
        skill="${entry#*|}"
        expected="npx skills add $repo --skill $skill --yes --global --full-depth"
    else
        expected="npx skills add $entry --yes --global"
    fi

    if ! grep -Fxq "$expected" <<<"$output"; then
        echo "FAIL: missing dry-run command: $expected"
        exit 1
    fi
done < <(grep -Ev '^[[:space:]]*(#|$)' shared/remote-skills.txt)

if grep -Eq '^google-labs-code/stitch-skills\|' shared/remote-skills.txt; then
    echo "FAIL: Stitch skills package must be installed as a whole repo"
    exit 1
fi

echo "Remote skill installer tests passed"
