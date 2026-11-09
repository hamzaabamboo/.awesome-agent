import json
import sys
from pathlib import Path
import numpy as np
from probe import probe

source, scored_path, tracks_path, edits_path = sys.argv[1:5]
min_score = float(sys.argv[5]) if len(sys.argv) > 5 else .3
info = probe(source)
W, H = info['width'], info['height']
scored = json.loads(Path(scored_path).read_text())
tracks = json.loads(Path(tracks_path).read_text())
edits = json.loads(Path(edits_path).read_text()) if edits_path != '-' else {}
removed = {int(k): v for k, v in edits.get('removed', {}).items()}
yy, xx = np.mgrid[0:H, 0:W]


def covered(index):
    mask = np.zeros((H, W), bool)
    for track in tracks:
        if not track['start'] <= index <= track['end'] or any(a <= index <= b for a, b in removed.get(track['id'], [])):
            continue
        cx, cy, w, h = track['states'][index - track['start']]
        mask |= (((xx - cx) / (w * .72 + 6)) ** 2 + ((yy - cy) / (h * .78 + 6)) ** 2) < 1
    return mask


hits = []
for index, boxes in enumerate(scored):
    mask = None
    for x1, y1, x2, y2, score, *_ in boxes:
        if score < min_score or y2 - y1 < 30:
            continue
        mask = covered(index) if mask is None else mask
        if mask[int(y1):int(y2), int(x1):int(x2)].mean() < .35:
            hits.append([index, [round(x1), round(y1), round(x2), round(y2)], round(score, 2)])
frames = sorted({hit[0] for hit in hits})
runs = []
for frame in frames:
    if runs and frame - runs[-1][1] <= 3:
        runs[-1][1] = frame
    else:
        runs.append([frame, frame])
print(json.dumps(dict(hits=hits, runs=runs)))
