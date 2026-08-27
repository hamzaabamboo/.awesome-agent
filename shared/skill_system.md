# SKILLS SYSTEM

Use `skills.sh` as the source of truth for non-local skills.

## Usage

- Discover remote skills at `https://skills.sh/`
- `./meta/sync.sh --yes` should install all remote `skills.sh` entries automatically
- Install remote skill repos manually only if you are debugging with `npx skills add <owner/repo>`
- Use repo-local custom skills directly from this repo-managed setup
- This repo should only store local custom skills and local skill tests
- Do not vendor or copy skills that already live on `skills.sh`
- Local custom skill source must live under `shared/local-skills/`
- Generated local skill targets must stay inside this repo, with external agent paths symlinked back here instead of copied into `~/.agent`, `~/.agents`, `~/.codex`, `~/.claude`, or `~/.gemini`

## Canonical Current-Task Record and Continuation Recovery

- Every repository task has exactly one live task record. Use the repository's established task directory; when none is declared, use `<repo>/conductor/CURRENT_TASK.md`. In this repository the canonical path is `conductor/CURRENT_TASK.md`.
- Replace the canonical record in place. Do not create dated `CURRENT` files, append new receipts to the live record, or create parallel task documents. Historical receipts and full handoffs are evidence, not live task authority.
- On every new turn, Goal continuation, or automatic conversation summary, check Goal state when available, then read the canonical current-task record before project work. Treat it as the query index: open only files it names as relevant to the immediate next action. Do not recursively read all project notes, handoffs, or instruction files.
- The latest raw user correction updates the canonical record before project work. A persistent Goal objective, generated summary, prior handoff, or model output never overrides that correction or substitutes for the record.
- Before compression or handing off, update the same canonical record with current scope, permissions, dirty state, verified evidence, unverified items, and one immediate next action. After compression, read it before resuming and update it in place as work proceeds.

## Every Skill Invocation

- Before executing any skill, create or update the current task's project-owned task document.
- The task document is the canonical current-task record above; do not satisfy this gate with a parallel or append-only receipt.
- Before taking any action from a skill, read its `SKILL.md` completely from line 1 through EOF. Read every directly required linked instruction, reference, template, script, and asset completely before acting on it. Follow further required links until the skill's execution path is fully read. Skill metadata, summaries, prior familiarity, partial reads, and generated copies never substitute for the complete source.
- Determine total lines before each skill or reference read. If any tool uses an offset or limit, maintain contiguous range coverage and continue immediately through EOF. Record `1–EOF` coverage in the task document. Any missing, overlapping, or unverified range blocks skill execution and blocks completion claims.
- Re-read every direct user message in the complete current session. Do not inspect other sessions merely because a skill was invoked.
- `$what-did-i-say` is current-session-only and never authorizes prior-session or cross-project history reads.
- Cross-session history reading is permitted only when the user explicitly requests history review or an invoked recovery/history skill explicitly requires it. Keep that read inside the current project unless the user explicitly names a broader scope.
- When cross-session history is authorized, identify relevant skill invocations in that project-scoped corpus, read their surrounding request sequences, and determine what the agent subsequently missed, ignored, contradicted, displaced, or failed to verify.
- Think across everything read before decomposing work. Preserve exact operative wording in transient context and execute it literally when technically coherent and authorized.
- Document every active user request, exact scope, ordering, dependencies, invoked skills and their gates, source-of-truth artifacts, current status, permissions granted this turn, explicit non-actions, next action, and verification target.
- Re-read the complete current-session user request stream and update the task document whenever the user adds, corrects, repeats, or overrides instructions, including rapid-fire messages.
- Preserve the full operational meaning and specificity of the user's wording. Do not narrow, soften, omit, or replace requirements with a convenient summary.
- Keep raw chat transcripts, verbatim quotes, session identifiers, and private history out of project files unless the user explicitly requests their persistence. Document actionable requirements, not conversation copies.
- Treat skill loading as incomplete. Record and execute every required action and completion gate before marking the skill or task complete.
- Keep the task document current throughout execution. Do not reconstruct it only at handoff or completion.
- Keep the live record under 200 lines and 16 KiB. Replace superseded state and receipts in place. Move reusable topic knowledge into focused indexed notes; never use the live record as an append-only log or raw transcript store.
- Project `AGENTS.md`, `CLAUDE.md`, documented workflow, and repository conventions govern execution inside that project. The current request defines the outcome; it does not silently waive project protocol. Ask only when an explicit request truly conflicts with a project rule and the conflict cannot be resolved from current artifacts.
- Do not create tests proactively. Add tests only when explicitly requested, required by project protocol, or necessary because existing verification cannot cover changed behavior. Running existing required verification remains allowed.

## Remote Skill Routing

- Install complete remote skill repositories when the registry entry has no `|skill` selector. Use selectors only when intentionally limiting the package.
- Every installed Matt Pocock skill is active by trigger, not just its setup or grilling skills. Match each request against installed skill descriptions and invoke every applicable skill; do not omit a matching skill because a generic workflow could complete the task.
- When `grill-me` or `grilling` matches materially underspecified plans, designs, or features whose unresolved choices would change the delivered result, invoke it before artifacts. Do not grill for facts discoverable from the repo or settled requirements.
- Prefer the smallest set covering all matching triggers. Skill discovery must reduce uncertainty or work; never load unrelated skills as ceremony.

## Design Skill Invocation

- Treat `design`, `redesign`, `UI`, `UX`, `mockup`, `visual`, `layout`, `theme`, `style`, `brand`, and `pixel-perfect` as design triggers.
- Before proposing or implementing design work, invoke the relevant installed design skills. For broad or open-ended design work, invoke most applicable design skills first, including `frontend-design`, `web-design-guidelines`, `ui-ux-pro-max`, `design-md`, `canvas-design`, `design-taste-frontend`, `taste-design`, `visual-pixel-match`, and any matching Stitch/Figma/design-system skill.
- Use a smaller subset only when the design scope is clearly narrow, and do not attempt the design first and retrofit skill guidance afterward.

## Handoff Invocation

- Invoke `$handing-off-pro-max` before context compression, changing which agent handles a project, ending active work with documentation, or whenever the user asks for a handoff, continuation record, exact commands, everything in context, or no summary.
- Routine compaction does not require a full handoff. Use `$handing-off-pro-max` only for an actual agent handoff, explicit handoff request, or deliberate stop requiring continuation documentation; use `$un-dumb-yourself` for compaction state recovery.
