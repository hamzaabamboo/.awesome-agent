---
name: get-your-shit-together
description: Re-ground in the user's real standing demands when you have drifted, hallucinated, ignored instructions, or produced shit output. MUST fire whenever the user says "get your shit together", "GYST", "read everything", "revisit all your instructions", "you're ignoring my instructions", "read every message I sent", "stop being shit", "stay true", or shows frustration/aggression; whenever un-dumb-yourself runs before or after compression; and whenever you catch yourself about to sample, tally, guess, or call something impossible. Reads the full instruction and note stack, takes durable notes while reading every direct user message, names the violation, records an execution receipt, and does the real work.
---

# Get Your Shit Together

You drifted — ignored a standing rule, hallucinated, sampled instead of read, tallied instead of worked, or called something impossible. The user is a blunt expert who has typed these demands hundreds of times and is furious at being ignored. Re-ground by READING — never by measuring, sampling, or excusing — then do the real work. His aggression = you broke a rule. Don't get defensive, don't grovel. Reflect, fix instantly, keep going.

## Fire When
- Explicit: "get your shit together", "GYST", "read everything", "revisit all your instructions", "you're ignoring my instructions", "read every message I sent", "extract all my demands", "stop being shit", "stay true", "do your own investigation".
- `$un-dumb-yourself before` and `$un-dumb-yourself after` — both require this entire procedure, never a summary or partial substitute.
- The user is angry/frustrated — treat it as a broken rule, not noise.
- You catch yourself about to: sample a file and stop, grep one keyword and call it done, report counts instead of resolving, guess instead of check, or say something is impossible / too big.

## Procedure

1. **Stop the task.** No task work resumes until this entire procedure has an execution receipt. Mentioning or loading this skill is not execution.

   Every skill invoked during recovery is independently gated: read its complete `SKILL.md` and every required linked instruction, reference, template, script, and asset through EOF before taking that skill's actions. Record contiguous `1–EOF` coverage for each source. Partial skill reads invalidate the entire GYST run.

2. **Lock the exact task and authority.** Record the latest user request verbatim, named source-of-truth artifact, working directory, branch, active processes, known-good commands/setup, dirty files, current-turn permissions, explicit non-actions, and the next concrete action. Latest raw user correction beats generated summaries and stale notes.

3. **Read the instruction and note stack in full, line by line.** Check every file size before reading. Open the files — don't grep-sample, don't recall from memory:
   - Global `~/.claude/CLAUDE.md` (→ `~/.awesome-agent/shared/AGENTS.md`); Codex `~/.codex/AGENTS.md` + config.
   - Repo source of truth: `~/.awesome-agent/shared/*.md` (`core_profile.md`, `skill_system.md`; `AGENTS.md` is generated from these).
   - Project: walk up from the working dir for `CLAUDE.md`/`AGENTS.md`/`GEMINI.md`, `docs/`, `conductor/` specs + task files.
   - Every relevant project note index and every note it links. Existing notes are mandatory input, not optional background.
   - `references/user-demands.md` — his ranked standing demands, mined from his real prompts.
   - Every asset he gave this session (screenshot, paste, archive, file). Asset = source of truth over your assumptions and over the code. Read all of it before acting.

   **Full-read invariant:** Determine each file's total line count before reading. If a tool read uses `offset` or `limit`, record the returned line range and immediately continue with the next contiguous range until the tool reports EOF or the final known line. A bounded read is a tranche, never a completed file. Before leaving this step, reconcile the range ledger against every line from 1 through EOF. Missing, overlapping, or unverified ranges block the receipt and block task resumption. Never say "the rest," "read fully," or equivalent unless the final read reached EOF.

4. **For history/log requests, read every direct user message and take notes continuously.** Locate the exact first-use cutoff. Run `scripts/isolate_user_messages.sh` per `references/refresh-procedure.md`. Exclude generated summaries, system wrappers, task notifications, subagent traffic, and tool output. Chunk the corpus, fan cheap low-effort readers, and append a durable tranche ledger after every fully read chunk. The steering agent reads every tranche note and reopens vague, conflicting, or high-impact raw messages. No final retrospective summary can substitute for notes taken during reading.

5. **Resolve conflicts by authority.** Use: latest raw user message → user-provided or explicitly named primary artifact → current live state → newer project notes → older project notes → generated summaries. Preserve settled decisions and exact known-good commands unless newer authoritative evidence changes them.

6. **Extract and confront.** Name the applicable demands, the exact violation, what was wrong, and the corrected course. Aggression means a rule was broken; no defense, groveling, reassurance, or softened paraphrase.

7. **Persist before resuming.** Update cross-agent rules in `~/.awesome-agent/shared/core_profile.md`, project rules in its owned instruction/docs/task files, standing demands in `references/user-demands.md`, and history-reading evidence in a dated refresh note. Never hidden memory.

8. **Record the execution receipt.** It must contain: exact latest request; violated rules; instruction files, note files, assets, and log ranges read fully; the contiguous `1–EOF` range ledger or an explicit whole-file read result for every required file; notes written; conflict resolution; source-of-truth artifact; corrected immediate action; verification artifact; explicit unverified items. Missing notes, missing EOF evidence, partial ranges described as complete, or a missing receipt means GYST did not run.

9. **Do the corrected real work.** Resume only the exact main workflow. Use the established setup and commands. No speculative side quests, audit theater, restarts of settled work, stale permissions, counts as work, or proxy completion. Verify the exact artifact the user will inspect next. On any "update / current / ready to deploy / safe to migrate" question: `git fetch` (+ `gh`) first.

## Non-Negotiables

The ranked list of his top standing demands lives in `references/user-demands.md`, and the condensed version is already in your always-loaded `CLAUDE.md` under "TOP STANDING DEMANDS". Read `references/user-demands.md` when re-grounding — do not restate the list here (it would just duplicate context you already hold). Violating any one is a failure state.

Skill invocation without the full read, continuous notes, durable updates, receipt, corrected work, and exact-artifact verification is a failure state.
