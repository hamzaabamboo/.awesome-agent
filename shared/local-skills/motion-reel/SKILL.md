---
name: motion-reel
description: Make motion-graphics videos rendered from code (Remotion or a seek(t) canvas page + headless browser + ffmpeg) - product launch/promo reels, feature highlight videos, showreels, animated explainers, music videos, release trailers - with real product UI, kinetic type, beat-synced cuts and an original synthesized soundtrack, then critique your own frames until they hold up. Use this whenever the user asks for a video, promo, trailer, reel, "motion graphic", "make a 15s/20s video", an animation to announce a release or feature, video music/soundtrack, or mentions Remotion, HyperFrames, seek(t), contact sheets, or the Opus 5.5 motion-design trend, even if they don't say "motion design".
---

# Motion Reel

The video is a program: a pure function of time rendered frame by frame. The prompt is 10% of the result; the harness (real assets, a render engine, a beat grid, synthesized sound, and a critique loop where you look at your own frames) is the other 90%.

Read `references/craft-rules.md` before building anything: the timing numbers, easing and spring presets, continuity rules, render hygiene, QA checks, sound placement and export settings that the sections below only summarise.

Hand off when another installed skill fits the job better, and keep this skill's critique loop:
- 8-second UI morph loop (button → player, chart morph, magnetic dock, masked type): `motion-effects`.
- Looping data graphic for a post: `animated-chart`.
- Illustrated explainer or history in a drawn style (cut paper, ink, riso, pixel, isometric): `animate`.
- Vertical Reel or TikTok version of a finished video: `reel-export`.
- No `brand.md` / `MOTION.md` in the project and the brand matters: `brand-intake` first.
- Engines: `hyperframes` for HyperFrames projects, `remotion-best-practices` for Remotion; GSAP timelines via `gsap-timeline`.

Sources, kept verbatim for study; read them when the task goes beyond a short promo:
- `references/course-opus-5-5-motion-design.md`: the full 12-step course (prompt patterns, seek(t) engine, springs, sound, director's brief, critique, shipping).
- `references/pdoom-video-TREATMENT.md`: a complete style bible for a code-rendered music video (palette discipline, type system, motifs, plate-by-plate art direction). This is the best example of *art direction*, read it before designing anything ambitious.
- `references/pdoom-video-ENGINE.md` / `pdoom-video-README.md`: engine contract, adaptive motion blur, deterministic sampling, scene API (MIT, `pdoom-video-LICENSE.md`).
- `references/motion-toolbox.md`: Remotion code for every technique below (springs/track, post layer, slams, UI shots and overlays, duel/rank-climb/gauge/sorting-bars, the non-jumping marquee wall, slab wipes, motion blur).
- `scripts/song.py`: original pop-song synthesizer (stdlib Python) with verse/pre/chorus structure on a frame grid.
- `scripts/critique.sh`: contact sheet, phone sheet, motion strip, audio waveform+spectrogram, loudness, stream check.

## 1. Collect inputs (infer from the repo before asking)

Product + URL, duration (15–20 s is the sweet spot), formats (16:9, 9:16, 1:1), language of the audience, brand colours/fonts (read the theme config), the features to show (read CHANGELOG / release notes / PR titles), a reference (frame, video, image folder, repo), and music (supplied track or synthesize). Ask only for what the repo cannot answer, and ask once. When the brief is vague about the look, name a style and show a contact sheet early instead of asking abstract questions.

## 2. Assets: real UI, captured fresh

Viewers want to see the actual product. Abstract motion *supports* the UI; it never replaces it.

- Capture from the running app in a real browser at `deviceScaleFactor 2` (e.g. `agent-browser set viewport 1440 900 2`), dark/light as the brand uses, in the audience's language. Old dev captures, 1× screenshots and wrong-language UI get rejected on sight.
- Put real data on screen by using the product for real (do actual sorts/orders/posts through the UI) against a local/throwaway backend. Never write to production to get prettier numbers, and never fabricate numbers: use the values the real screens show.
- Cover every major use case and the breadth of content (e.g. songs as well as characters; every franchise/category, not just the first one).
- Crop in physical pixels with ffmpeg; keep a list of crop offsets for overlay maths. Remove awkward states (test-data labels, stale status badges, "0% of 2 people") by recapturing or cropping bands, never by painting over pixels.
- Brand assets from the repo (icons, character art, logo) make the best textures: an icon wall, orbiting avatars, bars topped with icons.

## 3. Render contract

- Every frame is a pure function of the frame number: no timers, CSS transitions, `Math.random`, or state carried between frames. Seed noise with a hash of the frame.
- Route B (Remotion) is fine and fast for React/TS teams; route A (one `index.html` with `window.seek(t)`, Playwright frames → ffmpeg) is the zero-dependency default. Use what the project already knows.
- Pick the BPM so a beat is an integer number of frames (30 fps: 150 BPM = 12 frames). Put every cut, slam and hit on that grid.
- Write every beat into one `timeline.json` before scene code; picture and sound both read it, and nothing hardcodes a start time. Numbers on screen come from a `facts.md` with sources.
- Load every font before `seek(0)`, wait two `requestAnimationFrame` after each seek before capturing, and use seeded randomness only. Seek third-party timelines (GSAP, WAAPI, Lottie) instead of letting them run live.
- Motion blur by blended subframes over a half shutter, adaptive to speed, never across a hard cut and never on text meant to be read. Supersample text at 2×.
- Draft at half scale for every critique round; full resolution once, at the end.
- Before a full render run `df -h`: frame dumps need a few hundred MB. After renders delete Remotion temp dirs (`$TMPDIR/react-motion-render*`, `$TMPDIR/remotion-*`). A render on a nearly full disk dies with ENOSPC and can destabilise the machine.

## 4. The art: how it stops looking mid

The default failure is centred text on a gradient, everything fading in, a logo at the end. What works instead:

- **Hook in the first 2 s**: a collision, a VS, a slam. Something moves on frame 1.
- **The product's own verb is the motion language.** A sorter picks left/right and climbs rankings; a finance app counts up; an editor cuts. Animate that verb abstractly (duel cards, rows climbing into order, a gauge sweeping to the real number, bars sorting themselves), then resolve into the real UI.
- **One idea per beat, a new thing every 2–4 s.** Kinetic headline + one real UI moment + one motion accent per scene. More than that reads as noise; less reads as a slideshow.
- **Type does the shouting.** One display face (condensed grotesk: Anton/Archivo) for 130–300 px slams, one UI face for sub-lines, a mono face for kickers/labels. Headlines left-aligned, asymmetric; no corner labels, no frame borders.
- **Colour discipline.** Dark ink canvas, one accent (the brand's), neutrals; extra colour only from content (character/brand colours on bars, rings). One rare accent owned by one moment.
- **Energy lives in timing, not clutter.** Springs with a hair of overshoot, holds then snaps, kick-synced scale pulse (~1%), shake and flash only on section hits, motion blur on whips. "Chill a notch" means lower shake/chroma/sticker count, not removing motion: a calm pass that stripped the motion read as lifeless.
- **Copy**: short, concrete, in the audience's voice. A bit of playful slang or a sticker lands; a stamp or joke on every scene is too much. Every claim must be true of the product.
- **Transitions**: hard cuts on downbeats by default; slab wipes or whips as accents; cards fly in on springs. For UI-led films prefer continuity: one shape morphing through states, shared elements carrying each handoff, a camera zoom into the element that becomes the next scene.
- **Reading holds**: at least 1 s per short phrase plus 0.25 s per word beyond three, 2 s for the final hook, 3 s for the call to action. Exits run about half as long as entrances. One hero moment per film; build to it.
- **Background**: a slowly scrolling wall of brand icons at 10–20% opacity is a strong, cheap texture. It must scroll continuously (see toolbox §6) and sit outside the camera shake.
- **Ending**: logo lockup with the version, URL typed/wiped on, an `OUT NOW`-style chip, the background brightening; the last hit on the final chord.

Study `pdoom-video-TREATMENT.md` for the higher bar: visual puns and transformations instead of literal illustration, a recurring motif (the spark) threading every plate, palette changes as rhythm, deadpan in-world captions.

## 5. Sound: write a song, not a sound collage

Synthesize unless a track is supplied (then measure it: beats/downbeats/onsets, course §09). `scripts/song.py` is a working template; edit its constants (KEY, section frames, progressions, melodies) to the timeline.

What makes it a song people will sit through:
- **One key**, plain triads, one or two chords per bar. Jazzy 7ths, chords every two beats and a key change every scene sounded like free jazz and got rejected.
- **Structure**: intro hits → hook/theme → verse (lighter) → pre-chorus (melody climbs, snare roll) → chorus (hook returns, octave-doubled) → final chord on the logo. Map sections to the edit; cuts still land on beats.
- **A singable melody**: mostly stepwise, phrases that resolve on chord tones, a hook that repeats. Lead sits on top of the mix (duck the band on kicks, not the lead).
- **Arrangement builds**: fewer layers in the verse, everything in the chorus. No constant 16th arps + stabs + pads + lead all at once.
- **Homage without copying**: to evoke a genre (anison, J-pop, city pop), use its progressions (royal road IV–V–iii–vi, Komuro vi–IV–V–I, canon), instrumentation (octave disco bass, string/brass stabs, orchestra hits) and form, never the melodies of existing songs: quoting copyrighted melodies gets promos muted or taken down. Say this to the user plainly when they ask for "a mix of X, Y, Z".
- SFX on the same timeline as the picture, each placed by its measured peak; hero hits loudest, pad quiet and ducked under the hero moment, pan following screen position. One riser and one impact per film.
- Loudness about −14 LUFS (−12 is fine for social), true peak under −1 dBTP after AAC. You cannot listen: verify structure with the waveform + spectrogram from `scripts/critique.sh` (melody lines visible, sections where planned), then let the user judge by ear on a muxed draft.

## 6. Critique loop (every round, before showing anything)

1. Half-scale draft → `scripts/critique.sh out/draft.mp4 out/critique [strip_at_seconds]`.
2. Open the contact sheet and phone sheet and look properly. Then render full-res stills (`remotion still --frame=N`) of every scene whose sheet thumbnail looks crowded.
3. Score 1–10: hook, readability at phone size, motion quality, variety, composition, brand/UI accuracy, sound sync.
4. Hunt specifically for: text colliding with UI cards (zooms and fly-ins sweeping over headlines), overlays off their target, wrapped/clipped headlines, dead beats, grey mush on cut frames, jumping backgrounds, stale or awkward UI text.
5. Fix the three worst, re-render, compare. Repeat until every score is 8+. Then one full render, then verify duration/streams/loudness and look at the final contact sheet.
6. Before the full render, watch a low-resolution draft at normal speed: stills cannot prove reading holds or rhythm. Check every beat plus 0.3 s after it, and transitions at ±0.1 s.
7. On the final file: scan frame differences for one-frame pops, check loops in position and velocity, and make frame 0 a real composed image (it is the thumbnail).
8. Run the critique as a separate read-only sub-agent when available, and have a fresh agent state the message from the frames alone. If it cannot, the film fails.

## 7. Working with the user's feedback

- Treat each correction as a change to one axis and keep everything else that was working. The most expensive mistake is over-correcting: turning "more motion graphics" into "remove the UI", or "less going on" into "no energy". Keep a copy of the best-liked version's source before a big rewrite so you can merge instead of starting over.
- Show progress as contact sheets and muxed half-res drafts; they are cheap and let the user react early.
- Encode H.264 `yuv420p`, TV range, BT.709, AAC (a silent track when there is no sound), `+faststart`, and verify with `ffprobe`. Every format comes from the same timeline through a layout function, never a crop; 9:16 keeps text between y 360 and y 1420.
- Deliverables live in a gitignored project folder (e.g. `dogfood-output/<name>/out/`): `final.mp4`, `final-contact.png`, source, and the song script. Clean temp renders and drafts afterwards. Do not upload or post the video anywhere unless asked.

## 8. Prompt patterns worth reusing

From the course (full text in the reference): the showreel one-liner ("make a dynamic 15-second motion graphics video… like it's your showreel for a résumé. go all out") to test an engine; the brand template (URL + real screenshots + must have music); the reference ladder (frame → video → own library, write `style_guide.md` first); the XML state-list spec ("one shape, never cut", a cursor drives every change, last frame equals first); the director's brief for long pieces (logline, references, tools, character bible, beat sheet, gated workflow, critique loop, deliverables); and "every format from one timeline" via a layout function rather than cropping.
