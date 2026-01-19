# Implementation Plan - Fix Skill Structure & Format

## Phase 1: Engine Refactoring
- [x] Task: Update `meta/sync.sh` to remove XML wrapping and implement directory-based output for shared skills
- [x] Task: Update `meta/sync.sh` to preserve directory structure for Superpowers skills (copy `SKILL.md` to `.../<name>/SKILL.md`)
- [x] Task: Fix `meta/sync.sh` to exclude `.git` directories and correct find logic.
- [x] Task: Conductor - User Manual Verification 'Phase 1: Engine Refactoring' (Protocol in workflow.md)

## Phase 2: Cleanup & Sync
- [x] Task: Manually clean up old flat symlinks in `~/.gemini/skills` and `~/.claude/skills` (or use `sync.sh --clean` if reliable)
- [x] Task: Run `meta/sync.sh --verbose --yes` to deploy new structure
- [x] Task: Conductor - User Manual Verification 'Phase 2: Cleanup & Sync' (Protocol in workflow.md)