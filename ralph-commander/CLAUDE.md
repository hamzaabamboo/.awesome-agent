# Ralph Commander

A Web UI dashboard to visualize, orchestrate, and control Ralph Wiggum autonomous loops.

## Quick Reference
- **Dev**: `bun run dev` (Starts backend + frontend proxy)
- **Build**: `bun run build`
- **Lint**: `bun run lint`
- **Test**: `bun run test`

## Directory Structure
- `src/server/`: ElysiaJS Backend
- `src/client/`: React + Vite Frontend
- `docs/`: Documentation
- `specs/`: Requirements & Plans

## Tech Stack
- **Runtime**: Bun
- **Backend**: ElysiaJS
- **Frontend**: React, Vite, TailwindCSS (via Panda CSS or similar if preferred)
- **State**: Ralph Loop Files (`.gemini/ralph-loop.local.md`)
- **Orchestration**: Shell execution via Bun

## Conventions
- **Files**: `kebab-case.ts`, `PascalCase.tsx` components.
- **Backend**: 
  - Controllers in `src/server/controllers/`
  - Models/Types in `src/shared/types/` (shared with frontend if possible)
- **Frontend**:
  - Components in `src/client/components/`
  - Features in `src/client/features/`
- **State**: NO Redux. Use React Context or simple state for this scope.

## Philosophy
- **Visual Control**: The UI is the source of truth for the loop state.
- **Fail Fast**: If the loop breaks, the UI should show it immediately.
- **Zero Config**: Should point to existing `.gemini` state by default.

## Rules
- **NO** .env file edits without checking.
- **NO** destructive git operations without prompt.
- **Code**: Simple, readable, no excessive comments.

## Testing
- Unit tests for parsers/logic.
- E2E for critical loop control flows.
