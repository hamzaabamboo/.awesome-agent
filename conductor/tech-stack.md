# Tech Stack - AI Agent Config Manager

## Scripting & Automation
- **Primary Language**: POSIX-compliant Bash.
    - Focus on cross-platform compatibility (macOS/Linux).
    - Use standard Unix utilities (`ln`, `mkdir`, `rsync`, `sed`, `find`, `tr`).
- **Standardization**: [OpenSkills](https://github.com/openskills/openskills)
    - Used for indexing available skills into the universal prompt.
    - Defines the directory-based skill structure (`SKILL.md`).

## Version Control & Management
- **Git**: The entire configuration repository is tracked by Git.
- **Vendoring**: External dependencies (like Superpowers) are vendored into `shared/skills/` or `external/` to ensure offline availability and customization.

## Deployment Mechanism
- **Universal Store**: Skills are deployed to `~/.agent/skills/`.
- **Symlinking**:
    - `~/.gemini/GEMINI.md` and `~/.claude/CLAUDE.md` link back to `shared/AGENTS.md`.
    - Legacy skill folders in `~/.gemini/skills/` and `~/.claude/skills/` link to the Universal Store.
- **Rsync Layering**:
    1. Shared skills are copied to the build directory.
    2. Agent-specific overrides are layered on top, overwriting common skills if names collide.
    3. The final result is rsync'd to the home directory.