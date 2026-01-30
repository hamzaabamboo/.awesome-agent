# Ralph Commander - Internal Technical Specification

## 1. Overview
Ralph Commander is a real-time monitoring and control dashboard for autonomous AI agent loops (Ralph). It provides visibility into the agent's internal state, execution progress, and resource consumption.

## 2. Technical Stack
- **Runtime**: Bun (v1.x)
- **Backend Framework**: ElysiaJS
- **Frontend Framework**: React 18+ with Vite
- **Styling**: Tailwind CSS + Framer Motion (animations) + Lucide React (icons)
- **State Management**: Zustand
- **SSR/Routing**: Vike (formerly vite-plugin-ssr)
- **Communication**: WebSockets (WS) for real-time updates + REST API

## 3. System Architecture

### 3.1 Backend (ElysiaJS)
The backend acts as a bridge between the physical state files and the web frontend.

#### API Endpoints
- `GET /api/ralph/status`: Reads and parses `.gemini/ralph-loop.local.md` (YAML).
- `GET /api/ralph/tasks`: Parses `@fix_plan.md` to extract task lists and phases.
- `POST /api/ralph/tasks/toggle`: Updates task completion status in `@fix_plan.md`.
- `GET /api/ralph/logs`: Reads `ralph-runner.log`.
- `DELETE /api/ralph/logs`: Clears the log file.
- `GET /api/ralph/files`: Returns git status of the project.
- `POST /api/ralph/start`: Executes `scripts/run-loop.sh` to launch the agent.
- `POST /api/ralph/stop`: Kills the agent process (using `.gemini/runner.pid`) and updates the state file.
- `GET /agent/models`: Discovers available Gemini models via CLI.

#### WebSocket (`/ws`)
- **Pub/Sub**: Clients subscribe to `ralph-updates`.
- **File Watching**: Uses `fs.watch` on `.gemini/`, `@fix_plan.md`, and `ralph-runner.log` to push changes immediately to connected clients.

### 3.2 Frontend (React)
A "Fail Fast" oriented UI designed for high-density information display.

#### Components
- **Dashboard**: Main layout with real-time status indicators.
- **Mission Control**: Form to configure and launch missions (prompt, iterations, promise, model, resume).
- **StatsGrid**: 
  - **Iteration**: Current vs Max.
  - **Progress**: % of tasks completed in the blueprint.
  - **Intelligence**: Token consumption (Input/Output) and estimated cost.
  - **Velocity**: Time elapsed and average time per iteration.
  - **Density**: Heatmap of LLM inquiries per iteration.
- **LogViewer**: ANSI-highlighted terminal stream with filtering (Thoughts, Errors, Tools) and search.
- **Blueprint Sidebar**: Checklist of tasks grouped by phases with "Active Focus" highlighting.

## 4. Data Structures

### 4.1 State File (`.gemini/ralph-loop.local.md`)
```yaml
---
active: boolean
iteration: number
max_iterations: number
completion_promise: string
started_at: ISO8601
agent: "gemini" | "claude"
model: string
queries: number
phase: string
---
<Initial Prompt Content>
```

### 4.2 Stats File (`.gemini/stats.json`)
Used for historical tracking of iteration performance and token density.
```json
{
  "iteration_times": [
    { "iteration": number, "duration_ms": number, "queries": number }
  ],
  "models": {
    "<model_name>": {
      "tokens": { "input": number, "candidates": number, "total": number }
    }
  }
}
```

## 5. Lifecycle Phases
Ralph Commander enforces a structured development lifecycle:
1. **Elaboration (🔍)**: Agent analyzes the prompt and creates `specs/requirements_internal.md`.
2. **Planning (📝)**: Agent creates `@fix_plan.md`.
3. **Implementation (🔄)**: Agent executes tasks, updating status in real-time.

## 6. "Fail Fast" Principles
- **Zombie Detection**: Backend checks if the process in `runner.pid` is actually alive.
- **Instant Kill**: The "Kill Agent" button sends `SIGTERM` to the entire process group.
- **Uplink Monitoring**: Visual indicator for WebSocket connection stability.
- **Validation**: Strict schema validation for missions before launch.

## 7. Development Guidelines
- **No Placeholder Code**: Every feature must be fully functional.
- **Responsive Design**: UI must scale from laptops to large ultra-wide monitors.
- **Theming**: Integrated Dark/Light mode support.
