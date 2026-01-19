#!/bin/bash

# tests/test_transform.sh - Tests for transformation logic

set -e

SYNC_SCRIPT="./meta/sync.sh"
BUILD_DIR="./build"
SHARED_DIR="./shared/skills"

# Setup
mkdir -p "$SHARED_DIR"
echo "# Test Skill" > "$SHARED_DIR/test_skill.md"

# Test Gemini Transformation (Markdown pass-through)
test_gemini_transform() {
    echo "Testing Gemini transformation..."
    # Mocking the transform logic for now, expecting the script to handle it
    # We need to run the sync script to trigger the build
    $SYNC_SCRIPT --verbose
    
    if [ -f "$BUILD_DIR/gemini/test_skill.md" ]; then
        echo "PASS: Gemini file created"
    else
        echo "FAIL: Gemini file not created"
        exit 1
    fi
}

# Test Claude Transformation (XML wrapping)
test_claude_transform() {
    echo "Testing Claude transformation..."
    $SYNC_SCRIPT --verbose
    
    if [ -f "$BUILD_DIR/claude/test_skill.xml" ]; then
        echo "PASS: Claude file created"
    else
        echo "FAIL: Claude file not created"
        exit 1
    fi
}

# Run tests
test_gemini_transform
test_claude_transform

echo "Tests ready for implementation"
