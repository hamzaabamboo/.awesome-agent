# .awesome-agent

A repo-managed prompt and local-skill layer for Gemini CLI, Claude Code, and Codex.

## Core Model

- `skills.sh` is the source of truth for non-local skills.
- This repo stores only shared local custom skills plus the unified prompt/config glue.
- `meta/sync.sh` is the only command you need; it syncs the unified prompt, local custom skills, and remote `skills.sh` installs.

## Repository Structure

### `shared/`
- `shared/core_profile.md`: Canonical persona and operating rules.
- `shared/skill_system.md`: `skills.sh` usage policy.
- `shared/AGENTS.md`: Generated unified prompt for Claude, Gemini, and Codex.
- `shared/local-skills/`: Repo-local custom skills only.
- `shared/remote-skills.txt`: Remote skill repos that should be installed via `skills.sh`.

### `meta/`
- `meta/sync.sh`: Builds local skills, renders `shared/AGENTS.md`, installs remote `skills.sh` entries from `shared/remote-skills.txt`, and syncs the shared prompt/skill layer.
- `meta/install-remote-skills.sh`: Internal helper invoked by `meta/sync.sh`.

## Usage

### Sync repo-managed config

```bash
./meta/sync.sh --verbose --yes
```

Flags:
- `-v`, `--verbose`: print sync steps
- `-c`, `--clean`: remove broken links and stale repo-managed skill links
- `-d`, `--dry-run`: show intended filesystem actions without writing
- `-y`, `--yes`: non-interactive mode

### Add a new local skill

Put it in `shared/local-skills/<name>/SKILL.md` or `shared/local-skills/<name>.md`.

### Add a new remote skill repo

Add the repo to `shared/remote-skills.txt`, then run `./meta/sync.sh --yes`.

## Behavior

Running `meta/sync.sh`:

1. Renders `shared/AGENTS.md` from `shared/core_profile.md` plus `shared/skill_system.md`.
2. Normalizes local skills into the canonical local store at `~/.agent/skills`.
3. Links `~/.claude/CLAUDE.md`, `~/.gemini/GEMINI.md`, and `~/.codex/AGENTS.md` to the same prompt file.
4. Replaces `~/.claude/commands` and `~/.claude/rules` links that are not managed by this repo before syncing the shared global setup.
5. Installs every remote skill entry from `shared/remote-skills.txt`.
6. Leaves real skill directories alone instead of deleting them during sync.
