---
name: ralph-playbook
description: Use this skill whenever the user wants to set up, apply, adapt, or audit the Ralph methodology from ClaytonFarr/ralph-playbook in a real repository. Trigger on requests about Ralph loops, Geoff Huntley’s workflow, autonomous coding loops, IMPLEMENTATION_PLAN.md, AGENTS.md, specs workflows, plan/build prompt files, brownfield reverse-engineering into specs, or branch-scoped Ralph planning.
---

# Ralph Playbook

Apply the Ralph playbook as an operating model, not as a cargo-cult file drop.

This skill ships with bundled templates and a scaffold script:

- `references/ralph-playbook-guide.md`
- `references/sandbox-environments.md`
- `assets/AGENTS.md`
- `assets/IMPLEMENTATION_PLAN.md`
- `assets/PROMPT_plan.md`
- `assets/PROMPT_build.md`
- `assets/PROMPT_specs.md`
- `assets/PROMPT_reverse_engineer_specs.md`
- `assets/PROMPT_plan_work.md`
- `assets/loop.sh`
- `assets/loop_streamed.sh`
- `assets/parse_stream.js`
- `scripts/scaffold.sh`

Use the scaffold script when the user wants the Ralph file set created quickly in a repository. Use manual adaptation when the target repo already has partial Ralph artifacts or needs careful merging.

Prefer the smallest useful footprint. Leave only the durable repository artifacts Ralph actually needs. Avoid scratch files, duplicated notes, exported summaries, or temporary work products unless they are necessary for the task, and clean them up when they are no longer needed.

The bundled loop defaults to a YOLO-style autonomous Codex run. If the operator wants a sandboxed fallback, they can set `RALPH_APPROVAL_MODE=safe` before running the loop.

Start by reading the target repository and determining which part of the Ralph funnel is missing or stale:

- requirements definition
- specs hygiene
- implementation planning
- building from plan
- brownfield reverse-engineering
- branch-scoped planning

If the repository already has loop files, prompt files, specs, or planning artifacts, study them before changing anything. Do not assume functionality is missing.

## Core model

Ralph is a three-phase funnel with one persistent outer loop:

1. Define requirements
2. Plan from specs and current code
3. Build from the plan in single-task iterations

The loop is intentionally simple:

- one loop iteration should complete one meaningful task
- each iteration starts with fresh context
- state persists on disk through markdown artifacts, especially `IMPLEMENTATION_PLAN.md`
- the main agent acts as scheduler/coordinator
- subagents do the expensive reading, searching, implementation, and validation work

Prefer markdown artifacts over JSON unless the repository already has a stronger existing convention.

## Required artifacts

When setting up Ralph in a repository, the canonical artifacts are:

- `specs/*.md`: source-of-truth requirements, one topic per file
- `IMPLEMENTATION_PLAN.md`: prioritized worklist derived from specs vs current code
- `AGENTS.md`: brief operational instructions only
- `PROMPT_plan.md`: planning-mode loop prompt
- `PROMPT_build.md`: building-mode loop prompt
- `loop.sh`: outer loop runner

Optional artifacts when they fit the repo:

- `PROMPT_specs.md`: spec authoring/audit mode
- `PROMPT_reverse_engineer_specs.md`: brownfield spec generation mode
- `PROMPT_plan_work.md`: branch-scoped planning
- `loop_streamed.sh` and a stream parser for readable live output
- sandbox-environment notes if the team needs deployment guidance

Do not bloat `AGENTS.md`. It is for build/run/test commands and short operational learnings only. Status, progress, bugs, and discoveries belong in `IMPLEMENTATION_PLAN.md`.

## When to use each mode

Use planning mode when:

- no implementation plan exists
- the current plan is stale, noisy, or wrong
- specs changed materially
- the team is confused about what is actually done

Use building mode when:

- a plan exists and is good enough to execute
- the repository has enough backpressure to reject bad work

Use specs mode when:

- requirements are vague
- spec files are inconsistent
- specs drifted into implementation details
- topic boundaries are muddy

Use reverse-engineering mode when:

- the codebase is brownfield
- there are no usable specs
- the user wants to document current behavior before planning changes

Use branch-scoped planning when:

- the team wants Ralph to work on one coherent feature or workstream per branch
- runtime filtering would be unreliable

## Requirements phase

In requirements definition, identify the Job to Be Done, then split it into topics of concern.

Use the topic test from the playbook:

- a topic should be describable in one sentence without using "and" to glue unrelated capabilities together

Good topics describe a single behavioral area. Bad topics collapse multiple systems together.

When authoring specs:

- specify what should be true, not how to implement it
- write behavioral outcomes and observable acceptance criteria
- do not include code blocks, variable names, library choices, or architecture prescriptions unless the repository already requires that level of specificity
- create one spec per topic

If the user gives only a vague idea, interview first and clarify JTBD, constraints, acceptance criteria, and edge cases before writing specs.

## Planning mode

Planning mode compares `specs/*` against existing code and updates `IMPLEMENTATION_PLAN.md`.

Planning mode must:

- study specs first
- study the current plan if it exists
- inspect the real source tree before claiming gaps
- search for TODOs, placeholders, skipped tests, flaky tests, minimal implementations, and inconsistent patterns
- prioritize remaining work as a markdown bullet list
- avoid implementation

Planning mode should treat shared utilities as a project standard library when such a layer exists.

If the plan is obviously wrong, regenerate it instead of patching a bad plan forever.

## Building mode

Building mode executes from the plan one task at a time.

The building loop should:

1. study specs
2. study the current plan
3. choose the most important remaining task
4. investigate the codebase before editing
5. implement with parallel subagents when possible
6. run targeted validation with only enough concurrency to preserve backpressure
7. update `IMPLEMENTATION_PLAN.md`
8. update `AGENTS.md` only for durable operational learnings
9. commit and continue

Preserve the playbook’s central guardrails:

- do not assume something is unimplemented until the code proves it
- one task per loop iteration
- use subagents aggressively for searches and reads
- keep validation as real backpressure, not ceremonial command running
- complete work fully instead of leaving placeholders and stubs

If unrelated tests fail and the repository’s loop contract expects clean green state, either fix them as part of the increment or explicitly document the issue in the plan.

## Backpressure and loop tuning

Ralph works when the repository provides strong signals.

Steer upstream with:

- deterministic prompt inputs
- good existing code patterns
- useful shared utilities

Steer downstream with:

- tests
- typechecks
- lint
- build checks
- targeted runtime checks
- LLM-as-judge reviews for subjective acceptance criteria when appropriate

If Ralph fails in a repeatable way, add a sign:

- tighten the prompt
- improve `AGENTS.md`
- add or refactor a reusable utility
- add missing validation

Do not overfit upfront. Watch failures, then tune.

## Specs mode

Use specs mode to enforce spec hygiene across `specs/*`.

Enforce these rules:

- one topic per file
- outcomes over implementation
- no code blocks
- consistent naming
- acceptance criteria stay behavioral

If the repository already has a naming convention, match it. Otherwise a numbered kebab-case convention is reasonable.

## Reverse-engineering mode

When documenting a brownfield codebase into specs:

- document what the code does now, not what it should do
- bugs are part of documented reality unless the user is explicitly writing a new desired-behavior spec
- perform investigation first, then write implementation-free specs
- trace entry points, branches, side effects, data contracts, configuration-driven paths, and state transitions
- stop at topic boundaries and document only what crosses them
- keep each spec self-contained

If code comments explain why behavior exists, preserve the rationale without leaking implementation details into the spec.

## Branch-scoped Ralph

If the user wants Ralph to work on a specific initiative, scope the plan at plan-creation time, not during build selection.

Recommended flow:

1. create a work branch
2. generate a scoped implementation plan for that work only
3. build from that already-scoped plan

Do not rely on "filter the big plan to feature X" at runtime. That is probabilistic and undermines the playbook.

## AGENTS.md rules

Keep `AGENTS.md` short and operational. It should usually contain:

- build commands
- test commands
- lint/typecheck commands
- run/dev commands
- brief repo-specific execution notes
- durable codebase patterns that improve future loops

It must not become:

- a diary
- a changelog
- a TODO list
- a status board

## Sandbox posture

Ralph-style autonomy assumes the agent may run with broad in-environment permissions. Treat the sandbox as the real security boundary.

When helping the user operationalize Ralph:

- prefer isolated environments
- give the agent only the minimum secrets and network access required
- call out blast-radius risks plainly
- avoid recommending host-machine execution without acknowledging the exposure

For local experimentation, Docker-style sandboxes are acceptable. For stronger hosted isolation, microVM-based environments are closer to the playbook’s security posture.

## Bundled workflow

When the user asks to "Ralph this repo" or requests setup from scratch:

1. Read the target repository first.
2. Read `references/ralph-playbook-guide.md`.
3. If a clean scaffold is appropriate, run `scripts/scaffold.sh` against the target repository with a concrete project goal.
4. Adapt the generated files to the target repo’s actual commands, source layout, and branch conventions.
5. Fill in `AGENTS.md` with real build, test, lint, and run commands.
6. If the repo is brownfield, consider also using `PROMPT_reverse_engineer_specs.md` before planning.

Do not leave placeholder commands or generic validation commands in place if you can determine the real ones from the repository.
Do not leave temporary staging directories, copied source material, or validation scratch files behind unless the user explicitly wants them preserved.

## Output expectations

When using this skill, produce one of these outcomes:

- a Ralph-ready file set adapted to the target repository
- an update to an existing Ralph setup that fixes drift or weak guardrails
- a set of clean spec files for a JTBD/topic breakdown
- a regenerated `IMPLEMENTATION_PLAN.md`
- a scoped branch plan
- brownfield specs reverse-engineered from existing code

Prefer adapting the repository’s current language, tooling, and file layout over forcing the playbook’s examples verbatim.
