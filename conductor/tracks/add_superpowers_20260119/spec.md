# Specification - Add Superpowers Skills (Archived)

## Status

Superseded by the current `skills.sh` remote-skill model.

## Current Architecture

- `obra/superpowers` is listed in `shared/remote-skills.txt`.
- Remote skills install through `meta/install-remote-skills.sh`.
- Third-party remote skills should not be vendored into this repo.
- Repo-local custom skills remain under `shared/local-skills/`.
- Local skill builds are exposed through `~/.agent/skills` and per-skill links inside `~/.agents/skills`.

The earlier external clone, XML wrapping, and per-agent skill-directory output model is no longer active.
