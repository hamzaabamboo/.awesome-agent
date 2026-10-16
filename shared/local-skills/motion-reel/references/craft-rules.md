# Craft rules: numbers, continuity, render quality, QA

Distilled from public motion skills (all MIT): whaleyxbt/claude-motion (timing and sound numbers), howseen-ai/claude-motion-design (render pipeline and QA), AbubakrChan/product-launch-motion (one-shape continuity), charlie947/motion-graphics-skills (loops, safe zones, export). Rewritten as rules; read the originals for their code.

## Contents
1. Timeline as the single source
2. Timing numbers
3. Easing and springs
4. Continuity: one system, no generic cuts
5. Render quality
6. QA beyond the contact sheet
7. Sound placement
8. Formats, platforms, export

## 1. Timeline as the single source

- Write every beat as a named timestamp in one `timeline.json` before any scene code. Picture and sound both read it; nothing hardcodes a start time (offsets from a beat are fine). Retiming means editing the timeline, then re-rendering audio.
- Storyboard in numbers first: 6 beats, a layer list per beat (primary, secondary, ambient), and a sound plan (silence, coded SFX, or track). Name a reference style ("Linear launch", "Apple bumper"), never "premium modern".
- Numbers on screen come from a `facts.md` (value, source, date). No facts entry, no number. Illustrative values carry a visible "Example data" label on every frame.

## 2. Timing numbers

| Thing | Value |
|---|---|
| Word stagger | ~0.09 s (55 ms with a slight rotation for masked rises) |
| List items / chips | 0.2–0.25 s |
| Dots, rings | ~0.06 s |
| Masked word reveal | ~0.8 s |
| Entrance | 0.7–1.25 s; exit ≈ half (0.35–0.55 s) on ease-in |
| Typing | ~0.035 s per character, caret blink ~2.4 Hz when idle; typing only inside a product input, never on headlines |
| Reading hold | ≥ 1 s for a short phrase, +0.25 s per word beyond three, ≥ 2 s for the final hook, CTA ≥ 3 s |
| Nothing frozen | no element still for > 1 s except the final hold; keep a micro drift alive even on end cards |

- Overlap scenes: the next one starts drawing before the previous has left. A hard gap reads as loading.
- One hero moment per film (the biggest transition, impact, riser). Build to it; don't spend it early.
- When a 15 s cut flashes text too fast, make it longer and animate less rather than speeding reads up.

## 3. Easing and springs

| Curve | Bezier | Use |
|---|---|---|
| ease-out | (0.16, 1, 0.3, 1) | entrances, anything arriving |
| ease-in | (0.6, 0, 0.9, 0.35) | exits |
| ease-in-out | (0.65, 0, 0.35, 1) | moves between two states |
| landing overshoot | (0.55, 0, 0.2, 1.12) | a value that lands (gauge, slider) |

Linear only for continuous motion (rotation, drift, grain, clock hands).

Spring presets (closed-form step response, damping ratio ≥ 0.72, tiny overshoot, never cartoon bounce):

| Feel | stiffness / damping | Use |
|---|---|---|
| snappy UI | 320 / 30 | controls, toggles |
| default | 170 / 26 | containers, camera |
| heavy | 120 / 24 | big type, logos |
| playful | 180 / 12 | mascots only |

- A target that must arrive at time T is issued one settle-lead early: springs start at their event.
- Leading and trailing edges of a stretching element (tab indicator, pill, knob) on different springs so it stretches.

## 4. Continuity: one system, no generic cuts

- One shape or visual system from start to end. States are the same element morphing size, radius and colour; transitions are morphs, camera moves, or a zoom into an element that becomes the next scene. No generic wipes. Hard cuts only on downbeats, as accents.
- Text inside a morphing container gets its own enter and exit; exit short and early, swap with a brief blur, or old and new text overlap.
- Leave a faint ghost of the start state so the eye can follow the change.
- Shared elements carry handoffs (a button carries its label into the page). The next shot enters already moving in the previous exit's direction.
- Camera: one transform on a container, keys `[t, zoom, x, y]`, zoom interpolated in log space, never zoom in then straight out. Frame each state so it fills the frame; empty frames are a bug. Pull-backs reveal scale.
- Flood transitions grow from the source object and must clear the farthest corner (`hypot` to the 4 corners × 1.05) in ~0.3 s.
- One focal point per frame; with 3+ elements, at most a third move at once. Text never moves while it is meant to be read.
- Safe area: nothing important within ~60 px of the edge (110 px on 16:9 muted homepage films).

## 5. Render quality

- Capture hygiene: wait `document.fonts.ready` and load every font explicitly before `seek(0)` (frame 0 otherwise paints a fallback font); pause `document.getAnimations()`; wait 2 `requestAnimationFrame` after each `seek(t)` before the screenshot.
- Deterministic Chromium flags for identical reruns: `--deterministic-mode --run-all-compositor-stages-before-draw --disable-threaded-animation --disable-checker-imaging --font-render-hinting=none --force-color-profile=srgb`.
- Seek third-party timelines instead of banning them: GSAP `tl.pause(); tl.totalTime(t + 0.001, true); tl.totalTime(t, true)`; WAAPI/CSS `document.getAnimations().forEach(a => { a.pause(); a.currentTime = t * 1000 })`; Lottie `goToAndStop(t * 1000)`; anime.js `seek`. Libraries that only run in real time (Spline, Unicorn Studio, live framer-motion) cannot be used.
- Motion blur by subframes blended with `tmix` over a 0.5 shutter (180°). Adaptive count: still frame 1 sample, ≤ 20 px/frame 4, faster `ceil(px / 5)` up to 64. Never blur across a hard cut. Blur only the slam and whip moves, never text meant to be read.
- Supersample text at `deviceScaleFactor 2` and downscale with Lanczos for razor type; cheaper than blur on static type.
- Never `will-change` on anything the camera scales (blurry text). Never scale a blurred copy of text during a handoff; crossfade only the fill.
- Odometers: proportional digits jump; size each slot to its final glyph and clip vertically only.
- Films over ~25 s: render in parallel chunks and concat; re-render only changed seconds.

## 6. QA beyond the contact sheet

- One frame per beat plus 0.3 s after each beat (settled state), then transitions at ±0.1 s.
- Watch a low-resolution draft at normal speed before the full render: stills cannot prove reading holds or rhythm.
- Pops scan: frame-difference spikes > 3× neighbours flag glitches (intentional beat cuts show up too; say which). One-frame flash: frame n differs from both neighbours while n−1 ≈ n+1.
- Loops: the last frame equals the first in position and velocity (cursor included); check `seek(0)` against `seek(T)`; cycles are integer counts of the loop length.
- Judge is not builder: run the critique as a separate read-only sub-agent, and have a fresh agent restate the message from the frames alone. If it cannot, the film fails. Muted one-sentence test: a viewer summarises the loop in one sentence or too much moves.
- Score each shot 1–10 (readability, rhythm, continuity, brand, loop); fix only ≤ 7, leave 9+ alone.
- Frame 0 is the thumbnail (X, Slack and Discord ignore cover images): it is a real composed image, never black. Overlay a poster on frame 0 with `-filter_complex "[0:v][1:v]overlay=0:0:enable='eq(n,0)'[v]"` when needed.
- Report what was measured versus heard: you cannot listen, so say the audio was checked by waveform, spectrogram and loudness only.

## 7. Sound placement

- Cue sheet reads the same timeline as the picture; every hit time comes from a beat, never a typed number.
- Place each sample by its measured peak (argmax of |s|), not its file start, onto the beat or kick-peak grid.
- Gains: hero hits 0.25–0.35, supporting sounds 0.08–0.2, pad ~0.03 ducked ~65% under the hero transition; music ducked ~9 dB under voice-over.
- Pan follows on-screen position; sequences sweep across the stereo field; pitch rises with progress and resolves on the payoff, all in one key.
- Accent, don't narrate: continuous motion (drift, grain, rotation) stays silent. One riser and one impact per film.
- Visual event to sound: typing → humanised keystrokes (±4–6 ms jitter); reveal → whoosh + blip on landing; badge pop → pop with rising pitch across a sequence; control snap → click + blip in key; build-up → riser ending exactly on the hit; success → chime chord in key.
- With a supplied track, find the drop by band energy (never trust an auto beat grid; double/half tempo is the usual miss) and start the song at `drop_in_song − drop_in_film` so the drop lands on the hero moment.
- Master to −14 LUFS; limit true peak to about −2 dBFS before AAC so the MP4 stays under −1 dBTP. A mix of short hits with silence cannot reach −14 without crushing: add sustain (pad, longer tails) instead of forcing gain.

## 8. Formats, platforms, export

- Write scenes against a layout function and render 16:9, 1:1, 4:5 and 9:16 from the same timeline, reframing per format. Never crop one format into another.
- 9:16 safe zone: words and logos between y 360 and y 1420, out of the right 120 px. A 16:9 clip scaled to 1080 wide is 608 tall and sits well at y 660.
- Muted-first: feeds autoplay without sound, so kinetic type carries the message.
- Final encode: H.264 `yuv420p`, TV range, BT.709 (`scale=out_color_matrix=bt709:out_range=tv,format=yuv420p`, `-color_range tv -colorspace bt709 -color_primaries bt709 -color_trc bt709`), AAC, `-movflags +faststart`. Add a silent AAC track when there is no sound; some apps reject video-only files. Verify with `ffprobe` (h264, yuv420p, `color_range=tv`, bt709, one aac stream).
- Logos over footage sit on their own dark rounded tile or they vanish on light frames.
- Platforms: LinkedIn 4:5 1080×1350; X 16:9 or 1:1 up to 2:20; Reels and TikTok 1080×1920.
