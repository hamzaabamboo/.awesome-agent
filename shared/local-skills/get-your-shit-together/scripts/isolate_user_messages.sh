#!/usr/bin/env bash
set -euo pipefail

OUT="${1:?usage: isolate_user_messages.sh <out_dir> [since_epoch]}"
SINCE_EPOCH="${2:-0}"
SINCE_ISO="$(date -u -r "$SINCE_EPOCH" '+%Y-%m-%dT%H:%M:%SZ')"

mkdir -p "$OUT"

jq -c --argjson since "$SINCE_EPOCH" '
  select(.ts >= $since)
  | {
      source: "codex",
      epoch: .ts,
      timestamp: (.ts | strftime("%Y-%m-%dT%H:%M:%SZ")),
      session_id,
      cwd: null,
      text
    }
' "$HOME/.codex/history.jsonl" > "$OUT/codex_user.jsonl"

find "$HOME/.claude/projects" -type f -name '*.jsonl' ! -path '*/subagents/*' -print0 \
  | xargs -0 jq -c --arg since "$SINCE_ISO" '
      select(
        .type == "user"
        and .message.role == "user"
        and (.isMeta | not)
        and (.isCompactSummary // false | not)
        and (.promptSource // "") != "system"
        and (.timestamp // "") >= $since
      )
      | .message.content as $content
      | (
          if ($content | type) == "string"
          then $content
          else ($content | map(select(.type? == "text") | .text) | join("\n"))
          end
        ) as $text
      | select(
          ($text | type) == "string"
          and ($text | length) > 0
          and ($text | startswith("<local-command") | not)
          and ($text | startswith("<command-") | not)
          and ($text | startswith("<task-notification>") | not)
          and ($text | startswith("<system-reminder>") | not)
          and ($text | startswith("[Request interrupted") | not)
          and ($text | startswith("This session is being continued from a previous conversation") | not)
          and ($text | startswith("Caveat:") | not)
        )
      | {
          source: "claude",
          epoch: (.timestamp | sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601),
          timestamp,
          session_id: (.sessionId // .session_id),
          cwd: (.cwd // null),
          text: $text
        }
    ' > "$OUT/claude_user.jsonl"

jq -s -c 'sort_by(.epoch)[]' "$OUT/codex_user.jsonl" "$OUT/claude_user.jsonl" > "$OUT/user_messages.jsonl"
jq -r '"[\(.timestamp)] [\(.source)] [\(.session_id)]\n\(.text)\n"' "$OUT/user_messages.jsonl" > "$OUT/user_messages.txt"

mkdir -p "$OUT/chunks"
find "$OUT/chunks" -type f -delete
split -a 3 -l 100 "$OUT/user_messages.jsonl" "$OUT/chunks/messages_"

wc -l "$OUT/codex_user.jsonl" "$OUT/claude_user.jsonl" "$OUT/user_messages.jsonl"
echo "chunks: $(find "$OUT/chunks" -type f | wc -l | tr -d ' ') in $OUT/chunks"
