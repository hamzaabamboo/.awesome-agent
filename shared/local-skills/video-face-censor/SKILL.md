---
name: video-face-censor
description: Use when the user wants faces or heads in a video censored, blurred or pixelated, including crowds, people facing away, tilted or partly occluded heads, thrown or airborne people, and "inspect frame by frame" requests. Covers local detection, tracking, masking, rendering, frame-level verification and recovery of missed faces.
---

# Video Face Censor

Local, offline pipeline that censors every identifiable head in a video while keeping the original audio and frame count. Built and proven on a 1296-frame, 43 s portrait clip of a crowd with a person being thrown in the air. Everything below was learned by shipping defects and fixing them; the "What went wrong" section is the most valuable part.

## Result contract

- Output video has the same frame count, display size and byte-identical audio packets as the source.
- Every identifiable head is covered in every frame, including heads facing away, in profile, tilted, upside down, partly hidden behind a shoe, hand or another person.
- Masks follow one coherent motion per head. No twitching, no flicker, no stray masks over shirts, shoes, bags or jackets that read as "extra heads".
- Style requested by the user, applied consistently. The delivered style was mosaic blocks over heads plus faint ambient pixelation over the whole frame.
- Local processing only. No cloud inference, no uploading frames, no telemetry (`DO_NOT_TRACK=1`, `YOLO_OFFLINE=true`, `YOLO_AUTOINSTALL=false`).

## Environment and guards

- CPU only. Cap every library at 2 threads (`cv2.setNumThreads(2)`, `torch.set_num_threads(2)`, `OMP_NUM_THREADS=2`, ffmpeg `-threads 2`). Uncapped runs freeze the machine.
- `df -h /` before starting. A 43 s 720x1280 clip needs about 35 MB per render, but an almost-full volume (this session ran at 289 MB free) breaks encoders. Delete superseded renders in `outputs/` only after the user accepts the final one.
- No pipes in the Hermes environment; write intermediate JSON files instead of piping.
- Run long jobs in the foreground when you can. If one must be backgrounded, a bounded wait loop (`for i in $(seq 1 N); do grep -q '^done' log && break; sleep 5; done`) is fine; never leave a job unmonitored and stop jobs you started when the user says to stop.
- Never use `find /` or other filesystem-wide scans to locate models. Look only inside the project, `~/.insightface/models`, and `~/.cache/ultralytics`.
- Do not `open` or reveal files in Finder unless the user asks that turn. `open -R <file>` is the allowed form when they ask ("finder").
- Keep the user's chat wording out of repo files. Record requirements as neutral technical statements.

## Models available on this machine

| Model | Where | What it gives | Weakness |
|---|---|---|---|
| YOLO head detector `11n-head.pt` | project `work/` | head boxes incl. back-of-head and profile, with confidence | needs `ultralytics`; confidence drops under partial occlusion; axis-aligned boxes know nothing about tilt |
| YOLOv8n face `yolov8n-face.pt` | project `work/` | frontal face boxes | misses profile, back, upside-down |
| SCRFD `det_10g.onnx` via insightface `buffalo_l` | `~/.insightface/models/buffalo_l` | face box, 5 landmarks (eyes, nose, mouth corners), score | fails on upside-down, extreme profile, heavy occlusion |

`ultralytics` was not importable from any system python when the skill was written (`/usr/bin/python3`, `/usr/local/bin/python3`, pyenv 3.12). The YOLO outputs already existed as `work/scored-heads.json`. If detection must be redone, install `ultralytics` into a project venv, or reuse the saved JSON. `insightface` 0.7.3, `onnxruntime`, `torch` 2.2.2 and `opencv` are importable from pyenv python 3.12.

No single model is enough. The head model finds heads the face model cannot (back of head, upside down). The face model gives tilt and tight face geometry the head model lacks. The shipped result is the union of both plus manual correction for the intervals where both fail.

## Pipeline

All commands run from the project directory. Scripts live in `scripts/` next to this file; put that directory on `PYTHONPATH` (`probe.py` is shared).

1. Probe: `python3 scripts/probe.py <video>` prints display width/height (rotation side data is applied, so a 1280x720 file with -90 rotation reports 720x1280), average frame rate and the counted frame total.
2. Head detection, low threshold, all candidates kept with scores: `detect_heads.py <video> <weights.pt> work/scored-heads.json`. Each frame is a list of `[x1,y1,x2,y2,score,class]`. Threshold 0.08 on purpose; filtering happens later.
3. Face detection with landmarks: `scrfd_faces.py <video> work/faces-scrfd.json`. det_size 960, det_thresh 0.25, about 8 minutes for 1296 frames at 720x1280 on CPU. Each frame is a list of `{box, kps, score}`.
4. Tracking: `track_heads.py work/scored-heads.json work/head-tracks.json <height> <width>`. Hungarian assignment (`scipy.optimize.linear_sum_assignment`) between predicted track state and new detections, cost from normalized centre distance, IoU and log-scale change. Constant-velocity prediction, gap tolerance 35 frames. Tracks need at least 12 observations and a peak score of 0.60. Interpolate over gaps, then smooth: Gaussian sigma 2.5 on centres, median filter (9) then Gaussian sigma 5 on log-size. This smoothing is what removes twitching. Tracks that touch the first or last 8 frames are extended to the clip edge.
5. Decide edits. Review contact sheets of the rendered result and the detector overlays (`review_tiles.py`) and write an edits JSON (schema below) for: false tracks to remove for an interval, missed heads to add as hand-keyed tracks, and intervals where raw low-confidence detections should be trusted.
6. Render: `render_censor.py <video> work/head-tracks.json work/faces-scrfd.json work/edits.json outputs/out.mp4 [cell=8] [prefilter=3.5] [ambient_cell=3] [ambient_blend=0.3]`. Decodes with `-fps_mode passthrough` (never resample), builds the mask per frame, composites, encodes with libx264 crf 18, `-map_metadata -1`, audio `-c:a copy`, `+faststart`.
7. Verify (next section). Fix, re-render, re-verify. Repeat until no real face remains.

### Mask construction (render_censor.py)

- Per head track: filled ellipse centred at `(cx, cy + 0.06*h)` with semi-axes `(0.72*w + 6, 0.78*h + 6)`. The downward shift covers chin when the head pitches forward. The padding is deliberately generous; the previous 0.58/0.63 factors left faces exposed.
- Per SCRFD face (score >= 0.3): roll angle from the eye landmarks `atan2(right_eye_y - left_eye_y, right_eye_x - left_eye_x)`, clamped to +/-70 degrees. Ellipse semi-axes `(0.85*bw + 6, 0.88*bh + 6)`, rotated by roll, centre shifted by `0.12*bh` up along the head axis because the SCRFD box stops at the brow and hair sits above it. This is the tilt handling the plain tracker lacked.
- All ellipses are drawn into one uint8 mask (union via overwrite), Gaussian-feathered (sigma 2.2), multiplied by 1.6 and clipped to 0..1 so the interior is fully opaque while the edge stays soft.
- Mosaic layer: Gaussian prefilter (sigma 3.5), area-downscale to `(W/cell, H/cell)`, nearest-neighbour upscale. The prefilter destroys fine detail so a larger cell is not needed for anonymity.
- Ambient layer over the whole frame: downscale by `ambient_cell`, nearest-neighbour upscale, blended at `ambient_blend` over the frame. Fixed grid, fixed blend, temporally static so it never shimmers. At 3 px and 30% it is invisible at normal size, which is why the user asked where it went. 2 px at 70% shows as stepped edges on pipes and clothing at 2x zoom.
- Composite: `result*(1-alpha) + mosaic*alpha`.

### Edits JSON schema (`references/edits.example.json` is the real one used)

```json
{
  "scored": "work/scored-heads.json",
  "removed": {"<track id>": [[startFrame, endFrame]]},
  "added": [{"w": 75, "h": 75, "keys": [[frame, cx, cy], ...]}],
  "detections": [{"start": 596, "end": 704, "min_score": 0.15, "min_w": 40, "max_w": 130, "min_y": 380, "max_y": 760}]
}
```

- `removed`: suppress one tracker track for an interval. Use for tracks that latch onto shirts, shoes, jackets or an airborne body. Always remove an interval, not the whole track, when the track is valid elsewhere.
- `added`: hand-keyed head track. Keys are linearly interpolated per frame; `w`/`h` are fixed box sizes (the mask applies the padding factors on top). Measure centres from the actual frame pixels, not from a guess.
- `detections`: for an interval where the tracker lost a head, add every raw detector box above `min_score` inside the size and region limits as a one-frame mask. Over-masks a few non-faces in that interval; privacy beats tidiness there.

## Verification gates (do not skip, do not trust one signal)

1. Structure: `ffprobe -count_frames` equals the source frame count; display size equals the source display size; `ffmpeg -i out -map 0:a -c copy -f md5 -` equals the same command on the source; `ffmpeg -i out -f null -` prints no errors.
2. Automated coverage: `find_uncovered.py <video> work/scored-heads.json work/head-tracks.json work/edits.json 0.3` lists detector boxes (score >= 0.3, height >= 30) whose area is covered by the head masks less than 35%. Output is `hits` and frame `runs`. This list over-reports: backs, jackets, bags, pipes and hands trigger it. Review each run visually before acting. The shipped video had 115 flagged frames of which exactly one run contained real faces.
3. Visual review at full size around every run and every event (toss, group hug, turn-away, crowd re-forming). Use `review_tiles.py <video> out.jpg 596,600,604,... <x1,y1,x2,y2 crop> [boxes.json]` to build zoomed contact tiles. Look at the crop at 1:1 or 2x; thumbnails hide mosaic edges and hide exposed faces. Never accept a contact sheet at thumbnail scale for the "no face visible" claim.
4. Compare against the original frame at the same index for every suspected miss (`ffmpeg -vf "select=eq(n\,N),crop=w:h:x:y"`), so you know whether the face is real before editing masks.
5. Independent second pass on the output: run SCRFD over the finished video and count detections with score >= 0.5. A pixelated face should no longer be detected. This was started but not finished in the original session, so there is no recorded zero; do it.
6. The user's own spot check is final authority. If the user supplies a screenshot of a slip, find that frame in the source, measure the head there, fix that interval, then re-run gates 1-5.

## What went wrong, in order, and the fix for each

1. **First deliverable blurred random areas and flickered.** Per-frame detections drove per-frame blur, so boxes jumped, and one detector gave square masks. Fix: tracking with interpolation and heavy smoothing (step 4), elliptical masks, one coherent motion per head.
2. **Back-of-head and profile heads uncovered.** A frontal-face model alone cannot see them. Fix: a head detector, then SCRFD as a second source rather than a replacement.
3. **Extra masks on shirts, shoes, orange jackets, bags.** Fragmented or false tracks plus oversized ellipses. Fix: `removed` intervals per track, tracks need 12 observations and peak 0.60 confidence, tighter padding (later re-opened, see 6).
4. **Style changed from blur to mosaic with ambient texture.** The user asked for calmer pixelation, fewer extra heads, small ambient pixelation across the frame. Fix: mosaic layer plus a static 30% ambient layer.
5. **A real face was removed as a false track.** A track over the thrower with glasses was deleted for frames 595-705 (it overlapped the airborne shoe), but the face was real. The encoded video exposed it at frames about 596-706. Cause: removal intervals were chosen from low-resolution contact sheets and never compared with the source frame. Fix: restore coverage with hand-keyed tracks and the `detections` rule, verified at 4-frame steps over the window. Rule: before removing any track interval, crop the source at that location and confirm no face is there.
6. **Tilted and forward-leaning heads left face areas outside the mask.** Axis-aligned ellipses sized from head boxes ignore roll and pitch. Fix: SCRFD roll-aligned ellipses, chin-ward shift of the head ellipses, larger padding factors.
7. **Mosaic too coarse, blocking the action (16 px cells).** Fix: finer cells. At 6 px cells the faces of several people were still recognisable in the frame-150 crop, so that setting was rejected. Shipped setting: 8 px cells with a 3.5 sigma Gaussian prefilter. The user accepted it. Do not go finer than 6 px, and re-check a crop of a clear frontal face after any change to cell size.
8. **Wrong mental model of a keyed face.** The first manual keyframes for frames 694-704 were about 60 px off because one coordinate was read from a tile whose scale and crop offset were not applied. The tiles showed hair above the mask. Fix: map tile coordinates back with `x = crop_x0 + tile_x / scale` and `y = crop_y0 + tile_y / scale`, or print detector boxes for those frames and key from them. Two distinct heads (the glasses face and a grey-haired man behind it) occupied that spot; the fix needed one keyed track for each.
9. **Wasted effort on tool trouble.** `find /` for models, a 157 MB session-log grep and a stalled 30-minute background scan all hit time limits. Rule: scope searches to named directories, read large logs with a bounded Python filter, and wait on background work with a bounded loop.
10. **The finished-looking previous output was not finished.** A prior session ended mid-verification and left a final video with an exposed face and an "all verified" note. Always re-verify a handed-over output yourself with gates 1-5; "complete" in a task record is a claim, not evidence.

## Style steps used (head cell, prefilter, ambient cell, ambient blend)

| Version | Settings | Outcome |
|---|---|---|
| early render | 16 px, no prefilter, 3 px at 30% | too coarse, blocked the action |
| v3 candidate | 6 px, no prefilter | faces still recognisable, rejected |
| v3 shipped and accepted | 8, 3.5, 3, .3 | accepted; ambient texture not visible enough |
| v4 | 12, 3.5, 2, .7 | one step coarser heads, visible fine ambient texture |

When the user says "one more step", move heads 8 -> 12 -> 16 and ambient 3 -> 2 -> 1 px; re-render from the source, compare a 2x crop of the same frame between versions, and verify frame count and audio again.

## Decision notes

- Render from the source video every time. Patching an already encoded video stacks a second lossy generation and stacks masks over earlier mosaic. `render_censor.py` takes the source and the JSON files only.
- Keep detection and tracking outputs on disk (`scored-heads.json`, `faces-scrfd.json`, `head-tracks.json`). Re-rendering with a new style or edit takes about 3 minutes; re-detecting takes 10+ minutes.
- Do not interpret a low detector confidence as "no head". In airborne or heavily occluded frames both detectors drop to 0.1-0.4. Treat those intervals as manual-review intervals.
- Prefer a slight over-mask in occlusion intervals. The user complained about visible slips and about blocked action; the middle ground that satisfied them was generous masks with fine, softened mosaic.
- The rotation metadata matters. Source frames decode at the display orientation when ffmpeg autorotates; `probe.py` reports the display size so frame buffers match.
- Frame indexing: use `-fps_mode passthrough` everywhere. A constant-frame-rate resample once produced 1297 frames against a source of 1296 and shifted every index by one.

## Delivery

- Name the final file clearly (`<name>-pixelated-v3.mp4` style) and keep older renders until the user accepts.
- Update the project's canonical task record in place with: source path, final output path, scripts, parameters (cell size, prefilter, padding factors), edits JSON path, verification done and not done.
- Report plainly: frame count, audio equality, which checks ran, which did not, known over-masks, and the remaining risk (partially occluded faces are the weak spot for every model here). Tell the user to scrub the hardest interval (the toss or equivalent).
- Reveal in Finder only if the user asks.
