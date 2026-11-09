import os
os.environ['DO_NOT_TRACK'] = '1'
os.environ['YOLO_OFFLINE'] = 'true'
os.environ['YOLO_AUTOINSTALL'] = 'false'
import json
import sys
from pathlib import Path
import numpy as np
import torch
from ultralytics import YOLO, settings
from probe import decoder, probe

settings.update({'sync': False})
torch.set_num_threads(2)
torch.set_num_interop_threads(2)
source, weights, out = sys.argv[1:4]
info = probe(source)
model = YOLO(weights)
stream = decoder(source)
frames = []
size = info['width'] * info['height'] * 3
while True:
    raw = stream.stdout.read(size)
    if not raw:
        break
    assert len(raw) == size
    frame = np.frombuffer(raw, np.uint8).reshape(info['height'], info['width'], 3)
    result = model.predict(frame, imgsz=640, conf=.08, iou=.45, device='cpu', verbose=False)[0]
    frames.append(result.boxes.data.cpu().numpy().tolist())
    if len(frames) % 120 == 0:
        Path(out).write_text(json.dumps(frames))
        print(len(frames), flush=True)
assert stream.wait() == 0
assert len(frames) == info['frames']
Path(out).write_text(json.dumps(frames))
print('done', len(frames), flush=True)
