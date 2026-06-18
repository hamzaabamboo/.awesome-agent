# Specification - Fix Skill Structure & Format (Archived)

## Status

Superseded by the current unified local-skill build.

## Current Architecture

- Repo-local custom skills are Markdown files with YAML frontmatter.
- `meta/sync.sh` normalizes `shared/local-skills/<name>/SKILL.md` and flat `shared/local-skills/<name>.md` into `.build/skills/<name>/SKILL.md`.
- `~/.agent/skills` symlinks to `.build/skills`.
- `~/.agents/skills` stays a real global skill directory with repo-local skills linked into it one by one.
- Remote skills install through `skills.sh`, not through per-agent local skill directories.

The earlier per-agent skill-directory, Superpowers-vendoring, and per-agent build-output model is no longer active.
