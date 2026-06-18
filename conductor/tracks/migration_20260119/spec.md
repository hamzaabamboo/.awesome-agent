# Specification - Migrate Existing Configurations (Archived)

## Status

Superseded by the current unified prompt and local-skill symlink model.

## Current Architecture

- `shared/core_profile.md` and `shared/skill_system.md` generate `shared/AGENTS.md`.
- Claude, Gemini, and Codex prompt files symlink to `shared/AGENTS.md`.
- Repo-local custom skills live under `shared/local-skills/`.
- Remote skills live in `shared/remote-skills.txt` and install through `skills.sh`.
- `meta/sync.sh` builds local skills into `.build/skills`.
- `~/.agent/skills` symlinks to `.build/skills`.
- `~/.agents/skills` stays a real global skill directory with repo-local skills linked into it one by one.

The earlier per-agent source directory, legacy shared-skill directory, backup-confirmation, and per-agent skill-output model is no longer active.
