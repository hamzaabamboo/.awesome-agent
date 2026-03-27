# Product Definition - AI Agent Config Manager

## Vision
A centralized, DRY-compliant configuration manager for AI agents (Gemini, Claude, and future platforms). It serves as a single source of truth for persona definitions (`core_profile.md`), local custom skills, and agent-specific overrides, while using `skills.sh` as the source of truth for remote skills.

## Target Audience
Power users and developers who use multiple AI agents and want a unified, version-controlled environment for their personalized prompts and specialized skills.

## Core Features
- **Centralized Source of Truth**: Define your persona once in `shared/core_profile.md` and inherit it across all agents.
- **Layered Skill Architecture**:
    - `shared/local-skills/`: Common, cross-agent local custom skills.
    - `agents/<agent>/local-skills/`: Agent-specific local skills or overrides.
    - `shared/remote-skills.txt`: Remote skill repos installed from `skills.sh`.
- **Modular Skill Rules**: Supports stitching together modular rule files into a single, comprehensive `SKILL.md`.
- **Automated Synchronization**: A robust `meta/sync.sh` script that builds, merges, and deploys configurations to system locations (e.g., `~/.gemini/`).
- **Remote Skill Installation**: `meta/install-remote-skills.sh` installs remote skills via `npx skills add`.

## Directory Structure
- `shared/local-skills/`: Universal local skill definitions.
- `shared/core_profile.md`: The base persona and standards for all agents.
- `agents/`: Agent-specific overrides (plugins, extensions, local skills).
- `meta/`: Automation logic (syncing and remote skill installation).

## Goals
- **DRY (Don't Repeat Yourself)**: Persona and local skills are defined exactly once.
- **Native Compliance**: Output files match the exact formats required by the target agents.
- **Scalability**: Easily add support for new agents by extending the sync script's deployment logic.
