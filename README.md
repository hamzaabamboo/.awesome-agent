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
- `shared/wrappers/`: Repo-managed executable wrappers linked into `~/.local/bin`.

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

### Edit operating rules / persona

The master operating rules and persona live in `shared/core_profile.md`. This is the ONLY file to edit for rule/persona changes.

1. Edit `shared/core_profile.md` (and `shared/skill_system.md` for skill policy). NEVER hand-edit `shared/AGENTS.md` or the deployed `~/.claude/CLAUDE.md`, `~/.gemini/GEMINI.md`, `~/.codex/AGENTS.md` — they are GENERATED/symlinked and any direct edit is overwritten by the next sync.
2. Run `./meta/sync.sh --verbose --yes` to re-render `shared/AGENTS.md` and redeploy the symlinked targets.
3. Verify with `./meta/sync.sh --dry-run` first if the change is risky, and confirm the deployed prompt reflects the edit.

Do not duplicate rules into per-project `AGENTS.md`/`CLAUDE.md`; cross-agent rules belong here in `shared/core_profile.md`.

### Add a new local skill

Put it in `shared/local-skills/<name>/SKILL.md` or `shared/local-skills/<name>.md`.

### Add a new remote skill repo

Add the repo to `shared/remote-skills.txt`, then run `./meta/sync.sh --yes`.

Use `repo`, `repo|skill`, or `repo|skill|agent` lines. `agent` is passed to `npx skills add -a`.

### Agent wrappers

Wrappers in `shared/wrappers/` are linked into `~/.local/bin` by sync. The `claude` wrapper runs Claude Code with `ANTHROPIC_BASE_URL=http://127.0.0.1:47821` and kickstarts the `com.awesome-agent.pxpipe` LaunchAgent when needed. Set `PXPIPE_DISABLE=1` to bypass it.

## Behavior

Running `meta/sync.sh`:

1. Renders `shared/AGENTS.md` from `shared/core_profile.md` plus `shared/skill_system.md`.
2. Normalizes local skills into `.build/skills`, symlinks `~/.agent/skills` to that build, and links each repo-local skill into `~/.agents/skills` without replacing global skills.
3. Links `~/.claude/CLAUDE.md`, `~/.gemini/GEMINI.md`, and `~/.codex/AGENTS.md` to the same prompt file.
4. Replaces `~/.claude/commands` and `~/.claude/rules` links that are not managed by this repo before syncing the shared global setup.
5. Installs every remote skill entry from `shared/remote-skills.txt`.
6. Links repo-managed wrappers into `~/.local/bin`.
7. Writes the `com.awesome-agent.pxpipe` LaunchAgent plist.
8. Replaces the managed prompt targets and repo-owned local skill links.
