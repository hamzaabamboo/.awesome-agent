#!/usr/bin/env python3
"""Shared hook gates for Claude Code, Codex (`prompt|pretool|posttool|stop`) and Antigravity (`agy`).

prompt    inject every installed skill the user names ($name or /name) and record it for the stop gate
pretool   remind once per mid-turn message (Claude queued_command) to reply first; load skills it names
posttool  tell the agent to split a code file an edit grew past MAX_LINES
stop      refuse to end a turn whose final message does not report each named skill
agy       Antigravity hooks.json adapter: PreInvocation injects skills and split notices, PostToolUse tracks
          file growth, Stop continues the loop while a named skill is unreported
"""
import json
import os
import re
import sys
from pathlib import Path

HOME = Path.home()
SKILL_ROOTS = [HOME / ".claude/skills", HOME / ".agents/skills", HOME / ".codex/skills"]
STATE_DIR = Path(os.environ.get("AGENT_GATES_STATE", HOME / ".local/state/agent-gates"))
TAIL_BYTES = 4 * 1024 * 1024
INJECT_BYTES = 45000
MAX_LINES = 500
CODE_EXT = {
    ".py", ".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs", ".sh", ".bash", ".go", ".rs", ".rb", ".swift",
    ".kt", ".java", ".vue", ".svelte", ".c", ".cc", ".cpp", ".h", ".hpp", ".cs", ".php", ".lua", ".scala",
}
SKIP_PARTS = {"node_modules", "dist", "build", "vendor", ".venv", "venv", "__pycache__", ".next", "generated"}
SKILL_TOKEN = re.compile(r"(?:^|[\s(\[{\"'])[$/]([a-z][a-z0-9:_-]{1,63})(?=$|[\s)\]}\"'`.,;:!?])", re.MULTILINE)
EXPANDED = re.compile(r"<command-name>/([a-z0-9:_-]+)</command-name>")
NOT_USER = re.compile(r"\s*(?:Delegated task \S+ \(|<task-notification)")
PATCH_PATH = re.compile(r"^\*\*\* (?:Add|Update) File: (.+)$", re.MULTILINE)


def skill_file(name):
    for root in SKILL_ROOTS:
        path = root / name / "SKILL.md"
        if path.is_file():
            return path
    return None


def named_skills(text):
    if not isinstance(text, str):
        return []
    found = []
    for name in SKILL_TOKEN.findall(text):
        if name not in found and skill_file(name):
            found.append(name)
    return found


def load_state(session):
    try:
        return json.loads((STATE_DIR / f"{session}.json").read_text())
    except (OSError, ValueError):
        return {}


def save_state(session, state):
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    (STATE_DIR / f"{session}.json").write_text(json.dumps(state))


def skill_context(names):
    parts, size = [], 0
    for name in names:
        path = skill_file(name)
        body = path.read_text(errors="replace")
        if size + len(body) > INJECT_BYTES:
            parts.append(f"## Skill `{name}`\nRead {path} completely now; it was too large to inline.")
            continue
        size += len(body)
        parts.append(f"## Skill `{name}` (base directory: {path.parent})\n\n{body}")
    header = (
        "The user named these skills: " + ", ".join(names) + ". Each is a mandatory request. Execute every "
        "required step of each skill's procedure now, before other work. Your final message must report each "
        "skill by name with the steps executed and any unmet gate."
    )
    return header + "\n\n" + "\n\n".join(parts)


def emit(obj):
    print(json.dumps(obj))


def on_prompt(payload, state):
    text = payload.get("prompt")
    if isinstance(text, str) and NOT_USER.match(text):
        return
    expanded = set(EXPANDED.findall(text or ""))
    leading = re.match(r"\s*/([a-z0-9:_-]+)", text or "")
    if leading:
        expanded.add(leading.group(1))
    names = named_skills(text)
    state["turn_skills"] = names
    pending = [name for name in names if name not in expanded]
    if pending:
        emit({"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": skill_context(pending)}})


def tail_records(path, marker):
    with open(path, "rb") as handle:
        handle.seek(0, os.SEEK_END)
        size = handle.tell()
        start = max(0, size - TAIL_BYTES)
        handle.seek(start)
        lines = handle.read().split(b"\n")
    for raw in reversed(lines[1:] if start else lines):
        markers = marker if isinstance(marker, tuple) else (marker,)
        if not any(m in raw for m in markers):
            continue
        try:
            record = json.loads(raw)
        except ValueError:
            continue
        if isinstance(record, dict):
            yield record


def has_text(record):
    content = (record.get("message") or {}).get("content")
    return isinstance(content, list) and any(
        isinstance(b, dict) and b.get("type") == "text" and str(b.get("text", "")).strip() for b in content
    )


def newest_steer(path):
    for record in tail_records(path, (b"queued_command", b'"assistant"')):
        if record.get("type") == "assistant" and not record.get("isSidechain") and has_text(record):
            return None, None
        attachment = record.get("attachment")
        if (
            record.get("type") == "attachment"
            and isinstance(attachment, dict)
            and attachment.get("type") == "queued_command"
            and attachment.get("commandMode") == "prompt"
            and not record.get("isSidechain")
        ):
            prompt = attachment.get("prompt")
            text = prompt if isinstance(prompt, str) else json.dumps(prompt)
            if NOT_USER.match(text):
                continue
            return record.get("uuid") or attachment.get("source_uuid") or text, text
    return None, None


def on_pretool(payload, state):
    path = payload.get("transcript_path")
    if not isinstance(path, str) or not os.path.isfile(path):
        return
    key, text = newest_steer(path)
    if not key or key in state.get("reminded", []):
        return
    state["reminded"] = (state.get("reminded", []) + [key])[-200:]
    reason = (
        "The user sent a message mid-turn. Answer it now in visible reply text before any tool call: start with "
        "'YES CHEF', then what it changes and what you do next, about exactly the item named. Thinking is "
        "invisible to the user; an answer written only in thinking is no answer. If it adds or corrects a "
        "requirement, record it in the task's canonical record. Then retry; this reminder fires once per message."
    )
    names = named_skills(text)
    if names:
        state["turn_skills"] = list(dict.fromkeys(state.get("turn_skills", []) + names))
        reason += "\n\n" + skill_context(names)
    emit({"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": reason}})


def edited_paths(payload):
    tool_input = payload.get("tool_input")
    paths = []
    if isinstance(tool_input, dict):
        for key in ("file_path", "path", "notebook_path"):
            if isinstance(tool_input.get(key), str):
                paths.append(tool_input[key])
        blob = json.dumps(tool_input)
    else:
        blob = str(tool_input or "")
    paths += [p.strip() for p in PATCH_PATH.findall(blob.replace("\\n", "\n"))]
    cwd = payload.get("cwd") or os.getcwd()
    return [Path(cwd, p) for p in dict.fromkeys(paths)]


def oversized_files(paths, state):
    sizes = state.setdefault("lines", {})
    oversized = []
    for path in paths:
        if path.suffix not in CODE_EXT or SKIP_PARTS & set(path.parts) or ".min." in path.name:
            continue
        try:
            count = sum(1 for _ in path.open(errors="replace"))
        except OSError:
            continue
        before = sizes.get(str(path))
        sizes[str(path)] = count
        if count > MAX_LINES and (before is None or count > before):
            oversized.append(f"{path} ({count} lines)")
    return oversized


def split_message(oversized):
    return (
        f"Code file over {MAX_LINES} lines and growing: " + ", ".join(oversized) + ". Before adding more, split it "
        "by responsibility into cohesive modules with explicit imports, remove duplication, keep behavior "
        "identical, and run the project's existing checks. Code that is reused, re-run or committed is "
        "production code: structure it properly, cache expensive repeated work, follow the language's best practices."
    )


def unreported_message(missing):
    return (
        "The user named these skills this turn and your final message does not report them: " + ", ".join(missing)
        + ". Execute each one's remaining required steps now, then rewrite the final message reporting each "
        "skill by name with the steps executed and any unmet gate."
    )


def on_posttool(payload, state):
    oversized = oversized_files(edited_paths(payload), state)
    if oversized:
        emit({"decision": "block", "reason": split_message(oversized)})


def last_assistant_text(path):
    if not isinstance(path, str) or not os.path.isfile(path):
        return None
    for record in tail_records(path, b'"assistant"'):
        content = (record.get("message") or {}).get("content")
        if record.get("type") == "assistant" and isinstance(content, list):
            text = "\n".join(b.get("text", "") for b in content if isinstance(b, dict) and b.get("type") == "text")
            if text.strip():
                return text
    return None


def on_stop(payload, state):
    if payload.get("stop_hook_active"):
        return
    names = state.get("turn_skills") or []
    message = payload.get("last_assistant_message")
    if not isinstance(message, str) or not message.strip():
        message = last_assistant_text(payload.get("transcript_path"))
    if not names or not isinstance(message, str):
        return
    missing = [name for name in names if name not in message]
    if missing:
        emit({"decision": "block", "reason": unreported_message(missing)})
    else:
        state["turn_skills"] = []


def agy_paths(payload):
    args = (payload.get("toolCall") or {}).get("args") or {}
    paths = [
        value.strip().strip('"') for key, value in args.items()
        if isinstance(value, str) and ("File" in key or "Path" in key)
    ]
    cwd = payload.get("cwd") or os.getcwd()
    return [Path(cwd, p) for p in paths if p]


def agy_final_text(path):
    if not isinstance(path, str) or not os.path.isfile(path):
        return None
    for record in tail_records(path, b"PLANNER_RESPONSE"):
        if record.get("type") == "PLANNER_RESPONSE" and str(record.get("content", "")).strip():
            return record["content"]
    return None


def on_agy(payload, state):
    event = payload.get("hookEventName")
    if event == "PreInvocation":
        steps = []
        text = payload.get("lastUserInput")
        if isinstance(text, str) and text != state.get("agy_last_input"):
            state["agy_last_input"] = text
            state["turn_skills"] = named_skills(text)
            if state["turn_skills"]:
                steps.append(skill_context(state["turn_skills"]))
        if state.get("agy_split"):
            steps.append(split_message(state.pop("agy_split")))
        emit({"injectSteps": [{"systemMessage": {"systemMessage": step}} for step in steps]})
    elif event == "PostToolUse":
        oversized = oversized_files(agy_paths(payload), state)
        if oversized:
            state["agy_split"] = list(dict.fromkeys(state.get("agy_split", []) + oversized))
        emit({})
    elif event == "Stop":
        names = state.get("turn_skills") or []
        message = agy_final_text(payload.get("transcriptPath"))
        missing = [name for name in names if not message or name not in message]
        if missing and not payload.get("continuationActive"):
            emit({"decision": "continue", "reason": unreported_message(missing)})
        else:
            state["turn_skills"] = []
            emit({})
    else:
        emit({})


HANDLERS = {"prompt": on_prompt, "pretool": on_pretool, "posttool": on_posttool, "stop": on_stop, "agy": on_agy}


def main():
    handler = HANDLERS.get(sys.argv[1] if len(sys.argv) > 1 else "")
    try:
        payload = json.load(sys.stdin)
    except ValueError:
        return
    if not handler or not isinstance(payload, dict):
        return
    raw_session = payload.get("session_id") or payload.get("conversationId") or "default"
    session = re.sub(r"[^A-Za-z0-9_-]", "_", str(raw_session))[:128]
    state = load_state(session)
    try:
        handler(payload, state)
    except (OSError, TypeError, AttributeError, ValueError):
        return
    save_state(session, state)


if __name__ == "__main__":
    main()
