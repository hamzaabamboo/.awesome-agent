---
name: unfuck-yourself
description: Use when project notes or task records exceed 200 lines or 16 KiB, recovery repeatedly loads irrelevant files, or the same task compacts more than once without meaningful progress.
---

# Unfuck Yourself

Repair the context system causing wasted tokens. Produce a smaller query path, not another audit document.

## Diagnose

1. Read the canonical task record and latest correction.
2. Measure only project-owned task, note-index, and note files named by that record. Use byte/line metadata before content.
3. Trigger repair when any condition is true:
   - live task record exceeds 200 lines or 16 KiB;
   - one note mixes multiple unrelated topics or repeats superseded status;
   - recovery opens files not needed for the immediate next action;
   - the active task compacts twice before a meaningful milestone.
4. Identify the cause: append-only status, duplicated rules, raw transcript storage, stale receipts, missing index terms, recursive recovery pointers, or an oversized mixed-topic note.

## Refactor

- Replace the live record with current contract, state, evidence, permissions, and one next action.
- Keep stable reusable facts once, in focused topic notes linked from the project index.
- Merge duplicate rules into the narrowest authoritative file and update pointers to it.
- Remove superseded narration, raw chat, command diaries, repeated receipts, and stale copied facts from live context.
- Make compaction recovery read Goal state, the canonical record, and only artifacts named for the next action.
- Preserve user-owned evidence and unresolved requirements. Never delete uncertain material; move it to a focused historical note only when it remains useful.

## Verify

Report before/after line and byte counts, the exact query path for resuming the current task, and every authoritative file changed. Confirm:

- canonical record is within 200 lines and 16 KiB;
- each active requirement and permission remains represented once;
- a fresh recovery needs no unrelated note, history, handoff, or global instruction reread;
- repeated-compaction cause is removed or named as still unresolved;
- generated and installed skill targets match repo source when this repository manages them.

Stop when recovery is direct and bounded. Do not create a new report that recreates the bloat.
