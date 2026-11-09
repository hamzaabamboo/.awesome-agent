import json
import math
import subprocess
import sys
from pathlib import Path
import cv2
import numpy as np
from probe import decoder, probe

cv2.setNumThreads(2)
source, tracks_path, faces_path, edits_path, out = sys.argv[1:6]
CELL = int(sys.argv[6]) if len(sys.argv) > 6 else 8
PREFILTER = float(sys.argv[7]) if len(sys.argv) > 7 else 3.5
AMBIENT_CELL = int(sys.argv[8]) if len(sys.argv) > 8 else 3
AMBIENT_BLEND = float(sys.argv[9]) if len(sys.argv) > 9 else .3
FACE_SCORE = .3
info = probe(source)
W, H = info['width'], info['height']
GRID = (W // CELL, H // CELL)
tracks = json.loads(Path(tracks_path).read_text())
faces = json.loads(Path(faces_path).read_text())
edits = json.loads(Path(edits_path).read_text()) if edits_path != '-' else {}
removed = {int(k): v for k, v in edits.get('removed', {}).items()}
scored = json.loads(Path(edits['scored']).read_text()) if edits.get('scored') else []


def keyed_track(spec):
    keys = np.array(spec['keys'], float)
    grid = np.arange(int(keys[0, 0]), int(keys[-1, 0]) + 1)
    centers = np.column_stack([np.interp(grid, keys[:, 0], keys[:, j]) for j in (1, 2)])
    sizes = np.column_stack([np.full(len(grid), spec['w']), np.full(len(grid), spec['h'])])
    return dict(id=-1, start=int(grid[0]), end=int(grid[-1]), states=np.column_stack([centers, sizes]).tolist())


tracks += [keyed_track(spec) for spec in edits.get('added', [])]
for rule in edits.get('detections', []):
    for index in range(rule['start'], rule['end'] + 1):
        for x1, y1, x2, y2, score, *_ in scored[index]:
            w, h = x2 - x1, y2 - y1
            if score >= rule['min_score'] and rule['min_w'] <= w <= rule['max_w'] and rule['min_y'] <= y1 <= rule['max_y']:
                tracks.append(dict(id=-1, start=index, end=index, states=[[(x1 + x2) / 2, (y1 + y2) / 2, w, h]]))


def draw(mask, cx, cy, rx, ry, angle):
    cv2.ellipse(mask, (int(round(cx)), int(round(cy))), (max(1, int(round(rx))), max(1, int(round(ry)))), angle, 0, 360, 255, -1)


def head_mask(index):
    mask = np.zeros((H, W), np.uint8)
    for track in tracks:
        if not track['start'] <= index <= track['end'] or any(a <= index <= b for a, b in removed.get(track['id'], [])):
            continue
        cx, cy, w, h = track['states'][index - track['start']]
        draw(mask, cx, cy + h * .06, w * .72 + 6, h * .78 + 6, 0)
    for face in faces[index]:
        if face['score'] < FACE_SCORE:
            continue
        x1, y1, x2, y2 = face['box']
        bw, bh = x2 - x1, y2 - y1
        left, right = face['kps'][0], face['kps'][1]
        roll = max(-70, min(70, math.degrees(math.atan2(right[1] - left[1], right[0] - left[0]))))
        cx, cy, shift = (x1 + x2) / 2, (y1 + y2) / 2, bh * .12
        draw(mask, cx + math.sin(math.radians(roll)) * shift, cy - math.cos(math.radians(roll)) * shift, bw * .85 + 6, bh * .88 + 6, roll)
    return cv2.GaussianBlur(mask, (0, 0), 2.2).astype(np.float32) / 255


def render(frame, index):
    ambient = cv2.resize(cv2.resize(frame, (W // AMBIENT_CELL, H // AMBIENT_CELL), interpolation=cv2.INTER_AREA), (W, H), interpolation=cv2.INTER_NEAREST)
    result = cv2.addWeighted(frame, 1 - AMBIENT_BLEND, ambient, AMBIENT_BLEND, 0)
    softened = cv2.GaussianBlur(frame, (0, 0), PREFILTER)
    pixels = cv2.resize(cv2.resize(softened, GRID, interpolation=cv2.INTER_AREA), (W, H), interpolation=cv2.INTER_NEAREST)
    alpha = np.clip(head_mask(index) * 1.6, 0, 1)[:, :, None]
    return np.rint(result * (1 - alpha) + pixels * alpha).astype(np.uint8)


stream = decoder(source)
encoder = subprocess.Popen(['ffmpeg', '-v', 'error', '-y', '-f', 'rawvideo', '-pix_fmt', 'bgr24', '-s', f'{W}x{H}', '-r', info['rate'], '-i', '-', '-i', source, '-map', '0:v:0', '-map', '1:a:0', '-map_metadata', '-1', '-c:v', 'libx264', '-threads', '2', '-preset', 'fast', '-crf', '18', '-pix_fmt', 'yuv420p', '-c:a', 'copy', '-movflags', '+faststart', out], stdin=subprocess.PIPE)
size = W * H * 3
for index in range(info['frames']):
    raw = stream.stdout.read(size)
    assert len(raw) == size
    encoder.stdin.write(render(np.frombuffer(raw, np.uint8).reshape(H, W, 3), index).tobytes())
    if index % 300 == 0:
        print(index + 1, info['frames'], flush=True)
stream.stdout.close()
encoder.stdin.close()
assert stream.wait() == 0
assert encoder.wait() == 0
print('done', flush=True)
