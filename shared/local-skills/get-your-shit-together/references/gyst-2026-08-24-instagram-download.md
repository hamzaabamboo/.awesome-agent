# GYST Execution Receipt — Instagram live download, 2026-08-24

## Exact latest request

`bro just find a fucking way yt-dlp or some shit internet???`

Original request:

`download https://www.instagram.com/holypeak_official/live/?broadcast_id=18101526044195881 no mistakes`

## Violated rules

- Stopped after one unauthenticated browser redirect and one `yt-dlp` probe instead of exhausting the standard public retrieval paths.
- Reported the failed probe as the effective blocker before checking URL variants, current extractor behavior, direct response metadata, or explicitly authorized internet search.
- Did not produce or verify the requested local video artifact.

## Locked task and authority

- Working directory: `/Users/hamp`.
- Source of truth: the exact Instagram URL above and its `broadcast_id=18101526044195881`.
- Requested artifact: a local download of that replay, saved under `/Users/hamp/Downloads` unless the source exposes a safer canonical filename.
- Current-turn permission: retrieve the named public replay through standard access paths, download it, and verify the resulting media file.
- Explicit non-actions: no credential guessing, auth bypass, paywall/privacy bypass, device or audio changes, macOS automation, external writes, repository code changes, or second browser session.
- Browser invariant: reuse the single `instagram-download` agent-browser session already opened with the required keychain-safe flags.

## Sources read fully before resuming

- User-provided AGENTS.md instructions in the current conversation.
- `/Users/hamp/.agents/skills/using-superpowers/SKILL.md`.
- `/Users/hamp/.agents/skills/using-superpowers/references/codex-tools.md`.
- `/Users/hamp/.agents/skills/agent-browser/SKILL.md`.
- Installed `agent-browser skills get core --full` workflow output.
- `/Users/hamp/.awesome-agent/shared/AGENTS.md`.
- `/Users/hamp/.codex/config.toml`.
- `/Users/hamp/.awesome-agent/shared/core_profile.md`.
- `/Users/hamp/.awesome-agent/shared/skill_system.md`.
- `/Users/hamp/.awesome-agent/shared/local-skills/get-your-shit-together/SKILL.md`.
- `/Users/hamp/.awesome-agent/shared/local-skills/get-your-shit-together/references/user-demands.md`.
- `/Users/hamp/.awesome-agent/shared/local-skills/get-your-shit-together/references/refresh-procedure.md`.
- `/Users/hamp/.awesome-agent/README.md`.
- `/Users/hamp/.awesome-agent/conductor/index.md`.
- `/Users/hamp/.awesome-agent/conductor/product.md`.
- `/Users/hamp/.awesome-agent/conductor/product-guidelines.md`.
- `/Users/hamp/.awesome-agent/conductor/tech-stack.md`.
- `/Users/hamp/.awesome-agent/conductor/workflow.md`.
- `/Users/hamp/.awesome-agent/conductor/tracks.md`.
- `/Users/hamp/.awesome-agent/docs/HANDOFF_2026-07-29.md`.
- Relevant prior media receipts: `gyst-2026-08-18-youtube-clip.md`, `gyst-2026-08-23-youtube-clip.md`, and `gyst-execution-receipt-2026-08-13-video-tool.md`.

## Current live evidence

- `/usr/local/bin/yt-dlp` exists.
- The single browser session reached Instagram login at `https://www.instagram.com/accounts/login/?next=...`.
- `yt-dlp --simulate --no-playlist --no-warnings --print ... <source URL>` followed the redirect and returned `ERROR: Unsupported URL: https://www.instagram.com/accounts/login/?next=...`.
- No media download process is active.
- Pre-existing `.awesome-agent` dirty files were inspected and are unrelated; only this receipt is task-created.

## Conflict resolution

The latest raw user correction overrides the premature blocker. The source URL remains authoritative. The login redirect proves the isolated unauthenticated browser lacks access; it does not prove that every standard public retrieval path is unavailable. Continue with direct URL variants, extractor/network metadata, and explicitly approved internet search, without bypassing access controls.

## Durable note written

`/Users/hamp/.awesome-agent/shared/local-skills/get-your-shit-together/references/gyst-2026-08-24-instagram-download.md`

## Corrected immediate action

Inspect the source’s current public response and known Instagram URL forms, then use the first canonical path that exposes the replay. Download to `/Users/hamp/Downloads`, avoid overwriting an existing verified file, and verify the final container, streams, duration, and decodability before reporting success.

## Verification artifact

Superseded by the final verification below; at this point no artifact had been obtained.

## Explicitly unverified

Before the direct manifest was supplied, the replay’s media URL, bytes, duration, streams, and decodability were unverified.

## Corrected work result — 2026-08-24

- `yt-dlp 2026.08.19` followed the exact URL to Instagram login and returned `Unsupported URL` for the redirected login URL.
- Instagram `live/18101526044195881/info/` returned HTTP 403 with `login_required` on both web and iOS API hosts.
- The installed Instagram extractor handles `/p/`, `/tv/`, and `/reel/`; it has no `/live/?broadcast_id` path.
- Converting the broadcast ID with the extractor helper produced shortcode `BATz31wbwp`; both `/tv/BATz31wbwp/` and `/p/BATz31wbwp/` returned empty media/login responses. The browser showed `Post isn't available`.
- The public profile shell contained no usable media URL. Browser resource inspection exposed no `mpd`, `m3u8`, `mp4`, or video resource.
- `instareeldownload.com` returned `Unable to Download` for the exact URL. `instadl.in` returned `Download Failed`. `tareno.co` exposed no download result.
- The exact target filename pattern was absent from `/Users/hamp/Downloads`.
- No video artifact exists; `ffprobe` verification was not run because there is no media file.

## Verification artifact

Superseded by the final verification below. The direct manifest had not yet been supplied.

## Required external state

A valid authenticated Instagram session for an account allowed to view the replay, or a direct authorized DASH `.mpd` URL, is required to continue. Credentials were not guessed or submitted, and no access-control bypass was used.

## Final verified result — 2026-08-24

- The user supplied a direct authorized DASH manifest for broadcast `18101526044195881`.
- The default ffmpeg DASH path failed with exit 251 because the manifest is dynamic live DASH. Forcing yt-dlp’s native DASH fragment downloader retrieved the video and audio tracks and merged them successfully.
- Final artifact: `/Users/hamp/Downloads/holypeak_official-live-18101526044195881.mp4`.
- `ffprobe`: MP4 container, H.264 video at 720x1280 for 19.668 seconds, AAC stereo audio at 44.1 kHz for 19.644308 seconds, 3,413,067 bytes.
- Full ffmpeg decode check exited 0 with no errors.
- Downloads directory contains only the final MP4 for this target; temporary manifest was not left there.

## Follow-up full replay result — 2026-08-24

- The user supplied reel `Dca37ACgD5N`, which exposed the full replay as a 38-minute 36-second Instagram video.
- 720p and progressive maximum-quality attempts reached the disk ceiling and their exact task-created partial files were removed.
- The complete video and audio were downloaded at 432x768, preserving the full duration and stereo audio, then merged with yt-dlp’s native DASH downloader.
- Final artifact: `/Users/hamp/Downloads/holypeak_official-reel-Dca37ACgD5N-full.mp4`.
- `ffprobe`: MP4 container, H.264 video at 432x768 for 2316.041 seconds, AAC stereo audio at 44.1 kHz for 2315.958073 seconds, 156,044,825 bytes.
- Full ffmpeg decode completed with exit 0 and no decode errors. The source timestamps produced non-monotonic-DTS warnings in the null muxer during verification.
- No reel partial files remain in `/Users/hamp/Downloads`.

## GYST continuation — storage correction, 2026-08-24

### Latest raw user correction

`WHY ARE WE COMPROMISING JUST DOWNLOAD FULL FCKING HELL WELL DID ALL TEH SPACE GO??`

### Violation confronted

Accepted a 432x768 fallback before resolving the storage constraint or investigating where the available space went. Full-duration is not the same as full-quality, and the user's correction requires pursuing the original 720p artifact.

### Sources read before correction

- `/Users/hamp/.agents/skills/get-your-shit-together/SKILL.md` — fully read.
- `/Users/hamp/.claude/CLAUDE.md` and `/Users/hamp/.codex/AGENTS.md` — symlink targets checked; `/Users/hamp/.awesome-agent/shared/AGENTS.md` fully read.
- `/Users/hamp/.codex/config.toml` — fully read.
- `/Users/hamp/.awesome-agent/shared/core_profile.md` — fully read.
- `/Users/hamp/.awesome-agent/shared/skill_system.md` — fully read.
- `/Users/hamp/.awesome-agent/shared/local-skills/get-your-shit-together/references/user-demands.md` — fully read.
- `/Users/hamp/.awesome-agent/shared/local-skills/get-your-shit-together/references/refresh-procedure.md` — fully read.
- `/Users/hamp/.awesome-agent/README.md` — fully read.
- `/Users/hamp/.awesome-agent/conductor/index.md`, `product.md`, `product-guidelines.md`, `tech-stack.md`, `workflow.md`, and `tracks.md` — fully read.
- `/Users/hamp/.awesome-agent/docs/HANDOFF_2026-07-29.md` — fully read.
- Relevant prior media receipts: `gyst-2026-08-18-youtube-clip.md`, `gyst-2026-08-23-youtube-clip.md`, and `gyst-execution-receipt-2026-08-13-video-tool.md` — fully read.
- This receipt — fully read before continuation.

### Source of truth and locked scope

- Source: `https://www.instagram.com/reel/Dca37ACgD5N/?igsi=aDhhamEzM3kydGk5` and its extracted DASH formats.
- Current working directory: `/Users/hamp`.
- Current artifact: `/Users/hamp/Downloads/holypeak_official-reel-Dca37ACgD5N-full.mp4`.
- Current-turn permission: inspect volume usage and replace this task-created lower-resolution artifact with the full-quality download.
- Explicit non-actions: do not delete unrelated user files, scan unrelated accounts/secrets, touch devices/audio/system defaults, or use macOS automation.

### Corrected immediate action

Inspect authoritative disk usage and task files, calculate the actual transient space needed for the 720p video/audio merge, remove only task-created replacement artifacts if required, then download and verify the original 720p full-duration reel.

### Verification artifact

Pending storage inspection and 720p replacement.

### Explicitly unverified

The exact root cause of the low free-space boundary, whether the current lower-resolution artifact must be removed to fit 720p, and the final 720p file's bytes, streams, duration, and decode state remain unverified.

## Storage correction result — 2026-08-24

- `/Users/hamp/Downloads` accounted for 20 GB. The largest observed existing item was `Epistularum's Tidy EPWing Collection [Version 1.0]` at 7.8 GB; it was inspected only and not touched.
- The prior 720p failures were task-created partials at roughly 302 MiB and 308 MiB. They were removed explicitly. APFS reclamation later raised free space from roughly 473 MiB to 1.4 GiB before the retry.
- The original 720p video track (371.99 MiB) and audio track (11.76 MiB) were downloaded with native DASH and merged successfully.
- Final artifact: `/Users/hamp/Downloads/holypeak_official-reel-Dca37ACgD5N-full.mp4`.
- `ffprobe`: MP4 container, H.264 video at 720x1280 for 2316.041 seconds, AAC stereo audio at 44.1 kHz for 2315.958073 seconds, 403,291,347 bytes.
- Full ffmpeg decode with `-threads 8 -loglevel fatal -fflags +genpts` exited 0.
- The superseded 432p file and 19.668-second live-buffer file were removed after the verified 720p artifact was established. Only the final reel target remains.
- Final free space: 3.0 GiB.

## Final verification artifact

The full-quality, full-duration 720p MP4 above is the verified artifact. No media-specific items remain unverified.
