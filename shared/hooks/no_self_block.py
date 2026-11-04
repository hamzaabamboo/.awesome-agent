#!/usr/bin/env python3
"""Stop gate: a turn may not end on a self-imposed block, an answerable question, or unverified work.

In the Sep–Nov 2026 log audit, blocked (224), unverified (127) and question or offer (56)
endings were among the most common replies before 1,541 corrections (classes overlap; see
analysis/agent-log-pain-points/report-2026-11.md). Written rules already forbade them. This hook
re-checks the ending of the final message once and sends the agent back with one instruction.
The stop_hook_active flag guarantees at most one extra round, so the hook cannot loop.
"""
import json
import re
import sys

ENDING_CHARS = 400
QUOTED = re.compile(r"```.*?```|`[^`\n]*`|\"[^\"\n]*\"|“[^”\n]*”|‘[^’\n]*’", re.DOTALL)
NEGATION = re.compile(r"\b(nothing|none|no|not|never|0|zero)\b[^.\n]{0,20}$", re.IGNORECASE)
FOLLOWING_NONE = re.compile(r"\s*(none|nothing|no\b|n/a|0\b|zero\b|—|-\s*$)", re.IGNORECASE)

PATTERNS = [
    ("asks permission or offers options", False, re.compile(
        r"\b(should i|shall i|may i)\b[^\n?]*\?"
        r"|\b(want me to|do you want me to|would you like( me)? to)\b"
        r"|\bwhich (one|option)\b[^\n?]*\?"
        r"|\bsay if you want\b|\bsay so and i(?:'ll| will)\b|\blet me know if you(?:'d| would)? (?:want|like)\b",
        re.IGNORECASE)),
    ("declares itself blocked or waiting on the user", True, re.compile(
        r"(?:^|[\n.!?]\s*)blocked\s*[:\-—]|(?<!was )(?<!were )\bstill blocked\b"
        r"|\b(?:i am|i'm|we are|we're)(?: still)? blocked\b|\bblocked (?:until|on|by) (?:you|your)\b"
        r"|\bwaiting (on|for) you\b|\bonce you\b[^.\n]*\bi(?:'ll| will)\b|\bneeds? your (approval|input|action)\b",
        re.IGNORECASE)),
    ("reports work as unverified", True, re.compile(
        r"\b(?:is|are|remains?|still|left|marked|stays?)\s+(?:unverified|untested)\b"
        r"|(?:^|[\n.!?]\s*|[-•]\s*)(?:unverified|untested)\s*:"
        r"|\b(?:unverified|untested)\s*[.:]?\s*$|\bnot (?:yet )?(?:verified|tested)\s*(?:[.;:!,)]|$)"
        r"|\bno checks (were )?run\b|\bpass with limitation\b",
        re.IGNORECASE)),
]

INSTRUCTION = (
    "Your final message {what}. Before ending: do every in-scope action you can perform yourself, "
    "including verification in the real runtime, then rewrite the final message with the results. "
    "Keep a blocker or question only if it truly needs the user (a physical device, a credential not "
    "on disk, a human approval off this machine, or a decision the request, repo and sensible defaults "
    "cannot settle); state it in one line naming the single user action. Do not ask permission for "
    "something the user already asked for in this session."
)


def last_assistant_text(transcript_path):
    if not isinstance(transcript_path, str) or not transcript_path:
        return ""
    text = ""
    try:
        with open(transcript_path, encoding="utf-8") as handle:
            for line in handle:
                try:
                    record = json.loads(line)
                except ValueError:
                    continue
                if not isinstance(record, dict) or record.get("type") != "assistant":
                    continue
                content = (record.get("message") or {}).get("content") or []
                if not isinstance(content, list):
                    continue
                parts = [
                    block.get("text", "")
                    for block in content
                    if isinstance(block, dict) and block.get("type") == "text" and isinstance(block.get("text"), str)
                ]
                if any(part.strip() for part in parts):
                    text = "\n".join(parts)
    except (OSError, TypeError, ValueError, AttributeError):
        return ""
    return text


def matches(pattern, text, negatable):
    for match in pattern.finditer(text):
        start = match.start()
        while start < match.end() and not text[start].isalnum():
            start += 1
        sentence = re.split(r"[.!?\n]", text[:start])[-1]
        if not negatable or not (NEGATION.search(sentence) or FOLLOWING_NONE.match(text, match.end())):
            return True
    return False


def main():
    try:
        payload = json.load(sys.stdin)
    except ValueError:
        sys.exit(0)
    if not isinstance(payload, dict) or payload.get("stop_hook_active"):
        sys.exit(0)
    message = payload.get("last_assistant_message")
    if not isinstance(message, str) or not message.strip():
        message = last_assistant_text(payload.get("transcript_path"))
    ending = re.sub(r"[*_]+", "", QUOTED.sub(" ", message)).replace("\u2019", "'").replace("\u2018", "'")[-ENDING_CHARS:]
    hits = [label for label, negatable, pattern in PATTERNS if matches(pattern, ending, negatable)]
    if not hits:
        sys.exit(0)
    print(json.dumps({"decision": "block", "reason": INSTRUCTION.format(what=" and ".join(hits))}))


if __name__ == "__main__":
    main()
