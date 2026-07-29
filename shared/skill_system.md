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

## Design Skill Invocation

- Treat `design`, `redesign`, `UI`, `UX`, `mockup`, `visual`, `layout`, `theme`, `style`, `brand`, and `pixel-perfect` as design triggers.
- Before proposing or implementing design work, invoke the relevant installed design skills. For broad or open-ended design work, invoke most applicable design skills first, including `frontend-design`, `web-design-guidelines`, `ui-ux-pro-max`, `design-md`, `canvas-design`, `design-taste-frontend`, `taste-design`, `visual-pixel-match`, and any matching Stitch/Figma/design-system skill.
- Use a smaller subset only when the design scope is clearly narrow, and do not attempt the design first and retrofit skill guidance afterward.

## Handoff Invocation

- Invoke `$handing-off-pro-max` before context compression, changing which agent handles a project, ending active work with documentation, or whenever the user asks for a handoff, continuation record, exact commands, everything in context, or no summary.
- The project-owned full handoff comes before `$un-dumb-yourself before`; the compact `/tmp` recovery capsule is not a substitute for it.
