---
name: avatar-clip-pack
description: Generate and package reusable talking-avatar animations from a reference portrait and shared motion data. Use for interviewer clip packs, seamless idle/nod/listen/blink loops, Japanese vowel animation, transparent video assets, and integration-ready avatar players.
---

# Avatar clip pack

## Contract

One reference portrait → shared motion controls → temporally coherent full-frame animation masters → offline background removal → compact runtime assets → common player. Appearance changes through assets and a manifest; tuning changes through exposed settings. Do not create identity-specific player branches.

Before acting, read the project's canonical current task and avatar pipeline protocol. Determine the approved appearance, framing, motion source, renderer and output package. Preserve accepted assets. Missing automation is a task to implement and verify, not permission to claim that an arbitrary picture already works.

## Permissions

- Hosted image/video generation and paid APIs require an explicit request in the current turn. Existing local models, offline processing and local packaging may proceed within the authorized task.
- Do not send telemetry, feedback or source assets to vendors. Keep prompts, masters, reports and deliverables project-owned.
- Use the supplied likeness/reference. Ask for a reference only when none exists.

## Input gate

1. Inspect the actual reference at full useful resolution. Check visible face, mouth, hair silhouette, framing, expression and available alpha/background.
2. Validate the local animation model's face detection and supported input type. Stop clearly on failed detection; never silently substitute a different identity.
3. Transparent or controlled-background sources still need matte inspection. Arbitrary backgrounds require a validated segmentation/matting stage; chroma keying cannot remove arbitrary scenery.
4. Use a shared calibration/motion library. New identities must not require hand-coded facial coordinates, manually painted mouth patches or identity-specific runtime math. If model quality requires per-reference correction, report that limitation explicitly.

## Project execution

For the existing shinkijigyousitu project, read `docs/ars-2372/COMPACT_AVATAR_PIPELINE.md`, then use the common entry from the project root:

```bash
DO_NOT_TRACK=1 artifacts/liveportrait-trial-2026-10-20/fasterliveportrait-mlx/.venv/bin/python artifacts/liveportrait-trial-2026-10-20/build_avatar.py --image /absolute/portrait.png --output /absolute/new-pack
```

Optional `--tuning /absolute/settings.json` carries the same tuning fields as the page; `--budget` sets the complete package byte limit. The wrapper supplies offline/telemetry/thread controls to every child. It renders shared motions, applies CorridorKey, measures alignment, exports state video, compresses, validates and atomically packages. It requires the existing local model environment and shared calibration assets. Do not download or silently substitute missing models.

Supported input: one clearly visible front-facing human-like face with closed lips and open eyes, either RGBA or a controlled green background. Hair and shoulders may cover the lower corners; do not require every corner to be green. Other backgrounds need a separately validated segmentation stage. Do not claim arbitrary backgrounds or non-human geometry are supported.

Use a fresh output directory when the input, model or tool signature changes. Completed stages have output hashes; failed stages may be rerun only after their actual error is fixed. Do not mark a stage complete manually to skip a failure. Do not run simultaneous MLX/CorridorKey accelerator jobs or performance recordings during generation.

Inspect `build.json`, generated masters and the resulting `avatar-compact.zip`. A successful process exit is not visual acceptance. Run the project's real-browser runtime and failure-path harnesses against a fresh ZIP extraction, then inspect the recorded video/contact sheet. Record the actual delayed SDK audio together with canvas video; silent video alone cannot establish audio synchronization. The old `scripts/build_pack.py` is a legacy overlay builder and must not be used for this contract.

## Animation masters

- Generate neutral, idle, nod, listen and blink from the same source and shared motion controls. VRM-derived pose/expression curves are valid drivers; do not confuse a 2D image warp with a rendered 3D head rotation.
- Generate speech as complete coherent frames across vowel, mouth opening and head pose together. A baseline is 5 Japanese vowels ×8 poses ×8 opening levels. Keep every frame registered to the same identity, camera, lighting and silhouette.
- New mouth-reference images, when requested, calibrate the animator. They are not independently pasted over the face during playback.
- あ: relaxed open jaw; い: horizontally spread; う: narrower rounded lips; え: spread with moderate opening; お: rounded taller opening. Inspect rendered differences, teeth and lip closure; labels alone prove nothing.
- Silent idle/listen/nod must keep a stable closed mouth and friendly neutral expression. No involuntary lip twitch, frown drift or rubbery facial deformation.
- Preserve natural generated speech head motion. Do not add arbitrary sinusoidal face/body deformation to compensate for inadequate source motion.
- Loops and state transitions return to a common hub. Compare visible premultiplied RGB and alpha endpoints; invisible padding RGB is not a visible seam.
- Keep source/model/canvas resolutions explicit. A 60Hz renderer or duplicated output frames does not create 60fps source detail.

## Offline processing

- Remove background before runtime delivery. Prefer a proven neural matte/key implementation such as the project's CorridorKey stage over new ad-hoc color thresholds. Inspect hair against light, dark and checkerboard backgrounds, including moving frames.
- Preserve original source RGB in opaque foreground pixels; use reconstructed foreground only at fractional-alpha edges. Do not apply arbitrary per-avatar temperature offsets. Encode explicit BT709 matrix/primaries, limited range and sRGB transfer in both the bitstream and decoder configuration. Compare decoded opaque skin against source RGB before accepting color.
- Cache stages by source, configuration, model and motion hashes. Do not reuse an old matte after the source changes.
- Preserve original masters separately from delivery assets. Never overwrite accepted assets before replacement passes review.
- Motion interpolation may use measured bidirectional optical flow between generated frames. It must align features, not crossfade doubled eyes/teeth or invent arbitrary facial movement. Inspect slow motion and close-ups for ghosting.

## Compact runtime protocol

Use the established project protocol; do not replace it with a new engine per avatar. The current shinkijigyousitu implementation uses:

- 720px generated frames; RGB+alpha side-by-side H264 for state video and independently decodable speech pose groups.
- 5 speech binaries with AVC configuration/frame tables,4 state videos,40 compressed RG8 alignment fields, poster and manifest.
- 8 opening frames per pose group;3 cached poses per vowel. Decode incrementally with WebCodecs; close VideoFrame objects after upload. Do not preload full lossless atlases.
- 192px field tiles,8 quantization units; validate displacement error/range before delivery. Do not shrink fields solely to hit a byte target when quality regresses.
- Hash SDK module imports and manifest content revisions independently so code and data cannot remain stale after a release.
- Manifest content revision, explicit asset paths and a shared SDK. Never mix cached old assets with a new manifest.
- Audio-clock synchronization, coarticulation and smooth opening/closure. Sustained same-vowel speech should not repeatedly snap to closed mouth. Idle has no audio-driven mouth activity.
- Default motion playback speed 0.65 unless the user supplies another value. Preserve explicitly saved page settings; expose tuning rather than burying constants.

Project entry points and exact commands belong in the project protocol, not duplicated hard-coded machine paths in this skill. Inspect their actual help/source before execution. Legacy overlay builders are not the approved runtime.

## Validation and delivery

1. Show source, generated vowel/pose contact sheets, matte edges, loop joins and actual player output as separate visible stages.
2. Verify every shipped appearance through the same SDK: speech, all vowels, idle/nod/listen/blink, preview, interruption, cancellation and disposal. A style left on a legacy loader is incomplete.
3. Measure actual package bytes, startup milestones, decode stalls and frame intervals. State whether measurements are warm/local and distinguish declared texture allocation from measured memory.
4. Budget against the user's reference. In the current project the VRM comparison is 16,543,564bytes per avatar. Exclude model weights, masters and review videos from the runtime ZIP; include required SDK, classifier, licenses, manifest and checksums.
5. Verify connection cancellation, connection-specific cleanup ownership, repeated connect/disconnect, source interruption, closed-mouth idle, initialization abort/timeout, missing assets, unsupported graphics and disposal. Expected play/pause AbortError must not become a permanent playback failure. Preserve caller-owned AudioContext; release owned audio/graphics resources.
6. Extract the final ZIP into a fresh project-owned directory and run its own example through a real browser. Source-tree success is not portable-package verification. Keep browser/device limitations explicit.
7. Publish atomically after checks. Keep a single compact canonical task record, a Japanese integration protocol when required by the project, and an evidence-backed handoff.
8. Promise new-image automation only after an end-to-end run on a new supported input. Distinguish implemented commands, verified outputs and remaining manual/model-quality gates. Never equate packaging existing masters with animating a new image.
