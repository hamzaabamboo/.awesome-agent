---
name: un-dumb-yourself
description: Run get-your-shit-together in full and preserve exact active-task state before context compaction; reconstruct task state and run get-your-shit-together in full again after compaction without trusting a lossy summary. MUST fire when context usage is high, compaction is imminent, a continuation is about to lose detailed history, immediately after any compaction or automatic conversation summary, or when the user says "un-dumb-yourself", "before compression", "after compression", "you forgot everything", or equivalent. Both before and after modes mandate full re-grounding, not state capture alone.
---

# Un-Dumb Yourself

Compaction is lossy. Preserve operational state before it happens; reconstruct from evidence after it happens. Never replace investigation with a prettier summary.

## Invocation

- Run `$un-dumb-yourself before` before compression or when context usage becomes high.
- Run `$un-dumb-yourself after` immediately after compression or an automatic conversation summary.
- Run `$un-dumb-yourself` without a mode only when the phase is obvious. If a compaction/summary just occurred, run `after`; otherwise run `before`.

Both modes are first-class. Both must execute `$get-your-shit-together` in full. Never merely mention, summarize, or assume GYST happened.

## `before`

1. Stop starting new work.
2. Load `$get-your-shit-together` and execute its entire procedure against the current task. Finish its instruction-stack reread, applicable-demand extraction, mistake confrontation, source-of-truth realignment, and durable-rule persistence before continuing.
3. Load `$handing-off-pro-max` and write the complete project-owned handoff before creating this compact recovery capsule. The handoff preserves everything needed by a successor; this capsule only preserves the immediate resume state.
4. Read every user message since the previous capsule. Preserve exact wording for requirements, corrections, prohibitions, completion criteria, and current-turn authority.
5. Inspect current authoritative state:
   - working directory, repository, branch, worktree status, and pre-existing dirty files;
   - files changed during this task and whether each change is verified;
   - running foreground command, browser/session state, external operation state, and latest real result;
   - artifacts already read, artifacts still unread, blockers, and unanswered questions.
6. Write `/tmp/un-dumb-yourself/$CODEX_THREAD_ID.md`. Create the directory if needed. Replace the same thread file atomically. Use this exact structure:

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
8. Persist durable rules or project decisions in their authorized repo-owned instruction/task files. Keep the capsule ephemeral; never commit it or substitute it for durable project documentation.

## `after`

1. Assume the generated summary is incomplete.
2. Read `/tmp/un-dumb-yourself/$CODEX_THREAD_ID.md` fully. If no capsule exists, continue recovery from the current Codex session record and live state; missing `before` output must not make `after` unusable.
3. Inspect actual current workspace, processes, browser/external state, and artifacts named by the capsule.
4. Re-read the latest user messages from the current conversation. If any requirement is uncertain, inspect the current Codex session record after checking its size; recover the user's exact words instead of guessing.
5. Reconcile conflicts by authority:
   - latest user message;
   - user-provided asset or named source-of-truth artifact;
   - current live system/repository state;
   - capsule;
   - generated compaction summary.
6. Load `$get-your-shit-together` and execute its entire procedure against the reconstructed current task. Do not resume work until its instruction-stack reread, applicable-demand extraction, mistake confrontation, source-of-truth realignment, and durable-rule persistence are complete.
7. Read the project-owned `handing-off-pro-max` artifact named by the capsule before resuming. If the capsule does not name one, locate the latest project handoff; if none exists, create it with `$handing-off-pro-max` before material work.
8. Resume at `Immediate next action`. Do not restart completed work, rerun destructive/external actions, reopen settled decisions, or claim completion from the capsule.
9. Update the capsule before the next compaction.

## Failure Conditions

- Do not rely on the compaction summary alone.
- Do not refuse `after` because `before` was not run or its capsule is unavailable.
- Do not replace full `$get-your-shit-together` execution with capsule recovery.
- Do not reduce requirements to vague prose.
- Do not lose which files were dirty before the task.
- Do not turn past push/deploy/comment permission into current permission.
- Do not treat planned, plausible, or previously claimed work as verified.
- Do not ask the user for state recoverable from logs, files, tools, or the capsule.
