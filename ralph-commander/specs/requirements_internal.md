# Ralph Commander - Internal Specifications

## 1. Overview
Ralph Commander is a specialized management interface for autonomous coding agent loops (specifically for Ralph/Gemini CLI). It provides real-time visibility and control over long-running iterative tasks.

## 2. State & Persistence

### 2.1 Agent State File (`.gemini/ralph-loop.local.md`)
The source of truth for the loop's execution state.
- **Format**: Markdown with YAML frontmatter.
- **Frontmatter Schema**:
  ```yaml
  active: boolean      # Is the loop currently running?
  iteration: number   # Current turn count
  max_iterations: number
  completion_promise: string # Success trigger phrase
  started_at: string   # ISO timestamp
  queries: number      # Total LLM queries made
  phase: string        # Current logical phase (e.g. "THINKING", "ACTING")
  agent: string        # "gemini" | "claude"
  model: string        # Model identifier or "auto"
  ```
- **Body**: Contains the raw initial prompt.

### 2.2 Execution Metadata
- **PID File (`.gemini/runner.pid`)**: Stores the process ID of the `run-loop.sh` process group. Used for reliable termination.
- **Stats Store (`.gemini/stats.json`)**: Persistent telemetry.
  - `iteration_times`: List of `{ iteration, duration_ms, queries }`.
  - `start_times`: Map of `iteration -> ISO timestamp`.
  - `queries_at_last_iteration`: Offset for calculating incremental queries.

### 2.3 Task Plan (`@fix_plan.md`)
- Parsed by the backend to generate the "Active Blueprint".
- **Pattern**:
  - Phases: `**Phase \d+: (.*?)**`
  - Tasks: `- [ ] description` or `- [x] description`

## 3. Backend Services (ElysiaJS)

### 3.1 Lifecycle Management
- **START**: Spawns `scripts/run-loop.sh` with arguments mapping to the start form.
  - Redirects stdout/stderr to `ralph-runner.log`.
  - Records PID.
- **STOP**: 
  - Sets `active: false` in the state file.
  - Kills the process group via PID.
  - Clears PID file.

### 3.2 Real-time Sync (WebSockets)
- **Watcher**: Uses `fs.watch` to monitor:
  - `.gemini/ralph-loop.local.md` -> Triggers `status` update.
  - `@fix_plan.md` -> Triggers `tasks` update.
  - `ralph-runner.log` -> Streams incremental text chunks to `logs`.
- **Pub/Sub**: `ralph-updates` topic.

## 4. Frontend Architecture (React + Vike)

### 4.1 Global Store (`useRalphStore`)
- Manages status, logs, tasks, and connection state.
- Handles delta updates for logs to prevent UI lag on large buffers.

### 4.2 UI Components
- **StatsGrid**: 
  - Velocity calculation: Time diff / Iteration count.
  - Cost estimation: Based on token counters in `stats.json`.
  - Intelligence Density: Small heatmap of query counts per turn.
- **ControlPanel**:
  - "Fail Fast" Validation: Prevents starting if a loop is already active.
  - Resume functionality: Allows picking up an existing `@fix_plan.md`.
- **LogStream**: 
  - Auto-scrolling terminal-like container.
  - Manual scroll override.

## 5. Failure Recovery & Robustness
- **Zombie Detection**: Backend checks if the PID in `.gemini/runner.pid` is actually alive when `active: true` is reported.
- **Socket Reconnection**: Frontend implements exponential backoff for WS disconnection.
- **Log Rotation/Wiping**: Ability to clear `ralph-runner.log` to maintain performance.

## 6. Development Philosophy
- **Lightweight**: Must not consume significant CPU/RAM compared to the agent loop itself.
- **Fail Fast**: UI should immediately reflect if the backend or agent has crashed.
- **No Placeholders**: All visualized data must come from real system state.
