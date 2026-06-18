# Product Guidelines - AI Agent Config Manager

## Repository Structure
- **`shared/`**: Contains common components shared across multiple agents.
    - `shared/local-skills/`: Repo-local custom skill definitions.
    - `shared/prompts/`: Universal system prompts or templates.
    - `shared/mcps/`: Shared Model Context Protocol configurations.
- **`meta/`**: Infrastructure and automation logic.
    - `meta/sync.sh`: The primary synchronization and symlinking script.

## Synchronization Logic
- **Single Local Skill Source:** Repo-local custom skills live under `shared/local-skills/` and are built into `.build/skills`.
- **Safety First:**
    - The script must perform a check before creating a symlink.
    - External skill roots are symlinks back to the generated local build, not copied stores.
- **Verbose Reporting:** The script should expose the generated prompt path, canonical skill path, Codex skill path, and remote-skill dry-run commands when relevant.

## Content Standards
- **Native Compliance:** Configuration files (Skills, MCPs, `GEMINI.md`) should adhere strictly to the format and conventions required by their respective AI agent or platform. No additional metadata or wrappers should be added unless necessary for the target system.
- **Relative Linking:** Use standard Markdown relative links when referencing files within the repository.
