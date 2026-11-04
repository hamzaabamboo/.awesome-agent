# Current Task — agent-log self-improvement and self-blocking Stop hook

## Active (2026-11-04)
- Request: read Claude + Codex transcripts Sep 4 – Nov 4 2026, find recurring agent failures, document them, fix the instructions and the harness, council it, then commit, push and test.
- Causal finding: written rules already forbade self-blocking and agents ignored them; the first council loop repeated the failure (22 rounds of text patches with no convergence bound).
- Harness: `shared/hooks/no_self_block.py` Stop hook (blocks once on permission questions/offers, self-blocking, or unverified/untested endings). Claude: `~/.claude/hooks` symlink + `settings.json` Stop entry. Codex: `~/.codex/hooks.json` symlink to `shared/hooks/codex-hooks.json`. `tests/test_no_self_block.sh`: 47 cases.
- Docs: `analysis/agent-log-pain-points/report-2026-11.md`; scripts `extract`, `pairs`, `classify-pairs`, `bucket-messages` (`.mjs`).
- Rules: `shared/core_profile.md`, `shared/skill_system.md`, GYST `user-demands.md` §21; `shared/AGENTS.md` rendered by the sync generator.
- Council: final full-deliverable review returned 0 findings.
- User-only: approve the hook once in Codex's trust prompt.
- Not committed by design: `shared/local-skills/avatar-clip-pack/` (work-workspace skill; a recorded user rule keeps it out of global sync; this repo is public).
- Out of scope, reported: `block_pr_merge.py` blocks `gh pr merge` in every repo.

## Previous task (done)
- Global configuration sync without owning Hermes setup: committed and pushed upstream (f78a573, 917e788); Hermes-specific work lives in its own workspace record.
