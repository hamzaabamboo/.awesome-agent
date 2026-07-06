# Refresh Procedure — Re-Mine Standing Demands

Use this to rebuild or update `user-demands.md` from the user's real history. The point is to read every message he sent, not to sample.

## Why a script is allowed here
The user's rule is "no scripts" for reading — meaning: never grep for a keyword and quit, never tally instead of read. `isolate_user_messages.sh` does NOT do that. It strips only your output and system wrappers and leaves every one of his verbatim messages. The reading and the demand-extraction are still done by agents reading every line. Isolation makes full reading possible; it does not replace it.

## Steps
1. Isolate his words and pre-chunk:
   ```
   scripts/isolate_user_messages.sh <workdir>
   ```
   Produces `<workdir>/codex_user.txt` (all Codex prompts), `<workdir>/claude_user.txt` (all Claude user turns), and `<workdir>/chunks/` (8000-line pieces).

2. Read every chunk in full. Fan one reader per chunk (Workflow `parallel`, or subagents). Each reader reads its chunk end to end and extracts standing demands: `{rule, category, verbatim quote, strength}`. Include repeated corrections, pet peeves, and anything he says angrily. Exclude one-off task specifics unless they reveal a behavioral rule.

3. Merge and de-duplicate across readers. Combine paraphrases of the same rule, keep the strongest verbatim quotes, count frequency, set severity from intensity. Cluster by category. Order by severity (extreme first), then frequency.

4. Critic pass. Re-read a handful of raw chunks in full and look for any standing demand missing from the merged list. Add what is missing.

5. Persist. Append new/updated demands to `references/user-demands.md`. Promote cross-agent rules into `~/.awesome-agent/shared/AGENTS.md`; project-specific ones into that project's `AGENTS.md`/`CLAUDE.md`/docs.

## Sources
- `~/.codex/history.jsonl` — every Codex prompt (already user-only; no session mining needed for Codex).
- `~/.claude/projects/**/*.jsonl` — Claude transcripts; user turns are `type:"user"`, `role:"user"`, string content, `isMeta` absent.
