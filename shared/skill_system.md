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

## Every Skill Invocation

- Before executing any skill, create or update the current task's project-owned task document.
- Read every direct user message from all Codex and Claude sessions covering the previous two weeks. Do not sample, keyword-search and stop, or rely on generated summaries.
- Identify every skill invocation in that two-week corpus, read its surrounding request sequence, and determine what the agent subsequently missed, ignored, contradicted, displaced, or failed to verify.
- Re-read every direct user message in the complete current session. Reconcile the current session with the two-week cross-session findings as one evolving specification.
- Think across everything read before decomposing work. Preserve exact operative wording in transient context and execute it literally when technically coherent and authorized.
- Document every active user request, exact scope, ordering, dependencies, invoked skills and their gates, source-of-truth artifacts, current status, permissions granted this turn, explicit non-actions, next action, and verification target.
- Re-read the complete current-session user request stream and update the task document whenever the user adds, corrects, repeats, or overrides instructions, including rapid-fire messages.
- Preserve the full operational meaning and specificity of the user's wording. Do not narrow, soften, omit, or replace requirements with a convenient summary.
- Keep raw chat transcripts, verbatim quotes, session identifiers, and private history out of project files unless the user explicitly requests their persistence. Document actionable requirements, not conversation copies.
- Treat skill loading as incomplete. Record and execute every required action and completion gate before marking the skill or task complete.
- Keep the task document current throughout execution. Do not reconstruct it only at handoff or completion.

## Design Skill Invocation

- Treat `design`, `redesign`, `UI`, `UX`, `mockup`, `visual`, `layout`, `theme`, `style`, `brand`, and `pixel-perfect` as design triggers.
- Before proposing or implementing design work, invoke the relevant installed design skills. For broad or open-ended design work, invoke most applicable design skills first, including `frontend-design`, `web-design-guidelines`, `ui-ux-pro-max`, `design-md`, `canvas-design`, `design-taste-frontend`, `taste-design`, `visual-pixel-match`, and any matching Stitch/Figma/design-system skill.
- Use a smaller subset only when the design scope is clearly narrow, and do not attempt the design first and retrofit skill guidance afterward.

## Handoff Invocation

- Invoke `$handing-off-pro-max` before context compression, changing which agent handles a project, ending active work with documentation, or whenever the user asks for a handoff, continuation record, exact commands, everything in context, or no summary.
- The project-owned full handoff comes before `$un-dumb-yourself before`; the compact `/tmp` recovery capsule is not a substitute for it.
