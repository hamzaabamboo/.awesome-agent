---
name: hamflow-hamsannet-operations
description: Use whenever Ham asks about HamFlow, Ham-san.net, api.ham-san.net access, stale projects, daily project refreshes, overdue checks, personal or organization repository coverage, or whether the productivity automation actually ran. Perform the live read-only verification and use this workflow even when the request sounds like a simple API-access question.
---

# HamFlow + Ham-san.net Operations

Use this skill for live, read-only inventory and freshness checks across HamFlow and the Ham-san.net Strapi project catalog. The generated Markdown is a projection; HamFlow remains authoritative for task state and Strapi remains authoritative for the Ham-san.net project records.

## Service pairing

- HamFlow tasks and boards: `HAMFLOW_API_URL` from the workspace `.env`; production is `https://flow.ham-san.net` and local development is `http://localhost:3000` only when a listener exists.
- Ham-san.net projects: `https://api.ham-san.net`; the HTTP hostname redirects to HTTPS.
- HamFlow endpoints use the HamFlow bearer credential. Strapi endpoints use `STRAPI_KEY`. Never test one service with the other service's token.
- Send an explicit `User-Agent` on every API request.
- If credentials are absent from the shell, inspect the named workspace `.env` without printing values before reporting access unavailable.

## Authoritative project query

Request the English Strapi collection with:

`GET /api/projects?locale=en&pagination[pageSize]=100&populate=*`

Verify HTTP status, final URL, response count, and `meta.pagination.total`. If the page is smaller than the reported total, continue pagination. Preserve each record's title, slug, `isActive`, date fields, `updatedAt`, description, and GitHub links. Do not infer that an empty `locale=ja` response means the project catalog is empty.

A Strapi 404 on `/api/tasks` is a service-path error: `/api/tasks` belongs to HamFlow; `/api/projects` belongs to Strapi.

## HamFlow task semantics

For overdue reporting, use semantic fields:

- `completed === false`
- `completionState` absent or active
- `dueDate` before the current time

Do not use `columnName` as the completion source. For recurring tasks, compare current-window calendar instances before reporting a recurring master row overdue. Do not mutate tasks during an inventory or freshness check.

## Canonical local refresh

Run from `/Users/hamp/.hermes/workspace`:

`python3 scripts/hamflow/daily_project_list.py`

The same executable is scheduled through:

`python3 /Users/hamp/.hermes/scripts/hamflow_daily_project_list.py`

The refresh writes:

- `memory/hamflow-projects.md`
- `memory/hamflow-projects-state.json`

The note must contain both HamFlow task/project data and all paginated English Strapi project records, including GitHub-linked owner information and freshness fields.

## Verification sequence

1. Read the canonical task record at `/Users/hamp/.awesome-agent/conductor/CURRENT_TASK.md`.
2. Check file sizes before reading workspace docs or generated outputs.
3. Run the canonical refresh from the workspace root and retain its real exit status/output.
4. Read the generated Markdown and JSON state through EOF. Confirm the source timestamps and both service sections.
5. Run the launcher path once as the cron equivalent.
6. List Hermes cron jobs. Confirm the named job is enabled, script-only, points at `hamflow_daily_project_list.py`, and has the expected `09:10 JST` schedule. A null `last_run_at` means scheduled but not yet observed; do not report it as executed.
7. Report separately: live manual execution, launcher execution, cron registration, and observed scheduled execution.

## Coverage boundary

Strapi GitHub links prove which Ham-san.net project records reference personal or organization repositories. They do not prove that every GitHub repository is represented. If exhaustive repository coverage is requested, run the separate GitHub inventory and report GitHub Projects API scope failures independently; do not substitute Strapi counts for repository counts.

## Output contract

Report concrete evidence only:

- endpoint and final URL
- HTTP status and record/task counts
- generated artifact paths and freshness
- manual and launcher exit status
- cron enabled/schedule/last-run state
- personal and organization-linked owners actually found
- blockers or unverified scheduled state

Never print bearer tokens, API keys, `.env` values, or raw credential-bearing headers. Keep the workflow read-only unless the user explicitly requests a specific mutation.
