# Current Task

## Objective

Complete the full branch update from the live remote: pull the fetched `main`, run the canonical sync with remote installation enabled, verify all 37 Matt Pocock skills and the effective agent catalog, commit intended repository changes, push `main`, and prove equal local/remote heads with a clean worktree.

## Active requirements

- Full sync must run without `SKIP_REMOTE_SKILLS_INSTALL`.
- The 37-skill Matt Pocock installation is the primary acceptance target.
- Canonical records stay queryable, under 200 lines and 16 KiB; replace stale state, split stable topics, never ingest everything.
- Project protocol governs execution. No new tests unless explicitly requested, project-required, or otherwise unverifiable.

## Current state

- `git fetch origin` completed in this turn and advanced `origin/main` from `29ce4fd` to `6cb3a07`.
- `git pull --ff-only` completed as `29ce4fd..6cb3a07`.
- Pre-pull repository changes were stashed, reapplied, and conflict-resolved without discarding upstream or local content.
- `./meta/sync.sh --verbose --yes` completed with remote installation enabled and reported `Sync complete`.
- All 37 Matt Pocock skill directories exist under `/Users/hamp/.agents/skills`; `setup-matt-pocock-skills/SKILL.md` is non-empty at 6.7K.
- `hermes skills list --enabled-only` exited 0 and reported `0 hub-installed, 10 builtin, 175 local — 185 enabled shown`.
- Managed prompt and skill links resolve to this repository; `tests/test_transform.sh`, `tests/test_prompt_unification.sh`, `tests/test_cleanup.sh`, `tests/test_remote_skills.sh`, and `tests/test_sync_args.sh` all exited 0.
- Seven pre-existing GYST receipt files remain as untracked repository work and will be preserved in the final commit.

## Skill gates

- GYST source and the current instruction/note stack were read through EOF; the recovery receipt is maintained here.
- `$what-did-i-say` `SKILL.md` `1–97` was read; the selected two-week Codex tranche `1–30` was read fully and the current request stream was reconciled.
- Full sync must install the registered remote entries, including `mattpocock/skills|setup-matt-pocock-skills`.

## Permissions and non-actions

- Authorized this turn: pull, run full sync, inspect managed targets, run existing checks, commit intended repository changes, and push `main`.
- No deploy, PR, browser, device/audio/system changes, or unrelated test creation.

## GYST receipt

- Correction: remote-skill installation, Git pull, canonical sync, commit, push, and clean-tree verification are one update chain.
- Mistake: the earlier repair skipped remote installation, reported from stale remote state, and stopped before proving the critical Matt skill target.
- Source: live fetched refs, `conductor/CURRENT_TASK.md`, `shared/core_profile.md`, `shared/skill_system.md`, `meta/sync.sh`, `meta/install-remote-skills.sh`, `shared/remote-skills.txt`, managed skill directories, and existing checks.
- Durable correction: `shared/core_profile.md` and `references/user-demands.md` now require the complete branch-update chain through clean-tree verification.
- Action: full remote-enabled sync, all 37 Matt skill paths, effective catalogs, managed links, and existing checks are verified; stage intended changes, commit, push, refetch, and verify.
- Verification target: Matt skill directories, Hermes catalog, source/generated prompt alignment, test results, local/remote equality, and `git status --short --branch`.

## Next action

Stage the verified repository changes, commit, push `main`, refetch `origin`, and verify equal heads with an empty worktree.
