# GYST Receipt — handing-off-pro-max, 2026-07-29

## Exact latest request

`$skill-creator I WANT, ANOTHER SKILL`

`HANDING OFF PRO MAX`

`USE BEFORE COMPRESSION/CHANGING AGENT HANDLING THE PROJECT/LEAVING DOCUMENTATION`

`YOU MUST LIETERALLY WRITE DOWN EVERYTHING YOU HAD IN YOUR CONTEXT, WORKING STEPS, EXACT COMMAND`

`NO SUMMARY NO FULFF`

`GO READ MY LOGS AND SEE HOW I ORDER HANDOFF, THE LATEST ONE IN THE COURTA IS THE KIND OF HANDOFF I WANT, EVERYTHING IN PERFECT DETAIL`

`$get-your-shit-together $un-dumb-yourself`

## Violation and correction

The existing compaction procedure required a recovery capsule but did not require a project-owned exhaustive handoff before agent/project ownership changed or documentation was left. A capsule is intentionally compact and cannot satisfy the requested full operational transfer. Corrected by adding a standalone local skill and requiring the complete handoff before `un-dumb-yourself before` updates its compact recovery capsule.

## Sources read fully

- `shared/local-skills/get-your-shit-together/SKILL.md`
- `shared/local-skills/un-dumb-yourself/SKILL.md`
- `shared/core_profile.md`
- `shared/skill_system.md`
- `shared/AGENTS.md`
- `shared/local-skills/get-your-shit-together/references/user-demands.md`
- `shared/local-skills/get-your-shit-together/references/refresh-procedure.md`
- `shared/local-skills/get-your-shit-together/scripts/isolate_user_messages.sh`
- `/Users/vittayapalotai.tanyawat/.agents/skills/skill-creator/SKILL.md`
- `README.md`
- `conductor/index.md`
- `conductor/workflow.md`
- `conductor/product.md`
- `conductor/product-guidelines.md`
- `conductor/tech-stack.md`
- `conductor/tracks.md`
- `meta/sync.sh`
- `tests/test_transform.sh`
- `tests/test_prompt_unification.sh`
- `tests/test_cleanup.sh`
- `tests/test_remote_skills.sh`
- `tests/test_sync_args.sh`
- `/Users/vittayapalotai.tanyawat/uhh/courta/docs/HANDOFF_2026-07-28.md`

## Large logs inspected with bounded targeted reads

- `/Users/vittayapalotai.tanyawat/.claude/projects/-Users-vittayapalotai-tanyawat-uhh-courta/ea28dff1-c50f-4bb5-99ba-38a81568230a.jsonl` — 315 MB; searched for the exact handoff wording, then inspected the latest `last-prompt` and attached `HANDOFF_2026-07-28.md` artifact. The matching user demand requires every detail, methodology, and step-by-step record rather than a summary.
- `/Users/vittayapalotai.tanyawat/.codex/history.jsonl` — 2.7 MB; size checked. No task-specific historic handoff became authoritative over the named Courta artifact and latest raw request.

## Source-of-truth resolution

Latest raw request controls the new skill's trigger and completeness. The named Courta handoff controls its shape and evidence standard. Current `.awesome-agent` source controls installation and compaction integration. The existing dirty `shared/core_profile.md` change is unrelated and preserved.

## Corrected immediate action

Create `shared/local-skills/handing-off-pro-max/SKILL.md`, test prompts, and the integration edits required for compaction discovery. Render through the existing sync engine, inspect managed targets, and run scoped sync verification.

## Verification result

- `bash tests/test_transform.sh` — passed.
- `bash tests/test_prompt_unification.sh` — passed, including the new generated-prompt and global-link assertions.
- `bash tests/test_cleanup.sh` — passed.
- `bash tests/test_remote_skills.sh` — passed.
- `bash tests/test_sync_args.sh` — passed.
- `SKIP_REMOTE_SKILLS_INSTALL=true ./meta/sync.sh --verbose --yes` — completed.
- Built source exists at `/Users/vittayapalotai.tanyawat/.agent/skills/handing-off-pro-max/SKILL.md`.
- Global link exists at `/Users/vittayapalotai.tanyawat/.agents/skills/handing-off-pro-max`.
- Claude link exists at `/Users/vittayapalotai.tanyawat/.claude/skills/handing-off-pro-max`.
- Generated `shared/AGENTS.md` and deployed `/Users/vittayapalotai.tanyawat/.codex/AGENTS.md` both contain the invocation rule and skill metadata.
- Full project handoff written at `docs/HANDOFF_2026-07-29.md` and read back in full.

Explicitly unverified: future model invocation rate, future successor-agent execution, with-skill/baseline benchmark runs, and user review of skill outputs.
