# Daily skills/config maintenance

## Tanyawats-MacBook-Pro.local
- Date: 2026-11-27. `DO_NOT_TRACK=1`, `DISABLE_TELEMETRY=1`, `HOMEBREW_NO_ANALYTICS=1` enabled. No services, audio, browser settings, PRs, merges, deployment, or paid calls.
- Reconcile: fast-forwarded `main` (`26321c4 -> 7e1bc5c`) via temporary stash with `--index` pop; preserved staged `shared/remote-skills.txt`, unstaged `shared/AGENTS.md`/`shared/core_profile.md`/`shared/skill_system.md`, untracked `__pycache__`, and `stash@{0}`–`stash@{4}`.
- Toolchain (`meta/update-toolchain.sh`, `agent-browser` not installed): `codex` current (`0.172.0`); `skills@latest` `1.9.0`; unrelated Homebrew `isen-ng/dotnet-sdk-versions` tap migration warnings left alone.
- Remote update: selected 503 configured skills from 77 rows in `shared/remote-skills.txt` against `~/.agents/.skill-lock.json` (525 lock keys). Ran `SKILLS_CLONE_CONCURRENCY=1` with `npx --yes skills@latest update -g -y` (explicit names). Changed 8 (`antislop`, `antislop-code`, `antislop-copywriting`, `antislop-human`, `next-cache-components-adoption`, `next-cache-components-optimizer`, `next-dev-loop`, `ui-ux-pro-max`); 0 added, 0 removed; 1 failed (`react:components`: `No matching skills found`); upstream-deleted/multi-path warnings preserved without removal.
- Sync: `SKIP_REMOTE_SKILLS_INSTALL=true ./meta/sync.sh --skills-only --yes --verbose` exited 0. 549 global skills in `~/.agents/skills`, 532 Antigravity skills in `~/.gemini/config/skills`; Claude/Gemini/Codex prompt and hook links verified.
- Verification: serial `bash meta/check-harness.sh` exited 0 (6 shell suites, 19 evaluator tests, 9 parser tests). All 12 protected-file SHA-256 hashes unchanged. Logs in `.build/daily-maintenance-2026-11-27-local/`.

# Current task: Hermes personal assistant + Mac maintenance (T3)

- Hermes goal: Mai acts as a personal assistant. It decides, prepares artifacts, performs reversible HamFlow hygiene, and pings Ham via @mention only for a decision, due action or finished result, in Mai voice. No script-runner behavior, no status/backlog reports, no hardcoded items.
- Model/budget: default gpt-6-luna effort max; agent cron jobs a8000716b4c4 (Mai, hourly 09-21 JST) and 2d4a9bf745cb (triage 09:00) run medium because max cost 5-7M tokens/run. Anthropic fallback disabled (it spent Ham's Claude plan). Pace gate scripts/budget_gate.py pauses agent jobs after usage_limit_reached or when real Codex weekly percent is above pace.
- Status: Codex weekly limit hit 100% on 2026-11-12; resets 2026-11-15 02:20 JST. Agent jobs are gated until then. Standing jobs still off: career ops 553a658a10bd, travel 41a29f8fac6c, Thailand c18539c52f34.
- Monitoring (T3 scheduled tasks, fresh threads): Hermes monitor hourly; Mac maintenance every 6 hours. Both reply only when something non-disk needs Ham.
- Mac: disk headroom handled silently by dev-junk cleanup, never reported to Ham. Safari 27.2 needs Ham's password. No real malware scanner installed (XProtect + persistence diff only).
- Skills: ~470 installed; whole vetted repos added via shared/remote-skills.txt; skills that auto-report to vendors (mastra, expo/eas) removed.
- Next action: verify sync result, rescan new skills for vendor auto-reporting, re-enable career/travel jobs after the Codex reset.
