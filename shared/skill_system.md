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

## Skill Routing Map

Route by the task in front of you, not by keyword overlap. In each row the first skill is primary; load the others only when their specific condition holds. When two skills cover the same job, load the primary and skip the rest. A user naming a skill or framework always wins over this map. Project rules and an existing design system outrank every skill.

### Planning, specs, and decisions
- Underspecified plan, feature, or design: `grill-me` or `grilling`; `grill-with-docs` when project docs exist to grill against.
- Choosing an approach before coding: `think`. Restructuring existing code: `improve-codebase-architecture` or `codebase-design`. Domain vocabulary or `CONTEXT.md`: `domain-modeling`.
- Recording a settled architecture decision: `architecture-decision-records`.
- Turning agreed requirements into a spec or tickets: `to-spec`, `to-tickets`. Multi-step implementation plan: `writing-plans`.
- Vague request that needs sharpening before work: `sharpen`. Writing a prompt for another model or tool: `prompt-master`. Writing skills, `AGENTS.md`, or `CLAUDE.md`: `writing-for-agents`, then `skill-creator` to evaluate a skill.

### Implementation
- Tests requested or required by the project: `tdd`. Minimal fix: `surgical-patch`. Behavior-preserving refactor: `safe-refactor`.
- Type-level TypeScript (generics, conditional or mapped types): `typescript-advanced-types`. Effect code: `effect-ts`. Elysia backend: `elysiajs`.
- React/Next.js: `vercel-react-best-practices`; `react-doctor` to scan for React problems; `vercel-composition-patterns` for component API design; `vercel-react-view-transitions` for view transitions; `vercel-react-native-skills` for React Native.
- Three.js: `three-best-practices`; with `@react-three/fiber`: `r3f-best-practices`.

### Debugging, review, and shipping
- Bug, crash, or regression: `diagnosing-bugs`; `hunt` only when the user asks for it. Do not stack `systematic-debugging` on top.
- Reviewing a diff or branch: `code-review`. Release readiness or issue/PR triage: `check`, which never pushes, publishes, or closes anything without permission granted in the current turn.
- PR body: `pr`. PR evidence: `prove-it-in-pr`. Merge conflicts: `resolving-merge-conflicts`.

### Browser and quality audits
- Driving a browser or verifying UI: `agent-browser` (launch arguments per the hard limits above). Exploratory QA: `dogfood` or `agent-browser-dogfood`.
- Project uses Playwright, or a trace/codegen is needed: `playwright-cli`.
- Audits: `web-quality-audit` for a broad pass; `accessibility`, `core-web-vitals`, `performance`, or `seo` for one area.

### UI: styling stack (match the project)
- Panda CSS: `panda-css`; tokens, themes, recipes: `panda-css-theming`; migrating from another CSS tool: `panda-css-migrate`.
- Ark UI headless components: `ark-ui`.
- Park UI (Ark UI with Panda styles): `panda-css` plus `ark-ui`, and fetch `https://park-ui.com/llms.txt` for component and recipe docs. No Park UI skill exists.
- shadcn/ui, Radix, or Base UI: `shadcn`. `shadcn-ui` (Stitch) only inside Stitch workflows.

### UI: design and build
- Design triggers: `design`, `redesign`, `UI`, `UX`, `mockup`, `visual`, `layout`, `theme`, `style`, `brand`, `pixel-perfect`. Load skills before designing, never retrofit them afterward.
- New UI with no design system: `frontend-design` plus `design-taste-frontend`; add one style skill only when the brief names that style: `minimalist-ui`, `industrial-brutalist-ui`, `high-end-visual-design`, `brandkit`. Palette, font, and chart data: `ui-ux-pro-max`.
- Existing UI being improved: `redesign-existing-projects`, keeping the established system. `DESIGN.md` from Stitch: `design-md`.
- Anti-slop filter on every UI, copy, or code-comment task: `antislop` core plus the matching `antislop-ui`, `antislop-copywriting`, `antislop-human`, `antislop-layoutmobile`, or `antislop-code`. Use `ui-taste` or `anti-ui-slop` only when asked.
- Real product references for a screen, flow, or pattern: `ui-radar`.
- Rebuilding a screenshot or mockup 1:1: `image-to-ui`; capturing diff evidence: `visual-pixel-match`. A Figma URL for UI goes through the Figma MCP `figma-design-to-code` flow, never the HyperFrames `figma` skill.
- iOS screens: `ios-design`. Information density: `ui-density`. Usability review: `ux-heuristics`. Guideline compliance review: `web-design-guidelines`.
- Load `ui`, `ui-design`, `uizze-ui`, `gpt-taste`, `taste-design`, and `canvas-design` only when the user names them.

### Web animation
- GSAP: `gsap-core`; React: `gsap-react`; scroll: `gsap-scrolltrigger`; sequencing: `gsap-timeline`; plugins: `gsap-plugins`; jank: `gsap-performance`.
- Motion that feels wrong, easing, timing: `animation-principles`. Animated background: `motion-background`.

### Video and motion graphics
- Any video, reel, promo, or trailer: `motion-reel` first. It picks the engine; then load the engine's router.
- HyperFrames engine: `hyperframes` (router), which hands off to `product-launch-video`, `pr-to-video`, `faceless-explainer`, `motion-graphics`, `music-to-video`, `general-video`, `slideshow`, `embedded-captions`, or `talking-head-recut`.
- Remotion engine: `remotion-best-practices` (router), then `remotion-*`. `remotion` (Stitch) only for Stitch walkthroughs.
- Creative direction: `motion-art-direction`; framing: `shot-composition`; cut rhythm: `beat-sync-editing`; color: `color-motion`; logo stings: `logo-animation`; Adobe After Effects: `after-effects`.

### Data, analytics, and dashboards
- Answering a data question or investigating a metric: `analyze`. First look at a new table or file: `explore-data`; scientific files (HDF5, FASTA, NumPy, images): `exploratory-data-analysis`. QA before sharing results: `validate-data`.
- New SQL from a data need: `write-query`. Optimizing or translating SQL between dialects: `sql-queries`. Company warehouse context skill: `data-context-extractor`.
- Statistics and hypothesis tests: `statistical-analysis`; regression and time series models: `statsmodels`; machine learning: `scikit-learn`.
- DataFrames: pandas: `pandas-pro`; Polars: `polars`.
- Python charts: `create-viz`; chart choice and color principles: `data-visualization`; library-specific work: `matplotlib` or `seaborn`; publication figures: `scientific-visualization`. Charts in web UI or artifacts: `dataviz` where the host provides it.
- Standalone HTML dashboard from data: `build-dashboard`. Choosing metrics and dashboard layout: `kpi-dashboard-design`; a dashboard inside product code also gets the project's UI stack skills and `ui-density`.
- Stakeholder report or narrative: `data-storytelling`. Spreadsheet in or out: `xlsx`.

### Research, reading, and writing
- Read a URL or PDF to Markdown: `read`. Investigating a question from primary sources into a repo file: `research`. Deep study of an unfamiliar domain: `learn`. Personal knowledge wiki: `karpathy-llm-wiki`.
- Product and marketing copy: `antislop-copywriting`. Polishing prose: `write`. Load one prose skill per task.

### Agent setup and orchestration
- Auditing agent configuration drift in this repository: `health`.
- Parallel independent work: `dispatching-parallel-agents`.
- Inactive until Orca is installed: `orca-cli`, `orchestration`, `orca-*`, `jira-tickets`, `linear-tickets`. Handoffs always use `handing-off-pro-max`, never Orca.
- Never use Orca `computer-use`; it drives native GUI apps, which the macOS automation ban forbids.
- `design-mobile-apps` (Sleek) requires `SLEEK_API_KEY`; skip it while the key is unset.

<!-- antislop:start -->
## antislop
For UI, copy, people, mobile layout, or code comments work, read `~/.agents/skills/antislop/SKILL.md` (core) and then the skill for the task:
- UI / visual: `~/.agents/skills/antislop-ui/SKILL.md`
- Copy & text: `~/.agents/skills/antislop-copywriting/SKILL.md`
- People: `~/.agents/skills/antislop-human/SKILL.md`
- Mobile / responsive: `~/.agents/skills/antislop-layoutmobile/SKILL.md`
- Code comments: `~/.agents/skills/antislop-code/SKILL.md`
Before starting, follow the core's "Two Usage Modes" section in strict order: explicit session instruction first, then global preference, then ask. A session instruction always wins. For a resolved mode, say `antislop active: <mode> (session override).` or `antislop active: <mode> (global preference).` once before presenting findings or making edits, using the actual mode and source. Acknowledging the user's request without naming the source does not replace this notice.
Only an explicit choice of antislop during or after selects a session mode. A request to review, audit, or avoid file edits does not select a mode; read the global preference in that case. Another skill's mode does not select antislop's mode.
If the mode is unresolved, ask during/after and end the response; wait for the answer before any UI review, planning, or concept. For read-only tasks, put the active-mode notice only at the start of the final answer, never in progress messages. For editing tasks, announce before the first edit and omit it from the final answer.
To update antislop later, run `./meta/sync.sh --yes` from `.awesome-agent`; the skills are registered in `shared/remote-skills.txt`.
<!-- antislop:end -->

## Handoff Invocation

- Invoke `$handing-off-pro-max` before context compression, changing which agent handles a project, ending active work with documentation, or whenever the user asks for a handoff, continuation record, exact commands, everything in context, or no summary.
- Routine compaction does not require a full handoff. Use `$handing-off-pro-max` only for an actual agent handoff, explicit handoff request, or deliberate stop requiring continuation documentation; use `$un-dumb-yourself` for compaction state recovery.
