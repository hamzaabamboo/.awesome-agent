# Tech Stack - AI Agent Config Manager

## Scripting & Automation
- **Primary Language**: POSIX-compliant Bash.
    - Focus on cross-platform compatibility (macOS/Linux).
    - Use standard Unix utilities (`ln`, `mkdir`, `cp`, `sed`, `find`, `tr`).
- **Remote Skill Registry**: [skills.sh](https://skills.sh/)
    - Used as the source of truth for remote skills.
    - Installed via `npx skills add`.

## Version Control & Management
- **Git**: The entire configuration repository is tracked by Git.
- **Local Skills Only**: This repository stores only local custom skills. Upstream skills are installed from `skills.sh`.

## Deployment Mechanism
- **Local Skill Stores**: `~/.agent/skills/` points to the repo build. `~/.agents/skills/` stays a real global skill directory, with repo-local skills linked into it one by one.
- **Symlinking**:
    - `~/.gemini/GEMINI.md` and `~/.claude/CLAUDE.md` link back to `shared/AGENTS.md`.
- **Build Copying**:
    1. Shared local skills are copied to the build directory.
    2. The generated build directory is symlinked to `~/.agent/skills/`.
    3. Each generated local skill is symlinked into `~/.agents/skills/` without replacing existing global skills.
