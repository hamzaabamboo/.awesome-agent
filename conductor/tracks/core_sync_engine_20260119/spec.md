# Specification - Build the Core Sync Engine (Archived)

## Status

Superseded by the current `skills.sh`-based architecture.

## Current Architecture

- Repo-local custom skills live under `shared/local-skills/`.
- Remote skills live in `shared/remote-skills.txt` and install through `meta/install-remote-skills.sh`.
- `meta/sync.sh` builds local skills into `.build/skills`.
- `~/.agent/skills` is a symlink back to `.build/skills`.
- `~/.agents/skills` remains a real global skill directory; repo-local skills are linked into it one by one.
- `~/.claude/CLAUDE.md`, `~/.gemini/GEMINI.md`, and `~/.codex/AGENTS.md` are symlinks to `shared/AGENTS.md`.

The earlier per-agent source mapping, XML wrapping, per-agent skill output, and backup-confirmation model is no longer active.
