#!/bin/bash

set -e

hook="shared/hooks/steer_reply_gate.py"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
failures=0

user() { printf '{"type":"user","message":{"role":"user","content":"%s"}}\n' "$1"; }
steer() { printf '{"type":"attachment","attachment":{"type":"queued_command","commandMode":"%s","prompt":"%s"}}\n' "$1" "$2"; }
text() { printf '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"%s"}]}}\n' "$1"; }
think() { printf '{"type":"assistant","message":{"role":"assistant","content":[{"type":"thinking","thinking":"plan"}]}}\n'; }
tool() { printf '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"t","name":"Bash","input":{}}]}}\n'; }
result() { printf '{"type":"user","message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"t","content":"ok"}]}}\n'; }
side() { printf '{"type":"assistant","isSidechain":true,"message":{"role":"assistant","content":[{"type":"text","text":"child"}]}}\n'; }

check() {
    local want="$1" name="$2" tool_name="${3:-Bash}" got
    got="$(printf '{"tool_name":"%s","transcript_path":"%s"}' "$tool_name" "$work/$name.jsonl" | python3 -B "$hook" 2>/dev/null; echo "exit=$?")"
    case "$got" in
        *'"permissionDecision": "deny"'*) got=deny ;;
        exit=0) got=allow ;;
        *) got=error ;;
    esac
    if [ "$got" != "$want" ]; then
        echo "FAIL: $name want $want, got $got"
        failures=$((failures + 1))
    fi
}

{ user "fix it"; tool; result; } > "$work/turn_start.jsonl"
{ user "fix it"; tool; result; steer prompt "wrong box"; } > "$work/steer_unanswered.jsonl"
{ user "fix it"; tool; result; steer prompt "wrong box"; think; } > "$work/steer_thinking_only.jsonl"
{ user "fix it"; tool; result; steer prompt "wrong box"; side; } > "$work/steer_sidechain_text.jsonl"
{ user "fix it"; tool; result; steer prompt "wrong box"; text "Fixing the name box now."; } > "$work/steer_answered.jsonl"
{ user "fix it"; steer prompt "a"; text "On it."; tool; result; steer prompt "b"; } > "$work/second_steer.jsonl"
{ user "fix it"; tool; result; steer task-notification "<task-notification>done</task-notification>"; } > "$work/notification.jsonl"
{ user "fix it"; steer prompt "wrong box"; printf 'not json\n'; } > "$work/corrupt_tail.jsonl"

check allow turn_start
check deny steer_unanswered
check deny steer_thinking_only
check deny steer_sidechain_text
check allow steer_answered
check deny second_steer
check allow notification
check deny corrupt_tail
check allow steer_unanswered mcp__t3-code__send_to_user
check allow missing_file

if [ "$failures" -gt 0 ]; then
    echo "FAIL: $failures steer_reply_gate case(s)"
    exit 1
fi
echo "PASS: steer_reply_gate hook"
