#!/bin/bash
set -u

# Usage: ./run-loop.sh <agent> <prompt> <max_iterations> <completion_promise>
# agent: "gemini" or "claude"

AGENT="${1:-gemini}"
PROMPT="${2:-}"
MAX_ITERATIONS="${3:-20}"
COMPLETION_PROMISE="${4:-DONE}"
STATE_FILE=".gemini/ralph-loop.local.md"

if [[ -z "$PROMPT" ]]; then
  echo "Error: Prompt is required"
  exit 1
fi

mkdir -p .gemini

# 1. Initialize State
cat > "$STATE_FILE" <<EOF
---
active: true
iteration: 1
max_iterations: $MAX_ITERATIONS
completion_promise: "$COMPLETION_PROMISE"
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
agent: "$AGENT"
---

$PROMPT
EOF

echo "🚀 Starting Ralph Loop with $AGENT..."

# 2. The Loop
for ((i=1; i<=$MAX_ITERATIONS; i++)); do
  echo "🔄 Iteration $i / $MAX_ITERATIONS"
  
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^iteration: .*/iteration: $i/" "$STATE_FILE"
  else
    sed -i "s/^iteration: .*/iteration: $i/" "$STATE_FILE"
  fi

  # Construct the instruction payload
  INSTRUCTIONS="
@.gemini/ralph-loop.local.md
@ralph-commander/@fix_plan.md

You are Ralph.
1. Read the state file and the plan.
2. Find the next incomplete task.
3. Implement it.
4. Update the plan.
5. Commit your changes.

ONLY WORK ON A SINGLE TASK.
If the task is complete as per the prompt, output <promise>$COMPLETION_PROMISE</promise>.
"

  # Execute Agent
  if [[ "$AGENT" == "claude" ]]; then
    RESULT=$(claude --permission-mode acceptEdits -p "$INSTRUCTIONS")
  elif [[ "$AGENT" == "gemini" ]]; then
    # Gemini usually expects prompt as argument for one-shot, or stdin
    # We'll try passing as argument with --yolo
    RESULT=$(gemini "$INSTRUCTIONS" --yolo)
  else
    echo "Unknown agent: $AGENT"
    exit 1
  fi

  echo "$RESULT"

  if [[ "$RESULT" == *"<promise>$COMPLETION_PROMISE</promise>"* ]]; then
    echo "✅ Loop Completed Successfully!"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/^active: true/active: false/" "$STATE_FILE"
    else
        sed -i "s/^active: true/active: false/" "$STATE_FILE"
    fi
    exit 0
  fi
  
  CURRENT_ACTIVE=$(grep "active: " "$STATE_FILE" | awk '{print $2}')
  if [[ "$CURRENT_ACTIVE" == "false" ]]; then
    echo "🛑 Loop Cancelled externally."
    exit 1
  fi
done

echo "⚠️ Max iterations reached."
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^active: true/active: false/" "$STATE_FILE"
else
    sed -i "s/^active: true/active: false/" "$STATE_FILE"
fi
exit 0