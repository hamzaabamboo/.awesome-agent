---
name: un-dumb-yourself
description: Preserve compact active-task state before context compaction and recover it afterward from the canonical record and named live artifacts. Use when context is high, after compaction when state is missing, or when explicitly requested. Escalate to get-your-shit-together only when evidence shows drift or unresolved state.
---

# Un-Dumb Yourself

Compaction is lossy. Preserve operational state before it happens; reconstruct from evidence after it happens. Never replace investigation with a prettier summary.

## Invocation

- Run `$un-dumb-yourself before` before compression or when context usage becomes high.
- Run `$un-dumb-yourself after` immediately after compression or an automatic conversation summary.
- Run `$un-dumb-yourself` without a mode only when the phase is obvious. If a compaction/summary just occurred, run `after`; otherwise run `before`.

Both modes are query-first. Compaction alone does not justify rereading every instruction, note, handoff, or session record.

## `before`

1. Stop starting new work.
2. Check Goal state when available and read the canonical current-task record. Update its compact task contract, dirty state, proven/unverified evidence, and immediate next action in place.
3. Do not create or reread a full handoff unless responsibility is changing or the user requested one.
4. Read only current-session messages needed to resolve an omission in the canonical record. Never open prior sessions merely because compaction is near.
5. Inspect current authoritative state:
   - working directory, repository, branch, worktree status, and pre-existing dirty files;
   - files changed during this task and whether each change is verified;
   - running foreground command, browser/session state, external operation state, and latest real result;
   - artifacts already read, artifacts still unread, blockers, and unanswered questions.
6. Write `/tmp/un-dumb-yourself/$CODEX_THREAD_ID.md` only when the canonical record cannot hold the immediate volatile state without exceeding its 200-line or 16-KiB limit. Replace the same thread file atomically. Use this exact structure:

```markdown
# Recovery Capsule

## Task Contract
- Exact latest user request:
- Required completion:
- Explicit non-actions:
- Current-turn external-write authority:

## Source of Truth
- CWD:
- Repo and branch:
- User-provided assets:
- Relevant instructions/specs:

## State
- Pre-existing dirty state:
- Changes made this task:
- Commands/processes still active:
- Browser/external state:

## Verification
- Proven:
- Failed:
- Unverified:

## Decisions
- Settled decisions:
- Rejected approaches:
- User corrections:

## Resume
- Immediate next action:
- Remaining ordered work:
```

7. Keep exact identifiers, paths, URLs, error text, counts demanded by the user, and binary statuses. Omit generic narrative.
8. Persist durable rules or project decisions in their authorized repo-owned instruction/task files. Update the canonical current-task record in place before writing the capsule. Keep the capsule ephemeral; never commit it or substitute it for durable project documentation.

## `after`

1. Assume the generated summary is incomplete.
2. Check Goal state when available, then read the canonical current-task record fully.
3. Read a recovery capsule only if the canonical record names it or lacks required volatile state. Inspect only live artifacts named for the immediate next action.
4. Re-read current-session messages only when a requirement is absent or ambiguous in the record. Do not inspect prior-session records unless explicitly authorized.
5. Reconcile conflicts by authority:
   - latest user message;
   - user-provided asset or named source-of-truth artifact;
   - current live system/repository state;
   - capsule;
   - generated compaction summary.
6. Invoke `$get-your-shit-together` only if recovery reveals drift, a violated rule, contradictory authority, or an explicit user trigger. Normal compaction recovery does not invoke it.
7. Read a handoff only when the canonical record identifies it as current authority for this task. Never search for or create one as generic recovery ceremony.
8. Resume at the canonical record's `Immediate next action`. Do not restart completed work, rerun destructive/external actions, reopen settled decisions, or claim completion from the capsule or generated summary.
9. Update the canonical current-task record in place as work proceeds, then update the capsule before the next compaction.

## Failure Conditions

- Do not rely on the compaction summary alone.
- Do not refuse `after` because `before` was not run or its capsule is unavailable.
- Do not turn routine recovery into full `$get-your-shit-together` execution without its actual trigger.
- Do not reduce requirements to vague prose.
- Do not lose which files were dirty before the task.
- Do not turn past push/deploy/comment permission into current permission.
- Do not treat planned, plausible, or previously claimed work as verified.
- Do not ask the user for state recoverable from logs, files, tools, or the capsule.
