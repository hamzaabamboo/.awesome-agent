---
name: what-did-i-say
description: Re-read and reconcile every direct user message from the previous two weeks of Codex and Claude sessions plus the complete current session into one authoritative, ordered todo before responding or continuing work. Audit every skill invocation and what subsequently went wrong, then execute the user's operative wording literally. Use when the user invokes `$what-did-i-say`, asks what they said or requested, sends multiple rapid-fire additions or corrections, says instructions were missed or ignored, refers to earlier or cross-session instructions, or expresses frustration that cumulative requirements, skill invocations, priorities, permissions, or explicit non-actions were lost.
---

# What Did I Say

Treat the previous two weeks of Codex and Claude user history plus the current session as one evolving specification. Read all of it, reason across all of it, then execute what the user said as written.

## Stop and Re-read

1. Stop the active workflow.
2. Read every direct user message from all Codex and Claude sessions covering the previous two weeks.
3. Re-read every direct user message in the current session from the first task-defining message through the latest correction.
4. Include rapid-fire messages, short fragments, attachments, skill invocations, answers to prior questions, objections, permission changes, and scope corrections.
5. Exclude assistant summaries, generated compactions, tool output, subagent traffic, and stale interpretations as sources of user intent.
6. For every skill invocation in the two-week corpus, read the complete surrounding request sequence and identify what the agent subsequently missed, ignored, contradicted, displaced, or failed to verify.
7. Reopen any referenced artifact needed to interpret a message. Never fill a missing detail from memory when the session or artifact contains it.
8. Think across the complete cross-session request stream before decomposing it. Resolve pronouns, fragments, repeated emphasis, sequencing, and dependencies from the whole history rather than message by message.
9. Preserve the user's exact operative wording in the transient working ledger. Do not soften, narrow, summarize away, or substitute a more convenient interpretation.

Do not answer from the latest message alone when preceding messages are still active.

## Build the Live Request Ledger

Create or update a project-owned current-task document. Maintain an ordered todo with these fields:

- request
- source order
- status: pending, in progress, completed, superseded, or blocked
- priority
- dependencies
- required skill
- source-of-truth artifact
- verification target
- permission granted this turn
- explicit non-actions

Document every active request and preserve its complete operational meaning. Keep exact raw wording in transient session context unless the user explicitly requests verbatim persistence. Do not copy chat transcripts, session identifiers, or unrelated private history into repository files, skills, notes, fixtures, or evidence.

Update the document immediately after every new request, correction, override, completed item, failure, changed artifact, or verification result. Do not defer documentation until handoff or completion.

## Reconcile the Stream

Apply these rules in order:

1. Latest direct correction overrides conflicting earlier instructions.
2. Additions accumulate; they do not replace unfinished requests unless the user says they do.
3. A short fragment continues the current request when its meaning depends on nearby messages.
4. Repetition increases priority and signals an unresolved failure; it is not duplicate noise.
5. Explicit scope, permissions, and prohibitions remain active until the user changes them.
6. Completed work stays completed unless the user reports contrary evidence or requests re-verification.
7. Do not replace requested implementation with planning, testing, auditing, or reporting unless that order was requested or is a required safety gate.
8. Do not let a later status question erase the underlying unfinished task.
9. Execute literal wording when it is technically coherent and authorized. Do not silently reinterpret it into a smaller, safer-looking, easier, or more conventional task.
10. When literal wording is impossible, unsafe, unauthorized, or internally contradictory, identify the exact blocking clause. Preserve and execute every unaffected clause.

If two active instructions still conflict after applying these rules, state the exact conflict and ask only for the decision that cannot be recovered from the session or live state.

## Execute Skill Invocations

Treat every explicit skill invocation as a hard workflow requirement:

1. Add it to the ledger at its original position.
2. Read the complete skill instructions.
3. Add every required action, pause, artifact, and completion gate to the ledger.
4. Execute the skill; loading or mentioning it is not completion.
5. Preserve ordering between skills and task work.
6. Do not let an audit, review, or verification skill displace unfinished primary work unless its instructions require that gate at that point.
7. Record observable proof that the skill's required procedure ran.

When multiple skills apply, order them by dependency: re-grounding and state recovery, primary task work, direct artifact inspection and real verification, reviewer evidence, then final audit.

## Resume from the Ledger

Before resuming:

1. State the reconstructed active objective in one concise sentence.
2. Surface the ordered pending todo faithfully. Paraphrase only for chat brevity when no precision is lost.
3. Name the next concrete action and why it is next.
4. Continue execution without waiting for confirmation unless a real unresolved conflict or permission boundary remains.
5. Update the ledger after every material user message and completed item.

For rapid-fire input received during execution, pause at the next safe boundary, re-read the entire new sequence, merge it into the ledger, and course-correct before continuing.

## Completion Gate

Before reporting completion:

1. Re-read every direct user message from the previous two weeks of Codex and Claude sessions and every direct user message in the current session again.
2. Reconcile each request against the ledger.
3. Verify every non-superseded item is completed or explicitly blocked.
4. Execute every invoked skill's completion gate.
5. Inspect the exact artifact the user will check next.
6. Report remaining items directly. Never hide them behind a summary or completion claim.

No complete two-week Codex and Claude read plus current-session re-read means no claim that all instructions were handled.
