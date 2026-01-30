# Ralph Commander Requirements

## Overview
A Web UI to control the "Ralph" autonomous agent loop.

## Functional Requirements
1.  **Dashboard**:
    *   Display current loop status (Active/Idle).
    *   Show current iteration count vs max iterations.
    *   Show the "Completion Promise" string.
    *   Show the initial prompt.
    *   Live-update or auto-refresh every X seconds.

2.  **Control**:
    *   **Stop Button**: Immediately terminate the running loop (call `cancel-ralph-loop.sh`).
    *   **Start Button**: Form to launch a new loop (call `ralph-loop` command or script).

3.  **Technical Constraints**:
    *   Backend: ElysiaJS on Bun.
    *   Frontend: React + Vite + Tailwind.
    *   Must run alongside the agent (lightweight).

## Data Source
*   State is stored in `.gemini/ralph-loop.local.md` (YAML Frontmatter).
*   Logs are in `.gemini/ralph-loop.log` (if enabled, otherwise need to read stdout? For now focus on state file).
