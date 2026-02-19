# .awesome-agent

A centralized, DRY (Don't Repeat Yourself), and automated configuration manager for AI agents (Gemini CLI, Claude Code, Codex).

## Core Philosophy

- **Single Source of Truth**: Define your persona and coding standards once in `shared/core_profile.md`.
- **Layered Overrides**: Generic skills live in `shared/`, while agent-specific tweaks live in `agents/`.
- **Standardized Skills**: Powered by the [OpenSkills](https://github.com/openskills/openskills) specification.
- **Automated Sync**: One command to build and deploy your entire agent environment.

---

## Repository Structure

### `shared/` - The Universal Core
- **`shared/core_profile.md`**: Your global persona, coding standards, and operational protocols.
- **`shared/skills/`**: Cross-agent skills. Supports both directory-based skills (with `rules/` subfolders) and flat `.md` files (automatically transformed during sync).
- **`shared/AGENTS.md`**: The generated "Universal Prompt" that includes your profile and an indexed table of available skills.

### `agents/` - Agent Overrides
- **`agents/gemini/`**: Overrides for Gemini CLI.
  - `extensions/`: Gemini-specific extensions.
  - `skills/`: Gemini-only skills or overrides for shared skills.
- **`agents/claude/`**: Overrides for Claude Code.
  - `plugins/`: Claude-specific plugins.
  - `commands/`: Custom Claude slash commands.

### `meta/` - Automation & Infrastructure
- **`meta/sync.sh`**: The brain of the project. It builds the skill library, stitches modular rules, merges profiles, and symlinks everything to your home directory.
- **`meta/add-skill.sh`**: Utility to vendor external skills from GitHub into the project.

### `external/` - Third-party Dependencies
- Contains vendored components like `superpowers` that are integrated into the system but maintained separately.

---

## Getting Started

### 1. Prerequisites
- Node.js (for `npx openskills`)
- `rsync` and `sed` (standard on macOS/Linux)

### 2. Synchronize
To deploy your configuration to `~/.gemini`, `~/.claude`, `~/.codex`, `~/.agents`, and `~/.agent`:

```bash
./meta/sync.sh --verbose --yes
```

**Flags:**
- `-v, --verbose`: Show detailed build and sync logs.
- `-y, --yes`: Auto-confirm the OpenSkills index update.
- `-c, --clean`: (Optional) Remove broken symlinks in home directories.

---

## The Skill System

The project uses a hybrid skill system that adapts to your needs.

### 1. Directory Skills
Create a folder in `shared/skills/<name>/`.
- Must contain a `SKILL.md`.
- Can contain a `rules/` folder. All `.md` files in `rules/` will be appended to `SKILL.md` automatically during sync.

### 2. Flat Skills
Simply drop a `<name>.md` file into `shared/skills/`. The sync script will transform it into a compliant `shared/skills/<name>/SKILL.md` structure in your home directory.

### 3. Vendored Skills
Skills from external sources (like Superpowers) are prefixed with their source name (e.g., `superpowers-brainstorming`) to avoid collisions.

---

## Deployment Mechanics

When you run `./meta/sync.sh`, the following happens:

1. **Build Phase**:
   - Shared skills are collected.
   - Modular rules are stitched.
   - Flat files are converted to directory-based skills.
   - Agent-specific skills are layered on top (overwriting shared ones with the same name).
2. **Profile Merge**:
   - `shared/core_profile.md` is prepended to `shared/AGENTS.md`.
   - `npx openskills sync` updates the "Available Skills" index in `AGENTS.md`.
3. **Link Phase**:
   - All processed skills are rsync'd to `~/.agent/skills/`.
   - `~/.gemini/GEMINI.md` and `~/.claude/CLAUDE.md` are symlinked to `shared/AGENTS.md`.
   - Legacy symlinks are created in `~/.gemini/skills/` and `~/.claude/skills/` for backward compatibility.
   - Codex user skills are symlinked to `~/.agents/skills/`.
   - If Codex is installed (`~/.codex` exists), `~/.codex/AGENTS.md` is symlinked to `shared/AGENTS.md`.

---

## Customizing your Persona

Edit **`shared/core_profile.md`**. This file is the "brain" of your agent. It defines how the agent thinks, communicates, and codes. Because it's merged into `AGENTS.md`, both Gemini and Claude will inherit these traits instantly after a sync.

---

## Ralph Commander

A built-in Web UI to visualize, orchestrate, and control autonomous AI agent loops (Ralph Wiggum methodology).

### Features
- **Planning First**: Automatically elaborates prompts into technical specs and implementation plans.
- **Dual Engine**: Support for both Gemini CLI and Claude Code.
- **Real-time Telemetry**: Live log streaming and token/tool usage statistics.
- **Visual Control**: Stop, clear logs, and track task progress via a modern dashboard.

### Accessing the Dashboard
1. Enter the commander directory: `cd ralph-commander`
2. Start the server: `bun run dev`
3. Visit **http://localhost:3000** in your browser.
