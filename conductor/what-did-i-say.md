# What Did I Say

## Objective

Create two repo-local skills and a universal skill-invocation rule that prevent visual evidence, rapid-fire instructions, cumulative requirements, and skill gates from being ignored.

Current correction task: eliminate reflexive agreement and acknowledgement phrases from the managed core prompt, require explicit error identification and corrective action before responding, sync the generated prompt targets, and verify the deployed text.

Current request: recover every active instruction concerning all services from the actual Codex and Claude user-message history, reconcile it, and answer without guessing.

Latest correction: ordinary skill invocation must not trigger cross-session history excavation. Explicit history/recovery reads are bounded to sessions belonging to the current project unless broader scope is explicitly requested. Current-session reconciliation and current-task documentation remain mandatory for every skill invocation.

## Current execution: council loop correction

### Request

Inspect the council skill's repeated-audit completion gate, identify why execution continues after a valid clean result, remove any requirement for two consecutive clean rounds unless the active task explicitly requires it, and continue from the latest valid evidence.

### Active requirements

- Invoke `get-your-shit-together` because the user reported drift and frustration.
- Invoke `the-council` because the current request concerns its execution contract.
- Read each invoked skill and every required linked source completely from line 1 through EOF before acting.
- Keep the investigation scoped to this `.awesome-agent` workspace and the named council/GYST artifacts.
- Do not inspect unrelated sessions or projects.
- Do not commit, push, deploy to an external service, open a PR, or perform remote writes in this turn.
- Repo-managed local skill synchronization is in scope because the corrected source must replace stale generated targets.
- Preserve unrelated existing worktree changes.
- Verify the corrected completion behavior against the authoritative skill source and relevant validation checks.

### Status

- Current task record: updated before skill-directed work.
- Skill source inspection: `the-council/SKILL.md` 1–81 EOF; `get-your-shit-together/SKILL.md` 1–50 EOF; `user-demands.md` 1–276 EOF; `core_profile.md` 1–151 EOF; `skill_system.md` 1–41 EOF; global `AGENTS.md` 1–212 EOF; Codex config 1–177 EOF.
- Root cause: `the-council` made two clean rounds the universal success condition and instructed indefinite continuation at non-convergence.
- Root-cause correction: applied to `shared/local-skills/the-council/SKILL.md`; one complete clean round is the default, explicit repeat thresholds remain authoritative, and blind non-convergence repeats now escalate.
- Generated target state: stale before sync; `.agent/skills` resolves to `.build/skills`, while `.agents` and `.claude` skill entries resolve to that generated tree.
- Verification: source validation passed; isolated repo-managed sync completed; generated-target comparison passed.

### Source and verification targets

- `shared/local-skills/the-council/SKILL.md`
- `shared/local-skills/get-your-shit-together/SKILL.md`
- Any directly required references named by those skill files.
- Final diff and targeted skill validation.

### GYST execution receipt

- Request: correct the council execution contract so it does not impose an unrequested repeated-clean-round gate or continue blindly after the evidence stops changing.
- Violations found: the council skill required two clean rounds universally; its non-convergence branch required continued looping after repeated rounds; one per-item rule still referred to a terminating pair after the gate changed.
- Sources read completely: `the-council/SKILL.md` 1–81 EOF before and after correction; `get-your-shit-together/SKILL.md` 1–50 EOF; `user-demands.md` 1–276 EOF; `core_profile.md` 1–151 EOF; `skill_system.md` 1–41 EOF; generated global `AGENTS.md` 1–212 EOF; Codex config 1–177 EOF; `meta/sync.sh` 1–534 EOF; validator 1–101 EOF.
- Notes written: this task record updated before skill work, during correction, and at verification; no history extraction was performed because the request did not authorize history review.
- Authority resolution: latest user correction and the live council source overrode the older evidence-report convention that had been generalized into the skill.
- Corrected action: default completion is one fully-clean panel round; explicit repeat or stability thresholds remain authoritative; malformed auditor returns retry at most once; unchanged non-convergence escalates instead of looping.
- Verification artifact: validator returned `Skill is valid!`; isolated sync completed; source and generated `.build`, `.agent`, `.agents`, and `.claude` council skills compare equal; `git diff --check` passed; temporary sync root removed.
- Unverified: no separate live council run was active in this turn, so no runtime audit result was generated; the corrected loaded skill targets are verified byte-for-byte.

## Current execution: model-output trust correction

### Request

Add an explicit execution gate requiring the steering agent to investigate and independently verify model or subagent output before accepting it as evidence, a finding, a fix, or a completion signal.

### Active requirements

- Invoke `get-your-shit-together` for the reported trust-boundary failure.
- Reopen the authoritative managed instruction and skill sources before changing them.
- Treat every external model verdict as an untrusted claim until independently checked against the primary artifact, runtime, or reproducible test.
- Do not allow a model-generated recommendation to become both evidence and acceptance authority.
- Keep scope limited to this workspace's managed instructions and relevant skill source.
- Preserve unrelated dirty changes; no commit, push, deploy, PR, or remote write.
- Update the task receipt and verify source plus generated targets.

### Status

- Task record: updated before skill-directed work.
- Source audit: `get-your-shit-together/SKILL.md` 1–50 EOF; `the-council/SKILL.md` 1–85 EOF; `core_profile.md` 1–152 EOF; `user-demands.md` 1–276 EOF; generated `AGENTS.md` 1–212 EOF; `skill_system.md` 1–41 EOF; Codex config 1–177 EOF.
- Root cause: source instructions required independent auditors but did not require the steering agent to independently validate each auditor claim before accepting it as evidence or acting on it.
- Trust-boundary correction: applied to `core_profile.md`, GYST, `the-council`, and `user-demands.md`; generated targets were stale before sync and are current after sync.
- Trust-boundary propagation: isolated repo-managed sync completed; generated `AGENTS.md` and skill targets now contain the gate.
- Verification: source validators passed; direct generated-target checks passed; final diff check passed.

### GYST execution receipt

- Request: require investigation of model and subagent output before accepting it as evidence, a finding, a fix, or a completion signal.
- Violated rules: independent auditors were required, but the steering agent was not explicitly required to validate each auditor claim against the primary artifact or canonical runtime; model agreement could therefore be mistaken for verification.
- Sources read completely: `get-your-shit-together/SKILL.md` 1–50 EOF; `the-council/SKILL.md` 1–85 EOF after correction; `core_profile.md` 1–152 EOF after correction; `user-demands.md` 1–276 EOF after correction; generated `AGENTS.md` 1–213 EOF after sync; `skill_system.md` 1–41 EOF; Codex config 1–177 EOF. Current task record was read before update.
- Notes written: this task record updated before skill work, after source diagnosis, and during verification; no cross-session history extraction was performed.
- Authority resolution: latest user correction and current source files overrode the prior assumption that independent auditor outputs were sufficient evidence.
- Corrected action: added an explicit trust boundary to the general prompt, GYST, council, and durable-demand source; council now requires primary-artifact or canonical-runtime validation before a finding can drive a fix or completion decision.
- Verification artifact: both skill validators returned `Skill is valid!`; isolated sync exited successfully; source and generated skill targets compare equal; generated `AGENTS.md` contains the general trust rule; initial temp-prompt comparison returned status 2 because the configured `AGENTS_MD` correctly pointed at the repo source, so that invalid check was discarded rather than counted as a pass.
- Unverified: no live product workflow was involved; this was a surgical instruction/configuration correction, not browser/runtime testing.

## Active requirements

- Create `look-at-the-screen`.
- Require direct inspection of every relevant supplied or rendered visual artifact before visual reasoning, changes, verification, or completion claims.
- Create `what-did-i-say` using that exact normalized skill name.
- Create `stop-inventing`.
- Require complete reading of every referenced source before action, then literal conformance to those references without invented requirements, features, data, fallbacks, interpretations, or substitutions.
- Re-read every direct user request in the current session before continuing when instructions arrive rapidly or the user reports missed requirements.
- Read the complete request stream, reason across it as one evolving specification, and execute technically coherent authorized instructions literally.
- Maintain an ordered todo containing every active request, dependency, skill gate, artifact, permission, prohibition, status, next action, and verification target.
- Document the complete current task in a project-owned file and keep it updated throughout execution.
- Apply current-task documentation to every skill invocation through the central skill-system policy.
- For every skill invocation, reconcile the complete current session, preserve literal operative wording, and execute the resulting requirements without opening unrelated sessions.
- Use past Codex and Claude history only when explicitly requested or required by a recovery/history skill, and filter the corpus to the current project before reading messages.
- Keep raw chat content and private history out of Git-managed artifacts unless explicitly requested.
- Do not commit, push, deploy, open a PR, or upload anything in this turn.
- Install the created skills into the managed agent environments so they appear in the skill interface; local configuration sync is authorized as the required completion step.
- Do not use agreement or acknowledgement filler after a correction.
- State the concrete mistake, reopen the source of truth, change the behavior or artifact, and report verification.
- Modify the repo-owned prompt source rather than patching generated or external agent targets directly.
- Sync the prompt change through the managed engine after tests pass.

## Status

- `look-at-the-screen`: implemented; validation passed.
- `what-did-i-say`: implemented; incorporating current-task documentation requirement.
- `stop-inventing`: implemented; validation passed.
- Universal every-skill documentation policy: implemented in `shared/skill_system.md`.
- Two-week Codex and Claude audit: completed; temporary extracted history deleted.
- Managed-agent sync: completed; all three skills generated under `.build/skills`, installed under `~/.agent/skills`, and linked under `~/.agents/skills`.
- Cross-session every-skill requirement: superseded because it caused automatic unrelated transcript excavation; project-scoped replacement is in progress.
- Reflexive-agreement correction: in progress; source prompt and sync path pending inspection.

## Verification

- Validate both skill folders with the Skill Creator validator.
- Inspect all new and modified task files for raw chat quotes, private history, timestamps, and session identifiers.
- Inspect Git status and diff; preserve pre-existing user changes.
