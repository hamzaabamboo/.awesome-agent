# Pixel Match Methodology

## Artifact Layout

Use an external artifact folder:

```text
pr-281-screenshots/
  source/
  current/
  diff/
  comparison/
  metrics.tsv
```

This keeps project source clean. If a helper must exist, keep it outside the app folder and make it disposable. Do not commit preview routes, scratch pages, screenshots, generated reports, or test-only assets.

## Source Capture

Source screenshots are the design baseline. Use stable IDs that name both screen and state:

- `settings_desktop_active`
- `settings_mobile_modal`
- `question_desktop_q1`
- `question_mobile_last`
- `confirm_mobile`
- `complete_desktop`
- `results_mobile`

Record the exact viewport dimensions beside the capture script or issue notes. The PR 281 pass used source/current/diff/comparison tables for desktop and mobile states, then sorted work by normalized RMSE plus visual inspection.

## Current Capture

Capture current screenshots with `agent-browser` unless there is a hard blocker. Capture one screen/state at a time, verify the output, rename it to the stable ID, then move to the next state. Do not run a full matrix blindly.

Use `batch` only inside one state capture:

```bash
agent-browser batch \
  "open https://dev.example.com/path" \
  "set viewport 1280 862" \
  "wait 1200" \
  "screenshot --screenshot-dir /path/to/pr-281-screenshots/current"
mv <agent-browser-returned-screenshot-path> \
  /path/to/pr-281-screenshots/current/complete_desktop.png
```

For interactive states, first snapshot once, then batch the actions:

```bash
agent-browser batch "open https://dev.example.com/path" "set viewport 402 812" "snapshot -i"
agent-browser batch "click @e4" "wait 1200" "screenshot --screenshot-dir /path/to/pr-281-screenshots/current"
mv <agent-browser-returned-screenshot-path> \
  /path/to/pr-281-screenshots/current/question_mobile_q1.png
```

If the app requires the user's existing login/session, use `agent-browser --profile`, `--session-name`, or `--auto-connect` instead of rebuilding auth in a project helper.

Capture with deterministic state:

- fixed locale and route state
- fixed viewport
- fake or granted microphone permission as needed
- mocked API data where production APIs cannot produce the design state
- stable question order and answers
- loaded fonts and assets before screenshot

Do not freeze animated media just to make a screenshot easier unless the task explicitly allows that. For animated GIFs, keep the app behavior intact and use the captured frame only as static evidence.

Use Playwright or a custom script only when the required state cannot be reached through browser navigation, interaction, session reuse, or network setup in `agent-browser`. If that fallback is necessary, keep the helper outside the project folder and document why `agent-browser` was insufficient.

## Comparison

Run:

```bash
python3 ~/.codex/skills/visual-pixel-match/scripts/compare_screenshots.py \
  --source-dir /path/to/pr-281-screenshots/source \
  --current-dir /path/to/pr-281-screenshots/current \
  --out-dir /path/to/pr-281-screenshots
```

The script writes:

- `metrics.tsv`: `id`, `rmse`, `normalized`
- `diff/<id>.png`: amplified visual difference
- `comparison/<id>.png`: source, current, and diff side by side

RMSE uses `magick compare -metric RMSE` when ImageMagick is available, matching the existing PR artifact table format: `rmse` plus normalized value in parentheses. If ImageMagick is unavailable, the script falls back to white-flattened RGB comparison padded to the max width and height for the pair, then emits ImageMagick-style 16-bit RMSE by multiplying 8-bit RMSE by 257.

## Iteration Loop

1. Map design frames to state IDs and viewport sizes.
2. Capture source screenshots.
3. Capture exactly one current screenshot with `agent-browser`.
4. Generate metrics, diff, and composite for that ID.
5. Inspect the normalized diff and all user-reported problem areas for that ID.
6. Patch the smallest UI surface that explains the mismatch.
7. Recapture the same ID.
8. Repeat until that ID is acceptable, then move to the next ID.
9. Upload final evidence with `gh image`.
10. Clean the project folder before PR handoff.

Do not optimize only for RMSE. Check state selection, clickability, scrollability, visible copy, animation, clipping, asset scale, and whether the screenshot actually came from the current head.

## Transparent GIF Holes

Pure CSS masks and drop shadows process alpha pixels verbatim. They cannot distinguish transparent holes inside a character from transparent space outside the character.

For a transparent GIF with internal holes that must become white while the outside remains transparent, use morphological closing:

1. `feMorphology` dilate on `SourceAlpha`
2. `feMorphology` erode by the same radius
3. subtract the original alpha if only hole fill is needed
4. flood the closed internal area with white
5. layer the original animated GIF above the fill

Tune the radius to close the largest internal transparent gap without rounding the outer contour too much. Do not hand-place white circles over eyes or marks; that breaks as soon as the GIF frame, scale, or crop shifts.

## Artwork And Background Tuning

For mascot/background matching:

- use explicit component dimensions and responsive constraints
- compensate source asset padding with crop, object-position, scale, or a wrapper transform
- verify desktop and mobile separately
- check small phones for scroll instead of fixed overflow clipping
- avoid arbitrary margins unless they are measured against the source frame

If the visual asset includes padding that cannot change, compensate in CSS around the rendered asset. Keep the original asset intact unless asset editing is explicitly in scope.

## PR Evidence

Use:

```bash
gh image --repo owner/repo /tmp/source.png /tmp/current.png /tmp/comparison.png
```

Paste the returned Markdown or convert it into a PR table. Include:

- source image
- current image
- side-by-side comparison image
- normalized RMSE
- current head SHA
- build workflow link
- deploy-dev workflow link

Do not use gists. Do not add screenshot docs inside the project folder.

## Failure Checks

Before calling the pass done, verify:

- no preview routes or screenshot-only components remain in committed source
- no screenshot artifacts or docs were added inside the project folder
- `git status` is clean or only contains intended non-project skill/artifact files
- PR screenshots correspond to the current head SHA
- deploy-dev ran on the same branch/head the PR describes
- small-device layouts can scroll when they cannot fit
