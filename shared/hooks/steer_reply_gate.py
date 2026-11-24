#!/usr/bin/env python3
"""PreToolUse gate: a message the user sends mid-turn gets a visible text reply before the next tool call.

Claude Code records a mid-turn user message as an `attachment` of type `queued_command` with
commandMode `prompt`. On 2026-11-24 a fansub session absorbed such messages into silent tool chains
for hours although the profile already required a reply. This hook reads the transcript tail and
denies the tool call while the newest steering message has no assistant text after it.
"""
import json
import os
import sys

TAIL_BYTES = 4 * 1024 * 1024
EXEMPT_TOOLS = {"mcp__t3-code__send_to_user"}

REASON = (
    "The user sent a message while you were working and you have not answered it. Before any tool call, "
    "write a visible reply: one line per message stating what it changes and what you are doing now. "
    "Answer exactly the item the user named; do not rebut it or switch to another object. If it adds or "
    "corrects a requirement, write that requirement into the task's canonical record before resuming."
)


def tail_lines(path):
    with open(path, "rb") as handle:
        handle.seek(0, os.SEEK_END)
        size = handle.tell()
        start = max(0, size - TAIL_BYTES)
        handle.seek(start)
        data = handle.read()
    lines = data.split(b"\n")
    if start:
        lines = lines[1:]
    return lines


def has_text(record):
    content = (record.get("message") or {}).get("content")
    if isinstance(content, str):
        return bool(content.strip())
    if not isinstance(content, list):
        return False
    return any(
        isinstance(block, dict) and block.get("type") == "text" and str(block.get("text", "")).strip()
        for block in content
    )


def is_steer(record):
    attachment = record.get("attachment")
    return (
        record.get("type") == "attachment"
        and isinstance(attachment, dict)
        and attachment.get("type") == "queued_command"
        and attachment.get("commandMode") == "prompt"
    )


def unanswered_steer(path):
    for raw in reversed(tail_lines(path)):
        if b'"assistant"' not in raw and b"queued_command" not in raw:
            continue
        try:
            record = json.loads(raw)
        except ValueError:
            continue
        if not isinstance(record, dict) or record.get("isSidechain"):
            continue
        if record.get("type") == "assistant" and has_text(record):
            return False
        if is_steer(record):
            return True
    return False


def main():
    try:
        payload = json.load(sys.stdin)
    except ValueError:
        sys.exit(0)
    if not isinstance(payload, dict) or payload.get("tool_name") in EXEMPT_TOOLS:
        sys.exit(0)
    path = payload.get("transcript_path")
    if not isinstance(path, str) or not path:
        sys.exit(0)
    try:
        blocked = unanswered_steer(path)
    except (OSError, TypeError, AttributeError):
        sys.exit(0)
    if blocked:
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": REASON,
            }
        }))


if __name__ == "__main__":
    main()
