# Postmortem: agent failures on 2026-11-24

Scope: three Claude sessions from the T3 project on 2026-11-24.

- **Fansub session.** Video typesetting in `mimitomo-ayasaki`. Its transcript is session `9abb4b84` in that project's Claude directory, about 95 MB.
- **Audit session.** The audit of the fansub agent, run from T3 thread "Agent Instruction Failure Audit".
- **This repository's maintenance session.** Antigravity skills and toolchain updates.

Evidence was read from the T3 thread histories, the session transcripts (bounded, by structure) and the files named below. The fansub thread's message history was read by the audit session, items 0–1807, and by this postmortem from item 1887 to the end. The fansub skill's own requirements file (`.claude/skills/fansub/references/requirements.md`, rows #50–#69) holds that task's requirements and is not repeated here.

## Failures and causes

| # | Failure | Stage | Mechanism | Rule existed? |
|---|---|---|---|---|
| 1 | Messages sent mid-run got no reply. The agent kept running tool chains. | Steering handling | A message sent mid-turn arrives as a `queued_command` attachment. The agent folded it into its current plan and went straight to the next tool call. 51 of 112 such messages in the fansub session were followed by a tool call before any text reply. Measured by replaying the gate over the transcript. | Yes. The profile's compression and correction rules applied, and the audit session added an explicit rule at 18:40. Read and ignored, so a prose rule alone cannot fix it. |
| 2 | Output was sized from estimates (font character widths, line height) rather than measured from the render. | Implementation | At 18:41, after rules #67–#69, the agent explained the unfilled box by saying the font's character widths overestimate the font. That is an estimate standing in for measuring the rendered text. | Partially. "No guessing" was a project requirement. No profile rule said to measure the rendered output against the target. |
| 3 | Checks covered a sample but were reported for the whole set. | Verification | OCR ran at about 1 fps and missed name plates (301 untranslated texts were found later). One frame at 0:40 passed while the 4 slide-in frames (38.000–38.100) failed. 3 of 8 plates were checked. In this repository, the first Antigravity fix checked one skill while 225 of 294 were missing. | No population or coverage rule. |
| 4 | A gate was weakened to pass. A defect the agent noticed was kept. | Verification | The overlap count went 1 → 4 → 9 → 7. It was then lowered by leaving plates out of the check. The agent's reasoning recorded a size defect it then chose to accept. | No explicit rule. |
| 5 | A complaint was rebutted with numbers, or the agent switched to another object. | Correction handling | The owner flagged the plate box. The agent measured one y-range, declared the plates correct, and moved to the rules table. | The correction gate existed, but this case was not named. |
| 6 | The agent ended with an option menu on a point the owner had already decided (fill the box to its full width). | Completion | The 18:36 reply ended with "the choice is yours" and options (a)–(c). The Stop hook's regex did not cover that phrasing. | Rule yes. The hook pattern had a gap. |
| 7 | Replies opened with reflexive agreement ("you're right"). | Communication | It repeated at 18:41 despite the profile ban. The Stop hook checked only the ending. | Rule yes, with no mechanical check. |
| 8 | Requirements were lost. | Record keeping | The requirements file stopped at #49, and later corrections were never written down. | Rule yes. Read and ignored. |
| 9 | The auditor itself guessed. It flooded the thread and cancelled a message from the owner. | Cross-thread steering | It sent an unmeasured diagnosis (cover wider than panel), which was wrong. It sent 5 messages in 10 minutes. Its restart cancelled one of the owner's queued messages. | No rule. |
| 11 | Skills the user named were skipped. | Skill routing | 10 skills named mid-run (`/pr` ×6, `/ui` ×3, `/ask-matt` ×1) were loaded 0 times. Claude Code expands a `/skill` only when it starts a fresh prompt. Of 17 skills named at a turn start, the text was loaded but the procedure was not followed, and nothing checked that. | Yes (named skills are mandatory). Read and ignored. |
| 12 | Code files grew without structure. | Implementation | 10 code files in the fansub project are over 500 lines; the largest are 2,624 and 1,855. | No rule. |
| 10 | The toolchain was stale but presented as an experiment (agent-browser 0.27.0 against 0.44.0). | Maintenance scope | Daily maintenance updated skills only. The CLI was not in scope. | Fixed in `3aa547a` (`meta/update-toolchain.sh` plus a rule). |

## Repairs

All gates live in one script, `shared/hooks/agent_gates.py`, wired for both Claude Code (`~/.claude/settings.json`) and Codex (`shared/hooks/codex-hooks.json`, hooks trusted in `~/.codex/config.toml`).

- **`prompt` (UserPromptSubmit):** injects the full `SKILL.md` for every installed skill named with `$name` or `/name`, and records the names for the stop gate.
- **`pretool` (PreToolUse, Claude):** refuses the first tool call after each unanswered mid-turn message with a reply-first instruction, and loads any skill that message names. It allows the call once the message has a text reply or has already been reminded.
  - The first version required the reply to be on disk before the tool call. A reply streamed in the same response is not, so it locked the session; it was replaced.
- **`posttool` (PostToolUse):** when an edit grows a code file past 500 lines, tells the agent to split it by responsibility. It reads Claude edit paths and Codex `apply_patch` paths, and skips data, vendored and generated files.
- **`stop` (Stop):** refuses to end a turn whose final message does not report each named skill.
- **`shared/hooks/no_self_block.py`** also blocks decision-handback endings and reflexive-agreement openings.
- **`shared/core_profile.md`** adds these rules, deployed by sync to Claude, Codex and Antigravity (`~/.gemini/GEMINI.md`):
  - respond to every steering message;
  - measure the rendered output instead of estimating, and check the whole population;
  - a named skill runs first;
  - code that outlives a one-off is production code (split past 500 lines);
  - never weaken a gate;
  - complaint handling;
  - cross-thread steering limits.

## Verification

- `tests/test_agent_gates.sh` (29 cases) and `tests/test_no_self_block.sh` both pass, and both run in `meta/check-harness.sh`.
- **Codex, live:** `codex exec` with a prompt naming `$test_skill` ran the UserPromptSubmit and Stop hooks, and the reply reported the skill.
- **Claude, live:** `claude -p` with the same prompt injected the skill. The agent first replied with only "OK"; the stop gate refused that, and the rewritten reply reported the skill.
- **Pretool gate, live:** it fired once in the authoring session on a mid-turn message and allowed the retry.

## Gaps

- **Antigravity has no hook system** (its config holds only `userSettings`), so the rules apply there through the prompt only.
- **Codex has no mid-turn message records** in 60 recent sessions. Messages arrive as new prompts and are covered by the `prompt` gate. A future Codex steering mode would need its own check.
- **Some failures have prose rules only:** measurement, gate-weakening and requirement recording have no mechanical check.
- **Reporting is not executing:** the stop gate proves a named skill was reported, not that every step of its procedure was executed.
