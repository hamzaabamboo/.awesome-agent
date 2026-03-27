#!/bin/bash

set -euo pipefail
set -o pipefail

MODE="build"
PROMPT_FILE="PROMPT_build.md"
MAX_ITERATIONS=0
RALPH_CLI="${RALPH_CLI:-__AGENT_CLI__}"
RALPH_MODEL="${RALPH_MODEL:-__AGENT_MODEL__}"
RALPH_APPROVAL_MODE="${RALPH_APPROVAL_MODE:-yolo}"

if [ "${1:-}" = "plan" ]; then
    MODE="plan"
    PROMPT_FILE="PROMPT_plan.md"
    MAX_ITERATIONS=${2:-0}
elif [ "${1:-}" = "build" ]; then
    MODE="build"
    PROMPT_FILE="PROMPT_build.md"
    MAX_ITERATIONS=${2:-0}
elif [ "${1:-}" = "specs" ]; then
    MODE="specs"
    PROMPT_FILE="PROMPT_specs.md"
    MAX_ITERATIONS=${2:-0}
elif [ "${1:-}" = "plan-work" ]; then
    MODE="plan-work"
    PROMPT_FILE="PROMPT_plan_work.md"
    WORK_SCOPE=${2:-}
    MAX_ITERATIONS=${3:-5}
    if [ -z "$WORK_SCOPE" ]; then
        echo "Error: plan-work requires a work description"
        exit 1
    fi
elif [[ "${1:-}" =~ ^[0-9]+$ ]]; then
    MODE="build"
    PROMPT_FILE="PROMPT_build.md"
    MAX_ITERATIONS=$1
fi

ITERATION=0
CURRENT_BRANCH=$(git branch --show-current)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Mode:   $MODE"
echo "Prompt: $PROMPT_FILE"
echo "Branch: $CURRENT_BRANCH"
[ "$MAX_ITERATIONS" -gt 0 ] && echo "Max:    $MAX_ITERATIONS iterations"
[ "$MODE" = "plan-work" ] && echo "Scope:  $WORK_SCOPE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: $PROMPT_FILE not found"
    exit 1
fi

run_ralph_streamed() {
    local prompt="$1"

    if [ "$RALPH_CLI" = "codex" ]; then
        if [ "$RALPH_APPROVAL_MODE" = "safe" ]; then
            printf "%s" "$prompt" | codex exec \
                --full-auto \
                --model "$RALPH_MODEL" \
                -
            return
        fi

        printf "%s" "$prompt" | codex exec \
            --dangerously-bypass-approvals-and-sandbox \
            --model "$RALPH_MODEL" \
            -
        return
    fi

    if [ "$RALPH_CLI" = "claude" ]; then
        claude -p "$prompt" \
            --dangerously-skip-permissions \
            --model "$RALPH_MODEL" \
            --verbose \
            --output-format stream-json \
            --include-partial-messages | node "$SCRIPT_DIR/parse_stream.js"
        return
    fi

    echo "Error: unsupported RALPH_CLI '$RALPH_CLI'. Supported values: codex, claude."
    exit 1
}

while true; do
    if [ "$MAX_ITERATIONS" -gt 0 ] && [ "$ITERATION" -ge "$MAX_ITERATIONS" ]; then
        echo "Reached max iterations: $MAX_ITERATIONS"
        break
    fi

    if [ "$MODE" = "plan-work" ]; then
        PROMPT_CONTENT=$(python3 - "$PROMPT_FILE" "$WORK_SCOPE" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
scope = sys.argv[2]
print(path.read_text().replace("__WORK_SCOPE__", scope), end="")
PY
)
    else
        PROMPT_CONTENT=$(cat "$PROMPT_FILE")
    fi

    FULL_PROMPT="$PROMPT_CONTENT

Execute the instructions above."

    run_ralph_streamed "$FULL_PROMPT"

    git push origin "$CURRENT_BRANCH" || git push -u origin "$CURRENT_BRANCH"

    ITERATION=$((ITERATION + 1))
    echo
    echo "======================== LOOP $ITERATION ========================"
    echo
done
