# GYST Receipt — Codex wrapper origin, 2026-08-10

## Exact latest request

`why did we have fucking that shit??`

## Trigger and correction

User frustration required re-opening the origin instead of repeating the path diagnosis. The earlier answer established why the wrapper failed but did not establish why the wrapper existed. This pass traced the source commit, sync wiring, LaunchAgent, runtime logs, and event log.

## Locked task and authority

- Source of truth: `/Users/hamp/.awesome-agent/shared/wrappers/codex` and its introducing commit `da49fbc`.
- Working directory: `/Users/hamp/Documents/Codex/2026-08-10/users-hamp-local-bin-codex-line`.
- Repository: `/Users/hamp/.awesome-agent`, branch `main`.
- Current-turn permission: read-only investigation and answer; no code or external-state changes.
- Pre-existing dirty paths preserved, including the wrapper fix and GYST receipts.

## Root-cause and provenance evidence

- `git show --no-patch --format=fuller da49fbc`: commit dated 2026-07-24, message `feat: add transparent workflow tooling`.
- The same commit added both `shared/wrappers/claude` and `shared/wrappers/codex`, `sync_wrappers`, and `sync_launch_agents`.
- `README.md` says wrappers link into `~/.local/bin`; the documented Claude behavior routes through `http://127.0.0.1:47821` and the `com.awesome-agent.pxpipe` LaunchAgent.
- `meta/sync.sh` links every `shared/wrappers/*` file into `~/.local/bin` and writes the pxpipe LaunchAgent plist.
- The plist runs `npx -y pxpipe-proxy`, exposes Anthropic/OpenAI upstreams, and tracks events in `~/.pxpipe/events.jsonl`.
- `launchctl print gui/501/com.awesome-agent.pxpipe` shows the service is running.
- `~/.pxpipe/launchd.out.log` shows the proxy listening on port 47821, with Anthropic/OpenAI upstreams and a dashboard.
- `~/.pxpipe/events.jsonl` contains one real Anthropic request event.
- The original Codex wrapper routed OpenAI traffic through pxpipe only when `OPENAI_API_KEY` was set; otherwise it directly executed the real Codex binary.

## Conclusion

The wrapper existed to make Codex participate in the same local pxpipe proxy/accounting/dashboard workflow as Claude. It was not required by Codex. The wrapper shadowed the real CLI because sync linked it into `~/.local/bin`, and its direct-exec fallback used a hardcoded `/opt/homebrew/bin/codex` path. That path did not match the installed `/usr/local/bin/codex`, so the intended bypass failed.

The commit and code document the mechanism, but no artifact records the user’s original decision or whether pxpipe is still wanted. That product decision remains open and was not assumed.

## Sources read fully

- `/Users/hamp/.awesome-agent/.build/skills/get-your-shit-together/SKILL.md`
- `/Users/hamp/.awesome-agent/shared/AGENTS.md`
- `/Users/hamp/.awesome-agent/shared/core_profile.md`
- `/Users/hamp/.awesome-agent/shared/skill_system.md`
- `/Users/hamp/.codex/config.toml`
- `/Users/hamp/.awesome-agent/shared/local-skills/get-your-shit-together/references/user-demands.md`
- `/Users/hamp/.awesome-agent/shared/local-skills/get-your-shit-together/references/gyst-2026-08-02-unauthorized-llernote-merges.md`
- `/Users/hamp/.awesome-agent/shared/local-skills/get-your-shit-together/references/gyst-2026-08-10-codex-wrapper-fix.md`
- `/Users/hamp/.awesome-agent/docs/HANDOFF_2026-07-29.md`
- `/Users/hamp/.awesome-agent/conductor/index.md`
- `/Users/hamp/.awesome-agent/conductor/tracks.md`
- `/Users/hamp/.awesome-agent/conductor/product.md`
- `/Users/hamp/.awesome-agent/conductor/product-guidelines.md`
- `/Users/hamp/.awesome-agent/conductor/tech-stack.md`
- `/Users/hamp/.awesome-agent/conductor/workflow.md`
- `/Users/hamp/.awesome-agent/conductor/code_styleguides/general.md`
- `/Users/hamp/.awesome-agent/README.md`
- `/Users/hamp/.awesome-agent/meta/sync.sh`
- `/Users/hamp/.awesome-agent/shared/wrappers/codex`
- `/Users/hamp/.awesome-agent/shared/wrappers/claude`
- `/Users/hamp/Library/LaunchAgents/com.awesome-agent.pxpipe.plist`
- `/Users/hamp/.pxpipe/launchd.out.log`
- `/Users/hamp/.pxpipe/launchd.err.log`
- `/Users/hamp/.pxpipe/events.jsonl`

## Verification artifact

- Full `git show` of the introducing commit’s wrapper, sync, and README changes.
- Live `launchctl print` state and pxpipe logs/events read directly.
- Final current wrapper read directly after the path fix.

## Explicitly unverified

- The original user-level reason for enabling pxpipe is not present in the repository artifacts.
- Whether pxpipe should remain installed is an unresolved product choice; no removal was performed.
- Codex’s proxy branch with a real `OPENAI_API_KEY` was not exercised.
