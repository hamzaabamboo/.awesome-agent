#!/bin/bash
set -u

# Usage: ./run-loop.sh <agent> <prompt> <max_iterations> <completion_promise> <model> [--resume]
AGENT="${1:-gemini}"
PROMPT="${2:-}"
MAX_ITERATIONS="${3:-20}"
COMPLETION_PROMISE="${4:-DONE}"
INITIAL_MODEL="${5:-auto}"
RESUME=false

# Check for resume flag
for arg in "$@"; do
  [[ "$arg" == "--resume" ]] && RESUME=true
done

STATE_FILE=".gemini/ralph-loop.local.md"
TURN_LOG=".gemini/turn.log"
STATS_FILE=".gemini/stats.json"
PLAN_FILE="@fix_plan.md"

# Model Pool
MODELS=("auto" "gemini-2.0-flash-exp" "gemini-1.5-flash" "gemini-2.0-pro-exp-02-05" "gemini-1.5-pro")
MODEL=$INITIAL_MODEL
BLACKLIST=()

mkdir -p .gemini

# 1. Initialize State
if [[ "$RESUME" == "false" ]]; then
    cat > "$STATE_FILE" <<EOF
---
active: true
iteration: 0
max_iterations: $MAX_ITERATIONS
completion_promise: "$COMPLETION_PROMISE"
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
agent: "$AGENT"
model: "$MODEL"
queries: 0
phase: "ELABORATION"
---

$PROMPT
EOF
else
    sed -i '' "s/^active: .*/active: true/" "$STATE_FILE" 2>/dev/null || sed -i "s/^active: .*/active: true/" "$STATE_FILE"
fi

# Function to pick next available model not in blacklist
pick_next_model() {
    BLACKLIST+=("$MODEL")
    echo "🚫 Blacklisting $MODEL due to exhaustion."
    
    for m in "${MODELS[@]}"; do
        local blacklisted=false
        for b in "${BLACKLIST[@]}"; do
            [[ "$m" == "$b" ]] && blacklisted=true && break
        done
        if [[ "$blacklisted" == "false" ]]; then
            MODEL=$m
            echo "🔄 Switched to $MODEL"
            # Update state file
            sed -i '' "s/^model: .*/model: \"$MODEL\"/" "$STATE_FILE" 2>/dev/null || sed -i "s/^model: .*/model: \"$MODEL\"/" "$STATE_FILE"
            return 0
        fi
    done
    return 1 # All models exhausted
}

run_agent() {
    local instructions="$1"
    local phase_label="${2:-AGENT}"
    
    while true; do
        > "$TURN_LOG"
        echo -e "\n--- $phase_label START (Model: $MODEL) ---"
        
        if [[ "$AGENT" == "claude" ]]; then
            claude --permission-mode acceptEdits -p "$instructions" 2>&1 | tee "$TURN_LOG"
elif [[ "$AGENT" == "gemini" ]]; then
            local model_flag=""
            [[ -n "$MODEL" ]] && model_flag="--model $MODEL"
            gemini "$instructions" --yolo $model_flag 2>&1 | tee "$TURN_LOG"
            gemini "Report session stats" -o json --yolo $model_flag > "$STATS_FILE" 2>/dev/null
        fi
        echo -e "--- $phase_label END ---\n"
        
        # Check for Quota Errors
        if grep -qi "exhausted your capacity" "$TURN_LOG" || grep -qi "429" "$TURN_LOG" || grep -qi "RESOURCE_EXHAUSTED" "$TURN_LOG"; then
            echo "⚠️ Quota hit on $MODEL."
            if pick_next_model; then
                echo "♻️ Retrying with new model..."
                continue
            else
                echo "💀 ALL MODELS EXHAUSTED. Sleeping for 5 minutes before retrying..."
                BLACKLIST=() # Clear blacklist after sleep
                sleep 300
                continue
            fi
        fi
        break
    done
}

# ------------------------------------------------------------------------------
# LIFECYCLE
# ------------------------------------------------------------------------------

if [[ "$RESUME" == "false" ]]; then
    run_agent "Expand prompt into specs/requirements_internal.md. Output <promise>SPEC_READY</promise>" "ELABORATION"
    sed -i '' "s/^phase: .*/phase: \"PLANNING\"/" "$STATE_FILE" 2>/dev/null || sed -i "s/^phase: .*/phase: \"PLANNING\"/" "$STATE_FILE"
    run_agent "Based on specs, create @fix_plan.md checklist. Output <promise>PLAN_READY</promise>" "PLANNING"
fi

sed -i '' "s/^phase: .*/phase: \"IMPLEMENTATION\"/" "$STATE_FILE" 2>/dev/null || sed -i "s/^phase: .*/phase: \"IMPLEMENTATION\"/" "$STATE_FILE"

START_ITER=$(grep "iteration: " "$STATE_FILE" | awk '{print $2}' | tr -d '"')
[[ -z "$START_ITER" || "$START_ITER" == "0" ]] && START_ITER=1
QUERIES=$(grep "queries: " "$STATE_FILE" | awk '{print $2}' | tr -d '"')
[[ -z "$QUERIES" ]] && QUERIES=2

for ((i=$START_ITER; i<=$MAX_ITERATIONS; i++)); do
  echo "🔄 Turn $i / $MAX_ITERATIONS"
  QUERIES=$((QUERIES + 1))
  sed -i '' "s/^iteration: .*/iteration: $i/" "$STATE_FILE" 2>/dev/null || sed -i "s/^iteration: .*/iteration: $i/" "$STATE_FILE"
  sed -i '' "s/^queries: .*/queries: $QUERIES/" "$STATE_FILE" 2>/dev/null || sed -i "s/^queries: .*/queries: $QUERIES/" "$STATE_FILE"

  run_agent "@.gemini/ralph-loop.local.md @$PLAN_FILE You are Ralph. Implement next task in $PLAN_FILE, mark [x], and commit. If done, output <promise>$COMPLETION_PROMISE</promise>." "ITERATION $i"

  if grep -q "<promise>$COMPLETION_PROMISE</promise>" "$TURN_LOG"; then
    echo -e "\n✅ Lifecycle Completed!"
    sed -i '' "s/^active: true/active: false/" "$STATE_FILE" 2>/dev/null || sed -i "s/^active: true/active: false/" "$STATE_FILE"
    exit 0
  fi
  
  [[ "$(grep "active: " "$STATE_FILE" | awk '{print $2}')" == "false" ]] && exit 1
done
