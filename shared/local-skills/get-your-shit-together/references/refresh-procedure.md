# Refresh Procedure — Re-Mine Standing Demands

Use this to rebuild or update `user-demands.md` from the user's real history. The point is to read every message he sent, not to sample.

## Why a script is allowed here
The user's rule is "no scripts" for reading — meaning: never grep for a keyword and quit, never tally instead of read. `isolate_user_messages.sh` does NOT do that. It strips only your output and system wrappers and leaves every one of his verbatim messages. The reading and the demand-extraction are still done by agents reading every line. Isolation makes full reading possible; it does not replace it.

## Steps
1. Isolate his words and pre-chunk:
   ```
   scripts/isolate_user_messages.sh <workdir> [since_epoch]
   ```
   Omit `since_epoch` for all history. To refresh from the first use of a skill, resolve its earliest explicit invocation from the logs and pass that epoch. Produces source-specific JSONL, a chronologically merged `user_messages.jsonl`, readable `user_messages.txt`, and 100-message files under `<workdir>/chunks/`. Each record preserves source, timestamp, session, cwd when available, and exact text.

2. Create a durable refresh note before reading. Record cutoff derivation, source files, chunk assignments, and an append-only tranche ledger. After each chunk, append `{chunk, read fully, rules, strongest exact quotes, existing-note gaps}`. Never postpone note-taking until after all reading.

3. Read every chunk in full. Fan cheap readers across chunks when available. Each reader reads its assigned chunks end to end and returns standing demands: `{rule, category, verbatim quote, strength, source, timestamp, session}`. Include repeated corrections, pet peeves, and anything he says angrily. Exclude one-off task specifics unless they reveal a behavioral rule. The steering agent reads every tranche note and reopens raw chunks for any vague, unsupported, or conflicting extraction.

4. Merge and de-duplicate across readers. Combine paraphrases of the same rule, keep the strongest verbatim quotes, count frequency, set severity from intensity. Cluster by category. Order by severity (extreme first), then frequency.

5. Critic pass. Re-read the raw chunks whose tranche notes contain uncertainty, conflicts, or unusually few findings. Compare every extracted rule against the existing notes and identify omissions, stale rules, and rules the agent keeps violating.

6. Persist. Update `references/user-demands.md`, this skill, and `~/.awesome-agent/shared/core_profile.md` from the evidence. Keep the refresh note as the audit trail. Promote project-specific rules into that project's `AGENTS.md`/`CLAUDE.md`/docs.

## Sources
- `~/.codex/history.jsonl` — every Codex prompt (already user-only; no session mining needed for Codex).
- `~/.claude/projects/**/*.jsonl` — Claude transcripts; user turns are `type:"user"`, `role:"user"`, string content, `isMeta` absent.
