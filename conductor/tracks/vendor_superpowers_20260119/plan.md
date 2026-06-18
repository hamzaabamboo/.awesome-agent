# Implementation Plan - Vendor External Dependencies (Archived)

This historical plan predates the current `skills.sh` remote-skill model. It is not the active source of truth for skill installation.

## Phase 1: Cleanup & Vendoring [checkpoint: 1191c51]
- [x] Task: Add `tests/mock_home/` to `.gitignore` to reduce git status noise.
- [x] Task: Remove `.gitmodules`.
- [x] Historical task: Convert the then-current Superpowers submodule to a regular directory.
- [x] Historical task: Convert the then-current Claude plugin cache submodule to a regular directory.
- [x] Historical task: Convert the then-current Claude plugin marketplace submodule to a regular directory.
- [x] Historical task: Convert the then-current Superpowers marketplace submodule to a regular directory.
- [x] Task: Commit changes (Commit: `1191c51`).

## Phase 2: Verification
- [x] Task: Verify that `meta/sync.sh` still works correctly.
- [x] Historical task: Verify the then-current project was self-contained.
