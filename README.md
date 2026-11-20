# .awesome-agent

A repo-managed prompt and local-skill layer for Gemini CLI, Claude Code, Codex, and Hermes.

## Core Model

- `skills.sh` is the source of truth for non-local skills.
- This repo stores only shared local custom skills plus the unified prompt/config glue.
- `meta/sync.sh` is the only command you need; it syncs the unified prompt, local custom skills, and remote `skills.sh` installs.
- `shared/remote-skills.txt` includes `JuliusBrussee/caveman`, so Caveman is installed automatically on sync.

## Repository Structure

### `shared/`
- `shared/core_profile.md`: Canonical persona and operating rules.
- `shared/skill_system.md`: `skills.sh` usage policy.
- `shared/AGENTS.md`: Generated unified prompt for Claude, Gemini, Codex, and Hermes.
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
- `--skills-only`: sync managed skills and prompts without resetting commands/rules, changing Hermes settings, or cleaning legacy links. Rejects a symlinked `.claude/skills` root before writing. Incompatible with `--clean`. Remote installation still follows `SKIP_REMOTE_SKILLS_INSTALL`.

For local skill/prompt maintenance without remote installation:

```bash
DO_NOT_TRACK=1 SKIP_REMOTE_SKILLS_INSTALL=true ./meta/sync.sh --skills-only --yes
```

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

## Harness regression checks

Run `bash meta/check-harness.sh` for serial installer, sync, prompt, preservation and evaluator checks with telemetry disabled and thread caps.

For cross-agent experiments, `python3 meta/harness_eval.py prepare <run-name>` creates a fresh local fixture. Give only its task file to the candidate agent. Then run `python3 meta/harness_eval.py grade <run-name> --output <report.json>` independently. Missing actions, altered protected files, malformed outputs, premature exits and runtime mutations fail the gate. The workspace is not an OS sandbox; use only trusted agents. Experiments never operate on live automations.

An optional `--contract` on prepare creates an experimental task contract. It is not a default steering change; the initial cross-AI trial did not demonstrate an advantage.

## Skill Visibility

- Repo-owned skills live only in `shared/local-skills/` and are generated into `.build/skills/`.
- Remote `skills.sh` packages are intentionally not vendored into this repository. They install into the real global directory at `~/.agents/skills/`.
- Hermes discovers those global packages through `skills.external_dirs: ~/.agents/skills` and combines them with Hermes builtin/profile skills under `~/.hermes/skills/`.
- `shared/skills/` is not an active source and must not contain skills. Put custom skills in `shared/local-skills/` instead.
- Verify the effective Hermes catalog with `hermes skills list --enabled-only`. After adding or moving a skill, run `./meta/sync.sh --yes`, then use `/reload-skills` or start a new session.

### Agent wrappers

Wrappers in `shared/wrappers/` are linked into `~/.local/bin` by sync. The `claude` wrapper runs Claude Code with `ANTHROPIC_BASE_URL=http://127.0.0.1:47821` and kickstarts the `com.awesome-agent.pxpipe` LaunchAgent when needed. Set `PXPIPE_DISABLE=1` to bypass it.

## Behavior

Running `meta/sync.sh`:

1. Renders `shared/AGENTS.md` from `shared/core_profile.md` plus `shared/skill_system.md`.
2. Normalizes local skills into `.build/skills`, symlinks `~/.agent/skills` to that build, and links each repo-local skill into `~/.agents/skills` without replacing global skills.
3. Registers `~/.agents/skills` as Hermes's external skill directory and installs the unified prompt as Hermes's additive `agent.system_prompt` when Hermes is installed.
4. Links repo-local skills into `~/.claude/skills` and links `~/.claude/CLAUDE.md`, `~/.gemini/GEMINI.md`, and `~/.codex/AGENTS.md` to the shared prompt.
5. Replaces `~/.claude/commands` and `~/.claude/rules` links that are not managed by this repo before syncing the shared global setup.
6. Installs every remote skill entry from `shared/remote-skills.txt`.
7. Links repo-managed wrappers into `~/.local/bin`.
8. Writes the `com.awesome-agent.pxpipe` LaunchAgent plist.
9. Replaces the managed prompt targets and repo-owned local skill links.
