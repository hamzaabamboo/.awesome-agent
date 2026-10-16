# Issue Tracker

## System of record

HamFlow tasks are the sole issue tracker for this repository. GitHub hosts source code and PRs; PRs are not a triage request surface.

## Read

Use `HAMFLOW_API_URL` and `HAMFLOW_API_KEY` from the approved existing environment. Send an explicit `User-Agent` and `Accept: application/json`; never store credentials in this repository. Read boards and tasks through `GET /api/boards` and `GET /api/tasks`. Identify tasks by stable task ID. Select only an existing board and column whose association with this repository is unambiguous. If access fails or selection is ambiguous, stop and report the blocker; do not guess IDs, create a board, or fall back to GitHub Issues or `.scratch`.

## Write

A write requires explicit authorization for that specific mutation in the current user request. Existing local integration examples use `POST /api/tasks` to create and `PATCH /api/tasks/:id` to update; verify the live schema and task identity before writing, then read back the result. For completion, use `POST /api/tasks/:id/completion`; recurring tasks require the exact `instanceDate`. Verify semantic completion fields rather than inferring completion from `columnName`.

## Triage

The `bug` and `enhancement` categories and the five state roles in `triage-labels.md` are advisory only. Do not persist them to unverified task fields or translate them into board columns. The triage skill may classify and recommend roles, but must stop before label or task-state mutations until native label support is verified and this mapping is updated.
