# Ralph Playbook Guide

This reference condenses the operating model from ClaytonFarr/ralph-playbook into a form suitable for repeated use in other repositories.

## Mental model

Ralph is a simple outer loop over durable markdown state.

The main components are:

- `specs/*.md`
- `IMPLEMENTATION_PLAN.md`
- `AGENTS.md`
- planning and building prompts
- a loop runner

Each loop iteration should start fresh, read the current files from disk, complete one meaningful task, update shared state, and exit.

## Three phases

1. Define requirements
2. Plan from specs and current code
3. Build from the plan

Phase 1 is usually a human-plus-agent conversation. Phases 2 and 3 are loop-driven.

## Requirements definition

Break the user’s goal into Jobs to Be Done and then into topics of concern.

Use the topic test:

- one topic should be describable in one sentence without needing "and" to conjoin unrelated capabilities

Specs should:

- describe outcomes and acceptance criteria
- avoid implementation details
- stay focused on one topic per file

## Planning mode

Planning mode reads specs and current code, then updates `IMPLEMENTATION_PLAN.md`.

Planning mode should:

- study specs first
- study any existing plan
- inspect the codebase before declaring gaps
- search for TODOs, placeholders, skipped tests, flaky tests, and inconsistent patterns
- output a prioritized markdown plan
- avoid implementation

If the plan is stale or wrong, regenerate it instead of endlessly patching a broken plan.

## Building mode

Building mode reads specs and the plan, chooses the most important remaining item, implements it, validates it, updates the plan, and commits.

Key rules:

- one task per loop iteration
- do not assume not implemented
- use subagents heavily for reads/searches and parallel file work
- keep validation real
- keep `AGENTS.md` operational only
- keep plan state current so future loops do not duplicate work

## Backpressure

Backpressure is what keeps the loop honest.

Use:

- tests
- typechecks
- lint
- build commands
- runtime checks
- LLM-as-judge checks for subjective criteria when appropriate

The prompt can say "run tests" generically, but `AGENTS.md` must contain the actual repo-specific commands.

## AGENTS.md

`AGENTS.md` is the heart-of-the-loop operational file.

It should contain:

- build commands
- test commands
- lint/typecheck commands
- run/dev commands
- concise notes about how to operate the repository

It should not contain:

- status updates
- progress notes
- TODOs
- implementation history

## Specs mode

Specs mode exists to create or clean `specs/*`.

It should enforce:

- one topic per file
- outcome-oriented specs
- no code blocks
- naming consistency

## Reverse-engineering mode

Use reverse-engineering mode for brownfield repositories with weak or missing specs.

It should:

- inspect code first
- document what the system does now
- keep output implementation-free
- trace entry points, branches, side effects, state transitions, and configuration-driven behavior
- treat bugs as part of documented reality unless the user is explicitly changing behavior

## Branch-scoped planning

If the team wants Ralph to work on one workstream per branch, scope the plan at creation time, not at build time.

Recommended pattern:

1. create a branch
2. generate a scoped plan for that branch’s work
3. run the build loop against the scoped plan

Do not depend on runtime semantic filtering of a giant plan.

## Security posture

Ralph-style autonomy often assumes the agent can run with broad permissions inside its execution environment. The sandbox is the real boundary.

Prefer:

- isolated sandboxes
- minimal credentials
- constrained network access

Be explicit about blast radius when recommending local host execution.
