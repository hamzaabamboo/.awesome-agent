#!/usr/bin/env python3
"""Turn a generated avatar clip pack into the files the clip player plays.

Input (see SKILL.md): hub.png, clips/<name>.mp4, mouth/<vowel>.png and optional mouth/<vowel>-half.png,
optional pack.json. Clips and stills may have a solid green background or real transparency.

Output per clip: <name>.mp4 on the player background, <name>.webm with alpha, <name>-mouth.jpg and
<name>-mouth.json (mouth layer), plus report.json with the seam and tracking measurements.
"""
import argparse
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import cv2
import numpy as np

DEFAULT_CLIPS = {
    "idle": {"seconds": 4.0, "hubs": [2.0]},
    "talk": {"seconds": 3.0, "hubs": [1.5]},
    "nod": {"seconds": 0.94, "hubs": []},
    "listen": {"seconds": 4.0, "hubs": []},
    "blink": {"seconds": 0.3, "hubs": []},
}
VOWELS = [("a", "aa"), ("i", "ih"), ("u", "ou"), ("e", "ee"), ("o", "oh")]
PLAYER_BACKGROUND = (240, 240, 240)
SEAM_LIMIT = 2.5
SEAM_REJECT = 25.0


def load_rgba(path, size, key):
    image = cv2.imread(str(path), cv2.IMREAD_UNCHANGED)
    if image is None:
        sys.exit(f"cannot read {path}")
    if image.shape[2] == 3:
        image = cv2.cvtColor(image, cv2.COLOR_BGR2BGRA)
    image = cv2.resize(image, (size, size), interpolation=cv2.INTER_AREA)
    return key_green(image) if key else image


def key_green(bgra):
    """Green-screen key with despill; leaves already transparent pixels alone."""
    b, g, r = [bgra[:, :, i].astype(np.float32) for i in range(3)]
    greenness = g - np.maximum(r, b)
    alpha = np.clip(1 - (greenness - 25) / 60, 0, 1)
    out = bgra.copy()
    out[:, :, 1] = np.minimum(g, np.maximum(r, b) + 10).astype(np.uint8)
    out[:, :, 3] = np.minimum(bgra[:, :, 3], (alpha * 255).astype(np.uint8))
    out[out[:, :, 3] == 0, :3] = 0
    return out


def over_background(bgra):
    alpha = bgra[:, :, 3:4].astype(np.float32) / 255
    background = np.array(PLAYER_BACKGROUND[::-1], np.float32)
    return (bgra[:, :, :3] * alpha + background * (1 - alpha)).astype(np.uint8)


def read_frames(path, size, fps, seconds, key, workdir):
    frames_dir = Path(workdir) / path.stem
    frames_dir.mkdir()
    subprocess.run(
        ["ffmpeg", "-loglevel", "error", "-i", str(path), "-vf", f"fps={fps},scale={size}:{size}", "-t", str(seconds), str(frames_dir / "%05d.png")],
        check=True,
    )
    return [load_rgba(f, size, key) for f in sorted(frames_dir.glob("*.png"))]


def seam_distance(a, b):
    return float(np.abs(over_background(a).astype(np.float32) - over_background(b).astype(np.float32)).mean())


def flow_blend(frame, hub, t):
    """Move frame toward hub by t (0..1) along optical flow, then mix, so a near-miss pose meets the hub without ghosting."""
    gray_f = cv2.cvtColor(over_background(frame), cv2.COLOR_BGR2GRAY)
    gray_h = cv2.cvtColor(over_background(hub), cv2.COLOR_BGR2GRAY)
    flow = cv2.DISOpticalFlow_create(cv2.DISOPTICAL_FLOW_PRESET_MEDIUM).calc(gray_f, gray_h, None)
    h, w = gray_f.shape
    grid = np.dstack(np.meshgrid(np.arange(w), np.arange(h))).astype(np.float32)
    warped_frame = cv2.remap(premultiply(frame), grid + flow * t, None, cv2.INTER_LINEAR, borderMode=cv2.BORDER_REPLICATE)
    back = cv2.DISOpticalFlow_create(cv2.DISOPTICAL_FLOW_PRESET_MEDIUM).calc(gray_h, gray_f, None)
    warped_hub = cv2.remap(premultiply(hub), grid + back * (1 - t), None, cv2.INTER_LINEAR, borderMode=cv2.BORDER_REPLICATE)
    return unpremultiply(warped_frame * (1 - t) + warped_hub * t)


def premultiply(bgra):
    out = bgra.astype(np.float32)
    out[:, :, :3] *= out[:, :, 3:4] / 255
    return out


def unpremultiply(premultiplied):
    alpha = premultiplied[:, :, 3:4]
    out = premultiplied.copy()
    out[:, :, :3] = np.where(alpha > 0, premultiplied[:, :, :3] * 255 / np.maximum(alpha, 1e-3), 0)
    return np.clip(out, 0, 255).astype(np.uint8)


def fix_seams(frames, hub, blend_frames):
    report = {"start": seam_distance(frames[0], hub), "end": seam_distance(frames[-1], hub)}
    n = min(blend_frames, len(frames) // 3)
    if n and report["start"] > SEAM_LIMIT:
        for i in range(n):
            frames[i] = flow_blend(frames[i], hub, 1 - i / n)
    if n and report["end"] > SEAM_LIMIT:
        for i in range(n):
            frames[-1 - i] = flow_blend(frames[-1 - i], hub, 1 - i / n)
    report["start_after"] = seam_distance(frames[0], hub)
    report["end_after"] = seam_distance(frames[-1], hub)
    report["blended"] = n if max(report["start"], report["end"]) > SEAM_LIMIT else 0
    return report


def mouth_box(hub, stills, pad):
    base = over_background(hub).astype(np.int16)
    mask = np.zeros(hub.shape[:2], bool)
    for still in stills:
        mask |= np.abs(over_background(still).astype(np.int16) - base).sum(axis=2) > 24
    ys, xs = np.nonzero(mask)
    if not len(xs):
        sys.exit("mouth stills do not differ from hub.png")
    x0, x1, y0, y1 = xs.min() - pad, xs.max() + pad, ys.min() - pad, ys.max() + pad
    return int(x0), int(y0), int(x1 - x0), int(y1 - y0)


def track_mouth(frames, hub, box):
    """Follow the hub's lower-face patch through each frame (position and scale)."""
    x, y, w, h = box
    margin_x, margin_y = w // 2, h // 2
    template = cv2.cvtColor(over_background(hub)[max(0, y - margin_y): y + h + margin_y, max(0, x - margin_x): x + w + margin_x], cv2.COLOR_BGR2GRAY)
    offset = (x - max(0, x - margin_x), y - max(0, y - margin_y))
    anchors, scores = [], []
    for frame in frames:
        gray = cv2.cvtColor(over_background(frame), cv2.COLOR_BGR2GRAY)
        best = (-1, x, y, 1.0)
        for scale in (0.94, 0.97, 1.0, 1.03, 1.06):
            tpl = cv2.resize(template, None, fx=scale, fy=scale)
            sx0, sy0 = max(0, x - 2 * w), max(0, y - 2 * h)
            search = gray[sy0: y + 3 * h, sx0: x + 3 * w]
            if search.shape[0] < tpl.shape[0] or search.shape[1] < tpl.shape[1]:
                continue
            _, value, _, loc = cv2.minMaxLoc(cv2.matchTemplate(search, tpl, cv2.TM_CCOEFF_NORMED))
            if value > best[0]:
                best = (value, sx0 + loc[0] + offset[0] * scale, sy0 + loc[1] + offset[1] * scale, scale)
        scores.append(best[0])
        anchors.append([round(best[1], 1), round(best[2], 1), best[3]])
    return anchors, scores


def mouth_atlas(stills_full, stills_half, box):
    x, y, w, h = box
    rows = []
    for full, half in zip(stills_full, stills_half):
        for still in (half, full):
            rows.append(over_background(still)[y: y + h, x: x + w])
    return np.vstack(rows)


def encode(frames_bgra, out, fps, workdir, name):
    tmp = Path(workdir) / f"enc-{name}"
    tmp.mkdir()
    for i, frame in enumerate(frames_bgra):
        cv2.imwrite(str(tmp / f"{i:05d}.png"), frame)
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-framerate", str(fps), "-i", str(tmp / "%05d.png"), "-vf", "format=yuva420p", "-c:v", "libvpx-vp9", "-b:v", "0", "-crf", "26", "-row-mt", "1", "-auto-alt-ref", "0", str(out / f"{name}.webm")], check=True)
    for i, frame in enumerate(frames_bgra):
        cv2.imwrite(str(tmp / f"{i:05d}.png"), over_background(frame))
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-framerate", str(fps), "-i", str(tmp / "%05d.png"), "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "18", "-g", "1", "-movflags", "+faststart", str(out / f"{name}.mp4")], check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("pack", type=Path)
    parser.add_argument("out", type=Path)
    parser.add_argument("--size", type=int, default=512)
    parser.add_argument("--fps", type=int, default=30)
    parser.add_argument("--key", choices=["green", "none"], default="green")
    parser.add_argument("--blend-frames", type=int, default=6)
    args = parser.parse_args()

    spec_path = args.pack / "pack.json"
    clips = json.loads(spec_path.read_text())["clips"] if spec_path.exists() else DEFAULT_CLIPS
    key = args.key == "green"
    hub = load_rgba(args.pack / "hub.png", args.size, key)
    full, half = [], []
    for file, _ in VOWELS:
        full.append(load_rgba(args.pack / "mouth" / f"{file}.png", args.size, key))
        half_path = args.pack / "mouth" / f"{file}-half.png"
        half.append(load_rgba(half_path, args.size, key) if half_path.exists() else cv2.addWeighted(hub, 0.5, full[-1], 0.5, 0))
    box = mouth_box(hub, full, pad=max(6, args.size // 50))
    atlas = mouth_atlas(full, half, box)
    args.out.mkdir(parents=True, exist_ok=True)
    report = {"size": args.size, "fps": args.fps, "mouth_box": box, "clips": {}}
    with tempfile.TemporaryDirectory() as workdir:
        for name, spec in clips.items():
            path = args.pack / "clips" / f"{name}.mp4"
            if not path.exists():
                report["clips"][name] = {"missing": True}
                continue
            frames = read_frames(path, args.size, args.fps, spec["seconds"], key, workdir)
            seams = fix_seams(frames, hub, args.blend_frames)
            anchors, scores = track_mouth(frames, hub, box)
            encode(frames, args.out, args.fps, workdir, name)
            cv2.imwrite(str(args.out / f"{name}-mouth.jpg"), atlas, [cv2.IMWRITE_JPEG_QUALITY, 92])
            meta = {"w": box[2], "h": box[3], "fps": args.fps, "vowels": [v for _, v in VOWELS], "levels": [0.25, 0.5], "static": True, "boxes": anchors, "hubs": spec.get("hubs", [])}
            (args.out / f"{name}-mouth.json").write_text(json.dumps(meta))
            report["clips"][name] = {
                "frames": len(frames),
                "seam": {k: round(v, 2) if isinstance(v, float) else v for k, v in seams.items()},
                "reject": max(seams["start"], seams["end"]) > SEAM_REJECT,
                "tracking_min_score": round(min(scores), 3),
            }
    (args.out / "report.json").write_text(json.dumps(report, indent=2))
    print(json.dumps(report, indent=2))
    if any(c.get("reject") or c.get("missing") for c in report["clips"].values()):
        sys.exit(2)


if __name__ == "__main__":
    if not shutil.which("ffmpeg"):
        sys.exit("ffmpeg is required")
    main()
