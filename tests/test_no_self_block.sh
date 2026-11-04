#!/bin/bash

set -e

hook="shared/hooks/no_self_block.py"
failures=0

check() {
    local want="$1" payload="$2" got
    got="$(printf '%s' "$payload" | python3 "$hook" 2>/dev/null; echo "exit=$?")"
    case "$got" in
        *'"decision": "block"'*) got_kind=block ;;
        exit=0) got_kind=pass ;;
        *) got_kind=error ;;
    esac
    if [ "$got_kind" != "$want" ]; then
        echo "FAIL: want $want, got $got_kind: $payload"
        failures=$((failures + 1))
    fi
}

msg() { python3 -c 'import json,sys; print(json.dumps({"last_assistant_message": sys.argv[1]}))' "$1"; }

check block "$(msg "Still blocked: I can't fix the hair until you approve full-screen control.")"
check block "$(msg "Blocked: the approval prompt keeps timing out.")"
check block "$(msg "I'm still blocked until VRoid Studio is restarted.")"
check block "$(msg "The homepage change is not live yet. May I push and deploy the Three.js change?")"
check block "$(msg "Replaced the card layout. Browser result still unverified.")"
check block "$(msg "Older copy of the VRM is in use; say if you want the new one copied in.")"
check block "$(msg "Everything's deployed. Should I push the branch? It's ready.")"
check block "$(msg "Fixed. It's all verified now. Let me know if you want more. That's it.")"
check block "$(msg "Done. Want me to push it next")"
check block "$(msg "Typecheck passed. Browser behavior not verified.")"
check block "$(msg "Would you like to see the diff?")"
check block "$(msg "Two layouts are ready. Which one do you prefer?")"
check block "$(msg "The mobile path is untested.")"

check block "$(msg "The stash holds old notes. If you want it gone too, say so and I'll drop it.")"
check block "$(msg "Browser check not run. Blocked: need you to approve full-screen control.")"
check block "$(msg "The suite needs a database that is not on disk. Blocked: need DB credentials.")"
check block "$(msg "No errors found, want me to push it?")"
check block "$(msg "Done: tests pass. Nothing else changed, would you like me to deploy?")"
check block "$(msg "Built it. **Blocked**: need you to approve full-screen control.")"
check block "$(msg "- Status: **blocked** until you approve.")"
check block "$(msg "**Unverified:** browser behavior.")"
check block "$(msg "Built it. I’m blocked: need you to approve full-screen control.")"
check block "$(msg "Done. Let me know if you’d like me to push.")"
check block "$(msg "Done. Once you approve, I’ll deploy.")"
check pass "$(msg "Pushed main. 363 tests pass.")"
check pass "$(msg "Fixed the bug. Tests: 12 passed. Unverified: 0.")"
check pass "$(msg "Done. Verified in browser. Unverified: —")"
check pass "$(msg "Merged the refactor. Coverage: 41 tested, 0 untested.")"
check pass "$(msg "Fixed the env var and redeployed. The deploy was still blocked on the missing key earlier; it is green now.")"
check pass "$(msg "**Done.** Deployed and verified in the headed browser. Unverified: none.")"
check pass "$(msg "Added a guard so tokens that are not verified are rejected. 12 tests pass.")"
check pass "$(msg "Shipped the fix. Blocked: none. Verified in headed browser.")"
check pass "$(msg "Done. Tests pass. Say so if anything looks off.")"
check pass "$(msg "I fixed the retry logic and the unverified path is now covered, verified by the test.")"
check pass "$(msg "All checks pass. Nothing is unverified.")"
check pass "$(msg "This fixes the bug that was blocked earlier. Blocked PRs list is empty.")"
check pass "$(msg 'Four replies were blocked: "blocked until you approve", "May I push and deploy?". Clean finishes pass.')"
check pass "$(msg 'The hook rejects `Should I deploy it?` endings; the PR merge was blocked by CI once, fixed and green now.')"
check pass "$(printf '%s %s' "$(python3 -c 'print("Should I deploy it? " + "Then I deployed and verified it in the browser. " * 12)')" '' | python3 -c 'import json,sys; print(json.dumps({"last_assistant_message": sys.stdin.read()}))')"
check pass '{"stop_hook_active":true,"last_assistant_message":"Blocked: waiting on you."}'
check pass '[]'
check pass 'not json'
check pass '{}'
check pass '{"last_assistant_message":123}'
check pass '{"last_assistant_message":null,"transcript_path":null}'
check pass '{"transcript_path":"/nonexistent/file.jsonl"}'

transcript="$(mktemp)"
printf '%s\n' '{"type":"assistant","message":{"content":[{"type":"text","text":"Should I deploy it?"}]}}' > "$transcript"
check block "{\"transcript_path\":\"$transcript\"}"
rm -f "$transcript"

if [ "$failures" -ne 0 ]; then
    echo "FAIL: $failures no_self_block case(s)"
    exit 1
fi
echo "PASS: no_self_block hook"
