# Agent Log Pain Points: 2026-03-18 to 2026-06-18

## Scope

Parsed:

- Codex session JSONL: 195 files
- Claude main session JSONL: 15 files
- Claude memory/feedback notes: 84 files
- Codex memory/feedback notes: 6 files
- Normalized direct user/feedback messages after wrapper cleanup: 3,857
- Unique normalized texts: 2,966

Excluded from the primary read: Claude `subagents/*.jsonl`, because those are mostly agent-written task prompts to subagents, not the user's own words. The cleanup also dropped generated continuation summaries, interruption wrappers, embedded skill bodies, slash-command wrappers without user args, local command output wrappers, IDE context boilerplate, image tags, and environment/AGENTS boilerplate.

Important caveat: Codex resume/fan-out behavior creates exact duplicate user messages in some sessions, and some user messages paste large code blocks as the thing to inspect. Raw frequency is useful for signal strength, but the insight sections below are based on de-duplicated/high-signal reading and targeted cluster samples rather than blindly trusting exact repeat counts or top raw words.

The additional March 18-May 17 window contributed 1,371 cleaned messages and 1,294 unique texts. Its largest added clusters were Courta, Jobcan/interview record work, older ham-san.net, `llll`, career-ops, interviewAI record, the-sorter, and Holypeak.

## Three-Month Delta

The expanded range does not overturn the one-month conclusions. It strengthens them and adds older variants of the same operational failures.

### Older work shows the same "source of truth first" rule

March and April add many cases where the user pushes the agent back to the actual implementation, actual data, or actual browser state:

- 2026-03-23, `the-sorter`: CI must work with actual live data and existing generated output, not ignored local raw files.
- 2026-03-25, `llll`: "MAKE THE BROWSER FUCKING WORK FIRST" and use agent-browser instead of Playwright.
- 2026-04-06, `llll`: look at the actual data fetching script.
- 2026-04-17, `interviewAI-frontend-record`: test in browser, reproduce the error, test all flows.
- 2026-04-21, `wellbeing-frontend-record`: documented browser/camera behavior must be reused, and Chrome/Safari must be tested directly.

Added insight: this pattern predates the PKSHA-heavy month. It is not project-specific; the user consistently rejects proxy evidence when the real runtime/data path is available.

### Courta adds state-management and Figma-systematic pressure

The Courta cluster expands the UI/design story beyond "looks bad." The older messages and memories push for:

- dynamic values from state management, not hardcoded or disconnected UI
- complete loading/error states
- no mock imports leaking into production components
- exhaustive Figma comparison, including a saved memory of 625 exported frames and RMSE-style comparison
- agent-browser visual verification after worktree changes

Added insight: visual fidelity and production readiness are coupled. A UI that looks close but has mock data, missing states, or lost worktree changes still fails.

### Jobcan/interview work adds browser-matrix rigor

The Jobcan/interviewAI/wellbeing-record cluster adds repeated Safari/Chrome/device/video/audio constraints:

- test locally multiple times
- copy dashboard/dev URLs into local when needed
- test Chrome and Safari when browser-specific behavior is implicated
- compare recording/segmentation/video handling against the known-good implementation
- do not assume; read task details and existing docs

Added insight: "test the flow" often means a matrix: browser, device, camera/audio path, recording/upload, and Japanese business flow. A single successful local path is weak evidence.

### `llll` adds performance and pipeline realism

The `llll` cluster adds a different shape of pain:

- performance problems should be solved with the right architecture, such as virtualization for large tables
- asset/data pipelines must use the actual fetching scripts and stream/data sources
- browser proof still matters, but the user also expects logs/root-cause diagnosis before changing setup
- manual "next phase" deferral is rejected when the current problem can be investigated

Added insight: the user is not only asking for more effort. They want the correct technical level: performance needs structural fixes, data tools need real pipelines, and debugging needs root cause.

### This repo's own March setup work is a live example

The `.awesome-agent` cluster shows why the current request matters:

- skills should come from `skills.sh` when remote, not vendored locally
- generated local skill targets should remain repo-managed and symlinked
- agent setup should be unified across Claude/Gemini/agents
- "done done" includes conflict handling and push readiness

Added insight: the same agent-configuration principles in this repo are reflected in the log pain points: one source of truth, generated artifacts, no copied marketplace assets, and real verification before done.

## E2E Rules From Project Files

The user's "e2e tests" strictness is not just chat anger. It is encoded in the project control planes. The typed paths `~/shinkijigyoushitu` and `~/pksha` resolve in practice to `/Users/vittayapalotai.tanyawat/work/shinkijigyousitu` and `/Users/vittayapalotai.tanyawat/work/pksha-aitore`; the literal home-directory paths do not exist.

### Shinkijigyousitu: harness-first interview E2E

`/Users/vittayapalotai.tanyawat/work/shinkijigyousitu/CLAUDE.md` requires `.claude-rules/e2e-testing.md` at session start and makes screenshot evidence mandatory for PRs, Linear updates, task handoffs, QA requests, and UI work. Screenshots should be taken through `agent-browser --cdp 9222 screenshot`, resized, uploaded through `gh image`, and embedded as GitHub user attachments, not committed as repo files.

The hard interview rule is in `.claude-rules/e2e-testing.md` and `skills/e2e-interview-test/SKILL.md`: for interview/browser/audio work, read and use `/e2e-interview-test`; do not improvise Puppeteer, Playwright, raw CDP, or `/tmp/run_*.sh` harnesses. Browser control should go through `agent-browser`, usually with an isolated session and `--cdp 9222` when Chrome is externally launched.

The runtime proof definition is the full audio/browser chain, not unit tests: headed Chrome when recording is involved, OBS Virtual Camera where required, VOICEVOX, BlackHole, `--mute-audio`, upload/results checks, dashboard scores, `回答なし` count, screenshots, and video artifacts. The files explicitly warn against switching system audio devices, using FaceTime or MacBook mic by accident, killing the user's Chrome, and relying on iOS Simulator or Android emulator audio for the core interview E2E path. Desktop Chrome is documented as the only reliable fully automated E2E platform.

The daily tracker contract in `docs/morning-test-tracker.md` expects both platforms, per-topic rows, URL, pass/fail, score/per-axis, trends, incidents, and uploaded artifacts. One concrete rule conflict is also worth recording: `.claude-rules/e2e-testing.md` says no polling loops in one place, while another section and `.claude-rules/communication.md` allow bounded polling. That should be consolidated into one "bounded poll vs passive waiting" rule because agents will otherwise pick the convenient reading.

### PKSHA: evidence gates, not just expectations

`/Users/vittayapalotai.tanyawat/work/pksha-aitore/AGENTS.md` defines the loop as task, implementation, aggregate verification, browser dogfood, screenshots, PR evidence, then done. It also states that browser-reproducible behavior must be tested with `agent-browser`; source inspection, API scripts, and unit tests do not substitute for browser proof.

The dogfood contract in `docs/ai-workflow/dogfood-and-screenshots.md` covers happy path, empty state, validation, loading/error, permission/tenant, desktop/mobile, console, network, and AI-output quality where relevant. Dogfood reports belong in `dogfood/sessions/<task-id>/report.md`, screenshots in `pr/screenshots/<task-id>/`, and PR evidence in `pr/evidence/<task-id>/`. Uploaded PR media must use GitHub user-attachment links; videos go on standalone URL lines; local paths are secondary evidence only and must not be the reviewer-facing proof.

PKSHA also has executable checks. `scripts/verify-ui-coverage.mjs` enforces task/plan sections, links, expanded real-app screenshots, source-evidence alignment, task-plan pairing, backlog routing, manifest entries, and screenshot counts. `scripts/verify-pr-evidence.mjs` enforces done-task dogfood reports, evidence files, external-write records, screenshot files/links, explicit verification results, and clean reviewer-facing PR bodies with no internal approval metadata or local absolute paths. A passing unit suite is incomplete if these gates fail.

The practical insight is sharper than "test more": in both repos, e2e means use the canonical harness, preserve the device/browser/audio constraints, record real visual/media evidence, update the durable tracker/PR/task artifacts, and only then claim readiness.

## Second-Pass Insights

### The real rule is not "always test more"

The first pass could be misread as "the user always wants maximum verification." That is wrong. The corpus shows two distinct modes:

- **Surgical mode:** small obvious fixes should be made directly, without wasting time on lint/typecheck/build/browser unless risk justifies it.
- **Mission mode:** user-facing workflows, PRs, deploys, design matches, auth/audio/browser behavior, local setup, and data migrations require full end-to-end proof.

Evidence:

- 2026-05-18, Codex: "DON'T FUCKING RUN COMMANDS IF I ASK YOU TO DO A SMALL FUCKING FIX"
- 2026-05-18, Codex memory: "For small, surgical fixes, do not run command verification by default."
- 2026-05-19, Claude: "TEST THE UI TOO TEST EVERYTHING DOGFOOD DO EVERYTHING"
- 2026-06-18, Claude: "MUST HAVE 5 PERFECT CONSECUTIVE TESTS"

Deeper insight: the user is not anti-verification. They are anti-misaligned verification. Running a full build for a one-line text/layout fix wastes time; claiming a complex browser/audio/auth/UI flow is done after a unit test is worse.

### "Done" means artifact alignment, not code completion

Across the three-month corpus, "done?" is usually not asking whether code compiles. It means:

- the correct branch/repo is updated
- the PR body is updated
- evidence is embedded in the right place
- screenshots/video are real and current
- task/Linear/docs status is updated
- old wrong artifacts are removed
- live/dev/local state matches the claim
- no unrelated files/scratch assets were committed

Evidence:

- 2026-05-21, Claude: "are we clean and is dev clean and working perfectly connecting to real data real backend?"
- 2026-05-26, Claude: "WHY IS IT STILL NOT UPDATED ?????? THE FUCKING PR ???"
- 2026-05-26, Claude/Codex: "WHY DO YOU KEEP UPLOADING THIS PIC WIHOUT ATTACHING TO THE FUCKING PR ???"
- 2026-06-08, Codex: "VIDEO ... UPDATE THE FUCKING DESCRIPTION"
- 2026-06-09, Codex memory: screenshots/videos must be uploaded to GitHub user attachments, not local paths
- 2026-06-17, Claude: "WHY IS IT NOT IN THE PR ???? WHY IS THE PR STILL SLIDE SHOW ???"

Deeper insight: the user treats external coordination surfaces as part of the implementation. A code fix without PR/task/evidence hygiene is not complete.

### The strongest anger trigger is reintroducing a solved problem

The logs repeatedly escalate when an agent forgets that something had already been solved, undone, documented, or explicitly ruled out.

Evidence:

- 2026-05-26, Claude: "WE HAD A FUCKING WORKING SETUP"
- 2026-06-05, Codex: "READ THE OLD CODE/SETUP THROOUGHLY JESUS WE FIXED THIS"
- 2026-06-08, Claude: "did you just fucking undo my fixes????"
- 2026-06-08, Claude: "HOW DID THE FUCKING MERGE FUCK WITH WHAT I DID BEFORE MERGE BEFORE FUCKING MERGE IT WAS PERFECT"
- 2026-06-09, Codex: "OK IT WAS LITERALLY WORKING FLAWLESSLY IN THE FUCKING OLD UI"
- 2026-06-17, Claude: "DID YOU FUCKING READ YOUR DOCUMENTATION WE FUCKING COVERED THIS ALREADY"

Deeper insight: regression recovery should start with damage assessment, diff comparison, and restoring known-good behavior before inventing a new fix.

### The user expects agents to be tool-native, not tool-performative

The user repeatedly names tools and skills, but the intent is not "mention the tool." It is "use the right tool to prove the real state."

Evidence:

- 2026-05-19, Codex: "JUST USE FUCKING AGENT BROWSER MAKE IT WORK DAMMIT"
- 2026-05-26, Claude: "don't fucking automate shit, do it yourself SCRIPTS ARE NOT ALLOWED SEE FOR YOUR SELF"
- 2026-06-05, Codex: "JUST FUCKING PILOT THE FUCKING AGENT-BROWSER"
- 2026-06-05, Claude memory: "NEVER write puppeteer / playwright / nodejs scripts that automate end-to-end interview runs"
- 2026-06-17, Claude: "WHY ARE YOU NOT FUCKING USING SKILLS"
- 2026-06-17, Claude: "CAN YOU STOP HIJACKING AGENT-BROWSER SESSION"

Deeper insight: tools should shorten the path to real inspection. New scripts, fake self-tests, and abstract automation are treated as avoidance when the user wants hands-on browser/runtime proof.

### "Read" means reconstruct the real state before acting

The repeated "read" commands are rarely generic. They usually mean:

- read the current code, not docs alone
- read the old working implementation
- read the PR/task/Linear/Figma exactly
- read prior chat logs after compaction
- read every affected file, not a narrow subset
- read the current diff before blaming or fixing

Evidence:

- 2026-05-22, Codex: "NO??? READ INDIVIDUALLY AND DO ONE BY ONE"
- 2026-05-27, Codex: "why the fuck are you reading anything but source code????"
- 2026-05-27, Codex: "READ EVERY SINGLE PIECE OF CODE, YOUR OLD CONVERSATION, EVERY FUCKING THING"
- 2026-06-08, Codex: "stop hallucinating"
- 2026-06-09, Codex: "DON'T FUCKING NARROW DOWN DON'T SKIMP READ EVERY SINGLE FILE EVERY SINGLE CHANGE"
- 2026-06-17, Claude: "GO READ YOUR OLD INSTRUCTIONS ... EVERYTHING PRE COMPRESSION NO SKIMPING"

Deeper insight: for this user, reading is not passive prep. It is the main correctness mechanism.

### The user dislikes "agent cleverness" when there is a direct source of truth

The strongest corrections often follow unnecessary invention: new architecture when a previous setup exists, approximation when Figma exists, generic copy when real content exists, guessed language translation, or alternate state handling when old behavior already worked.

Evidence:

- 2026-05-25, Claude: "STOP FUCKING GUESSING"
- 2026-05-27, Codex: "if you can't do that ... look at the lib and work from there"
- 2026-06-05, Codex: "THINK ABOUT THE FUCKING CONTENT WHO FUCKING CARES HOW MANY COMPONENT GETS IMPLEMENTED"
- 2026-06-05, Codex: "do you fucking know thai????? it's fucking งานอดิเรก"
- 2026-06-08, Claude: "LOOK UP BROWSER BEHAVIOR LOOK UP EVERYTHING IF YOU KEEP NUDGING SHIT IT'S NOT GONNA WORK"
- 2026-06-16, Claude memory: "do not invent scope or reintroduce something the user deliberately removed"

Deeper insight: the user values grounded reconstruction over novel synthesis unless the task explicitly asks for ideation.

### The user wants accumulated memory, but only when it is correct and situated

There is a repeated demand for agents to remember protocols, but also anger when memory is vague, misplaced, or causes wrong-context action.

Evidence:

- 2026-05-27, Codex: "HOW MANY TIME DO WE HAVE TO TALKA BOUT THIS"
- 2026-05-27, Claude memory: "Product names != repo names"
- 2026-06-03, Codex: "GET THIS SHIT IN MEMORY NOT YOU SHITTY MEMORY PERSIST IT INTHE FUCKING PROJECT PROTOCL"
- 2026-06-08, Codex: "READ OLD LOG WE DONE THIS SHIT BEFORE"
- 2026-06-17, Claude memory: project-specific LLerNote and PKSHA protocols

Deeper insight: memory is useful only if it points to exact project-local protocol and current-state evidence. Generic memory can become another hallucination source.

### The user's repeated profanity compresses a small set of concrete instructions

After reading more of the corpus, the repeated language maps to stable operational meanings:

- "READ" = reconstruct current/old/source-of-truth state before acting.
- "TEST" = prove the actual user path, not a narrow technical proxy.
- "DONE?" = align code, PR, task/docs/evidence, and runtime state.
- "WRONG" = wrong artifact/context/scope, not necessarily wrong syntax.
- "DOGSHIT/CRINGE" = generic output, bad ergonomics, poor visual hierarchy, or content that misses the product's actual purpose.
- "NO MISTAKE" = do not rely on inference when a source of truth is available.
- "DON'T WAIT" = keep polling/checking/working; do not end a turn with passive status.
- "WHY" = provide root cause, not surface symptoms.

## Third-Pass Project Clusters

### PKSHA is mostly process trust, not just implementation

The PKSHA cluster is heavy on task routing, PR body accuracy, local setup, external write safety, and evidence handling. The recurring failure is not only bad code; it is breaking the reviewer-facing contract around branches, PR titles, task names, screenshots, videos, and docs.

Evidence themes:

- Linear/Figma/external MCP access is allowed only under explicit write protocol.
- Local setup must be actually usable with seeded data, not just a smoke test.
- PR titles/descriptions must match current scope, not stale Cognito or previous-task wording.
- Screenshots/videos belong in GitHub-hosted PR evidence, not as local paths or repo trash.
- AWS should not be touched directly unless the exact AWS action is requested.

Inferred rule: for PKSHA, always identify the artifact of record first: task file, PR body, branch, product worktree, evidence file, and current checks. Code completion without those surfaces aligned is incomplete.

### Shinkijigyousitu is where runtime proof matters most

The shinkijigyousitu/wellbeing/happiness cluster is dominated by browser behavior, E2E interview flows, Figma fidelity, ports, deploy restraint, and audio/video harness details. This is where unit tests are most likely to be rejected as insufficient.

Evidence themes:

- Canonical ports matter because auth/CORS/Firebase/dev URLs are keyed to origins.
- Docs/specs belong outside the frontend/backend repo unless explicitly requested.
- OBS/BlackHole/mute/headless setup is part of the test environment, not optional trivia.
- Browser verification should be hands-on through the existing harness, not newly written Puppeteer/Playwright scripts.
- Old UI behavior is a source of truth when a redesign is supposed to be cosmetic.

Inferred rule: when working here, preserve known-good runtime behavior first, then iterate visuals. If behavior regresses, compare against the old UI/setup before inventing a new path.

### LLerNote shows the "new app" standard

The LLerNote cluster is aggressive because the request is not "make a prototype." It is "build a useful personal product fast, using the real neighboring data sources, with serious UI density and working flows."

Evidence themes:

- `../the-sorter` is a source of truth, not inspiration.
- Real labels, real event data, and real MyPick behavior matter more than generic dashboard components.
- Every new requirement must be written into TODO immediately.
- The user expects repeated dogfood passes across every page/button/view, not a narrow happy path.
- Handoff/design docs are acceptable when they preserve all requirements and project philosophy.

Inferred rule: for new personal apps, do not ship "nice shell, thin semantics." Build the actual workflow, keep TODO current, and treat nearby repos as data contracts.

### Vibe-code-creations exposes domain-semantics failures

The BLD/cubing sessions look repetitive because a single failing pattern repeats: the agent builds UI around the task but misses the domain interaction itself.

Evidence themes:

- Dynamic preview must reflect the current buffer/cycle/sticker state, not just display a static cube.
- Domain libraries like `cubing.js` should be used directly when they encode the needed behavior.
- Test cases must cover alternate cycle order, multiple cycles, arbitrary stickers, and edge/corner buffers.
- "Self-test" code is rejected when the user expects the agent to actually drive the UI and inspect it.

Inferred rule: for domain tools, verify the domain model and interaction loop before polishing the interface.

### Ham-san.net is content and stack conformity

The ham-san.net cluster is not simply "make it prettier." The complaints target stack drift and content quality.

Evidence themes:

- Park UI/Panda conventions matter; plain CSS rewrites are suspect.
- Custom components are supposed to embed inside markdown content, not replace the main content model.
- The content has to carry the page; component count does not matter if the writing/media are weak.
- Big dependency upgrades require migration awareness.

Inferred rule: respect the existing design stack and content architecture before adding visual features.

### Mobile/local apps require real-device and state proof

The oshi-diary and puremon-tracker clusters center on practical user friction: bad modals, broken persistence, invisible errors, aspect-ratio jank, device/simulator behavior, and confusing local-vs-auth state.

Evidence themes:

- Test real devices/simulators when the bug is mobile layout or platform behavior.
- Error state must be visible in-app; alerts and silent failures are rejected.
- Authenticated state should persist across browser sessions; local-only state is suspect.
- Avoid broad deletions when the user still wants scanner/crop/document functionality.

Inferred rule: for mobile-ish tools, prove persistence, error visibility, and real-device layout before calling it done.

## Hard Operating Contract

What the three months of messages reduce to:

1. Identify the source of truth before editing: current code, old working code, PR/task, Figma, browser, local cache, or neighboring repo.
2. Classify the task mode. Surgical fixes get scoped edits and minimal verification. Mission-mode work gets full user-flow proof.
3. Preserve known-good behavior. If a regression appears after merge/rebase/redesign, diff against the old working state first.
4. Use the right tool directly. Browser work means real browser/harness inspection; design work means side-by-side screenshots; PR work means current GitHub state.
5. Keep durable artifacts current: TODO, task file, evidence, PR body, docs, and memory/protocol where requested.
6. Stop inventing adjacent scope. Reviewer comments, stale memory, or "helpful" ideas are not authorization.
7. Before saying done, check the visible surfaces the user will check next: UI, PR, branch, screenshots/video, deploy/local URL, task status, and dirty files.

## Main Pain Points

### 1. Agents claim completion without real proof

This is one of the strongest qualitative pain points. The user keeps asking whether the agent actually tested, looked, compared, verified, or proved the claim. The failure mode is not just missing tests; it is claiming done from weak evidence.

Representative messages:

- 2026-04-17, Claude, `interviewAI-frontend-record`: "test in the browser, reproduce the error"
- 2026-04-20, Claude, `jobcan-interview-frontend`: "test locally 5x lah"
- 2026-05-18, Claude, `wellbeing-frontend`: "did you every fucking test ???"
- 2026-05-18, Claude, `wellbeing-frontend`: "did you test every tab??? there are 3 tabs dammit ??"
- 2026-05-25, Claude memory: "Always verify pixel-by-pixel BEFORE pushing UI changes"
- 2026-05-28, Claude memory: "NEVER claim 'ready to merge' / 'fix verified' without e2e on affected pages."
- 2026-06-04, Codex, `pksha-aitore`: "iterate refine, production quality, map and test all possible edge case, video evidence"
- 2026-06-18, Claude/Codex logs: "MUST HAVE 5 PERFECT CONSECUTIVE TESTS"

Underlying need: completion should be evidence-backed, user-flow-backed, and artifact-backed. Unit/build checks are not enough when the claim is about UI, auth, audio, local setup, deploy state, or PR readiness.

### 2. Agents do not look at the actual thing

You repeatedly object when agents reason from memory, summaries, code intuition, or generic assumptions instead of inspecting the real artifact: the screenshot, Figma, PR, browser, current branch, current logs, current data, current diff, or old session.

Representative messages:

- 2026-03-25, Codex, `llll`: "MAKE THE BROWSER FUCKING WORK FIRST ... KEEP THE ORIGINAL SETUP"
- 2026-04-21, Claude, `jobcan-interview-frontend`: "CAN YOU NOT FUCKING ASSUME SHIT??? READ THE DETAILS JESUS"
- 2026-05-18, Claude, `wellbeing-frontend`: "did you look at this shit??? it fucking said last interview 4/17 but there is fucking may 8??"
- 2026-05-22, Codex, `pksha-aitore`: "WHY ARE YOU NOT USING REAL SCREENSHOT INSIDE THE APP???"
- 2026-05-25, Claude, `happiness-frontend-record`: "STOP FUCKING GUESSING"
- 2026-05-25, Claude, `happiness-frontend-record`: "LOOK AT THE DAMN SCREENSHOTS COMPARE THEM SIDE BY SIDE, PIXEL BY PIXEL"
- 2026-06-05, Codex, `shinkijigyousitu`: "READ THE OLD CODE/SETUP THROOUGHLY JESUS WE FIXED THIS"
- 2026-06-10, Codex, `pksha-aitore`: "FUCKING READ EVERY SINGLE FILE EVERY SINGLE LITTLE FEATURE JESUS"

Underlying need: agents should use current-state evidence first, especially when there is a reference implementation or prior working version.

### 3. Agents invent or expand scope

You react strongly when agents do something adjacent but unasked: deploy, push, create docs in PR, touch CI, create routes, automate scripts, change logic for a cosmetic request, reopen optional reviewer suggestions, create nested projects, or solve a different task.

Representative messages:

- 2026-05-18, Codex, `pksha-aitore`: "never assume write permission just because it's mentioned once somewhere, ask EVERY move"
- 2026-05-19, Claude memory: "Never push/deploy to dev unsolicited"
- 2026-05-21, Claude, `wellbeing-frontend`: "WHY ARE DOCS IN THE DAMN PR ???"
- 2026-05-26, Codex, `shinkijigyousitu`: "bro???? don't touch the ci until shit is perfect"
- 2026-05-29, Codex, `shinkijigyousitu`: "why the fuck is that part of the logic touched ????? this doesn't make fucking sense you shoudl just fucking use the value IT'S JSUT A FUCKING COSMETIC FUCKING CHANGE"
- 2026-06-16, Claude memory: "do not invent scope or reintroduce something the user deliberately removed"

Underlying need: scope must be treated as a contract. Optional, adjacent, and "helpful" work is harmful unless it directly advances the requested final state.

### 4. Agents work in the wrong context

Wrong repo, wrong project, wrong branch, wrong team, wrong port, wrong browser session, wrong deploy target, and wrong product/repo mapping all appear repeatedly.

Representative messages:

- 2026-05-20, Claude memory: "Local dev server must use the canonical project port"
- 2026-05-25, Claude, `happiness-frontend-record`: "WHAT THE FUCK??? THIS HAS NOTHING TO DO WITH PKSHA WHERE DID YOU GET THAT FROM???"
- 2026-05-27, Claude memory: "Product names != repo names. Always verify before triggering deploys."
- 2026-06-01, Codex, `shinkijigyousitu`: "WRONG FUCKING PROJECT CLEAN UP WHAT YOU JUST DID"
- 2026-06-03, Codex, `pksha-aitore`: "WHY CAN'T THE MAIN VS CODE NOT BEIN THAT FUCKING BRANCH???"
- 2026-06-15, Claude memory: "New projects must be standalone siblings in ~/code, never nested inside another repo"

Underlying need: before acting, agents must prove they are in the right workspace, branch, project, URL, team, and runtime.

### 5. UI output is judged by lived experience, not implementation count

For frontend tasks, the strongest dissatisfaction comes when the UI is generic, cramped, clipped, janky, visually off, or technically complete but not actually good.

Representative messages:

- 2026-03-25, Codex, `llll`: "rendering performance is absolute dogshit. Use virtualization for table"
- 2026-04-16, Claude memory, `courta`: "625 Figma frames exported and cataloged"
- 2026-05-18, Codex, `courta`: "ok this shit jank as fuck do something about it, how does it even work now ?"
- 2026-05-22, Claude, `wellbeing-frontend`: "THE UI IS SOMEHWAT DOGSHIT, HAVING TO SCROLL SUCKS, DO BETTER, TEST IT FFS, MAKE SHIT FIT IN A VIEW"
- 2026-05-25, Codex, `courta`: "LAYOUT ALL FUCKED UP, FIX IT JUESUS, DON'T GUESS PIXELS"
- 2026-06-05, Codex, `ham-san.net`: "THINK ABOUT THE FUCKING CONTENT WHO FUCKING CARES HOW MANY COMPONENT GETS IMPLEMENTED"
- 2026-06-11, Claude memory, `LLerNote`: rejects "first-pass generic UI" and wants dense, real-label, polished interaction
- 2026-06-16, Codex, `puremon-tracker`: "SHIT SHOULD PERSIST, ACROSS BROWSER FUCKING SESSION"

Underlying need: frontend success means visual polish, ergonomics, responsiveness, real content, durable state, and correct interaction behavior, not just completed components.

### 6. Agents keep failing at durable project hygiene

You repeatedly ask for work to be written to the right durable place: task files, notes, evidence, PR body, docs outside repo, memory, or tracker. You dislike chat-only state and scratch files polluting repos.

Representative messages:

- 2026-04-22, Claude, `shinkijigyousitu`: "CREATE A JOURNOAL OR SOME SHIT IN /SHINKIJIGYOUSHITU, ORGANIZE YOUR OWN DOCS/JOURNAL"
- 2026-05-18, Codex, `pksha-aitore`: "always document ALL decisions/ progress and shit"
- 2026-05-20, Claude, `wellbeing-frontend`: "write everything down document it in /shinkijigyoushitu or someshit not in the code"
- 2026-05-21, Claude memory: "Project docs live OUTSIDE the code repo"
- 2026-05-27, Codex memory: "no project-folder scratch files"
- 2026-06-10, Codex memory: "write or update the relevant notes/evidence/task/PR-body files as part of the work"
- 2026-06-15, Claude memory: "For PR screenshots/proof: upload with the gh image extension ... NEVER commit a docs/pr-proof folder"

Underlying need: the artifact of record matters. Chat summaries are not enough, and repo pollution is a failure.

### 7. You want autonomy, but not unauthorized mutation

This is a tension agents keep mishandling. You say "continue," "do it," "iterate," "don't wait," "finish," and "start working," but also forbid unauthorized deploys, pushes, AWS calls, destructive operations, or unrelated edits.

Representative messages:

- 2026-05-18, Codex, `pksha-aitore`: "LEAVE IT THERE FOR NOW just check if it connects"
- 2026-05-18, Codex, `pksha-aitore`: "anything involving external MCP calls" needs write protocol
- 2026-06-01, Claude memory: "Don't write 'waiting for X' ... Poll/check/monitor and report"
- 2026-06-10, Codex memory: "When the user gives a command, execute it after checking the relevant files/context"
- 2026-06-11, Codex memory: "do not interact with AWS directly unless the user explicitly asks for that exact AWS call"
- Frequent short commands: "continue", "go", "push", "commit push", "done ??", "are we done?"

Underlying need: agents should self-drive reversible/local/read-only work, but pause before external mutation, destructive operations, deploys, pushes, AWS, or changing scope.

### 8. Agent communication itself is a pain point

You dislike process narration, weak status language, vague acknowledgements, excessive explanation, and telling you instead of doing the requested change.

Representative messages:

- 2026-06-01, Claude memory: "Don't write 'waiting for X' / 'Will report when done'"
- 2026-06-05, Claude, `happiness-frontend-record`: "WHY ARE THESE FUCKING USELESS INFO IN THE FUCKING PR MESSAGE ???"
- 2026-06-05, Claude, `happiness-frontend-record`: "I FUCKING TOLD YOU TO UPDATE THE PR WHY ARE YOU TELLING ME THIS FUCKING INFO ???"
- 2026-06-10, Codex memory: "Do not reply with only acknowledgement, restatement, or process narration."
- 2026-06-18 AGENTS instructions: "NO FLUFF", "DIRECTNESS", "REALITY CHECK"

Underlying need: communicate only the state, evidence, and next action. Prefer action over explanation unless asked for a plan.

## What You Keep Saying

Most repeated cleaned themes across unique texts:

- PR/current artifact alignment: 539 unique texts mention PR.
- Testing/verification: 379 unique texts mention test.
- Reading/current-state reconstruction: 243 unique texts mention read.
- UI/UX/runtime surface: 228 unique texts mention UI.
- Environment/context: 123 unique texts mention port; 50 mention branch; 21 mention AWS.
- Done/readiness checks: 103 unique texts mention done.
- Task/status routing: 84 unique texts mention task.
- Browser/runtime proof: 104 unique texts mention browser; 45 mention agent-browser.
- Screenshot/video evidence: 67 unique texts mention screenshot; 57 mention video.
- Scope restraint: 74 unique texts mention deploy; 25 mention docs; 78 mention push.
- Source-of-truth wording: 49 unique texts mention actual; 71 mention real; 42 mention verify; 20 mention evidence.

The strongest exact repeats are less useful after inspection because several come from Codex resume/fan-out duplication. The meaningful repeated commands are not one slogan; they are a loop:

1. Read the actual source/context.
2. Do the work.
3. Test the real user flow.
4. Update the PR/task/evidence.
5. Check whether it is actually done.

When that loop breaks, the same words recur: read, test, actual, real, screenshot, video, PR, done, wrong, stop, why.

## Behavioral Pattern

The pattern is not random anger. It is escalation after the same classes of agent failure:

1. The agent starts from assumptions instead of the current artifact.
2. It makes a plausible fix or explanation.
3. It does not test the actual user path deeply enough.
4. It claims readiness or updates an external artifact.
5. The user checks the real UI/PR/runtime and finds an obvious miss.
6. The user then tightens protocol: no deploy, no scripts, no scratch files, no wrong repo, no chat-only state, no generic UI, no weak evidence.

The repeated "fuck/shit/ffs" phrasing is usually attached to one of three concrete failures:

- The agent did not inspect what was already provided.
- The agent changed the wrong thing or worked in the wrong place.
- The agent claimed completion before a real end-to-end check.

## Practical Operating Model Inferred

For future agents, the effective model is:

1. First identify the true artifact of record: PR, task file, Figma, screenshot, repo, branch, browser URL, old session, memory note, or local cache.
2. Confirm context before writing: repo, branch, cwd, default port, product/repo mapping, and whether mutation is allowed.
3. For UI/runtime/auth/audio/data work, use live browser evidence and screenshots/video where applicable.
4. For small surgical fixes, edit first and skip expensive verification unless risk justifies it.
5. For larger or user-facing work, run aggregate verification at the end and explicitly tie evidence to the claim.
6. Update the durable artifact, not just chat.
7. Never treat optional reviewer comments, old context, or agent intuition as authorization to expand scope.
8. If the user says "continue" or sets a goal, keep moving until the goal is actually satisfied; don't pause with status-only language.

## Bottom Line

Your core pain point is not "agents make mistakes." It is that agents repeatedly act like plausible completion is equivalent to verified completion.

Your desired agent behavior is: inspect the real current state, do the actual work, verify the real user path, preserve proof in the right artifact, and avoid any mutation outside the exact scope.
