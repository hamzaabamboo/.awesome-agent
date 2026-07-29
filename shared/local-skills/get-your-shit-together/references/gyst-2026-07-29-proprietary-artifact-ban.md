# GYST Receipt — proprietary artifact ban, 2026-07-29

## Exact latest request

`1) i want to ban the use of claude in chrome, scratch pad and whatever proprietary shit that fucking prevents stuff from being left in the project, dogshit`

## Violation and correction

The prior handoff procedure accepted a Claude-owned scratchpad as a reference location. That permits required work state to exist outside the project and violates the durable-artifact rule. Browser-hosted Claude, Claude scratchpads, Claude/Cowork private workspaces, and other proprietary assistant artifact stores are now forbidden as project work surfaces and canonical evidence/handoff locations.

## Sources read

- `shared/local-skills/get-your-shit-together/SKILL.md`
- `shared/core_profile.md`
- `shared/skill_system.md`
- `shared/local-skills/get-your-shit-together/references/user-demands.md`
- `shared/local-skills/get-your-shit-together/references/refresh-procedure.md`
- `shared/local-skills/get-your-shit-together/references/gyst-2026-07-29-handoff-pro-max.md`
- `docs/HANDOFF_2026-07-29.md`
- `MEMORY.md` targeted scratchpad context

## Conflict resolution

Latest raw request overrides the prior acceptance of Claude scratchpad paths. Project-owned repository artifacts are canonical. External proprietary locations have no authority unless the user explicitly authorizes an exception, and they still cannot be the only required artifact.

## Corrected immediate action

Add the ban to `shared/core_profile.md` and `user-demands.md`, regenerate managed instructions with local-only sync, then inspect the generated/deployed prompt and run prompt-unification verification.

## Verification

- `SKIP_REMOTE_SKILLS_INSTALL=true ./meta/sync.sh --verbose --yes` completed.
- `bash tests/test_prompt_unification.sh` passed with assertions for `Project-owned artifacts only` and `browser-hosted Claude/Claude in Chrome`.
- `shared/core_profile.md`, generated `shared/AGENTS.md`, and deployed `/Users/vittayapalotai.tanyawat/.codex/AGENTS.md` all contain the ban.
- `git diff --check` passed.

## Explicitly unverified

No future browser-hosted Claude/scratchpad invocation has occurred after this rule was deployed. The enforcement is instruction-level and immediately agent-visible.
