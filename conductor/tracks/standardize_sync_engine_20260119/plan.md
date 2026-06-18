# Implementation Plan - Standardize Sync Engine

Archived. This track is superseded by the current sync-engine contract.

Current behavior:

- Canonical prompt source is `shared/core_profile.md`; generated prompt output is `shared/AGENTS.md`.
- Skills are Markdown `SKILL.md` directories, not XML blocks.
- Repo-local custom skill source lives in `shared/local-skills/`.
- Remote skills are listed in `shared/remote-skills.txt` and installed through `skills.sh` by `meta/sync.sh`.
- `~/.agent/skills` points at this repo's `.build/skills`.
- `~/.agents/skills` remains a real global skills directory; repo-local custom skills are linked into it per skill.
- Remote skills are not vendored under `external/` or `shared/skills/`.

Verification lives in `tests/`:

- `tests/test_transform.sh`
- `tests/test_cleanup.sh`
- `tests/test_prompt_unification.sh`
- `tests/test_remote_skills.sh`
- `tests/test_sync_args.sh`
