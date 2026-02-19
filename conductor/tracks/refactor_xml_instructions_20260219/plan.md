# Plan: Refactor XML Instructions to Markdown

## Phase 1: Research & Preparation
- [x] Research current XML usage in `AGENTS.md` and `sync.sh`.
- [x] Verify `openskills sync` output (confirmed to be XML).

## Phase 2: Implementation
- [x] Update `meta/sync.sh`:
    - [x] Update the section that initializes `AGENTS.md` to remove XML tags like `<skills_system>`.
    - [x] Enhance the Python post-processing script to transform the XML skill list into a Markdown table.
- [x] Update `shared/core_profile.md` to remove any XML-like instructions or tags.
- [x] Manually clean up `shared/AGENTS.md` to remove old XML tags.

## Phase 3: Verification
- [x] Run `./meta/sync.sh --verbose` to trigger a full sync.
- [x] Verify `shared/AGENTS.md` contains a clean Markdown list of skills.
- [x] Verify that Gemini and Claude still correctly see the skills (the content of `AGENTS.md` is what they read).

## Phase 4: Cleanup
- [ ] Remove temporary files.
