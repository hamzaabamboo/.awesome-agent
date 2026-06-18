#!/bin/bash

set -e

SYNC_SCRIPT="./meta/sync.sh"
HOME_MOCK="$(mktemp -d "${TMPDIR:-/tmp}/awesome-agent-args.XXXXXX")"
trap 'rm -rf "$HOME_MOCK"' EXIT
export TARGET_ROOT="$HOME_MOCK"
export SKIP_REMOTE_SKILLS_INSTALL=true
export PROJECT_TEMP_DIR="$HOME_MOCK/.build"
export AGENTS_MD="$HOME_MOCK/AGENTS.md"

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

echo "All argument parsing tests passed!"
