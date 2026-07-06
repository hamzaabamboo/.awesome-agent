#!/usr/bin/env bash
set -euo pipefail

OUT="${1:?usage: isolate_user_messages.sh <out_dir>}"
mkdir -p "$OUT"

jq -r '.text' "$HOME/.codex/history.jsonl" > "$OUT/codex_user.txt"

: > "$OUT/claude_user.txt"
find "$HOME/.claude/projects" -type f -name '*.jsonl' -print0 \
  | xargs -0 jq -rc '
      select(.type=="user" and .message.role=="user" and (.isMeta|not))
      | .message.content
      | (if type=="string" then . else (map(select(.type?=="text")|.text)|join("\n")) end)
      | select(type=="string" and length>0)
      | select((startswith("<local-command")|not) and (startswith("<command-")|not) and (startswith("Caveat:")|not))
    ' >> "$OUT/claude_user.txt"

mkdir -p "$OUT/chunks"
rm -f "$OUT/chunks/"* 2>/dev/null || true
split -a 3 -l 8000 "$OUT/codex_user.txt" "$OUT/chunks/codex_"
split -a 3 -l 8000 "$OUT/claude_user.txt" "$OUT/chunks/claude_"

wc -l "$OUT/codex_user.txt" "$OUT/claude_user.txt"
echo "chunks: $(ls "$OUT/chunks" | wc -l) in $OUT/chunks"
