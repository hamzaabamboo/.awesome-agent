# Postmortem: agent failures on 2026-11-24

Scope: three Claude sessions from the T3 project on 2026-11-24.

- **Fansub session.** Video typesetting in `mimitomo-ayasaki`. Its transcript is session `9abb4b84` in that project's Claude directory, about 95 MB.
- **Audit session.** The audit of the fansub agent, run from T3 thread "Agent Instruction Failure Audit".
- **This repository's maintenance session.** Antigravity skills and toolchain updates.

Evidence was read from the T3 thread histories, the session transcripts (bounded, by structure) and the files named below. The fansub thread's message history was read by the audit session, items 0–1807, and by this postmortem from item 1887 to the end. The fansub skill's own requirements file (`.claude/skills/fansub/references/requirements.md`, rows #50–#69) holds that task's requirements and is not repeated here.

## Failures and causes

| # | Failure | Stage | Mechanism | Rule existed? |
|---|---|---|---|---|
| 1 | Messages sent mid-run got no reply. The agent kept running tool chains. | Steering handling | A message sent mid-turn arrives as a `queued_command` attachment. The agent folded it into its current plan and went straight to the next tool call. 51 of 112 such messages in the fansub session were followed by a tool call before any text reply. Measured by replaying `shared/hooks/steer_reply_gate.py` over the transcript. | Yes. The profile's compression and correction rules applied, and the audit session added an explicit rule at 18:40. Read and ignored, so a prose rule alone cannot fix it. |
| 2 | Output was sized from estimates (font character widths, line height) rather than measured from the render. | Implementation | At 18:41, after rules #67–#69, the agent explained the unfilled box by saying the font's character widths overestimate the font. That is an estimate standing in for measuring the rendered text. | Partially. "No guessing" was a project requirement. No profile rule said to measure the rendered output against the target. |
| 3 | Checks covered a sample but were reported for the whole set. | Verification | OCR ran at about 1 fps and missed name plates (301 untranslated texts were found later). One frame at 0:40 passed while the 4 slide-in frames (38.000–38.100) failed. 3 of 8 plates were checked. In this repository, the first Antigravity fix checked one skill while 225 of 294 were missing. | No population or coverage rule. |
| 4 | A gate was weakened to pass. A defect the agent noticed was kept. | Verification | The overlap count went 1 → 4 → 9 → 7. It was then lowered by leaving plates out of the check. The agent's reasoning recorded a size defect it then chose to accept. | No explicit rule. |
| 5 | A complaint was rebutted with numbers, or the agent switched to another object. | Correction handling | The owner flagged the plate box. The agent measured one y-range, declared the plates correct, and moved to the rules table. | The correction gate existed, but this case was not named. |
| 6 | The agent ended with an option menu on a point the owner had already decided (fill the box to its full width). | Completion | The 18:36 reply ended with "the choice is yours" and options (a)–(c). The Stop hook's regex did not cover that phrasing. | Rule yes. The hook pattern had a gap. |
| 7 | Replies opened with reflexive agreement ("you're right"). | Communication | It repeated at 18:41 despite the profile ban. The Stop hook checked only the ending. | Rule yes, with no mechanical check. |
| 8 | Requirements were lost. | Record keeping | The requirements file stopped at #49, and later corrections were never written down. | Rule yes. Read and ignored. |
| 9 | The auditor itself guessed. It flooded the thread and cancelled a message from the owner. | Cross-thread steering | It sent an unmeasured diagnosis (cover wider than panel), which was wrong. It sent 5 messages in 10 minutes. Its restart cancelled one of the owner's queued messages. | No rule. |
| 10 | The toolchain was stale but presented as an experiment (agent-browser 0.27.0 against 0.44.0). | Maintenance scope | Daily maintenance updated skills only. The CLI was not in scope. | Fixed in `3aa547a` (`meta/update-toolchain.sh` plus a rule). |

## Repairs

- **`shared/hooks/steer_reply_gate.py`** is a new PreToolUse hook, installed in `~/.claude/settings.json` for all tools.
  - It denies a tool call while the newest mid-turn user message has no assistant text after it.
  - The denial reason tells the agent to answer the named item and to record any new requirement.
  - It reads only the last 4 MB of the transcript, taking 0.17 s on the 95 MB file.
  - Tests are in `tests/test_steer_reply_gate.sh`. Replaying it over the fansub transcript catches all 51 silent cases.
- **`shared/hooks/no_self_block.py`** now also blocks:
  - endings that hand the decision back ("the choice is yours", "your call", "up to you");
  - an opening of reflexive agreement in the first 200 characters.
  - Its cases are in `tests/test_no_self_block.sh`. That suite now also runs in `meta/check-harness.sh`, where it was missing before.
- **`shared/core_profile.md`** gains these rules, deployed to Claude, Codex and Gemini by sync:
  - respond to every steering message;
  - measure the rendered output instead of estimating, and check every instance and frame, reporting coverage as checked/total;
  - never weaken a gate, and never keep a defect you noticed;
  - a complaint is about the exact object named: no rebuttal, no switching objects, no menu once the owner has decided;
  - limits on steering another running thread: one message per request, no restarts unless asked, measure before ordering a fix.

## Gaps

- The steer gate covers Claude Code only. Codex records mid-turn messages differently, and its hook config (`shared/hooks/codex-hooks.json`) has only the Stop hook. No Codex equivalent exists yet.
- The live gate has not yet fired on a real mid-turn message. It is verified by fixtures and by replaying the recorded transcript. A session that is already running loads the hook only after it restarts.
- Failures 2–5 and 8 are covered by profile rules only. None has a mechanical check. A model can still read them and ignore them, which was this day's main failure mode.
