#!/bin/bash

set -euo pipefail

TARGET_ROOT="${TARGET_ROOT:-$HOME}"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOCAL_SHARED_SKILLS="$PROJECT_ROOT/shared/local-skills"
CORE_PROFILE="$PROJECT_ROOT/shared/core_profile.md"
SKILL_SYSTEM="$PROJECT_ROOT/shared/skill_system.md"
AGENTS_MD="$PROJECT_ROOT/shared/AGENTS.md"
REMOTE_SKILLS_INSTALLER="$PROJECT_ROOT/meta/install-remote-skills.sh"
BUILD_ROOT="${PROJECT_TEMP_DIR:-$PROJECT_ROOT/.build}"
BUILD_SKILLS_DIR="$BUILD_ROOT/skills"
VERBOSE=false
CLEAN=false
DRY_RUN=false
YES=false
SKIP_REMOTE_SKILLS_INSTALL="${SKIP_REMOTE_SKILLS_INSTALL:-false}"

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            VERBOSE=true
            echo "Verbose mode enabled."
            ;;
        -c|--clean)
            CLEAN=true
            echo "Clean mode enabled."
            ;;
        -d|--dry-run)
            DRY_RUN=true
            echo "Dry run mode enabled."
            ;;
        -y|--yes)
            YES=true
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
    shift
done

log() {
    if [ "$VERBOSE" = true ]; then
        echo "$1"
    fi
}

run() {
    if [ "$DRY_RUN" = true ]; then
        log "[dry-run] $*"
        return 0
    fi
    "$@"
}

reset_dir() {
    local path="$1"
    if [ -L "$path" ] || [ -f "$path" ]; then
        run rm -f "$path"
    elif [ -d "$path" ]; then
        run rm -rf "$path"
    fi
    run mkdir -p "$path"
}

link_path() {
    local source="$1"
    local target="$2"
    run mkdir -p "$(dirname "$target")"
    if [ -e "$target" ] || [ -L "$target" ]; then
        run rm -rf "$target"
    fi
    run ln -s "$source" "$target"
}

clean_broken_symlinks() {
    for root in \
        "$TARGET_ROOT/.claude" \
        "$TARGET_ROOT/.gemini" \
        "$TARGET_ROOT/.agent" \
        "$TARGET_ROOT/.agents" \
        "$TARGET_ROOT/.codex"
    do
        if [ ! -d "$root" ]; then
            continue
        fi

        find "$root" -type l ! -exec test -e {} \; -print 2>/dev/null | while read -r broken_link; do
            log "Removing broken symlink: $broken_link"
            run rm -f "$broken_link"
        done
    done
}

clean_claude_paths() {
    local claude_dir="$TARGET_ROOT/.claude"
    local commands_path="$claude_dir/commands"
    local rules_path="$claude_dir/rules"

    if [ -L "$commands_path" ] && [ "$(readlink "$commands_path")" != "$claude_dir/commands" ]; then
        log "Removing Claude commands link not managed by this repo: $commands_path"
        run rm -f "$commands_path"
    fi

    if [ -L "$rules_path" ]; then
        log "Removing Claude rules link not managed by this repo: $rules_path"
        run rm -f "$rules_path"
    fi
}

clean_legacy_skill_links() {
    for path in \
        "$TARGET_ROOT/.claude/skills" \
        "$TARGET_ROOT/.gemini/skills" \
        "$TARGET_ROOT/.gemini/antigravity/skills" \
        "$TARGET_ROOT/.agents/skills" \
        "$TARGET_ROOT/.codex/skills"
    do
        if [ -L "$path" ]; then
            run rm -rf "$path"
        fi
    done
}

install_remote_skills() {
    if [ "$SKIP_REMOTE_SKILLS_INSTALL" = true ]; then
        log "Skipping remote skills install."
        return 0
    fi

    if [ ! -x "$REMOTE_SKILLS_INSTALLER" ]; then
        echo "Remote skills installer not found: $REMOTE_SKILLS_INSTALLER" >&2
        exit 1
    fi

    if [ "$DRY_RUN" = true ]; then
        "$REMOTE_SKILLS_INSTALLER" --dry-run
        return 0
    fi

    "$REMOTE_SKILLS_INSTALLER"
}

normalize_skill() {
    local skill_root="$1"
    local skill_name="$2"
    local skill_file="$skill_root/SKILL.md"

    if [ ! -f "$skill_file" ]; then
        return 0
    fi

    python3 - "$skill_file" "$skill_name" <<'PY'
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
skill_name = sys.argv[2]
text = path.read_text()

if text.startswith('---'):
    parts = text.split('---', 2)
    if len(parts) == 3:
        frontmatter = parts[1].strip().splitlines()
        body = parts[2].lstrip('\n')
        updated = []
        seen_name = False
        for line in frontmatter:
            if re.match(r'^name\s*:', line):
                updated.append(f'name: {skill_name}')
                seen_name = True
            else:
                updated.append(line)
        if not seen_name:
            updated.insert(0, f'name: {skill_name}')
        path.write_text('---\n' + '\n'.join(updated).strip() + '\n---\n\n' + body)
        sys.exit(0)

path.write_text(f'---\nname: {skill_name}\n---\n\n{text}')
PY

    if [ -d "$skill_root/rules" ]; then
        python3 - "$skill_file" "$skill_root/rules" <<'PY'
import pathlib
import sys

skill_path = pathlib.Path(sys.argv[1])
rules_dir = pathlib.Path(sys.argv[2])
parts = skill_path.read_text().split('---', 2)
if len(parts) != 3:
    sys.exit(0)
header = '---' + parts[1] + '---'
body = parts[2].strip()
rules = []
for rule in sorted(rules_dir.glob('*.md')):
    rules.append(rule.read_text().strip())
chunks = [chunk for chunk in [body] + rules if chunk]
skill_path.write_text(header + '\n\n' + '\n\n'.join(chunks) + '\n')
PY
    fi
}

copy_skill_dir() {
    local src="$1"
    local dest_root="$2"
    local skill_name
    skill_name="$(basename "$src")"
    run mkdir -p "$dest_root/$skill_name"
    run rsync -a "$src/" "$dest_root/$skill_name/"
    if [ "$DRY_RUN" = false ]; then
        normalize_skill "$dest_root/$skill_name" "$skill_name"
    fi
}

copy_skill_file() {
    local src="$1"
    local dest_root="$2"
    local skill_name
    skill_name="$(basename "${src%.md}")"
    run mkdir -p "$dest_root/$skill_name"
    run cp "$src" "$dest_root/$skill_name/SKILL.md"
    if [ "$DRY_RUN" = false ]; then
        normalize_skill "$dest_root/$skill_name" "$skill_name"
    fi
}

process_skill_source() {
    local source_dir="$1"
    local dest_root="$2"

    if [ ! -d "$source_dir" ]; then
        return 0
    fi

    find "$source_dir" -mindepth 1 -maxdepth 1 | sort | while read -r entry; do
        if [ -d "$entry" ]; then
            copy_skill_dir "$entry" "$dest_root"
        elif [[ "$entry" == *.md ]]; then
            copy_skill_file "$entry" "$dest_root"
        fi
    done
}

render_agents_prompt() {
    if [ "$DRY_RUN" = true ]; then
        log "[dry-run] render $AGENTS_MD"
        return 0
    fi

    cat "$CORE_PROFILE" > "$AGENTS_MD"
    printf '\n' >> "$AGENTS_MD"
    cat "$SKILL_SYSTEM" >> "$AGENTS_MD"

    python3 - "$BUILD_SKILLS_DIR" >> "$AGENTS_MD" <<'PY'
import pathlib
import re
import sys

skills_dir = pathlib.Path(sys.argv[1])
skill_dirs = sorted([p for p in skills_dir.iterdir() if p.is_dir()]) if skills_dir.exists() else []

print("\n## Repo-Local Skills\n")

if not skill_dirs:
    print("- None")
    sys.exit(0)

for skill_dir in skill_dirs:
    skill_file = skill_dir / "SKILL.md"
    description = ""
    if skill_file.exists():
        text = skill_file.read_text()
        match = re.search(r"^description:\s*(.*)$", text, re.MULTILINE)
        if match:
            description = match.group(1).strip()
    line = f"- `{skill_dir.name}`"
    if description:
        line += f": {description}"
    print(line)
PY
}

sync_claude_commands() {
    local claude_dir="$TARGET_ROOT/.claude"
    reset_dir "$claude_dir/commands"
}

sync_gemini_commands() {
    local gemini_dir="$TARGET_ROOT/.gemini/extensions/init-repo/commands"
    reset_dir "$gemini_dir"

    if [ ! -d "$PROJECT_ROOT/shared/commands" ]; then
        return 0
    fi

    find "$PROJECT_ROOT/shared/commands" -maxdepth 1 -type f -name '*.md' | sort | while read -r cmd_path; do
        local cmd_name
        cmd_name="$(basename "${cmd_path%.md}")"
        if [ "$DRY_RUN" = true ]; then
            log "[dry-run] generate $gemini_dir/$cmd_name.toml"
            continue
        fi

        python3 - "$cmd_path" "$gemini_dir/$cmd_name.toml" <<'PY'
import json
import pathlib
import re
import sys

source = pathlib.Path(sys.argv[1])
target = pathlib.Path(sys.argv[2])
raw = source.read_text()
description = "Agent command"
match = re.search(r'^description:\s*(.*)$', raw, re.MULTILINE)
if match:
    description = match.group(1).strip()
content = raw
if raw.startswith('---'):
    parts = raw.split('---', 2)
    if len(parts) == 3:
        content = parts[2].strip()
target.write_text(
    f'description = {json.dumps(description)}\n'
    'prompt = """\n'
    + content +
    '\n"""\n'
)
PY
    done
}

echo "Standardizing skills..."

if [ "$YES" = false ]; then
    log "Running without --yes."
fi

if [ "$CLEAN" = true ]; then
    clean_broken_symlinks
fi

clean_claude_paths

run rm -rf "$BUILD_SKILLS_DIR"
run mkdir -p "$BUILD_SKILLS_DIR"

process_skill_source "$LOCAL_SHARED_SKILLS" "$BUILD_SKILLS_DIR"

render_agents_prompt

run mkdir -p "$TARGET_ROOT/.agent"
reset_dir "$TARGET_ROOT/.agent/skills"
run rsync -a "$BUILD_SKILLS_DIR/" "$TARGET_ROOT/.agent/skills/"

for agent in gemini claude; do
    run mkdir -p "$TARGET_ROOT/.$agent"
done

link_path "$AGENTS_MD" "$TARGET_ROOT/.claude/CLAUDE.md"
link_path "$AGENTS_MD" "$TARGET_ROOT/.gemini/GEMINI.md"

sync_claude_commands
sync_gemini_commands

reset_dir "$TARGET_ROOT/.claude/rules"
link_path "$AGENTS_MD" "$TARGET_ROOT/.codex/AGENTS.md"
clean_legacy_skill_links
install_remote_skills

if [[ "$BUILD_ROOT" == "$PROJECT_ROOT/.build" ]] && [ "$DRY_RUN" = false ]; then
    run rm -rf "$BUILD_ROOT"
fi

echo "---"
echo "Sync complete."
echo "Canonical prompt: $AGENTS_MD"
echo "Canonical skills: $TARGET_ROOT/.agent/skills"
