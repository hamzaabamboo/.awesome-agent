---
name: look-at-the-screen
description: Inspect the actual visible artifact before interpreting, diagnosing, editing, testing, or claiming visual correctness. Use whenever the user supplies or references a screenshot, image, screen recording, browser page, app screen, rendered document, design, mockup, canvas, terminal capture, or other visual state; asks the agent to look, see, inspect, compare, verify, show, or match what is on screen; says the visible result contradicts code, logs, tests, or prior reasoning; or expresses frustration that the agent is reasoning without directly examining the displayed artifact.
---

# Look At The Screen

Inspect the pixels first. Treat the visible artifact as primary evidence for claims about visible state.

## Execute Immediately

1. Identify every visual artifact named, supplied, attached, generated, or currently rendered for the task.
2. Open each artifact with the appropriate image, video, document-rendering, or headed-browser inspection tool.
3. Inspect the complete visible state at sufficient resolution. Zoom, paginate, scrub, or capture additional states when the relevant detail is not legible or not present in one frame.
4. State the concrete visual observations that affect the task.
5. Reconcile those observations against code, DOM, logs, tests, requirements, or prior assumptions.
6. Continue the requested diagnosis or change from the observed state.
7. Inspect the resulting visual artifact again before reporting success.

Do not continue from filenames, alt text, attachment metadata, OCR alone, source code, DOM structure, test output, console output, or another agent's description when direct visual inspection is possible.

## Evidence Rules

- Examine every supplied visual asset, not a representative sample.
- Inspect the full frame before focusing on a detail. Account for clipping, overlays, loading states, viewport size, scaling, theme, and surrounding context.
- Distinguish observation from inference. Report only visible facts as observed.
- If text or detail is unreadable, obtain a higher-resolution view or say exactly what remains unreadable.
- If the artifact is stale or does not show the relevant state, capture or request the exact missing state. Never treat absence of visual evidence as a pass.
- If runtime behavior is implicated, reproduce it in the real headed surface and inspect each material state directly.
- For comparisons, inspect source and current render at matching viewport, scale, state, and content before evaluating differences.
- For video, inspect the complete relevant sequence, including the triggering action and final result.

## Correct Contradictions

When the screen conflicts with code, logs, tests, or prior reasoning:

1. Treat the contradiction as evidence that the current explanation or verification is incomplete.
2. Identify the exact visible mismatch.
3. Trace the rendered data, selected state, layout, or runtime path responsible for that mismatch.
4. Fix the root cause within the user's scope.
5. Re-render and inspect the same state again.

Never argue that the screen should be correct because the implementation or tests appear correct.

## Privacy Boundary

- Use conversation history only as transient context when explicitly required.
- Do not copy user messages, transcripts, session identifiers, screenshots, or private history into a skill, repository, note, fixture, or evidence artifact unless the user explicitly requests that exact persistence.
- Generalize learned behavior into procedural instructions without quotes or identifying details.

## Completion Gate

Before making any visual claim:

1. Reopen the exact artifact or live state the user will inspect.
2. Look at it directly.
3. Verify every requested visible state at matching scope.
4. Report the observed result and any state that remains uninspected.

No direct inspection means no visual completion claim.
