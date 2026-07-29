---
name: handing-off-pro-max
description: Produce a complete, continuation-safe operational handoff before context compression, changing the agent handling a project, stopping work, leaving documentation, or whenever the user says handoff, hand over, continue later, preserve context, everything in context, exact commands, or no summary. Use this before `un-dumb-yourself before`; it replaces vague status summaries with a current, exhaustive, evidence-backed handoff another agent can execute without rediscovery.
---

# Handing Off Pro Max

Create a handoff that another capable agent can resume immediately. This is not a status update, retrospective, or executive summary. It is the task's operational state, method, evidence, failures, exact commands, decisions, and remaining work.

Run this skill before context compression, a model/agent/project-owner change, ending active work with documentation, or an explicit handoff request. Do not resume new work until the handoff is written and its current-state claims are checked.

## Authority and scope

1. Read the latest raw user request, current task instructions, project instructions, existing handoff docs, active task/issue/PR artifacts, and the source-of-truth artifact for the task.
2. Check every file/log size before reading it. For files larger than 500 KB, use bounded targeted reads and name the range inspected.
3. Treat the current workspace, live process/browser/external state, and latest raw user correction as authoritative over prior handoffs.
4. Preserve pre-existing dirty changes. Name their ownership or mark it unknown; never attribute them to this task without evidence.
5. Do not push, deploy, merge, post, or perform a new external write merely to make the handoff look complete.

## Required investigation

Inspect and record, not infer:

- exact working directory, repository, branch, HEAD, remote/base only when relevant, worktree status, and every changed/untracked path relevant to the handoff;
- task contract, named artifacts, current-turn permissions, explicit non-actions, and completion criteria;
- current processes, ports, browser sessions, external jobs, auth/tenant/data constraints, and whether each is actually usable;
- every command run in the task, in chronological order, with exact invocation, working directory, intent, material output, exit state, and whether it is safe to rerun;
- all changed files with the purpose, state before/after, reasoning, dependency/call path, and current verification;
- all documents, notes, screenshots, recordings, dashboards, logs, test output, PRs, tickets, datasets, and generated artifacts used or created, using exact paths/URLs/identifiers;
- failed approaches, false positives, stale evidence, traps, rejected decisions, and why each is not to be repeated;
- verified facts, failed facts, unknown facts, and blockers. `blocked`, `not run`, `code-inspected`, and `browser-proven` are distinct states.

If history was read, append a tranche ledger while reading. State the source, time range, direct user messages read, durable note path, and unresolved conflicts. Never reconstruct the ledger from memory after the fact.

## Write the handoff

Write it to the project-owned documentation location. If no established location exists, create `docs/HANDOFF_YYYY-MM-DD.md` at the project/umbrella-repo level, never inside a deployable package unless that package owns the documentation. Use a descriptive title.

Use this structure. Do not omit a section; write `None`, `Not applicable`, or `Unknown — reason` only after checking.

```markdown
# <Project/task> — full handoff and methodology, <date>

Everything required to resume this task without rediscovery. This is not a summary.

# PART I — TASK CONTRACT AND LIVE STATE

## 1. Exact task contract

- Latest raw user request:
- Required completion:
- Explicit non-actions:
- Current-turn authority:
- Source-of-truth artifacts and precedence:

## 2. Ground truth: repository and working tree

| Field | Current value | Evidence command/artifact |
|---|---|---|
| Working directory | | |
| Repository and branch | | |
| HEAD | | |
| Base/PR state when relevant | | |
| Pre-existing dirty state | | |
| Task changes | | |
| Untracked artifacts | | |
| Ownership uncertainty | | |

List each relevant changed/untracked path. State whether it was pre-existing, task-created, externally changed, or unknown. Include the command used to establish that classification.

## 3. Environment and operational rules

Document actual runtime commands, required environment variables by name only, ports/URLs, agent/browser launch prefix, auth/tenant state, process state, test concurrency caps, filesystem constraints, and commands that must not run together. State every observed failure mode and recovery command.

# PART II — COMPLETE EXECUTION RECORD

## 4. Chronological command and action ledger

For every material command/action, preserve this exact information:

| Order | Timestamp or phase | CWD | Exact command/action | Why | Material output/exit | Safe to rerun? |
|---|---|---|---|---|---|---|

Include manual browser actions, source reads, tool calls, data mutations, test runs, and recovery actions. Keep full commands. Do not replace commands with “ran tests”, “checked logs”, or prose paraphrases.

## 5. Methodology and decision record

Explain the exact method used, in execution order. For every decision, include:

- observed evidence and source;
- alternatives considered and rejected;
- why the selected path matches the task contract;
- dependencies/call paths/data flow affected;
- what a successor must preserve.

## 6. Files and artifacts

For every relevant file/artifact:

| Path/URL/ID | Role | State before | Exact change or observed content | Verification | Ownership | Resume instruction |
|---|---|---|---|---|---|---|

Include docs, screenshots, videos, logs, generated files, dashboards, scratchpads, test fixtures, PR artifacts, and external references. Never say “see previous work” without the exact location and what it proves.

# PART III — EVIDENCE, FAILURES, AND HONESTY

## 7. Verification matrix

| Requirement/claim | Required evidence layer | Exact evidence artifact | Current result | What remains unverified |
|---|---|---|---|---|

Use the actual layer the task needs: source, unit, integration, browser, device, CI, PR, deploy, or external system. Do not allow a weaker layer to imply a stronger one.

## 8. Failures, traps, and rejected approaches

For every failed command, false pass, stale artifact, wrong assumption, or rejected approach:

| Item | Exact symptom/evidence | Root cause | Why it was rejected | Do not repeat / recovery |
|---|---|---|---|---|

Include operational traps such as cwd reset, stale build output, incompatible concurrent processes, browser safety constraints, environment mismatches, and incorrect routes/components. Preserve real error text where it changes the next action.

## 9. Known limitations and blockers

For each blocker, name the exact missing authority, data, credential, service, device, or external action; prove that it blocks the named requirement; list safe work completed around it; and state the first action after it clears. Blocked is never a pass.

# PART IV — RESUME WITHOUT REDISCOVERY

## 10. Immediate next action

One concrete first action, including CWD, exact command/tool action, expected observation, and branch on success/failure.

## 11. Remaining ordered work

Number every remaining item. For each: prerequisite, exact target, method, verification artifact, and stop condition. Do not replace this with a generic backlog.

## 12. Command cookbook

Include copyable, current commands for setup, state checks, test gates, browser/runtime verification, artifact generation, and recovery. Keep commands scoped and safe. Mark commands that must not run concurrently or require fresh user authority.

## 13. Handoff receipt

- Handoff authoring time:
- Live state checked at:
- Sources read:
- Logs/history ranges read:
- Durable notes written:
- Exact verification artifact inspected after writing:
- Explicitly unverified items:
```

## Handoff quality gate

Before leaving the task:

1. Re-inspect every fact that can drift: git status/branch/HEAD, active process state, browser/runtime URL, changed files, current artifacts, and external state named in the handoff.
2. Read the finished handoff from top to bottom against the latest user request and the source-of-truth artifact.
3. Confirm another agent can identify the exact first command, current state, every important prior command, every changed artifact, every failure/recovery path, and every unverified requirement without searching the old conversation.
4. Record the exact verification artifact in `## 13. Handoff receipt`.
5. If compression is next, update `/tmp/un-dumb-yourself/$CODEX_THREAD_ID.md` only after this handoff is complete, then invoke `un-dumb-yourself before`.

## Courta reference standard

The reference handoff is `/Users/vittayapalotai.tanyawat/uhh/courta/docs/HANDOFF_2026-07-28.md`. It is a format and thoroughness reference, not task-specific authority. Its required qualities are: state before narrative, complete methodology, exact commands, observable evidence, non-repeatable traps, decision reasons, explicit unknowns, and ordered continuation steps.
