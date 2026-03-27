#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ASSETS_DIR="$SKILL_DIR/assets"

TARGET_DIR="${1:-}"
PROJECT_GOAL="${2:-}"
WORK_SCOPE="${3:-}"
AGENT_CLI="${4:-${RALPH_CLI:-codex}}"
AGENT_MODEL="${5:-${RALPH_MODEL:-gpt-5}}"

if [ -z "$TARGET_DIR" ] || [ -z "$PROJECT_GOAL" ]; then
    echo "Usage: $0 <target-dir> <project-goal> [work-scope] [agent-cli] [agent-model]"
    exit 1
fi

mkdir -p "$TARGET_DIR/specs"

copy_asset() {
    local src="$1"
    local dest="$2"
    cp "$src" "$dest"
}

render_asset() {
    local src="$1"
    local dest="$2"
    local replace_scope="${3:-yes}"
    python3 - "$src" "$dest" "$PROJECT_GOAL" "$WORK_SCOPE" "$AGENT_CLI" "$AGENT_MODEL" "$replace_scope" <<'PY'
from pathlib import Path
import sys
src = Path(sys.argv[1])
dest = Path(sys.argv[2])
project_goal = sys.argv[3]
work_scope = sys.argv[4] if len(sys.argv) > 4 else ""
agent_cli = sys.argv[5] if len(sys.argv) > 5 else "codex"
agent_model = sys.argv[6] if len(sys.argv) > 6 else "gpt-5"
replace_scope = sys.argv[7] if len(sys.argv) > 7 else "yes"
text = src.read_text()
text = text.replace("__PROJECT_GOAL__", project_goal)
if replace_scope == "yes":
    text = text.replace("__WORK_SCOPE__", work_scope or project_goal)
text = text.replace("__AGENT_CLI__", agent_cli)
text = text.replace("__AGENT_MODEL__", agent_model)
dest.write_text(text)
PY
}

copy_asset "$ASSETS_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"
copy_asset "$ASSETS_DIR/IMPLEMENTATION_PLAN.md" "$TARGET_DIR/IMPLEMENTATION_PLAN.md"
render_asset "$ASSETS_DIR/PROMPT_plan.md" "$TARGET_DIR/PROMPT_plan.md"
copy_asset "$ASSETS_DIR/PROMPT_build.md" "$TARGET_DIR/PROMPT_build.md"
copy_asset "$ASSETS_DIR/PROMPT_specs.md" "$TARGET_DIR/PROMPT_specs.md"
copy_asset "$ASSETS_DIR/PROMPT_reverse_engineer_specs.md" "$TARGET_DIR/PROMPT_reverse_engineer_specs.md"
render_asset "$ASSETS_DIR/PROMPT_plan_work.md" "$TARGET_DIR/PROMPT_plan_work.md"
render_asset "$ASSETS_DIR/loop.sh" "$TARGET_DIR/loop.sh" "no"
render_asset "$ASSETS_DIR/loop_streamed.sh" "$TARGET_DIR/loop_streamed.sh" "no"
copy_asset "$ASSETS_DIR/parse_stream.js" "$TARGET_DIR/parse_stream.js"

chmod +x "$TARGET_DIR/loop.sh" "$TARGET_DIR/loop_streamed.sh" "$TARGET_DIR/parse_stream.js"

echo "Scaffolded Ralph playbook files into $TARGET_DIR"
echo "Only durable Ralph artifacts were written."
