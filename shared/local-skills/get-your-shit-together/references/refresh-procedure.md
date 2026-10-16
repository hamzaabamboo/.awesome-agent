# Refresh Procedure — Re-Mine Standing Demands

Use this to rebuild or update `user-demands.md` from the user's real history. The point is to read every message he sent, not to sample.

This procedure extracts standing requirements. It does not audit agent execution. For a failure/process audit, use `unfuck-yourself` and inspect the surrounding skill loads, actions, tool results, corrections, and completion claims in raw records; a user-message-only extraction cannot establish what the agent did. Historical reading requires explicit authorization and exact project scope before extraction.

## Why a script is allowed here
The user's rule is "no scripts" for reading — meaning: never grep for a keyword and quit, never tally instead of read. `isolate_user_messages.sh` does NOT do that. It strips only your output and system wrappers and leaves every one of his verbatim messages. The reading and the demand-extraction are still done by agents reading every line. Isolation makes full reading possible; it does not replace it.

## Steps
1. Isolate his words and pre-chunk:
   ```
   scripts/isolate_user_messages.sh <workdir> <project_root> [since_epoch]
   ```
   `project_root` is mandatory and bounds both Codex and Claude extraction to that project. Omit `since_epoch` for all history in that project. To refresh from the first use of a skill, resolve its earliest explicit invocation from the project-scoped logs and pass that epoch. Produces source-specific JSONL, a chronologically merged `user_messages.jsonl`, readable `user_messages.txt`, and 100-message files under `<workdir>/chunks/`. Each record preserves source, timestamp, session, cwd when available, and exact text.

2. Update the canonical task record before reading. Record scope, cutoff derivation, source locators, assignments, coverage, neutral requirements, and evidence gaps. Keep raw messages and private session identifiers out of project files. If temporary extraction is needed, keep it outside tracked artifacts, redact sensitive data before output, and delete it immediately after use. Maintain compact coverage in place; do not create another live record or an append-only transcript.

3. Read every selected chunk in full. Fan cheap readers across chunks when available. Each reader returns neutral requirements, categories, source locators, coverage, and evidence gaps. Include repeated corrections. Exclude one-off task specifics unless they reveal a reusable requirement. The steering agent reopens the decisive raw records before accepting findings; summaries and model agreement are not evidence.

4. Reconcile requirements chronologically before de-duplicating. Later explicit corrections supersede conflicting earlier instructions; repetition does not reactivate a superseded rule. Keep neutral reusable requirements and evidence locators, not verbatim quotes or frequency rankings in place of causal analysis.

5. Critic pass. Re-read the raw chunks whose tranche notes contain uncertainty, conflicts, or unusually few findings. Compare every extracted rule against the existing notes and identify omissions, stale rules, and rules the agent keeps violating.

6. Persist only authorized, supported rule changes in the narrowest responsible source. Link durable findings from the canonical task record and retain verification gaps. Do not automatically change every instruction file or copy raw messages into a skill, note, or project rule.

## Sources
- `~/.codex/state_5.sqlite` plus `~/.codex/history.jsonl` — the indexed thread table supplies the mandatory current-project session-id filter without scanning unrelated rollout files; history supplies user-only prompts for those IDs.
- The encoded current-project directory under `~/.claude/projects/` — never every Claude project; user turns are `type:"user"`, `role:"user"`, string content, `isMeta` absent.
