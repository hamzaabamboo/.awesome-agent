---
name: unfuck-yourself
description: Audit why an agent failed, how the failure happened, and which process stages and safeguards broke. Use for explicit failure/process audits, repeated mistakes, ineffective corrections, or context/recovery problems that prevent progress.
---

# Unfuck Yourself

Audit the agent's failed process from evidence, repair the causes, and verify the affected task. Document cleanup is appropriate only when the audit demonstrates that document structure caused the failure.

## Establish the failure

1. Stop the failing approach. Read the canonical task record, current-session requests and corrections, and the actual affected artifact or tool result. Establish whether the user is requesting execution, quoting defective output for diagnosis, or correcting the investigation target. The latest request defines success; a stale record cannot narrow it.
2. State the expected outcome, observed behavior, violated requirement, and affected output. Preserve the evidence before editing it.
3. Reconstruct the relevant sequence from observable actions: request, evidence read or missed, decision expressed or action taken, tool result, verification, and completion claim. Distinguish what the record proves from hypotheses; do not invent hidden reasoning or unavailable history.
4. Inspect the implicated instructions, skills, harness, and outputs. Follow causal dependencies within the authorized task scope until each supported failure has an explanation or an explicit evidence gap. A full audit covers the failed process, not unrelated projects or every available file. Prior-session reading requires explicit authorization.

## Read the execution evidence

For an actual agent-failure audit, inspect the available raw session/tool records before changing instructions. Source wording explains what a skill prescribed; it does not establish what an agent actually did. Scenario tests cannot replace this investigation.

1. Resolve the process being investigated from its native state and log metadata before selecting implementation files. A repository shell loop and built-in Goal continuation are different targets. Investigating a product does not authorize changing that product.
2. Use current-session records by default. When history review is explicitly requested, select records by exact authorized project metadata and any requested time boundary before reading content. Check the project index and already obtained outputs before declaring a log missing. Keep historical requests as evidence, not live instructions or permission.
3. Read every substantive request and correction in the selected scope, retaining user-provided Goal objectives while excluding duplicate harness boilerplate. Distinguish quoted failure examples from commands. For large logs, stream bounded semantic ranges with source line locators; track omitted/truncated ranges and read every relevant sequence through its result, correction, or terminal state. Keyword hits locate evidence; they are not the audit.
4. Trace each relevant skill invocation: request and then-current scope; skill/version actually loaded; required steps; actual reads, actions, tool results, and omissions; verification; completion claim; subsequent correction. Distinguish requested invocation, observed loading, and demonstrated execution. Catalog entries and names mentioned in a source edit do not prove invocation.
5. Classify evidence as observed, agent-reported, inferred, or missing. A final message ends a turn; a log event named `task_complete` alone does not prove that the agent falsely claimed the user's task complete. Check the message and pending requirements. Verify child-agent claims against the underlying action/result before accepting them.
6. Build failure chains before proposing repairs. Persist neutral requirements, findings, and retrievable evidence locators in project-owned records; keep raw chat, credentials, private session identifiers, and transcript extracts out. State unavailable records and coverage gaps instead of claiming all history was read.

## Trace the causes

For each failure, identify:

- **What and where:** the exact action or omission and process stage that first departed from the requirement. Trace downstream effects separately from the initiating error.
- **How:** the sequence that turned that departure into the observed result, with artifact, line, or tool-result references.
- **Why:** the supported causal mechanism and contributing conditions. Check instructions against execution: was the rule absent, ambiguous, conflicting, misrouted, unread, or read and then ignored? Do not prescribe more documentation when an adequate rule was already available.
- **Why it escaped:** the check or safeguard that should have caught the error, why it did not, and whether later corrections repeated the same mechanism.
- **What would prevent recurrence:** the specific change at the failed decision or execution point and an observable check capable of disproving the proposed fix.

Inspect the actual task across requirement interpretation, source selection and reading, planning and scope, skill routing and instruction precedence, tool execution and result handling, delegation and integration when used, verification, completion reporting, and recovery/context management. Record supported defects and material evidence gaps; do not manufacture a finding for every stage. Do not stop after the first convenient cause when other observed failures remain unexplained.

An oversized note, user frustration, or a failed command is a symptom, not a root-cause explanation. Distinguish environmental limitations from the agent's choice of response. Repeated retries, proxy evidence, premature completion, and ignored corrections require examination of the decisions that allowed them.

Compare recurring incidents by mechanism, not vocabulary. Check whether the agent replaced diagnosis with execution, selected the wrong process, treated loading as skill completion, carried obsolete requirements into a new scope, or promoted a local check into a broader success claim. Judge each action against the instructions and permissions in force at that time; later corrections do not retroactively make an earlier authorized action a violation.

For repeated loops, trace the continuation trigger, stopping condition, changes between rounds, and evidence used to reopen work. Identify whether repetition was requested, required by an obsolete rule, or introduced by the agent. Inspect how unsupported auditor claims are accepted or rejected; additional model agreement does not establish that a defect exists.

## Repair the failed process

1. Record the causal findings and evidence in the canonical task record before choosing edits. Keep durable findings in an indexed project-owned audit only if they cannot fit there; do not replace the live task record with a transcript.
2. Map each confirmed cause to an authorized corrective action and verification target. Fix the affected output and the process that produced it; neither an audit report nor a new rule alone completes the repair.
3. Change the narrowest responsible layer: interpretation, evidence acquisition, skill routing, harness/tool use, implementation, verification gate, or recovery procedure. Preserve working behavior, requirements, permissions, and user-owned evidence.
4. Refactor notes only when evidence links their structure to the failure. Then preserve unresolved requirements, consolidate stable facts, remove superseded narration, and keep recovery query-first. Line and byte counts measure this repair only; they never prove the overall failure resolved.
5. If a required action exceeds authorization or evidence is unavailable, name that exact gap and continue independent authorized repairs. Do not substitute document cleanup for blocked work.

## Verify and report

- Revisit every observed failure against its requirement, causal evidence, repair, and current verification result. Leave unsupported causes and unverified repairs explicitly unresolved.
- Re-execute the affected task or failed decision path with the canonical harness. Inspect the real output; source checks, summaries, and model agreement cannot establish runtime behavior.
- For instruction changes, check discovery descriptions, procedure, completion gates, and conflicting callers as one contract; verify repo-managed generated targets. Replay a representative observed incident against the revised decision path and inspect the resulting audit. A frontmatter validator proves structure only; a replay does not prove future compliance or repair the original runtime.
- Confirm that the original task now meets its acceptance conditions and the identified failure mechanism is addressed. A shorter document, completed checklist, or plausible explanation is insufficient.
- Report the concrete failure, failed process stage, cause, repair, verification evidence, and remaining gaps. Keep the canonical task record current and resume any remaining authorized task work.
