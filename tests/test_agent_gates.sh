#!/bin/bash

set -e

hook="$PWD/shared/hooks/agent_gates.py"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
export HOME="$work/home"
export AGENT_GATES_STATE="$work/state"
mkdir -p "$HOME/.claude/skills/demo-skill" "$HOME/.agents/skills/other-skill" "$work/src"
printf -- '---\nname: demo-skill\n---\nDEMO BODY\n' > "$HOME/.claude/skills/demo-skill/SKILL.md"
printf -- '---\nname: other-skill\n---\nOTHER BODY\n' > "$HOME/.agents/skills/other-skill/SKILL.md"
failures=0

run() { printf '%s' "$2" | python3 -B "$hook" "$1" 2>/dev/null || true; }
expect() {
    local name="$1" want="$2" got="$3"
    case "$want" in
        empty) [ -z "$got" ] && return ;;
        *) case "$got" in *"$want"*) return ;; esac ;;
    esac
    echo "FAIL: $name want '$want', got '${got:0:160}'"
    failures=$((failures + 1))
}
json() { python3 -c 'import json,sys; print(json.dumps(dict(zip(sys.argv[1::2], sys.argv[2::2]))))' "$@"; }

expect prompt_injects_dollar "DEMO BODY" "$(run prompt "$(json session_id s1 prompt 'fix it $demo-skill now')")"
expect prompt_injects_agents_root "OTHER BODY" "$(run prompt "$(json session_id s1b prompt 'use /other-skill please')")"
expect prompt_skips_unknown empty "$(run prompt "$(json session_id s2 prompt 'cost is $5 and see /usr/bin')")"
expect prompt_skips_code_mention empty "$(run prompt "$(json session_id s4 prompt 'the `$demo-skill` cap is too high')")"
expect prompt_skips_delegated_result empty "$(run prompt "$(json session_id s5 prompt 'Delegated task node:x (Test) in child thread t [completed]: use $demo-skill')")"
expect prompt_skips_task_notification empty "$(run prompt "$(json session_id s6 prompt '<task-notification>done $demo-skill</task-notification>')")"
expect prompt_skips_leading_slash empty "$(run prompt "$(json session_id s3 prompt '/demo-skill go')")"
expect stop_blocks_unreported '"decision": "block"' "$(run stop "$(json session_id s1 last_assistant_message 'Done.')")"
expect stop_passes_reported empty "$(run stop "$(json session_id s1 last_assistant_message 'demo-skill: steps 3/3 done.')")"
expect stop_cleared_after_pass empty "$(run stop "$(json session_id s1 last_assistant_message 'Done.')")"
expect stop_no_skills empty "$(run stop "$(json session_id s9 last_assistant_message 'Done.')")"
expect stop_hook_active empty "$(run stop '{"session_id":"s3","stop_hook_active":true,"last_assistant_message":"x"}')"

transcript="$work/t.jsonl"
tp() { python3 -c 'import json,sys; d={"session_id":"p1","transcript_path":sys.argv[1]}; d.update(dict(zip(sys.argv[2::2], sys.argv[3::2]))); print(json.dumps(d))' "$transcript" "$@"; }
printf '%s\n' '{"type":"user","message":{"role":"user","content":"go"}}' > "$transcript"
expect pretool_no_steer empty "$(run pretool "$(tp)")"
printf '%s\n' '{"type":"attachment","uuid":"u1","attachment":{"type":"queued_command","commandMode":"prompt","prompt":"wrong box /demo-skill"}}' >> "$transcript"
first="$(run pretool "$(tp)")"
expect pretool_denies_once '"permissionDecision": "deny"' "$first"
expect pretool_loads_steer_skill "DEMO BODY" "$first"
expect pretool_allows_retry empty "$(run pretool "$(tp)")"
expect stop_tracks_steer_skill '"decision": "block"' "$(run stop "$(tp last_assistant_message Done.)")"
printf '%s\n' '{"type":"attachment","uuid":"n1","attachment":{"type":"queued_command","commandMode":"task-notification","prompt":"<task-notification/>"}}' >> "$transcript"
expect pretool_ignores_notification empty "$(run pretool "$(tp)")"
printf '%s\n' '{"type":"attachment","uuid":"d1","attachment":{"type":"queued_command","commandMode":"prompt","prompt":"Delegated task node:x (Test) in child thread t [completed]: done"}}' >> "$transcript"
expect pretool_ignores_delegated_result empty "$(run pretool "$(tp)")"
printf '%s\n' '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"On it."}]}}' >> "$transcript"
printf '%s\n' '{"type":"attachment","uuid":"u3","attachment":{"type":"queued_command","commandMode":"prompt","prompt":"third"}}' >> "$transcript"
printf '%s\n' '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Answered third."}]}}' >> "$transcript"
expect pretool_answered_steer empty "$(run pretool "$(tp)")"
printf '%s\n' '{"type":"attachment","uuid":"u4","attachment":{"type":"queued_command","commandMode":"prompt","prompt":"fourth"}}' >> "$transcript"
expect pretool_new_steer '"permissionDecision": "deny"' "$(run pretool "$(tp)")"

python3 -c 'print("x = 1\n" * 499, end="")' > "$work/src/small.py"
python3 -c 'print("x = 1\n" * 501, end="")' > "$work/src/big.py"
python3 -c 'print("x\n" * 900, end="")' > "$work/src/data.json"
mkdir -p "$work/src/node_modules"
python3 -c 'print("x\n" * 900, end="")' > "$work/src/node_modules/lib.js"
post() { run posttool "{\"session_id\":\"f1\",\"cwd\":\"$work/src\",\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$1\"}}"; }
expect post_small empty "$(post small.py)"
expect post_big '"decision": "block"' "$(post big.py)"
expect post_big_unchanged empty "$(post big.py)"
echo 'y = 2' >> "$work/src/big.py"
expect post_big_grew '"decision": "block"' "$(post big.py)"
expect post_data empty "$(post data.json)"
expect post_vendor empty "$(post node_modules/lib.js)"
patch_input="$(python3 -c 'import json; print(json.dumps({"session_id":"f2","cwd":"'"$work/src"'","tool_name":"apply_patch","tool_input":{"input":"*** Begin Patch\n*** Update File: big.py\n@@\n*** End Patch"}}))')"
expect post_codex_patch '"decision": "block"' "$(run posttool "$patch_input")"

agy() { python3 -c 'import json,sys; d={"conversationId":"g1","cwd":sys.argv[1],"transcriptPath":sys.argv[2]}; d.update(json.loads(sys.argv[3])); print(json.dumps(d))' "$work/src" "$work/agy.jsonl" "$1"; }
printf '%s\n' '{"type":"USER_INPUT","content":"go"}' '{"type":"PLANNER_RESPONSE","content":"Done."}' > "$work/agy.jsonl"
expect agy_inject_skill '"systemMessage": "The user named these skills: demo-skill' "$(run agy "$(agy '{"hookEventName":"PreInvocation","lastUserInput":"fix it $demo-skill"}')")"
expect agy_same_input_no_reinject '{"injectSteps": []}' "$(run agy "$(agy '{"hookEventName":"PreInvocation","lastUserInput":"fix it $demo-skill"}')")"
expect agy_stop_continue '"decision": "continue"' "$(run agy "$(agy '{"hookEventName":"Stop"}')")"
expect agy_stop_loop_guard '{}' "$(run agy "$(agy '{"hookEventName":"Stop","continuationActive":true}')")"
expect agy_post_big '{}' "$(run agy "$(agy '{"hookEventName":"PostToolUse","toolCall":{"name":"write_to_file","args":{"TargetFile":"\"big.py\""}}}')")"
expect agy_split_notice 'over 500 lines' "$(run agy "$(agy '{"hookEventName":"PreInvocation","lastUserInput":"next"}')")"
printf '%s\n' '{"type":"PLANNER_RESPONSE","content":"demo-skill: 2/2 steps done."}' >> "$work/agy.jsonl"
expect agy_stop_reported '{}' "$(run agy "$(agy '{"hookEventName":"PreInvocation","lastUserInput":"use /demo-skill"}' >/dev/null; run agy "$(agy '{"hookEventName":"Stop"}')")")"

expect bad_json empty "$(run stop 'not json')"
expect bad_mode empty "$(run nope '{}')"

if [ "$failures" -gt 0 ]; then
    echo "FAIL: $failures agent_gates case(s)"
    exit 1
fi
echo "PASS: agent_gates hook"
