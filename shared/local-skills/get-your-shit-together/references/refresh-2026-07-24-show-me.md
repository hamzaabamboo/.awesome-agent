# SHOW-ME History Refresh — 2026-07-24

## Scope

- Request: create `$show-me`; literally expose work and understanding through a browser, screenshot, Finder-visible artifact, or HTML mockup instead of working in an invisible void.
- Latest correction: `$show-me` is continuous transparency mode. Expose every material step so the user can course-correct; use VS Code, live hot reload, headed testing browser, or the closest inspectable surface.
- Corpus: all direct Codex and Claude user messages available locally through 2026-07-24.
- Canonical extraction: `/tmp/show-me-history.fHOq7f/user_messages.jsonl`.
- Coverage target: 4,595 direct-user messages across 46 chronological chunks.
- Excluded by extraction: generated summaries, system wrappers, task notifications, subagent traffic, tool output, and local-command wrappers.
- Authority: latest raw request, then raw historical messages, current repository state, existing durable notes, generated summaries.

## Reading Ledger

| Chunks | Reader | Read fully | Notes |
|---|---|---|---|
| `messages_abk` | steering agent | yes | “do this, all 3 projects, show me first”; “show in chrome” followed by “where ??” proves saying shown without a discoverable display fails; explicit `open` authority appeared only in a separate “open pr in browser using open” turn; “OPEN IN VSCODE” and “write everything we discussed into a file” show artifact/path handoff variants. |
| `messages_abl` | steering agent | yes | “14 fucking minutes of nothing???” and “I want something tangible i can see now” require visible intermediate output during long work; “DO IT HEADED I WANNA SEE” prefers observable process over hidden headless execution; “ALWAYS FUCKING VISUALLY CHECK ... DON'T JUST GUESS”; screenshot must show the relevant part, not any screenshot; `OPEN FINDER`, `open in browser`, and explicit `!open .` are turn-scoped display commands. |
| `messages_abm` | steering agent | yes | Permanent boundary stated exactly: “OSASCRIPT ARE ... FORBIDDEN” and “ONLY OPEN IS ALLOWED UNDER EXPLICIT COMMAND”; repeated “where are you at/how far” proves progress must expose current stage and output, not a vague ping; “open apk folder in finder” shows exact artifact selection matters; handoff must name all progress and remaining work. |
| `messages_abn` | steering agent | yes | Repeated `?`, “STATUS REPORT?”, and “whole day of 0 progress” expose silent/stalled long work; user wants progress indicators beyond a spinner, but rejects minute-by-minute noise; runtime must be shown through the real app/browser, not pointless test scripts; monitoring display must distinguish alive, stalled, failed, and corrected. |
| `messages_aam`–`messages_aax` | cheap reader B | yes | Browser-visible real-user flow, current screenshot/video, final result/persistence, responsive/error states, exact reproduction, and direct reviewer embedding repeatedly demanded. Command transcript, unit-test spam, slideshow, partial video, mock state, and internal reasoning rejected as proof. Scoped waiver may override verification for one named surface only. |
| `messages_aay`–`messages_abi` except `messages_abj` | cheap reader C | yes | Headed browser and UI-first dogfood; every requested state/option/viewport; full-flow labelled video; current screenshots; before/after/Figma/side-by-side proof; readable full text; PR attachment; pixel-level self-inspection. Dev-only and excluded-area boundaries remain binding. |
| `messages_aaa`–`messages_aal` | cheap reader A | yes | Actual browser/emulator/preview, exact editor location, user-provided screenshots, one-by-one source/current/diff evidence, full page/button dogfood, current PR screenshots, readable rendered reports, and user-perspective E2E repeatedly override build/script/status claims. Explicit `open`, deploy, push, and upload authority remains turn-scoped. |
| `messages_abi`–`messages_abs` | prior 2026-07-23 full-corpus refresh | yes | Existing durable refresh already certifies every canonical direct-user message since 2026-07-07 through its cutoff; reopened high-impact visibility and PR-proof records in the current extraction. |
| Current thread through latest correction | steering agent | yes | Continuous transparency, headed testing, VS Code/live/hot-reload surfaces; PR proof as separate skill; self-inspect every output; exact GitHub account; gate individual steps; keep PR text readable and relevant instead of concatenating evidence. |

## Emerging Requirements

- No task work may remain visible only as internal reasoning or status prose.
- User must receive a concrete inspectable representation of current understanding and work.
- Allowed display methods must obey the permanent ban on macOS automation and current-turn authority for `open`.
- “Show me first” is a pre-action approval/checkpoint use case, not merely end-of-task evidence.
- A browser claim must include the exact visible target and ensure the user can locate it; “where?” means display failed.
- Long-running or exploratory work needs an early tangible checkpoint, then refreshed checkpoints when the visible state materially changes.
- Display quality matters: inspect the image/browser state yourself and frame the relevant part; irrelevant or broken screenshots are failed evidence.
- Headed/live process is required when watching the behavior is itself the requested proof; static summary cannot substitute.
- Never invoke Finder/browser/editor through macOS automation. Use `open` only when explicitly authorized in the current turn; otherwise surface a clickable absolute artifact path.
- Every checkpoint must answer: current artifact/state, what visibly changed, what remains, and exact next action. Never emit progress theater while no real process/work is advancing.
- Visibility cadence is event-driven: first tangible state, material state transition, failure/blocker, and final artifact. No arbitrary minute-by-minute spam.
- For long operations, show authoritative progress evidence and remain attached; if it fails, expose failure and corrective action instead of leaving a stale “running” view.
- Show the complete causal path when behavior matters: initial state → user action → resulting/persisted state. A partial recording that omits the result fails.
- For multi-state work, map evidence to every requested state/variant/error/viewport; one representative screenshot cannot prove exhaustive scope.
- Reviewer-facing evidence must be current and embedded where requested, but only with current-turn authority for external mutation.
- While `$show-me` is active, headed execution is the default for browser testing. Headless testing is allowed only when no headed equivalent exists, and its live output/result must still be surfaced.
- Keep a continuous course-correction loop: announce the next visible action, expose its live/current artifact, state the observed result, then proceed.
- The latest request explicitly authorizes opening the VS Code/live/browser surfaces needed to demonstrate this skill in the current turn.
- PR-proof mode is separate from continuous transparency: test every matrix row step by step, embed current evidence next to the claim, then reopen and proofread the complete rendered PR.
- Before PR upload/edit, verify the exact required GitHub account, repository owner, author identity, and live authenticated account. Account mismatch is a hard stop.
- Inspect each individual capture and matrix result before advancing. Never trust filenames, commands, or upload success as proof of content.
- Rewrite PR evidence into coherent, readable, current sections. Do not concatenate new blocks onto stale, duplicated, or irrelevant content.

## Execution Receipt

- Latest request: create `$show-me` as continuous transparent execution with visible material steps, headed testing, VS Code/live/hot-reload surfaces, and course correction; create separate `$prove-it-in-pr` for stepwise tests, current embedded PR proof, rendered self-proofreading, exact account verification, per-step inspection, and readable relevant PR content.
- Violated rules: tangible proof and artifact visibility were not enforced as a continuous invariant; prior PR workflows could trust upload/command success, use a wrong account, skip self-inspection, or concatenate stale evidence.
- Instruction files read fully: `shared/AGENTS.md`, `shared/core_profile.md`, `shared/skill_system.md`, Codex config, GYST, un-dumb-yourself, skill-creator, skill-creator `openai_yaml.md`, agent-browser, frontend-design, repo context/workflow/guidelines/style files, `user-demands.md`, `refresh-procedure.md`, and `refresh-2026-07-23.md`.
- Logs read: all 4,595 isolated direct-user messages covered through current readers plus the certified 2026-07-23 refresh for the overlapping large late-history tranche; every direct message in the current thread read raw.
- Notes written: this append-only refresh ledger, per-tranche findings, current GYST receipt, and recovery capsule.
- Conflict resolution: latest raw corrections override older headless requests and stale notes; headed testing is default only while `$show-me` is active; `open` is still current-turn-only; external PR mutation still requires current-turn authority.
- Source of truth: `shared/local-skills/show-me/`, `shared/local-skills/prove-it-in-pr/`, raw prompt corpus, and live generated/installed outputs.
- Corrected immediate action: use `$show-me` and `$prove-it-in-pr` on future triggered tasks; keep their visible and reviewer-facing gates active until explicitly stopped or completed.
- Verification artifacts: both official skill validators pass; all five repo suites passed; affected prompt and transform suites passed again after later edits; managed sync completed; installed source/metadata byte comparisons passed; generated prompt contains both skill triggers; VS Code opened both skill sources and the HTML understanding view; fresh SHOW-ME forward-test exposed three visible course-correction stages; fresh PR-proof forward-test produced stepwise matrix/evidence/rendered-proofreading behavior; fresh wrong-account forward-test stopped before every external write.
- Final self-proofread: read both complete generated skill bodies line by line; corrected the missing `--mute-audio` launch argument; revalidated, resynced, and byte-compared the corrected installed skill.
- Secret/diff checks: scoped high-confidence token/private-key scan returned no matches; `git diff --check` passed.
- Explicit unverified items: `/tmp/show-me-live.html` was opened in VS Code but not rendered through a headed HTTP browser because no authorized server serves it, `file://` navigation is forbidden, and unrelated listeners were not hijacked. This does not block the requested demonstration because the user accepted the visible VS Code/mockup direction and the real skill sources were opened.

## Commit And Push Correction Receipt

- Latest request: “WHY ARE YOU NOT DOING IT THEN??? JESUS CHECK CHECK GO”.
- Violation: answered committed/pushed/refreshed status without completing the explicitly demanded chain.
- Applicable demands: aggression means execution drift; update means fetch first and finish synchronization; inspect every dirty file; never claim pushed or refreshed without live proof; current-turn push authority is now explicit.
- Instruction and note stack: current thread raw messages, `shared/AGENTS.md`, `shared/core_profile.md`, `shared/skill_system.md`, GYST skill, `user-demands.md`, `refresh-procedure.md`, `refresh-2026-07-23.md`, this full current refresh ledger, and the existing recovery capsule.
- Conflict resolution: latest raw “GO” authorizes the commit/push chain; it overrides the prior read-only interpretation. It does not authorize unrelated deployment, PR mutation, or destructive cleanup.
- Source of truth: complete current worktree diff, generated `.build` state, installed skill links, fetched `origin/main`, test results, final git status, and remote tracking counts.
- Notes written: this correction receipt.
- Corrected immediate action: inspect all dirty changes, refresh sync, test, commit, fetch/rebase if needed, push, then prove clean and 0 ahead/behind.
- Verification artifact: full sync exited 0; four changed skills passed official validation; all five repository suites passed; commit `da49fbc` pushed to `origin/main`; remote `refs/heads/main` resolved to `da49fbce0fe924144ac59f07284393f359a92034`; post-push tracking count was `0 0`; worktree was clean.
- Unverified items: none for the requested refresh, commit, push, and synchronization chain.
