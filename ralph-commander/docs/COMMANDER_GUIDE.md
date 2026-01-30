# Ralph Commander Guide

## Overview
Ralph Commander is a management dashboard for autonomous AI agent loops. It allows you to orchestrate complex tasks by following a strict lifecycle: **Elaboration -> Planning -> Implementation**.

## Lifecycle Phases

### 1. Elaboration (🔍)
The agent analyzes your prompt and generates a `specs/requirements_internal.md` file. This ensures the agent understands the scope and technical requirements before planning.

### 2. Planning (📝)
The agent creates a structured implementation plan in `@fix_plan.md`. This plan is visible in the sidebar of the dashboard and tracks the progress of each phase and task.

### 3. Implementation (🔄)
The agent executes the plan task-by-task, committing changes after each step and updating the blueprint in real-time.

## UI Features

- **Session Intelligence**: Real-time token consumption and tool execution metrics.
- **Active Blueprint**: Live checklist of the implementation plan.
- **Terminal Stream**: Real-time output from the agent process.
- **Agent Control**: One-click termination and model selection.

## Configuration

- **Models**: Supports standard Gemini aliases (`auto`, `pro`, `flash`) and concrete model names discovered from the CLI.
- **Engines**: Orchestrate both Gemini CLI and Claude Code (via `run-loop.sh`).

## Troubleshooting

If the dashboard doesn't load:
1. Ensure Bun is installed.
2. Run `bun run dev` in the `ralph-commander` directory.
3. Check `ralph-commander/app.log` for server errors.
