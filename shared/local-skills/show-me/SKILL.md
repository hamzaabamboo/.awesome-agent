---
name: show-me
description: Make active work continuously visible and course-correctable through headed browsers, live hot-reload views, VS Code-visible files, screenshots, videos, rendered mockups, or directly inspectable artifacts. Use when the user invokes `$show-me`, says “show me,” “I want to see,” “open it,” “headed,” “live view,” “hot reload,” “what are you doing,” “where are you at,” asks to watch every step, or objects that work/testing/thinking is hidden, silent, happening in a void, or not tangible.
---

# Show Me

Turn the current task into a continuously inspectable working session. Do not substitute narration, commands, logs, tests, or a final summary for a visible artifact.

## Activation

- Start immediately when triggered.
- Keep active for the rest of the current task or until the user says to stop, hide, or return to normal.
- Preserve the task scope. Visibility mode does not authorize unrelated edits, deployment, pushing, comments, device changes, or external writes.
- State the current understanding and next visible action before taking it.

## Visibility Loop

For every material step:

1. Name the concrete action and the artifact or surface the user can inspect.
2. Expose the current state before or while changing it.
3. Perform the work on that visible surface when possible.
4. Inspect the rendered or resulting state yourself.
5. Report what visibly changed, what the result proves, and the next visible action.
6. Pause only when course correction is required; otherwise continue.

A material step changes direction, behavior, layout, data, runtime state, verification state, or the artifact the user will inspect next. Do not spam microscopic edits or raw chain-of-thought. Expose the working model, decisions, actions, and evidence needed to correct the course.

## Surface Selection

Use the most direct surface for the claim:

1. Existing live app or canonical runtime for user-visible behavior.
2. Headed browser with hot reload for web implementation and testing.
3. VS Code-visible source or artifact for code, prose, configuration, and structured data.
4. Screenshot or video for a specific visual state or complete interaction flow.
5. Rendered HTML mockup when the task is conceptual and no real UI exists yet.
6. Directly inspectable local artifact with a clickable absolute path when no live surface exists.

Prefer the real target over a mockup. A mockup demonstrates understanding, not completed behavior.

## Headed Testing

- Run browser testing headed while this skill is active.
- Reuse the project’s canonical browser session and harness.
- Keep hot reload or the nearest live feedback path visible during UI changes.
- Show the full causal path: initial state, user action, result, and persistence when relevant.
- Show every requested state, variant, viewport, and error case. Do not use one screenshot as proof of exhaustive coverage.
- Look at every screenshot, video, and rendered state yourself. Tiny, clipped, stale, irrelevant, blank, crashed, or result-less evidence fails.
- Treat scripts, source inspection, console output, and automated tests as supporting evidence only.
- If no headed equivalent exists, surface the live output and resulting artifact, and state the limitation.

During browser testing, never click or navigate `mailto:`, `tel:`, or non-HTTP(S) links. Read the composed target only. Launch agent-browser or Chromium with `AGENT_BROWSER_ARGS="--use-mock-keychain,--password-store=basic,--mute-audio"`.

## Opening Surfaces

- Use `open` only when the user explicitly authorizes it in the current turn.
- Never use `osascript`, AppleScript, Automator, Finder automation, Terminal automation, or other macOS GUI/system automation.
- When opening is not authorized, surface the exact clickable artifact path and keep working.
- Name exactly what was opened and where. “Shown” without a discoverable target fails.

## Progress Visibility

- Provide the first tangible state before substantial implementation.
- Update on every material state transition, failure, corrected direction, and final artifact.
- For long operations, expose authoritative progress, remain attached, and show failure plus corrective action immediately.
- Use event-driven updates. Do not emit arbitrary minute-by-minute chatter, stale “running” claims, spinners without progress detail, or command diaries.
- Every checkpoint must contain: current visible artifact, observed state, material change, remaining work, and next visible action.

## Completion Gate

Before claiming completion:

1. Re-read the active request and visibility requirements.
2. Show the exact final artifact on its real surface.
3. Inspect it yourself.
4. Verify every requested state and flow at matching scope.
5. Identify anything still unverified without implying it passed.
6. Leave the user with the live surface or exact clickable artifact path.

Visible does not mean verified. Verified but hidden does not satisfy this skill. Completion requires both.

## Failure Conditions

- Working silently until the final response.
- Reporting commands, counts, tests, code, or plans without an inspectable artifact.
- Using headless browser testing when a headed path exists.
- Showing a mockup after claiming the real implementation is complete.
- Capturing a flow without its final result.
- Showing stale, partial, irrelevant, or uninspected evidence.
- Saying “open,” “shown,” “live,” or “done” without the exact target.
- Hiding a failure or continuing on the wrong course after the visible state contradicts the plan.
