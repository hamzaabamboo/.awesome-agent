#!/bin/bash

# tests/test_sync_args.sh - Basic tests for sync.sh argument parsing

set -e

SYNC_SCRIPT="./meta/sync.sh"
mkdir -p tests/mock_home
export TARGET_ROOT="$(pwd)/tests/mock_home"

test_flag() {
    local flag=$1
    local expected_output=$2
    echo "Testing flag: $flag"
    output=$($SYNC_SCRIPT "$flag")
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

echo "All argument parsing tests passed!"
