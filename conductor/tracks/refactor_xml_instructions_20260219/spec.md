# Track: Refactor XML Instructions to Markdown

The current `AGENTS.md` and skill indexing system use XML-like tags (`<skills_system>`, `<skill>`, etc.). The user wants to move away from XML and use standard Markdown instead.

## Goals
- Remove XML tags from `shared/AGENTS.md` and `shared/core_profile.md`.
- Update `meta/sync.sh` to generate Markdown-based skill listings.
- Ensure cross-agent compatibility (Gemini CLI and Claude Code) is maintained.

## Success Criteria
- `AGENTS.md` contains no XML tags.
- Skill index is readable and functional for both agents.
- `./meta/sync.sh` correctly populates the skill index in the new format.
