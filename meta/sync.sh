#!/bin/bash
# meta/sync.sh - Standardized Sync Engine (OpenSkills Compatible)

set -e

# Configuration
TARGET_ROOT="${TARGET_ROOT:-$HOME}"
SHARED_SKILLS="./shared/skills"
AGENTS_DIR="./agents"
AGENTS_MD="./shared/AGENTS.md"
CORE_PROFILE="./shared/core_profile.md"
VERBOSE=false
CLEAN=false
YES=false

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -v|--verbose) VERBOSE=true ;;
        -c|--clean) CLEAN=true ;;
        -y|--yes) YES=true ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

log() {
    if [ "$VERBOSE" = true ]; then
        echo "$1"
    fi
}

echo "Standardizing skills..."

# 1. Ensure openskills is available
if ! command -v npx &> /dev/null; then
    echo "Error: npx not found. Node.js is required for openskills compatibility."
    exit 1
fi

# 2. Local BUILD directory for intermediate state (to avoid polluting repo)
# Use the project's temporary directory if provided, otherwise a local .build
BUILD_DIR="${PROJECT_TEMP_DIR:-./.build}/skills"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# 3. Helper to process skills into OpenSkills format
process_skill_dir() {
    local src=$1
    local dest_root=$2
    
    find "$src" -maxdepth 1 -mindepth 1 | while read skill_path; do
        local skill_name=$(basename "$skill_path")
        
        if [ -d "$skill_path" ]; then
            # Directory-based skill
            log "Processing directory skill: $skill_name"
            mkdir -p "$dest_root/$skill_name"
            rsync -aK "$skill_path/" "$dest_root/$skill_name/"
            
            local skill_file="$dest_root/$skill_name/SKILL.md"
            
            # Fix frontmatter name to match directory name (OpenCode requirement)
            if [ -f "$skill_file" ]; then
                log "  Normalizing name in frontmatter..."
                sed -i.bak "s/^name:.*/name: $skill_name/" "$skill_file"
                rm -f "$skill_file.bak"
            fi
            
            # Stitch modular rules if present
            if [ -d "$dest_root/$skill_name/rules" ]; then
                if [ -f "$skill_file" ]; then
                    log "  Stitching rules for $skill_name..."
                    sed -n '1,/---/p' "$skill_file" > "$skill_file.tmp"
                    cat "$dest_root/$skill_name/rules"/*.md >> "$skill_file.tmp" 2>/dev/null || true
                    mv "$skill_file.tmp" "$skill_file"
                fi
            fi
        elif [[ "$skill_path" == *.md ]]; then
            # Flat file skill -> convert to directory
            local name_no_ext="${skill_name%.md}"
            log "Processing flat skill: $name_no_ext"
            mkdir -p "$dest_root/$name_no_ext"
            cp "$skill_path" "$dest_root/$name_no_ext/SKILL.md"
        fi
    done
}

# 4. Process Shared Skills
if [ -d "$SHARED_SKILLS" ]; then
    log "Processing shared skills..."
    process_skill_dir "$SHARED_SKILLS" "$BUILD_DIR"
fi

# 4b. Process Shared Commands (New)
# Transforms Markdown commands from shared/commands/ to:
# - ~/.claude/commands/*.md (Symlink)
# - ~/.gemini/extensions/init-repo/commands/*.toml (Generated)

COMMANDS_DIR="./shared/commands"

process_commands() {
    local src_dir=$1
    if [ ! -d "$src_dir" ]; then return; fi
    
    log "Processing shared commands from $src_dir..."
    
    find "$src_dir" -name "*.md" | while read cmd_path; do
        local cmd_filename=$(basename "$cmd_path")
        local cmd_name="${cmd_filename%.md}"
        
        # 1. Deploy to Claude (Symlink)
        mkdir -p "$TARGET_ROOT/.claude/commands"
        log "  Linking $cmd_name for Claude..."
        rm -f "$TARGET_ROOT/.claude/commands/$cmd_filename"
        ln -sf "$(pwd)/$cmd_path" "$TARGET_ROOT/.claude/commands/$cmd_filename"
        
        # 2. Deploy to Gemini (Generate TOML)
        # Note: We assume these go into 'init-repo' extension for now, as that's the primary use case.
        # Ideally, we'd have a mapping or a 'core-commands' extension.
        local gemini_ext_dir="$TARGET_ROOT/.gemini/extensions/init-repo/commands"
        mkdir -p "$gemini_ext_dir"
        
        log "  Generating $cmd_name.toml for Gemini..."
        local toml_file="$gemini_ext_dir/$cmd_name.toml"
        
        # Use python for robust frontmatter stripping and TOML generation
        python3 -c "
import sys
import json
import re

file_path = sys.argv[1]

with open(file_path, 'r') as f:
    raw_content = f.read()

# Extract description from frontmatter if possible, or use filename
description = \"Agent command\"
match = re.search(r'^description:\s*(.*)$', raw_content, re.MULTILINE)
if match:
    description = match.group(1).strip()

# Strip YAML frontmatter if present
content = raw_content
if raw_content.startswith('---'):
    try:
        parts = raw_content.split('---', 2)
        if len(parts) >= 3:
            content = parts[2].strip()
    except ValueError:
        pass

# Create TOML content
print(f'description = {json.dumps(description)}')
print('prompt = \"\"\"')
print(content)
print('\"\"\"')
" "$cmd_path" > "$toml_file"

    done
}

process_commands "$COMMANDS_DIR"

# 5. Use openskills to sync the index into AGENTS.md
# We do this BEFORE agent-specific overrides so the index reflects the "Universal" set
# or we could do it after, but shared is usually the source of truth for the index.

# 5.1 Refresh AGENTS.md with Core Profile first
if [ -f "$CORE_PROFILE" ]; then
    log "Merging $CORE_PROFILE into $AGENTS_MD..."
    if grep -q "# SKILLS SYSTEM" "$AGENTS_MD"; then
        sed -n '/# SKILLS SYSTEM/,$p' "$AGENTS_MD" > "$AGENTS_MD.tmp"
        cat "$CORE_PROFILE" > "$AGENTS_MD"
        echo "" >> "$AGENTS_MD"
        cat "$AGENTS_MD.tmp" >> "$AGENTS_MD"
        rm "$AGENTS_MD.tmp"
    else
        cat "$CORE_PROFILE" > "$AGENTS_MD"
        echo "" >> "$AGENTS_MD"
        echo "# SKILLS SYSTEM" >> "$AGENTS_MD"
        echo '<skills_system priority="1">' >> "$AGENTS_MD"
        echo "" >> "$AGENTS_MD"
        echo "## Available Skills" >> "$AGENTS_MD"
        echo "" >> "$AGENTS_MD"
        echo "<!-- SKILLS_TABLE_START -->" >> "$AGENTS_MD"
        echo "<!-- SKILLS_TABLE_END -->" >> "$AGENTS_MD"
        echo "" >> "$AGENTS_MD"
        echo "</skills_system>" >> "$AGENTS_MD"
    fi
fi

log "Syncing index into AGENTS.md..."
# We point openskills to our build dir for indexing
mkdir -p .agent
rm -rf .agent/skills
ln -sf "$(pwd)/$BUILD_DIR" .agent/skills
OPENSKILLS_ARGS="-o $AGENTS_MD"
if [ "$YES" = true ]; then
    OPENSKILLS_ARGS="$OPENSKILLS_ARGS -y"
fi
npx openskills sync $OPENSKILLS_ARGS
rm .agent/skills
rmdir .agent 2>/dev/null || true

# Post-process AGENTS.md to ensure absolute paths for Gemini CLI native integration
log "Rewriting skill locations in $AGENTS_MD for native integration..."
# Use a temporary file for the rewrite
TMP_AGENTS_MD=$(mktemp)
sed "s|<location>project</location>|<location>$TARGET_ROOT/.gemini/skills/SKILL_NAME_HINT/SKILL.md</location>|g" "$AGENTS_MD" > "$TMP_AGENTS_MD"
# This is a bit tricky with sed. Let's use a small perl/python script or a loop.
# We want to replace each <location>...</location> with the correct path based on the preceding <name>... </name>

python3 -c "
import sys, re, os
path = sys.argv[1]
target_root = sys.argv[2]
with open(path, 'r') as f:
    content = f.read()

def replace_location(match):
    skill_name = match.group(1)
    return f'<name>{skill_name}</name>\n<description>{match.group(2)}</description>\n<location>{target_root}/.gemini/skills/{skill_name}/SKILL.md</location>'

# Match <name>...</name>, <description>...</description>, <location>...</location>
pattern = re.compile(r'<name>([^<]+)</name>\s*<description>([^<]*)</description>\s*<location>[^<]+</location>', re.DOTALL)
new_content = pattern.sub(replace_location, content)

with open(path, 'w') as f:
    f.write(new_content)
" "$AGENTS_MD" "$TARGET_ROOT"

# 6. Deploy to Home
echo "Deploying to $TARGET_ROOT/.agent/skills/..."
mkdir -p "$TARGET_ROOT/.agent/skills"
rsync -aKq --delete "$BUILD_DIR/" "$TARGET_ROOT/.agent/skills/"

# 7. Agent-Specific Deployment (Overrides & Legacy)
for agent in gemini claude; do
    log "Deploying for $agent..."
    mkdir -p "$TARGET_ROOT/.$agent"
    
    # 7.1 Link Universal Prompt
    agent_upper=$(echo "$agent" | tr '[:lower:]' '[:upper:]')
    ln -sf "$(pwd)/$AGENTS_MD" "$TARGET_ROOT/.$agent/${agent_upper}.md"
    
    # 7.2 Sync agent-specific files (overrides)
    if [ -d "$AGENTS_DIR/$agent" ]; then
        # Exclude 'skills' from general rsync as we handle it specifically
        rsync -aKq --exclude ".git" --exclude "skills" "$AGENTS_DIR/$agent/" "$TARGET_ROOT/.$agent/"
        
        # 7.3 Agent-Specific Skills (Overrides)
        if [ -d "$AGENTS_DIR/$agent/skills" ]; then
            log "  Processing agent-specific skills for $agent..."
            # Create a temp dir for this agent's processed skills
            AGENT_BUILD_DIR=".build/skills_$agent"
            mkdir -p "$AGENT_BUILD_DIR"
            process_skill_dir "$AGENTS_DIR/$agent/skills" "$AGENT_BUILD_DIR"
            
            # Sync to home (overwriting shared ones if name matches)
            rsync -aKq "$AGENT_BUILD_DIR/" "$TARGET_ROOT/.agent/skills/"
            rm -rf "$AGENT_BUILD_DIR"
        fi
    fi
    
    # 7.4 Maintain Legacy Symlinks & Antigravity Support
    log "  Maintaining legacy symlinks & Antigravity support for $agent..."
    mkdir -p "$TARGET_ROOT/.$agent/skills"

    # Antigravity support for Gemini
    if [ "$agent" == "gemini" ]; then
        log "  Setting up Antigravity skills for Gemini..."
        mkdir -p "$TARGET_ROOT/.$agent/antigravity"
        rm -rf "$TARGET_ROOT/.$agent/antigravity/skills"
        ln -sf "$TARGET_ROOT/.agent/skills" "$TARGET_ROOT/.$agent/antigravity/skills"
    fi
    
    find "$TARGET_ROOT/.agent/skills" -maxdepth 1 -mindepth 1 -type d | while read skill_path; do
        skill_name=$(basename "$skill_path")
        
        # Clean up existing to avoid nesting
        rm -rf "$TARGET_ROOT/.$agent/skills/$skill_name"
        ln -sf "$skill_path" "$TARGET_ROOT/.$agent/skills/$skill_name"
        
        if [ "$agent" == "gemini" ]; then
            rm -f "$TARGET_ROOT/.$agent/$skill_name.md"
            ln -sf "$skill_path/SKILL.md" "$TARGET_ROOT/.$agent/$skill_name.md"
        else
            rm -f "$TARGET_ROOT/.$agent/$skill_name.xml"
            ln -sf "$skill_path/SKILL.md" "$TARGET_ROOT/.$agent/$skill_name.xml"
        fi
    done
done

# 8. OpenCode Support
OPENCODE_CONFIG="$TARGET_ROOT/.config/opencode"
if [ -d "$OPENCODE_CONFIG" ] || [ -d "$TARGET_ROOT/.openclaw" ]; then
    log "Deploying for opencode..."
    mkdir -p "$OPENCODE_CONFIG/skills"
    
    find "$TARGET_ROOT/.agent/skills" -maxdepth 1 -mindepth 1 -type d | while read skill_path; do
        skill_name=$(basename "$skill_path")
        
        rm -rf "$OPENCODE_CONFIG/skills/$skill_name"
        ln -sf "$skill_path" "$OPENCODE_CONFIG/skills/$skill_name"
    done
    
    echo "OpenCode skills linked to $OPENCODE_CONFIG/skills/"
fi

# Cleanup local build if it's not in temp
if [[ "$BUILD_DIR" == .build* ]]; then
    rm -rf .build
fi

echo "---"
echo "Sync complete. All skills unified in shared/skills and agents/*/skills."
echo "Index location: $AGENTS_MD"
echo "Skill store: $TARGET_ROOT/.agent/skills/"
echo "OpenCode: $TARGET_ROOT/.config/opencode/skills/"