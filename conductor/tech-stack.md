# Tech Stack - AI Agent Config Manager

## Scripting & Automation
- **Primary Language**: POSIX-compliant Bash.
    - Focus on cross-platform compatibility (macOS/Linux).
    - Use standard Unix utilities (`ln`, `mkdir`, `rsync`, `sed`, `find`, `tr`).
- **Remote Skill Registry**: [skills.sh](https://skills.sh/)
    - Used as the source of truth for remote skills.
    - Installed via `npx skills add`.

## Version Control & Management
- **Git**: The entire configuration repository is tracked by Git.
- **Local Skills Only**: This repository stores only local custom skills. Upstream skills are installed from `skills.sh`.

## Deployment Mechanism
- **Local Skill Store**: Repo-local skills are deployed to `~/.agent/skills/`.
- **Symlinking**:
    - `~/.gemini/GEMINI.md` and `~/.claude/CLAUDE.md` link back to `shared/AGENTS.md`.
- **Rsync Layering**:
    1. Shared local skills are copied to the build directory.
    2. Agent-specific local overrides are layered on top.
    3. The final result is rsync'd to the local skill store in the home directory.
