import json
import sys
import cv2
import numpy as np
from probe import decoder, probe

video, out = sys.argv[1:3]
frames = [int(v) for v in sys.argv[3].split(',')]
crop = [int(v) for v in sys.argv[4].split(',')] if len(sys.argv) > 4 else None
boxes = json.loads(open(sys.argv[5]).read()) if len(sys.argv) > 5 else None
info = probe(video)
size = info['width'] * info['height'] * 3
stream = decoder(video)
wanted = set(frames)
kept = {}
for index in range(max(frames) + 1):
    raw = stream.stdout.read(size)
    if index in wanted:
        kept[index] = np.frombuffer(raw, np.uint8).reshape(info['height'], info['width'], 3).copy()
stream.kill()
tiles = []
for index in frames:
    image = kept[index]
    if boxes:
        for x1, y1, x2, y2 in boxes.get(str(index), []):
            cv2.rectangle(image, (x1, y1), (x2, y2), (0, 0, 255), 2)
    x1, y1, x2, y2 = crop or (0, 0, info['width'], info['height'])
    tile = cv2.resize(image[y1:y2, x1:x2], (360, int(360 * (y2 - y1) / (x2 - x1))))
    cv2.putText(tile, str(index), (4, 18), cv2.FONT_HERSHEY_SIMPLEX, .6, (0, 255, 255), 2)
    tiles.append(tile)
columns = 5
while len(tiles) % columns:
    tiles.append(np.zeros_like(tiles[0]))
cv2.imwrite(out, np.vstack([np.hstack(tiles[row:row + columns]) for row in range(0, len(tiles), columns)]))
