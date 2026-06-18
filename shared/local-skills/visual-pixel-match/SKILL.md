---
name: visual-pixel-match
description: Capture, compare, and publish design-to-implementation screenshots for pixel-perfect UI work. Use when asked to match Figma/design screenshots, produce source/current/diff evidence, compute RMSE or normalized visual diffs, generate side-by-side comparison images, tune UI screenshots toward pixel-perfect output, or update PR screenshots with GitHub-hosted images.
---

# Visual Pixel Match

## Workflow

1. Keep all screenshot helpers, exports, diffs, and reports outside the project folder unless the user explicitly asks otherwise.
2. Create an artifact folder shaped like `pr-<number>-screenshots/{source,current,diff,comparison}`.
3. Export or capture source design frames into `source/` with stable IDs, for example `question_mobile_q1.png`.
4. Capture current app screenshots into `current/` with `agent-browser`, one state ID at a time, using the exact same viewport dimensions.
5. After each screenshot, rename it to the stable state ID before capturing the next one.
6. Run `scripts/compare_screenshots.py --source-dir <source> --current-dir <current> --out-dir <artifact-root>` to generate `metrics.tsv`, `diff/*.png`, and `comparison/*.png`.
7. Inspect the highest normalized diffs and the side-by-side composites before editing UI.
8. Iterate in this order: source map, one current capture, RMSE/diff, visual inspection, code change, recapture the same ID.
9. Upload final source/current/comparison images with `gh image --repo <owner>/<repo> <paths...>`.
10. Update the PR with the GitHub-hosted table and include the exact head SHA, workflow links, and any remaining real checks.
11. Before finalizing, remove screenshot-only preview routes, scratch components, scratch assets, and project-local docs.

## RMSE Rules

- Use identical IDs for source and current screenshots.
- Prefer `magick compare -metric RMSE` for metrics so reruns match existing ImageMagick PR evidence.
- If ImageMagick is unavailable, fall back to white-flattened RGB comparison padded to the max dimensions of each pair.
- Treat RMSE as a ranking signal, not the verdict. A lower number can still hide wrong state, wrong text, missing animation, clipping, or broken interaction.

## Capture Rules

- Use `agent-browser` as the default screenshot capture tool.
- Capture one screenshot/state per `agent-browser` cycle; do not hide a broken state machine behind one huge batch.
- Match the design frame dimensions exactly for each state.
- Capture every user-visible state in scope: desktop, mobile, active/inactive controls, modals, question steps, completion, and results.
- Stabilize test data, API responses, language, permissions, and viewport before capturing.
- Do not upload error states or stale screenshots as final evidence.
- If a visible UI change lands after screenshots are uploaded, regenerate the affected current/comparison set or explicitly mark the evidence stale.
- Use Playwright/custom capture scripts only as a fallback when `agent-browser` cannot reach or stabilize the required state, and keep those helpers outside the project folder.

## PR Rules

- Use GitHub-hosted images from `gh image`; do not create gists.
- Put source, current, and comparison columns in the PR body.
- Do not commit screenshots or screenshot docs in the project source tree.
- Include deploy-dev and build workflow links when the user asks for dev deployment evidence.

## Detailed Reference

Read `references/methodology.md` when the task involves reconstructing a prior pixel-perfect workflow, handling transparent GIF holes, tuning fixed artwork/backgrounds, or cleaning up screenshot infrastructure before merge.
