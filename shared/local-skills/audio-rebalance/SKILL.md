---
name: audio-rebalance
description: Rebalance vocals against music in local recordings or HLS downloads, compare separation artifacts, and deliver processed audio or video clips while retaining editable stems.
---

# Audio rebalance

Use local processing and project-owned files. Preserve the source recording. A quiet vocal, a loud backing track, clipping, and separation artifacts require different treatments.

## Establish the target

1. Resolve the source, exact ranges, desired output, and current approved mix from the active task. A new song range inherits an approved audio treatment; an explicit clip-only request preserves original audio.
2. Inspect the requested timestamp, both audio channels, and a nearby working reference. Low file amplitude does not exclude distortion earlier in the recording chain. Distortion in a generated candidate is not evidence of distortion in the source.
3. Start with a short representative excerpt. Retain separated vocals and accompaniment so gain changes require only remixing. Obtain listening approval before extending a new treatment across a song.

Whole-mix gain cannot change vocal/music balance. Lowering music can improve balance without raising microphone noise. Raising a vocal stem also raises residual noise in that stem. Use the user's chosen gains; the examples below are successful settings from one recording, not universal presets.

## Source acquisition

For an authorized HLS URL, inspect with `yt-dlp`. A failed plain `curl` request is not conclusive if `yt-dlp` can read the manifest. Prefer direct FFmpeg downloading/muxing when a native HLS download followed by remuxing would duplicate a large file. Keep signed URLs and authentication out of skill files, task receipts, and public repositories.

```sh
DO_NOT_TRACK=1 yt-dlp --no-progress --downloader ffmpeg --downloader-args 'ffmpeg:-threads 1' -o source.mp4 '<authorized HLS URL>'
```

## Separate and remix

The bundled path uses Sony MIMO BS-RoFormer small, three iterations, stereo 44.1 kHz, CPU with two threads, and overlapping four-second windows. Setup pins the upstream source and verifies the released checkpoint archive. It downloads public source/weights and packages locally; no recording is uploaded.

Set `AUDIO_SKILL` to this skill's directory. Keep runtime dependencies and downloads in the active project's work directory, outside the skill source.

```sh
DO_NOT_TRACK=1 python3 "$AUDIO_SKILL/scripts/setup_mimo.py" --tools ./work/audio-tools --python python3.12
```

Clip-only work needs only system Python and FFmpeg; skip model setup. Use the Python executable reported by setup for separation, mixing, and verification:

```sh
DO_NOT_TRACK=1 python3 "$AUDIO_SKILL/scripts/audio.py" clip --input source.mp4 --start 00:10 --end 00:40 --output ./work/preview-original.mp4
```

```sh
DO_NOT_TRACK=1 ./work/audio-tools/venv/bin/python "$AUDIO_SKILL/scripts/audio.py" separate --input ./work/preview-original.mp4 --tools ./work/audio-tools --output-dir ./work/preview-stems
```

For a no-microphone-boost preview, try vocal 0 dB and music about -13 dB. When the listener requests both more vocal and less music, a modest example is vocal +3 dB and music -16 dB. Preserve explicit user choices rather than automatically returning to a reference balance.

```sh
DO_NOT_TRACK=1 ./work/audio-tools/venv/bin/python "$AUDIO_SKILL/scripts/audio.py" mix --stems ./work/preview-stems --vocal-db 3 --music-db -16 --output ./work/preview.wav
```

```sh
DO_NOT_TRACK=1 ./work/audio-tools/venv/bin/python "$AUDIO_SKILL/scripts/audio.py" mux --video ./work/preview-original.mp4 --wav ./work/preview.wav --output ./work/preview-processed.mp4
```

The mixer uses independent linear gains and writes a 24-bit WAV. It fails on overload rather than silently adding normalization, limiting, or denoising. Render the final range with the same approved settings. For clip-only work, stop after `clip`; separation is unnecessary. Stream-copy clips can round at packet/frame boundaries; use `clip --accurate` when exact boundaries outweigh preserving the encoded streams.

## Verify the delivered artifact

```sh
DO_NOT_TRACK=1 ./work/audio-tools/venv/bin/python "$AUDIO_SKILL/scripts/audio.py" verify --video ./work/preview-processed.mp4 --wav ./work/preview.wav --reference-video ./work/preview-original.mp4
```

Inspect the reported duration, starts, decoded audio correlation/offset, peak, and video-stream equality. The final MP4 must contain the processed WAV's content; an unchanged source clip is not audio restoration. Numerical checks establish signal integrity, not listening quality. Compare candidates at matched vocal levels and with the same accompaniment when evaluating models. Inspect isolated retained and rejected components before saying a model kept the intended voice.

## When the result is wrong

Read [references/limits.md](references/limits.md) for muffled or rattling output, backing vocals, model comparisons, and the tested runtime caveats. A vocal/music model does not identify a physical live microphone. Lead/backing-role models can still select a louder recorded voice; reference- or visually conditioned extraction is a different task.

## Keep the current iteration

After new exports pass verification, retain the source, latest MP4/WAV, current vocals/music stems, and compact gain/verification metadata. On cleanup requests, remove only enumerated task-owned superseded renders, model/runtime caches, scratch clones and scripts. Preserve unrelated files and stop owned processes. Never delete current stems before a requested remix is finished.
