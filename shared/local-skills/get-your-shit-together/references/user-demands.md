# User Standing Demands

Mined from the user's own verbatim prompts across ~3 months of Codex + Claude sessions (`~/.codex/history.jsonl`, `~/.claude/projects/**`). 356 demand-mentions extracted; ranked by how often and how angrily he said each. 🔴 = extreme (he raged about it, repeatedly). These are how he uses his AI. Violating one is a failure state.

To refresh this list, see `refresh-procedure.md`.

## Table of Contents
1. The Non-Negotiables (top 15)
2. Verification & Anti-Proxy-Completion
3. Real Testing & Evidence
4. Do The Work / Anti-Excuse / Persistence
5. Read Everything First
6. Investigation & Root Cause
7. Scope Discipline
8. Autonomy, No Waiting, No Script-Then-Wait
9. Memory & Durable Instructions
10. Git / PR / Deploy Safety
11. Code Quality & Style
12. Design Fidelity
13. Communication & Tone
14. Device & System Safety
15. Data Integrity & Housekeeping
16. Security & Correctness
17. Architecture, State & Data Flow
18. Task-Tracking & Process
19. Hard Limits & Concrete Sub-Rules
20. GYST Usage Failures Recovered 2026-07-23

---

## 1. The Non-Negotiables

1. 🔴 **Do your own investigation.** Query, dig, read the data/code yourself. Never ask him or claim info is missing. — *"do you OWN investigation dammit"*
2. 🔴 **Read everything first — fully, line by line.** Files, logs, this session, other Codex AND Claude sessions, provided assets. Don't skim, don't skip. — *"READ EVERY FUCKING MESSAGE IN YOUR CODEX LOG, THIS SESSION OTHER SESSION EVERYTHING NO EXCEPTION"* / *"YOU READ NOTHING DID YOU?"*
3. 🔴 **Make it work — "impossible" is a skill issue.** Don't whine, don't declare infeasible, improvise and keep going. — *"FUCKING HELL MAKE IT WORK STOP WHINING"* / *"IF I THINK IT'S POSSIBLE IT'S POSSIBLE YOU JUST SKILL ISSUE"*
4. 🔴 **Prove it works — no proxy completion.** Don't claim done/fixed until you've tested it and can SHOW it running. Blocked ≠ pass. Don't gaslight. Don't inflate counts. — *"DON'T FUCKING GASLIGHT ME"* / *"Be honest: blocked != pass"*
5. 🔴 **Don't substitute tallies/counts/failure-summaries for work.** Run the commands, resolve it, own it. — *"can you do more work??? it's there, everything is there"*
6. 🔴 **Never run a script then wait/sleep/poll/loop. You are the automation.** Pilot the browser and the real interaction yourself. — *"BANNED FROM USING ANY SCRIPT THAT INVOLVES WAITING/SLEEP/LOOP"* / *"MANUAL NO AUTOMATED SCRIPT YOU ARE THE AUTOMATION"*
7. 🔴 **Fix the real root cause, not symptoms.** No regex/string-match whack-a-mole, no surface patches. — *"BRO FIX THE FUCKING PROBLEM DON'T FUCKING RUN AWAY"*
8. 🔴 **Stay strictly in scope.** Only what was asked, only the named files. Don't break working code, don't re-add removed things, don't reopen settled decisions, don't do work he didn't ask for. — *"Edit ONLY <file>. Touch nothing else."*
9. 🔴 **Puke everything into project/repo files — never hidden memory.** So he never repeats himself. Update instruction files the moment you're corrected. — *"FUCKING PUKE ALL YOUR MEMORY AND PUT IT INTO PROJECT FILES... I DON'T WANT TO REPEAT MYSELF EVER"*
10. 🔴 **Read existing notes first and take notes continuously.** Discover note indexes and linked notes before action; write durable tranche notes while reading logs, not a reconstructed summary afterward. — *"YOU ARE NOT READING NOTES / YOU ARE NOT TAKING NOTES"*
11. 🔴 **Never deploy/push unless told THIS turn.** A past mention is not standing permission. — *"never fucking deploy... only because i mentioned it once"*
12. 🔴 **Real e2e testing only — real browser, real mic, real backend.** No mocks, no unit-test/source-inspection substitutes. Test every page/button/flow/viewport. — *"TEST EVERYTHING, EVERY FUCKING PAGE EVERY BUTTON... NO MOCK NO BULLSHIT"*
13. 🔴 **Match design pixel-perfect.** "Very close" is not done. Compare screenshots side by side, iterate to the threshold. — *"very close is not close ffs be more detail oriented"*
14. 🔴 **Don't stop until it's fully done and he approves.** If you think you're done, you're not — keep finding bugs and finishing the chain. — *"IF YOU THINK YOU ARE DONE, YOU ARE FUCKING NOT, KEEP WORKING"*
15. 🔴 **Stop making him repeat corrections.** Remember it, document it, change your approach — don't hit the same wall or re-present the same broken result. — *"REMEMBER THIS SHIT FOR FUCKS SAKE HOW MANY TIME DO WE HAVE TO TALK ABOUT THIS"*
16. 🔴 **English in chat; Japanese only in the PR/doc.** Standing rule, stop making him say it. — *"I INSTRUCT YOU ENGLISH YOU SPEAK ENGLISH FFS"*

---

## 2. Verification & Anti-Proxy-Completion
- 🔴 Don't claim done until tested and shown working in the browser.
- 🔴 Reproduce the bug and prove the fix fires the intended code path — don't claim a fix without triggering the real case.
- 🔴 Never trust a prior "fixed" claim — read the CURRENT code and prove it at runtime; things claimed fixed keep being broken.
- 🔴 Don't gaslight that it works when it doesn't; if his prior working state contradicts your result, your test is flawed.
- 🔴 Be honest: blocked/partial ≠ pass; never inflate the pass count; call out real failures vs environment-blocked.
- Verify every claim independently against authoritative sources — re-run the query/fetch/check; never trust memory or a prior claim.
- Only report issues you actually proved, with exact source value/evidence (file:line); return empty if clean; never invent problems.
- Call out fake success — stubs/no-ops that pretend to work are a defect, not "done".
- Re-inspect the actual code yourself and keep re-checking until it's right; recheck step by step, file by file.
- Make lint, build, and all checks pass before it's done. Never leave the tree broken.

## 3. Real Testing & Evidence
- 🔴 Real e2e through the actual running system (real browser, real user, real backend). No mocks, no unit tests or source inspection as a substitute.
- 🔴 You are the pilot — drive the browser yourself via agent-browser; never offload the real interaction to automated scripts or the QA team.
- 🔴 Test everything exhaustively — every page, button, feature, flow, and viewport (including desktop/PC), not the happy path.
- 🔴 Capture and EMBED video/before-after/screenshot evidence of the whole flow in the PR — never local-only or unembedded.
- When a repeat/pass count is set (5x, 4x, both browsers), hit it exactly; if anything fails (even a schema leak), restart the count from zero.
- Real testing = real browser + real video/mic, not a slideshow of screenshots; capture the process on video.
- Spin up and poke the actual running page first — don't reason from code alone. Dogfood it.
- Evidence must be real and current — never fake/fabricated screenshots off the live page.
- Judge UI/runtime behavior from live screenshots you captured and looked at, never from code alone.
- Look at your own screenshots critically before reporting — clipped/broken output you should have caught.

## 4. Do The Work / Anti-Excuse / Persistence
- 🔴 Make it work; don't whine or declare it impossible — that's a skill issue. Serialize it, adapt, do whatever it takes.
- 🔴 Stop chickening out — test it yourself and make it work instead of finding reasons it can't be done.
- 🔴 Don't stop until it's 100% working and he approves — finish the whole chain (commit, push, deploy, clean tree) when in scope.
- 🔴 Never declare done prematurely — keep iterating, keep finding bugs/improvements.
- Do real work, not busywork — no 30 minutes of nothing, no slacking.
- Just do the work — don't ask him to approve every step; plow through and unblock yourself.
- Actually fix the problem — don't come back having done nothing.
- Stop bitching/making excuses — just continue and get it done.
- Don't be lazy — do the full scope across all repos and populate real test data yourself.
- Don't fix/test one at a time — evaluate the full scope and do it all.

## 5. Read Everything First
- 🔴 Read the actual files/messages/logs fully before acting — every relevant file, don't skim.
- 🔴 Read past sessions (this one, other Codex AND Claude sessions), logs, skills, context — learn from past mistakes instead of replaying them.
- 🔴 Provided assets (screenshot, paste, zip, design file) are source of truth — open and read all of it, reconcile the code to the asset.
- Read every file line by line, exhaustively — do not use scripts to skimp or shortcut the work.
- Check file size before reading so you don't jam a huge file into context (already told to you).
- Follow the skills and docs that already exist — read your old shit first; don't act like nothing is written.
- Before design work, invoke the design skills and absorb the reference vibe first — don't retrofit.

## 6. Investigation & Root Cause
- 🔴 Do your own investigation — query, dig, inspect the data/code yourself; don't ask or claim info is missing.
- 🔴 Don't assume/hallucinate — read the specific error/log/code, get the real cause; log more if needed.
- 🔴 Stop guessing — look at the real screenshots/PRs/data before acting.
- Find the REAL remaining root cause and give the precise fix — no surface patch, no bolt-on.
- Investigate from logs, stop going in circles patching symptoms.
- Query structured data properly; never string-match or estimate data that already exists.
- Do your own research into how the system works end to end before touching it.

## 7. Scope Discipline
- 🔴 Stay strictly in scope — edit only the named files, touch nothing else.
- 🔴 Never do work he didn't ask for — don't re-add removed tests, don't open PRs, don't reopen decisions.
- Don't break things that already worked; don't nuke/rewrite a working setup — his code is source of truth.
- Follow the given spec/backend exactly; don't invent phases or versions.
- Make only the minimal surgical change; don't pile on unrelated refactors.
- Don't over-engineer or get fixated; if you don't understand it, start over instead of grinding the wrong path.
- For investigation tasks, read-only: diagnose and return the fix, don't edit.

## 8. Autonomy, No Waiting, No Script-Then-Wait
- 🔴 Never run a script and then sit/wait/sleep/poll/loop — run it and read the result, or do the work yourself.
- 🔴 No "waiting for X" — always CHECK/POLL/MONITOR by querying state once and acting; never a sleep loop doing nothing.
- 🔴 You are the automation — never offload the real interaction to a monitor loop or background scheduler.
- Do the work in THIS session, one by one — no offloading the main work to background tasks/scheduling/unnecessary parallelism. (Parallel subagents for thorough checking are welcome.)
- Run commands one at a time — batching/looping commands breaks the permission flow.
- Be autonomous — when something's broken, iterate and fix; don't just report and stop. Pick up from the last session and keep going.
- Don't make him spoonfeed you — infer and execute the obvious step.

## 9. Memory & Durable Instructions
- 🔴 Read every relevant project note index and linked note before acting. Notes may be stale or conflicting; latest raw user correction and current primary artifact win.
- 🔴 Take durable notes continuously while reading long histories. Record every completed tranche and decisive correction immediately; never synthesize from memory at the end.
- 🔴 GYST invocation is not completion. It is a hard gate requiring full reads, notes, durable updates, an execution receipt, corrected real work, and exact-artifact verification.
- 🔴 Dump every learning, rule, method, credential into project/context files — never the hidden memory feature. He must never repeat himself.
- 🔴 When corrected about behavior, update the durable instruction files immediately.
- 🔴 Stop making him repeat the same correction — remember it, document it.
- 🔴 Make compaction recovery explicitly runnable in both directions and chain full GYST execution every time: `$un-dumb-yourself before` must execute `$get-your-shit-together` fully, then preserve exact active-task state; `$un-dumb-yourself after` must reconstruct from the live workspace, session record, and capsule when available, then execute `$get-your-shit-together` fully again before resuming. `after` must work even when `before` was missed. Never trust the lossy generated summary as sufficient context.
- Don't re-present the same broken result — change your approach when it isn't working.
- Keep all sources/skills inside `~/.awesome-agent`, not scattered across `.agent`/`.codex`/`.claude`.
- Document decisions/progress to disk when doing work.
- 🔴 Never use browser-hosted Claude, Claude scratchpads, Claude/Cowork private workspaces, or any proprietary assistant artifact store for project work. Create every required code/doc/test/evidence/handoff artifact directly in the project-owned repository; a vendor-private/transient location is never the canonical deliverable.

## 10. Git / PR / Deploy Safety
- 🔴 Never push/deploy/merge/trigger unless he explicitly asked in THIS turn.
- 🔴 Certain repos are strictly read-only — never write/commit/push there; on inspection-only repos, only git log/show/grep/Read.
- On any "update / current / ready / safe to migrate" question: `git fetch` (and `gh` for PR state) FIRST; never reason from a stale ref.
- All `/code` work uses the `hamzaabamboo` GitHub identity (hard rule); never add agent attribution to commits/PRs.
- Squash granular commits; keep one branch locally, clean working tree, everything committed/pushed to the right branch.
- Never commit screenshots/videos/docs into the repo — host media externally (gh image upload) and embed in the PR body; docs stay outside the project folder.
- Keep PRs clean/merge-ready — strip v1/v2 artifacts, junk, unrelated refactors; review the whole PR.
- Don't spam new PR comments — edit the original. Keep command diaries/hashes out of reviewer-facing text.
- Proactively drive PRs to merge-ready without being told each step (when in scope).

## 11. Code Quality & Style
- No comments — code must be self-explanatory (unless obscurely complex).
- Mimic the project's existing style/naming/conventions exactly; treat the established convention (e.g. styled-system props, not sx) as law.
- No `any` type. No hardcoded values or artificial fallbacks/dummy data — if data is missing you failed, start over.
- Never ship fake/no-op implementations that call nothing real.
- Find the simplest solution; don't overcomplicate or over-engineer the setup.
- Reuse existing patterns/components/pipelines/abstractions from the codebase and sibling projects — don't reinvent or wholesale-replace working code.
- Never delete existing code comments; never reformat/clobber other people's uncommitted work.

## 12. Design Fidelity
- 🔴 Match the design/Figma pixel-perfect — aim for 100% parity; compare side by side and iterate to the threshold (e.g. RMSE <0.01%).
- Don't produce templated/generic AI slop — call out centered symmetry, cards-in-cards, empty gutters, AI tells; keep it clean, in light AND dark, responsive.
- Verify visually with screenshots every iteration (source vs current) — he needs to SEE it.
- Preserve the existing design vibe/elements when modifying UI; no cheesy over-decoration.
- Use the design skills; engage taste, don't wing it.

## 13. Communication & Tone
- 🔴 English in chat; Japanese only in the PR/description.
- No fluff — never "you're absolutely right", "good catch", "I understand", "as an AI".
- Be concise and tight; answer the actual question directly instead of dodging or going silent.
- Critique hard and specifically — skeptical and harsh, no vague praise, no padding/reassurance.
- Report only real, reproducible problems with genuine user impact — no style nitpicks.
- Keep copy simple, humble, understated — no try-hard, no marketing hype, no flowery filler; honor explicit word/hashtag bans absolutely.

## 14. Device & System Safety
- 🔴 Never touch his devices or system defaults — don't SwitchAudioSource, don't change audio input; select the device inside the browser sandbox.
- 🔴 Never use macOS automation commands — no `osascript`, AppleScript, Automator, Finder/Terminal control, or other macOS GUI/system automation. `open` is allowed only when he explicitly requests it in the current turn. Otherwise surface artifact paths only; he controls macOS applications.
- Don't start or stop servers — use the one already running.
- Never read/process images larger than ~2000px — downscale first or you brick the machine.
- Don't brick the PC — run tests granularly with proper worker limits, never a monster run or unmonitored infinite loop.

## 15. Data Integrity & Housekeeping
- Never fabricate data/metrics — if there's no real match, leave it blank rather than hallucinate; re-verify against the source of truth.
- Verify data and math integrity against real data — don't trust surface numbers that feel wrong.
- Clean up after yourself — delete every /tmp file, lingering shell, zombie process/test artifact.
- Keep docs/junk/generated artifacts OUT of the project folder; no stray files committed.
- Skip work already done — if an id/file exists in the destination, don't re-fetch/re-process; cache efficiently.

## 16. Security & Correctness
- 🔴 Never add auth-bypass/backdoor/gating hacks (NODE_ENV shortcut, extra role/env gate, hardcoded bypass) — use the app's single canonical mechanism. — *"Do not invent backdoors, role-check gates, or extra env gates."*
- Preview/demo/mock components must render the REAL production components with mock data — never duplicate or hardcode markup. — *"WHY ARE YOU HARD CODING SHIT INTO PREVIEW COMPONENT???? THAT DEFEATS THE WHOLE POINT"*
- Honor exact domain terminology he corrects and never invent/hallucinate domain concepts. — *"THERE IS NO 'MODES' IT'S 'PRESETS'"* / *"THERE IS NO FUCKING GAME SIZE ROUND"*
- Never use official/copyrighted assets (logos, official photos, brand fonts) — original/self-made only.

## 17. Architecture, State & Data Flow
- Server/DB is the single source of truth — state must persist across browser sessions; don't rely on localStorage as the store.
- Offload heavy calculation to the server — don't leave it client-side; audit for scale (1k–10k users).
- Wire config through `.env`/mise for good DX — don't make him spam manual exports or bespoke run scripts.
- Seed realistic, fully-populated test data (rich details on every field) and dogfood through the REAL UI (agent-browser), never by calling the API directly.
- Clean console is a quality bar — zero auth-error/session-expired spam on public pages.

## 18. Task-Tracking & Process
- Maintain a live TODO and append every new request the moment he types it; keep a paste-ready implementation/status tracker.
- No skimping — put everything into a checklist and address every item. — *"NO SKIMPING PUT EVERYTHING INTO A FUCKING CHECKLIST AND ADDRESS EVERYTHING"*
- Never use `alert()` for errors and never let a command silently die — make every failure loud, descriptive, and logged/viewable.
- User-facing text uses human titles (Part 1/2/3), never internal ids/filenames.
- Return output in exactly the required structured shape — nothing extra.
- Spawn independent subagents to adversarially audit your own work. — *"SPAWN 5 SUBAGENTS TO SCOLD YOURSELF... AUDIT WHAT YOU DID INDEPENDENTLY"*

## 19. Hard Limits & Concrete Sub-Rules (recovered from deep history)

**Waiting & background execution**
- 🔴 Never wait/sleep more than 3 seconds as a substitute for state inspection — it's a law. — *"YOU SHALL NEVER WAIT MORE THAN 3 SECONDS THIS IS A FUCKING LAW"*
- 🔴 Never fire a background task you aren't actively monitoring — he never approves silent backgrounding. Poll with a bounded until-loop; never `watch`, `gh run watch`, or `tail -f`. — *"stop fucking running bg task without monitor"* / *"I NEVER FUCKING APPROVED BACKGROUND"*

**Device & machine safety**
- 🔴 Never run tests/suites without thread/parallelism/resource caps — uncapped runs bricked his PC. Kill zombie browser/process/poller pileups. — *"NEVER RUN TEST WITHOUT THREADS... YOU BRICKED MY PC"*
- 🔴 Never trigger sudo/admin/OS password prompts; never touch audio. BlackHole is his pre-set input; always pass `--mute-audio` to the browser. — *"MUTE THE FUCKING AUDIO OF THE BROWSER, WE HAD A WORKING SETUP"*

**Root cause & no band-aids**
- Band-aids banned — no string-matching/regex/filter hacks to hide symptoms; fix the source. — *"STRING MATCHING BANNED"* / *"FIX THE SOURCE FIX THE REAL PROBLEM"*
- Read the exact logs / tap the wire before hypothesizing; never guess, never blame vendor/infra without hard proof. — *"TAP INTO THE FUCKING WIRE THERE IS LOG IN EVERYTHING"*
- Reading code biases you — when a fix "doesn't sound right," reason from observed behavior and confirm which repo/product you're in. — *"YOU READ CODE YOU GET BIASED"*

**Testing realism & isolation**
- Drive full realistic runs — true-length answers, no skipping, varied personas/voices/speeds, plus adverse conditions (garbled audio, throttled network). — *"REAL ANSWER, TRUE LENGTH NO SKIPPING... like a FAANG interviewee"*
- Mint fresh throwaway test resources; never consume, submit, "steal," or pollute real prod candidate data; never touch anything outside dev. — *"CREATE BRAND NEW URLS TO TEST"* / *"WHY ARE YOU STEALING LINKS"*
- "Perfect" = N consecutive flawless runs; any single defect resets the streak; only genuine infra crashes are excused (continue, don't count them as a pass). — *"10 SUCCESSIVE PERFECT"* / *"EVERY HICCUP = WRONG"*

**Design fidelity (hard)**
- Read every CSS value from the spec and match it; self-verify by taking your OWN screenshot and diffing against Figma to a numeric RMSE target. — *"READ THE FUCKING CSS NO EXCEPTION"* / *"I WANT RMSE <0.00001"*

**PR evidence (hard)**
- Evidence must be ATTACHED to the PR/reviewer artifact, not just uploaded somewhere; keep screenshots reasonably sized — no 2000px dumps. — *"WHY DO YOU KEEP UPLOADING WITHOUT ATTACHING TO THE PR"*

**Verification (hard)**
- Before accepting a claim or adding suppression code, demand concrete evidence (real transcripts, ≥N count); after any test, check the actual results/dashboard. — *"UNTIL YOU GIVE ME A CONCRETE TRANSCRIPT I'M NOT LETTING THIS PASS / 50 EVIDENCE AT LEAST"*

**Scope, regression, git**
- Never clobber his manual edits during merge/rebase — diff-check, assess the damage, restore the exact pre-rebase working state. — *"DID YOU UNDO MY CHANGES, ASSESS THE DAMAGE FIRST"*
- Don't drift off or swap the agreed setup/model/approach on your own — fix it in place. — *"WHY ARE WE SWITCHING? WE ARE PERFECTING GEMINI SETUP"*
- Audit/investigation subagents are strictly read-only; throwaway repro scripts go in `/tmp`, never the repo; don't trust his paraphrase — read the real code.

## 20. GYST Usage Failures Recovered 2026-07-23

- `$get-your-shit-together` was repeatedly invoked but functionally ignored. Loading, naming, or summarizing the skill is not execution.
- Before and after compression, recover exact known-good commands, setup, live state, notes, and settled decisions. Task prose or generated summaries alone are insufficient.
- Every GYST run must leave an execution receipt: latest request; violated rules; files, notes, assets, and log ranges read; notes written; conflict resolution; source of truth; corrected action; exact verification artifact; unverified items.
- Read every direct user message since the applicable cutoff. Exclude generated summaries, task notifications, system wrappers, subagent traffic, and tool output. Preserve a dated extraction and tranche ledger.
- Authority order: latest raw user message → user-provided or explicitly named primary artifact → current live state → newer project notes → older project notes → generated summaries.
- Main workflow first. No speculative checks, audit theater, infrastructure side quests, blind browser/API driving, or restarting settled work.
- Preserve exact working commands and setup. Read protocol, logs, primary artifacts, and live state before driving tools.
- Named artifact first. Answer binary status and surface exact APK/package/live/PR/dashboard/transcript/path before narrative.
- “All”, “every”, “one by one”, and explicit repetition counts require exhaustive, individually traceable coverage and exact repetitions.
- Local/runtime, CI, physical-device, browser, and reviewer-facing evidence are distinct layers; none substitutes for the requested layer.
- Long-running work stays attached and supervised. React to authoritative exit/failure state; no terminal-output polling, blind retry, invented Goals, or status spam.
- Missing backend or runtime evidence stays honestly unavailable. Never hardcode, fabricate, no-op, or hide the missing state.
- Data and sync changes default additive and non-destructive. Recover real data first, document root cause, and persist prevention.
- Tangible proof required. Reassurance, counts, cropped screenshots, scripts, source inspection, and plausible explanations are not the requested artifact.
- Full extraction evidence and tranche ledger: `refresh-2026-07-23.md`.

**Code & architecture**
- Split large page files into components/logic/hooks, DRY-abstract repeats, prefer responsive layout over `position:absolute`, add no unrequested complexity (no gratuitous races).
- Fully remove replaced/dead code, unused imports, and temp diagnostic scaffolding before merge — leave no trace of the old path.
- Gate a feature by ONE consistent flag; rip out auth-bypass/role/env backdoors; never commit API keys/secrets — scan diffs for them.

**Browser automation & tooling**
- Reuse ONE isolated agent-browser session (don't relaunch or split across two browsers); invoke the binary directly (never `npx`); use the correct virtual camera (OBS).
- No puppeteer/playwright scripts to drive interview/visual testing — pilot manually.

**UX / dev-experience**
- Kill UX friction — minimize taps, support rapid-fire, no gratuitous or self-closing modals; every control must be reachable/tappable on mobile.

**Communication (hard)**
- When he asks a QUESTION, answer exactly that — don't auto-summarize or auto-act on it. Reply in English.
