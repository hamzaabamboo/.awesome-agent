---
name: real-testing-evidence
description: Use when work touches real user workflows, browser/auth/audio/data behavior, PR readiness, screenshot/video evidence, dogfood, or subagent orchestration across independent slices.
---

# Real Testing And Evidence

Use this when the task is bigger than a surgical edit or when the user asks for real testing, dogfood, evidence, PR readiness, video/screenshots, or orchestration. The goal is to prevent plausible completion from being mistaken for verified completion.

## Durable Artifacts

- Store project-specific learnings in that project's AGENTS.md, CLAUDE.md, docs, task files, or other repo-owned artifacts.
- Store cross-agent operating rules in `.awesome-agent`.
- Do not rely on hidden assistant memory as the source of truth.

## Real Testing

- Classify the task before verifying. Surgical fixes get small edits and minimal checks; real-testing work gets full user-flow proof.
- Browser-observable behavior requires real browser or canonical harness proof.
- Unit tests, typechecks, source inspection, API scripts, logs, and screenshots are supporting evidence only when the claim is about UI/auth/audio/upload/recording/runtime behavior.
- Use the repo's canonical harness first. Do not invent Puppeteer, Playwright, raw CDP, shell chains, or temporary scripts when the project already has an e2e skill, dogfood workflow, browser session, or test harness.
- Repo-specific evidence paths, harness docs, dogfood scripts, and PR verifier scripts override the generic matrix.
- Build the verification matrix from the affected behavior: happy path plus relevant empty, validation, loading/error, permission/tenant, desktop/mobile, console/network, AI-output/domain-quality, and persistence checks.
- For audio/video/browser work, preserve the documented device/session constraints before testing. Include the implicated browser, device, camera/mic/audio, recording, upload, and business-flow paths. Do not switch system audio, hijack a user's browser profile, kill unrelated browser processes, or collapse a browser/device matrix into one convenient path.
- If the user or project specifies a pass count, repeat count, or stability threshold, satisfy it exactly and report the consecutive pass count.
- For real-testing completion, record what was tested, where it was tested, what user path was exercised, and what remains unverified.

## PR And Video Evidence

- PR/video evidence is part of the implementation.
- Before saying PR work is ready, inspect the current PR/task/evidence artifact, not just the code diff.
- Screenshots and videos must be current, from the relevant branch/head when applicable, and placed where the reviewer will see them.
- For reviewer-facing PR evidence, upload screenshots/videos to GitHub user attachments or the repo-required media host and embed/link those URLs in the PR/task evidence.
- Local paths, committed proof folders, and loose repo screenshots are not reviewer-facing proof; keep local paths only as secondary internal references.
- Videos go on standalone URL lines.
- Keep internal approval, external-mutation audit notes, command diaries, and raw chat process out of reviewer-facing PR bodies unless explicitly requested.
- If visible UI changes after media is captured, regenerate the affected evidence or mark it stale.

## Subagents

- Use subagents for independent research, implementation, and verification slices.
- Dispatch only when the slices are truly independent or when verification can run in parallel with implementation.
- Before dispatching subagents, identify the source-of-truth artifact for the slice and include it in the prompt.
- Give each subagent a narrow task, explicit read/write scope, constraints, expected output, and the evidence it must return.
- Subagent returns must cite the files, line numbers, commands, screenshots, browser states, or external artifacts they inspected. Unsupported summaries are not evidence.
- Do not let subagents redefine the goal. Integrate their output against the user's requested end state.
- Verify subagent results yourself before relying on them. Agent summaries are not completion evidence.
- Close subagents when their output has been integrated.

## No Passive Waiting

- Do not stop at passive waiting.
- Do not use sleep loops as a substitute for work, reading, or state inspection.
- If a check, deploy, test, browser run, upload, or review is in progress, query the authoritative state with a bounded target and max attempt/time budget.
- Read the result after each check and choose the next concrete action.
- Run commands one by one unless the user explicitly asks for batching or the command is an established single project script.
- Do not write "waiting for X" and end the turn when the state can be queried.
- If the user interrupts a wait or poll, stop polling immediately, stop any background poller you started, and report the latest authoritative state.
- Only stop when blocked by required user input or an external state you cannot query.

## Completion Gate

Before saying done:

1. Re-read the user request and active task artifact.
2. Check the actual files, branch, PR/task/evidence surfaces, and runtime state relevant to the claim.
3. Run the aggregate verification appropriate to the task mode.
4. Run repo evidence, dogfood, screenshot, PR-body, task-plan, or UI-coverage verifier scripts when they exist.
5. Confirm screenshots/video/dogfood evidence is attached or explicitly not required.
6. Report any unverified surface directly instead of implying completion.
