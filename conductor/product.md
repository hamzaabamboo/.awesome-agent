# Product Definition - AI Agent Config Manager

## Vision
A centralized, DRY-compliant configuration manager for AI agents (Gemini, Claude, and future platforms). It serves as a single source of truth for persona definitions (`core_profile.md`), skills, and agent-specific overrides, ensuring consistency across different environments through automated synchronization and standardizing on the OpenSkills specification.

## Target Audience
Power users and developers who use multiple AI agents and want a unified, version-controlled environment for their personalized prompts and specialized skills.

## Core Features
- **Centralized Source of Truth**: Define your persona once in `shared/core_profile.md` and inherit it across all agents.
- **Layered Skill Architecture**:
    - `shared/skills/`: Common, cross-agent skills.
    - `agents/<agent>/skills/`: Agent-specific skills or overrides.
- **OpenSkills Integration**: Automatically transforms repository skills into the standardized OpenSkills directory format.
- **Modular Skill Rules**: Supports stitching together modular rule files into a single, comprehensive `SKILL.md`.
- **Automated Synchronization**: A robust `meta/sync.sh` script that builds, merges, and deploys configurations to system locations (e.g., `~/.gemini/`).
- **Backward Compatibility**: Maintains legacy symlink structures for agents that don't yet natively support OpenSkills loading.

## Directory Structure
- `shared/skills/`: Universal skill definitions (Directory-based or Flat Markdown).
- `shared/core_profile.md`: The base persona and standards for all agents.
- `agents/`: Agent-specific overrides (plugins, extensions, local skills).
- `meta/`: Automation logic (syncing, vendoring).

## Goals
- **DRY (Don't Repeat Yourself)**: Persona and common skills are defined exactly once.
- **Native Compliance**: Output files match the exact formats required by the target agents (Markdown for Gemini, XML/Markdown for Claude).
- **Scalability**: Easily add support for new agents by extending the sync script's deployment logic.