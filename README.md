# .awesome-agent

A repo-managed prompt and local-skill layer for Gemini CLI, Claude Code, and Codex.

## Core Model

- `skills.sh` is the source of truth for non-local skills.
- This repo stores only local custom skills and agent prompt/config glue.
- `meta/sync.sh` syncs the unified prompt plus local custom skills.
- `meta/install-remote-skills.sh` installs remote skill repos with `npx skills add`.

## Repository Structure

### `shared/`
- `shared/core_profile.md`: Canonical persona and operating rules.
- `shared/skill_system.md`: `skills.sh` usage policy.
- `shared/AGENTS.md`: Generated unified prompt for Claude, Gemini, and Codex.
- `shared/local-skills/`: Repo-local custom skills only.
- `shared/remote-skills.txt`: Remote skill repos that should be installed via `skills.sh`.

### `agents/`
- `agents/gemini/local-skills/`: Gemini-only local custom skills.
- `agents/claude/commands/`: Claude slash commands managed by this repo.
- Other agent-specific files are linked into the target home config as top-level overrides.

### `meta/`
- `meta/sync.sh`: Builds local skills, renders `shared/AGENTS.md`, cleans foreign Claude links, and syncs repo-managed config.
- `meta/install-remote-skills.sh`: Installs remote skill repos listed in `shared/remote-skills.txt`.

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

### Install remote skills from `skills.sh`

```bash
./meta/install-remote-skills.sh
```

Dry run:

```bash
./meta/install-remote-skills.sh --dry-run
```

### Add a new local skill

Put it in `shared/local-skills/<name>/SKILL.md` or `shared/local-skills/<name>.md`.

### Add a new remote skill repo

Add the repo to `shared/remote-skills.txt` and install it with `meta/install-remote-skills.sh`.

## Behavior

Running `meta/sync.sh`:

1. Renders `shared/AGENTS.md` from `shared/core_profile.md` plus `shared/skill_system.md`.
2. Normalizes local skills into the canonical local store at `~/.agent/skills`.
3. Links `~/.claude/CLAUDE.md`, `~/.gemini/GEMINI.md`, and `~/.codex/AGENTS.md` to the same prompt file.
4. Replaces foreign `~/.claude/commands` and `~/.claude/rules` links so project-specific junk does not bleed into the global setup.
5. Leaves agent skill directories alone so `npx skills add` can manage remote skills without this repo overwriting them.
