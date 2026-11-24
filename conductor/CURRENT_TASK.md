# Harness postmortem — 2026-11-25

- Correction (GYST): Antigravity was reported as having no hook system, based only on `~/.gemini/config/config.json` containing one key.
- Mistake: an absent capability was inferred from one config file. The Antigravity binary documents `hooks.json` (in `~/.gemini/config/` and `.agents/`) with PreInvocation, PreToolUse, PostToolUse, SessionStart and Stop events. Source: the `/opt/homebrew/bin/agy` built-in docs.
- Rule change: `shared/core_profile.md` now requires a capability claim to be checked against the tool's docs or binary, and the named-skill rule now lists Antigravity hooks.
- Action: `shared/hooks/agent_gates.py agy` adapter; `shared/hooks/antigravity-hooks.json`; `meta/sync.sh` links the Codex and Antigravity hook configs; tests cover all three agents.
- Verification: live `agy -p` injected `test_skill` and the reply reported it; live Codex and Claude runs had already passed; check-harness passes.
- Open: postmortem gaps in `analysis/postmortem-2026-11-24/report.md`. The prior maintenance open items are unchanged.
