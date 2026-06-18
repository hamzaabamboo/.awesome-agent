# Project Workflow

## Guiding Principles

1. `shared/core_profile.md` is the source of truth for cross-agent operating rules.
2. Project-specific learnings live in that project's files. Cross-agent learnings live in this repo.
3. Remote skills come from `skills.sh`; local custom skills live under `shared/local-skills/`.
4. Generated local skill targets stay repo-managed and are exposed through symlinks without replacing global skill installs.
5. Verification must match the task: surgical fixes get scoped checks; workflow, browser, PR, media, setup, and runtime behavior need real evidence.

## Task Workflow

1. Read the report, request, issue, PR, task file, or source artifact that defines the work.
2. Inspect the current repo state before editing.
3. Identify the source-of-truth files that should change.
4. Use subagents for independent reading, implementation, or verification slices when the work benefits from parallel audit.
5. Patch the repo-owned source, not generated or external copies, unless the generated output is intentionally refreshed by the sync engine.
6. Run commands one by one unless the user explicitly asks for batching or the command is an established single project script.
7. After each command, inspect the result and choose the next concrete action.
8. Do not use sleep loops as progress. If external state is in flight, query the authoritative state with a bounded target and act on what returned.
9. Run aggregate verification after the full scoped change is implemented.
10. Sync with `./meta/sync.sh --verbose --yes` when profile, skill, command, or generated prompt output changes.
11. Inspect installed outputs when the claim depends on agent-visible behavior.
12. Do not call work done until repo source, generated outputs, tests, and any user-facing artifact agree.

## Current Verification Commands

- `bash tests/test_cleanup.sh`
- `bash tests/test_prompt_unification.sh`
- `bash tests/test_remote_skills.sh`
- `bash tests/test_sync_args.sh`
- `bash tests/test_transform.sh`

Run these one command at a time unless the user asks for batching.

## Evidence Rules

- For prompt and skill behavior, verify `shared/core_profile.md`, `shared/local-skills/*/SKILL.md`, `shared/AGENTS.md`, and the installed files under `~/.codex`, `~/.claude`, `~/.gemini`, `~/.agent/skills`, and `~/.agents/skills`.
- For sync behavior, verify `meta/sync.sh`, `meta/install-remote-skills.sh`, and the `tests/*.sh` harness.
- For local-skill source behavior, verify `shared/local-skills/` and `shared/remote-skills.txt`; do not treat `shared/skills/` as the active source.
- For PR/media/runtime claims in downstream projects, use that project's canonical evidence, dogfood, browser, screenshot, and PR-body verifier scripts when they exist.
- Keep reviewer-facing media as GitHub user attachments or the repo-required media host, not local-only paths.

## Completion Gate

A task is complete only when:

1. The requested source files are updated.
2. Generated outputs are refreshed when required.
3. The relevant test or verifier commands pass.
4. Installed outputs match the managed source when agent behavior is affected.
5. Subagent audit findings have been integrated or explicitly disproven with stronger evidence.
6. No known source-of-truth artifact still contradicts the claimed behavior.
