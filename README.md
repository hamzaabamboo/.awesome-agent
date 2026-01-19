# .awesome-agent

A centralized, DRY (Don't Repeat Yourself), and automated configuration manager for AI agents (Gemini CLI, Claude Code).

## Features

- **Automated Sync**: One script to rule them all (`meta/sync.sh`).
- **DRY Profiles**: Share persona and guidelines across agents using a single source of truth.
- **Smart Skill Transformation**: Automatically converts flat Markdown skills into the directory-based structure required by modern AI CLIs.
- **Agent Overrides**: Easily manage agent-specific plugins, extensions, and settings.
- **Safety First**: Automatic backups of existing configurations before symlinking.

## Project Structure

- `shared/`: Common assets (core profile, common skills).
- `agents/`: Agent-specific configuration overrides (e.g., `agents/claude/plugins`).
- `meta/`: Core logic and synchronization scripts.
- `external/`: Integrated third-party components (e.g., `superpowers`).
- `conductor/`: Feature specs and implementation plans.

## Usage

### Synchronize Configurations

To deploy your configurations to the home directory (`~/.gemini` and `~/.claude`):

```bash
./meta/sync.sh --verbose --yes
```

**Options:**
- `-v, --verbose`: Show detailed symlink and build info.
- `-d, --dry-run`: Preview changes without applying them.
- `-c, --clean`: Interactively remove broken symlinks.
- `-y, --yes`: Auto-confirm prompts.

## Development

### Adding a Skill
Place your flat Markdown skill in `shared/skills/`. The sync script will automatically create the required `skills/<name>/SKILL.md` structure during deployment.

### Modifying Persona
Update `shared/core_profile.md`. Changes will be synced to both agents on the next run.
