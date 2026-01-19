# Workspace Context: .awesome-agent

## Purpose
This repository is a **Centralized AI Agent Configuration Manager**. It aims to provide a DRY (Don't Repeat Yourself), version-controlled, and automated environment for managing profiles, skills, and extensions across multiple AI agents (currently Gemini CLI and Claude Code).

## Philosophy & Core Principles
1.  **Single Source of Truth:** All configurations (Markdown profiles, skill instructions, agent-specific overrides) reside in this repository.
2.  **Infrastructure as Code:** Agent environments are deployed and updated via the `sync.sh` engine. Manual changes to `~/.gemini` or `~/.claude` should be avoided; they should be mirrored back to `agents/` and deployed via the script.
3.  **Cross-Agent Compatibility:** Shared assets (like `core_profile.md` and `shared/skills/`) are automatically transformed into the agent-specific formats and structures required (e.g., directory-based skills for both, Markdown everywhere).
4.  **DRY (Don't Repeat Yourself):** Common skills and profile instructions are shared between agents via symlinking and build-time transformations.
5.  **Strict Hygiene:** The sync engine must strictly ignore project internals (like `.git` and `.DS_Store`) to prevent polluting the agent's global configuration directories.

## Project Structure
-   `shared/`: Common assets. `core_profile.md` is the primary persona definition. `skills/` contains flat Markdown skills.
-   `agents/`: Agent-specific overrides. Mapped to `$HOME/.[agent_name]/`.
-   `external/`: Git submodules or cloned repos (e.g., `superpowers`).
-   `build/`: Intermediate directory where skills are transformed into the required directory structure (`skills/<name>/SKILL.md`).
-   `meta/sync.sh`: The core executable. Handles transformation and symlinking.
-   `conductor/`: Tracks the progress of features and fixes via localized specifications and plans.

## Workflow for AI Agents
-   **Read Before Act:** Always verify the target agent's documentation (Gemini CLI vs Claude Code) before suggesting structural changes.
-   **Engine First:** If a new type of configuration is needed, update the `sync.sh` engine to handle it automatically.
-   **Verification:** Use the `tests/` suite to verify transformation logic before running a full sync.
-   **Safe Deployment:** Use `./meta/sync.sh --verbose --yes` to deploy changes. Use `-d/--dry-run` when testing risky changes.

## Global Guidelines
-   **No XML for Skills:** Both Gemini and Claude use Markdown with YAML frontmatter for skills.
-   **Directory-Based Skills:** Skills MUST be organized as `skills/<name>/SKILL.md`. The `sync.sh` handles this; source files in `shared/skills/` can remain flat.
-   **Backup Policy:** The sync engine automatically backs up existing regular files to `~/.agent_config_backups/` before replacing them with symlinks.
