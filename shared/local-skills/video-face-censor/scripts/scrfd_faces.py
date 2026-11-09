import os
os.environ['OMP_NUM_THREADS'] = '2'
import json
import sys
from pathlib import Path
import cv2
import numpy as np
from insightface.app import FaceAnalysis
from probe import decoder, probe

cv2.setNumThreads(2)
source, out = sys.argv[1:3]
info = probe(source)
app = FaceAnalysis(name='buffalo_l', allowed_modules=['detection'], providers=['CPUExecutionProvider'])
app.prepare(ctx_id=-1, det_size=(960, 960), det_thresh=.25)
stream = decoder(source)
size = info['width'] * info['height'] * 3
faces = []
for index in range(info['frames']):
    raw = stream.stdout.read(size)
    assert len(raw) == size
    frame = np.frombuffer(raw, np.uint8).reshape(info['height'], info['width'], 3).copy()
    faces.append([dict(box=f.bbox.tolist(), kps=f.kps.tolist(), score=float(f.det_score)) for f in app.get(frame)])
    if index % 100 == 0:
        Path(out).write_text(json.dumps(faces))
        print(index, flush=True)
Path(out).write_text(json.dumps(faces))
print('done', sum(len(f) for f in faces), flush=True)
