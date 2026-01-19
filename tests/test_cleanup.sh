#!/bin/bash

# tests/test_cleanup.sh - Tests for broken symlink cleanup

set -e

SYNC_SCRIPT="./meta/sync.sh"
HOME_MOCK="$(pwd)/tests/mock_home"

# Setup
rm -rf "$HOME_MOCK"
mkdir -p "$HOME_MOCK/.gemini"
ln -s "/tmp/non_existent_file_12345" "$HOME_MOCK/.gemini/broken_link"

# Test Cleanup
test_cleanup() {
    echo "Testing cleanup logic..."
    
    export TARGET_ROOT="$HOME_MOCK"
    
    # Run sync with --clean and --yes
    $SYNC_SCRIPT --clean --yes
    
    if [ ! -L "$HOME_MOCK/.gemini/broken_link" ]; then
        echo "PASS: Broken symlink removed"
    else
        echo "FAIL: Broken symlink still exists"
        exit 1
    fi
}

# Run tests
test_cleanup
