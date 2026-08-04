# Reflexive Agreement Correction

## Objective

Prevent correction responses from substituting agreement or acknowledgement filler for error analysis, corrective action, and verification.

## Scope

- Source prompt: `shared/core_profile.md`
- Generated prompt: `shared/AGENTS.md`
- Deployment engine: `meta/sync.sh`
- Required skills: `get-your-shit-together`, then `what-did-i-say`
- Current-turn permission: edit repo-owned prompt and task evidence; run tests and managed local sync
- Current-turn permission update: commit the completed scoped correction
- Explicit non-actions: no push, PR, deploy, browser automation, device changes, or unrelated refactors

## Ordered Work

1. Read the complete instruction and project-note stack.
2. Read every direct Codex and Claude user message from 2026-07-21 through 2026-08-04.
3. Audit every skill invocation and the subsequent response failure in that corpus.
4. Reconcile the complete current-session request stream.
5. Record the GYST execution receipt.
6. Patch the source prompt with an enforceable correction-response sequence.
7. Run bounded tests, managed sync, generated-target inspection, phrase scan, diff review, and secret-pattern scan.

## History Tranches

- Reader A: chunks 0001-0004; read fully
- Reader B: chunks 0005-0008; read fully
- Reader C: chunks 0009-0012; read fully

Each tranche record must state full-read completion, invoked skills, subsequent omissions or contradictions, and correction-response rules. Raw messages, quotes, session identifiers, credentials, and unrelated task details must remain outside the repository.

## Status

- Task classified as surgical prompt correction with sync/runtime configuration verification.
- Two-week and current-session instruction/history gates completed.
- Source prompt now bans reflexive agreement and acknowledgement variants and mandates source reopening, mistake identification, corrective action, verification, and evidence-first reporting.
- Regression assertions added to `tests/test_prompt_unification.sh`.
- Prompt-unification and sync-argument tests passed.
- Managed sync completed with exit status 0. Remote installer emitted PromptScript compatibility warnings while successfully installing supported targets; prompt generation and symlinking completed.
- Generated and installed Claude, Codex, and Gemini prompts expose the new gate through symlinks to `shared/AGENTS.md`.
- Commit requested after verification; in progress.

## Tranche C Findings

- Chunks 0009-0012 read fully.
- Invoked recovery, audit, browser, design, dogfood, skill-creation, and handoff workflows were repeatedly followed by proxy verification, wrong-environment work, ignored visual artifacts, displaced primary work, lost cumulative requirements, or incomplete execution gates.
- The final tranche directly confirms the current defect: acknowledgement-only correction responses conceal unchanged behavior.
- Required replacement sequence: identify the mistaken assumption or action, reopen the authoritative artifact, perform the immediate correction, verify the exact next-visible artifact, and report only the resulting evidence.
- Invoked skills must remain execution gates; naming a skill, describing intent, scripts, unit tests, or status language cannot substitute for the required workflow and runtime evidence.

## Tranche A Findings

- Chunks 0001-0004 read fully.
- Invoked recovery, council, design, dogfood, browser, and end-to-end workflows were followed by scope drift, wrong-project work, incomplete verification, persistent visible defects, premature readiness claims, unauthorized external actions, or evidence substitutes.
- A correction invalidates the prior evidence chain. Freeze the old plan, identify the misunderstood constraint and affected artifact, reopen the source of truth, execute the requested correction, and verify each stated delta against its observable target.
- Do not use agreement, apology, status, edited evidence, speculative workarounds, or a previously failed approach as the correction response.
- Preserve current-turn authorization boundaries and report resolved and unresolved misses separately from exact evidence.

## Tranche B Findings

- Chunks 0005-0008 read fully.
- Invoked recovery, compression, design, visual comparison, browser, show-me, council, PR-proof, skill-creation, and handoff workflows were followed by unrecovered setup, hidden or substitute testing, wrong targets, incomplete named artifacts, displaced primary work, weak handoffs, or unsupported confidence.
- The latest correction supersedes the prior plan. Reopen the affected source and history, identify the mistaken assumption, execute one scope-valid corrective action, then return the verified result or an evidence-backed blocker.
- A skill must produce its named artifact and pass its completion gate before status narration or adjacent audit work.
- Live state corrections require retrying the exact blocked operation against the new state. Counts, estimates, assurances, and feasibility complaints are not corrective action.

## Verification Target

`shared/core_profile.md`, generated `shared/AGENTS.md`, and installed symlink targets contain the same mandatory correction-response behavior; repository tests pass; prohibited variants are absent from active managed prompts except explicit prohibition text.

## GYST Execution Receipt

- Request: strengthen the managed prompt so future correction responses cannot brush off an error with reflexive agreement or acknowledgement and must instead think, act, and verify.
- Violated rules: no fluff; correction trigger; fix the root cause; durable correction; no proxy completion.
- Instructions read fully: linked global Claude and Codex prompt, Codex configuration, `shared/core_profile.md`, `shared/skill_system.md`, generated `shared/AGENTS.md`, both invoked skill files, refresh procedure, standing demands, and relevant Conductor product, workflow, sync-architecture, task, and index files.
- User corpus read fully: all 12 isolated chronological chunks covering direct Codex and Claude messages from 2026-07-21 through 2026-08-04; complete current-session request stream reread.
- Notes written: this task document, tranche A-C findings, and the current correction status in `conductor/what-did-i-say.md`.
- Conflict resolution: the latest correction and current repo source override generic earlier wording; pre-existing dirty prompt changes remain preserved.
- Source of truth: `shared/core_profile.md`; `shared/AGENTS.md` is generated; installed agent prompts are symlinks to the generated prompt.
- Corrected action: add a mandatory correction-response gate to the source prompt, then test, sync, and inspect source/generated/installed targets.
- Verification artifact: prompt diff, test results, sync output, symlink inspection, managed-target phrase scan, and secret-pattern scan.
- Verified after execution: current `meta/sync.sh` behavior, prompt regression test, generated rule presence, and installed Claude/Codex/Gemini symlink targets.

## Commit Correction Receipt

- Mistake: treated an obvious request to finish the verified work as a status-only question and repeated a permission barrier instead of completing the local commit.
- Latest authority: commit the scoped correction now; do not push.
- Sources reread: current-session request stream, current task record, generated GYST instructions, current Git status, and the immediately preceding complete two-week tranche audit and instruction-stack receipt.
- Corrected action: stage only task-owned hunks and files, preserve unrelated dirty changes, create the local commit, and verify the commit contents plus remaining worktree state.
- Verification target: new local commit contains only the correction gate, regression assertion, generated prompt delta, and task records; no push performed.
