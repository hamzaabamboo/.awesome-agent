# GYST Receipt — Codex wrapper path fix, 2026-08-10

## Exact latest request

`fix it then??`

## Violated rule and correction

The prior response diagnosed the missing executable but stopped at a workaround instead of implementing the requested fix. The correction was to patch the repo-managed wrapper after the user explicitly authorized implementation.

Applicable rules:

- Do the work in scope instead of returning a diagnosis when implementation is requested.
- Fix the root cause, not the symptom.
- Preserve unrelated dirty work.
- Verify the real runtime before claiming completion.

## Locked task and authority

- Source of truth: `/Users/hamp/.awesome-agent/shared/wrappers/codex`.
- Runtime entrypoint: `/Users/hamp/.local/bin/codex` → repo-managed wrapper.
- Current-turn authority: modify the wrapper and run local verification only.
- Explicit non-actions: no package installation, sync deployment, push, merge, or external write.
- Pre-existing dirty paths preserved: `shared/AGENTS.md`, `shared/core_profile.md`, and `shared/local-skills/get-your-shit-together/references/gyst-2026-08-02-unauthorized-llernote-merges.md`.

## Sources read fully

- `/Users/hamp/.awesome-agent/.build/skills/get-your-shit-together/SKILL.md`
- `/Users/hamp/.agents/skills/using-superpowers/SKILL.md`
- `/Users/hamp/.agents/skills/using-superpowers/references/codex-tools.md`
- `/Users/hamp/.agents/skills/systematic-debugging/SKILL.md`
- `/Users/hamp/.agents/skills/brainstorming/SKILL.md`
- `/Users/hamp/.agents/skills/test-driven-development/SKILL.md`
- `/Users/hamp/.agents/skills/karpathy-guidelines/SKILL.md`
- `/Users/hamp/.agents/skills/verification-before-completion/SKILL.md`
- `/Users/hamp/.awesome-agent/shared/AGENTS.md`
- `/Users/hamp/.awesome-agent/shared/core_profile.md`
- `/Users/hamp/.awesome-agent/shared/skill_system.md`
- `/Users/hamp/.awesome-agent/shared/local-skills/get-your-shit-together/references/user-demands.md`
- `/Users/hamp/.awesome-agent/conductor/index.md`
- `/Users/hamp/.awesome-agent/conductor/tracks.md`
- `/Users/hamp/.awesome-agent/conductor/product.md`
- `/Users/hamp/.awesome-agent/conductor/product-guidelines.md`
- `/Users/hamp/.awesome-agent/conductor/tech-stack.md`
- `/Users/hamp/.awesome-agent/conductor/workflow.md`
- `/Users/hamp/.awesome-agent/conductor/code_styleguides/general.md`
- `/Users/hamp/.awesome-agent/docs/HANDOFF_2026-07-29.md`
- `/Users/hamp/.awesome-agent/shared/local-skills/get-your-shit-together/references/gyst-2026-08-02-unauthorized-llernote-merges.md`
- `/Users/hamp/.awesome-agent/shared/wrappers/codex`
- `/Users/hamp/.awesome-agent/shared/wrappers/claude`

No user-provided asset or history-log request required additional extraction.

## Root cause evidence

- `/opt/homebrew/bin/codex` does not exist.
- `/usr/local/bin/codex` exists and resolves to Codex CLI `0.147.0`.
- `OPENAI_API_KEY` is unset, so the wrapper takes its direct-exec branch.
- Before the patch, `PXPIPE_DISABLE=1 /Users/hamp/.local/bin/codex --version` reproduced the exact missing-path error.

## Corrected action

Changed only `shared/wrappers/codex` to preserve `PXPIPE_CODEX_BIN`, prefer `/opt/homebrew/bin/codex`, fall back to `/usr/local/bin/codex`, and emit an actionable error if neither path exists.

## Verification artifacts

- `/Users/hamp/.local/bin/codex --version` → `codex-cli 0.147.0`.
- `PXPIPE_CODEX_BIN=/usr/local/bin/codex /Users/hamp/.local/bin/codex --version` → `codex-cli 0.147.0`.
- `bash -n /Users/hamp/.awesome-agent/shared/wrappers/codex` exited 0.
- `git -C /Users/hamp/.awesome-agent diff --check` exited 0.
- Final status confirms only `shared/wrappers/codex` was added to the pre-existing dirty paths.

## Explicitly unverified

- The `/opt/homebrew/bin/codex` branch was not exercised because that executable is absent on this machine.
- The pxpipe branch with `OPENAI_API_KEY` set was not exercised because the key is unset and testing it could trigger the launch-agent path.
- No commit or deployment was requested or performed.
