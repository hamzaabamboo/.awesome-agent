# GYST History Scope Correction

## Active task

- Diagnose why agents repeatedly inspect unrelated chat history and sources outside the current session.
- Read the latest relevant Codex and Claude user messages for this project only using the canonical isolation procedure.
- Remove unconditional cross-session history excavation from ordinary skill invocation.
- Preserve exhaustive history reading only when explicitly requested or required by recovery/history skills, always scoped to the current project unless the user explicitly expands scope.

## Authority and scope

- Source of truth: current user correction, repo-managed instruction sources, GYST procedure, latest local Codex and Claude session records.
- Working directory: `/Users/vittayapalotai.tanyawat/.awesome-agent`.
- Branch: `main`.
- Existing dirty files are user-owned and must not be overwritten.
- Current permission: inspect local session records and edit repo-managed instruction sources for this defect.
- Explicit non-actions: no push, deploy, merge, external write, sibling-project chat inspection, broad filesystem inspection, or browser work.

## Skill gate

- `get-your-shit-together`: supplied in full in the current request; coverage `1-EOF` confirmed from the supplied artifact.
- Required linked sources and history range ledger: pending.

## Current diagnosis

- The repo rule under `Every Skill Invocation` requires every skill use to read two weeks of Codex and Claude messages and audit every invocation. This converts bounded skill work into unrelated cross-session excavation.
- The canonical isolation script scans all Codex history and every Claude project without a current-project filter. Even authorized history reads cross project boundaries.
- GYST itself separately requires history reading for history/log requests. The unconditional global rule and unscoped script defeat session and project boundaries.

## History tranche ledger

- Cutoff: 2026-07-23 00:00:00 JST, covering the latest two-week project history requested for diagnosis.
- Scope: Codex session IDs whose session metadata cwd is exactly `/Users/vittayapalotai.tanyawat/.awesome-agent`; Claude records only from the encoded `.awesome-agent` project directory.
- Chunk `messages_aaa`: 53 direct user messages, read fully from record 1 through record 53. Claude contributed no matching records in this period.
- Decisive sequence: the 2026-08-04 request originally placed two-week history review on every skill; the 2026-08-06 correction supersedes it and restricts chat review to the current project. Ordinary skills must use current-session context only; explicit recovery/history review may cross sessions only inside this project.
- Repeated failure: a narrowly requested skill action was displaced by automatic global transcript mining, then the extractor widened further across unrelated Claude projects because it lacked a project argument.
- Preserved requirements: current-task documentation, complete skill-source reads, current-session reconciliation, exact source following, and full reads remain mandatory. Only automatic cross-session and cross-project excavation is removed.

## Next action

- Read the instruction stack, refresh procedure, standing demands, note indexes, and latest current-project session corpus with continuous tranche notes.

## Verification target

- Repo source no longer mandates cross-session history reads for ordinary skills.
- Canonical history isolation requires and enforces an explicit project root.
- Generated AGENTS instructions contain the corrected bounded trigger after sync/tests.

## GYST execution receipt

- Latest request: diagnose repeated pointless chat excavation, read the latest relevant chats, and restrict any authorized history read to the current project.
- Violated rules: scope lock, closed reference set, proportional research, latest-correction authority, and root-cause correction.
- Task classification: surgical managed-prompt, skill, and extractor correction.
- Instruction coverage: supplied current-session `AGENTS.md` artifact `1-EOF`; supplied `get-your-shit-together/SKILL.md` artifact `1-EOF`; `~/.codex/config.toml` lines 1-177 with sensitive values excluded from durable notes; `shared/core_profile.md` lines 1-151; `shared/skill_system.md` lines 1-41; `shared/local-skills/get-your-shit-together/references/user-demands.md` lines 1-276; `refresh-procedure.md` lines 1-27; `isolate_user_messages.sh` lines 1-68 before correction; `shared/local-skills/what-did-i-say/SKILL.md` lines 1-97.
- Project-note coverage: `conductor/index.md` lines 1-14; `product.md` lines 1-27; `product-guidelines.md` lines 1-20; `tech-stack.md` lines 1-22; `workflow.md` lines 1-53; `tracks.md` lines 1-20; `code_styleguides/general.md` lines 1-23; `gyst-20260805.md` lines 1-28; `reflexive-agreement-correction-20260804.md` lines 1-93; `what-did-i-say.md` lines 1-50.
- History coverage: project-filtered chunk `messages_aaa`, records 1-53, read fully; cutoff 2026-07-23 00:00:00 JST through the current request. Matching Claude records: zero.
- Notes written: this task record with live scope, diagnosis, continuous tranche ledger, corrected state, and receipt; `conductor/what-did-i-say.md` supersession record.
- Conflict resolution: the earlier current-project request made two-week history review universal; the latest current-project correction supersedes it. Complete current-session review remains universal. Cross-session review now requires an explicit history/recovery trigger and cannot cross project roots without explicit scope expansion.
- Source of truth: `shared/skill_system.md`, `shared/core_profile.md`, repo-local skill sources, and the indexed Codex thread cwd mapping in `~/.codex/state_5.sqlite`.
- Corrected action: removed universal cross-session excavation, restricted recovery/history skills to current-project sessions, and replaced global rollout scanning with indexed exact-cwd session-id selection.
- Verification artifacts: project-scoped extractor returned 53 Codex and zero Claude records with every output cwd equal to this repo; shell syntax check passed; prompt-unification regression test passed; managed sync completed; generated prompt and skill targets expose the new boundary; source/build extractor files match.
- Explicit unverified items: no other project chats were opened, so their contents were intentionally not inspected; no push, commit, deploy, merge, browser, or external write performed.
