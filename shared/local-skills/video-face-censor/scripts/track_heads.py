import json
from pathlib import Path
import numpy as np
from scipy.ndimage import gaussian_filter1d, median_filter
from scipy.optimize import linear_sum_assignment

import sys
raw = json.loads(Path(sys.argv[1]).read_text())
HEIGHT = int(sys.argv[3])
WIDTH = int(sys.argv[4])
tracks = []

def state(box):
    x1,y1,x2,y2 = box[:4]
    return np.array([(x1+x2)/2,(y1+y2)/2,x2-x1,y2-y1])

def overlap(a,b):
    lo = np.maximum(a[:2]-a[2:]/2,b[:2]-b[2:]/2)
    hi = np.minimum(a[:2]+a[2:]/2,b[:2]+b[2:]/2)
    area = np.prod(np.maximum(0,hi-lo))
    return area/(np.prod(a[2:])+np.prod(b[2:])-area+1e-6)

for frame,detections in enumerate(raw):
    candidates = []
    for detection in detections:
        s = state(detection)
        edge=detection[0]<3 or detection[2]>WIDTH-3
        if HEIGHT*.2 < s[1] < HEIGHT*.7 and (8 if edge else 18) < s[2] < 220 and 22 < s[3] < 230 and (.12 if edge else .45) < s[2]/s[3] < 1.8:
            candidates.append((s,detection[4]))
    active = [t for t in tracks if frame-t['observations'][-1][0] <= 35]
    cost = np.full((len(active),len(candidates)),1e4)
    for i,track in enumerate(active):
        observations = track['observations']
        last_frame,last_state,_ = observations[-1]
        predicted = np.array(last_state)
        if len(observations)>2:
            previous_frame,previous_state,_ = observations[max(0,len(observations)-5)]
            velocity = (predicted[:2]-np.array(previous_state[:2]))/(last_frame-previous_frame)
            predicted[:2] += np.clip(velocity,-25,25)*min(frame-last_frame,10)
        for j,(candidate,confidence) in enumerate(candidates):
            distance = np.linalg.norm(candidate[:2]-predicted[:2])/max(30,np.sqrt(np.prod(predicted[2:])))
            scale = np.abs(np.log(candidate[2:]/predicted[2:])).sum()
            if distance<1.6 and scale<1.8 and confidence>.16:
                cost[i,j] = distance*.7+(1-overlap(predicted,candidate))*.4+scale*.25
    assigned = set()
    if cost.size:
        rows,columns = linear_sum_assignment(cost)
        for i,j in zip(rows,columns):
            if cost[i,j]<1.6:
                s,confidence = candidates[j]
                active[i]['observations'].append([frame,s.tolist(),confidence])
                assigned.add(j)
    for j,(s,confidence) in enumerate(candidates):
        if j not in assigned and confidence>=.35:
            tracks.append({'id':len(tracks),'observations':[[frame,s.tolist(),confidence]]})

accepted = []
table = []
for track in tracks:
    observations = track['observations']
    times = np.array([o[0] for o in observations])
    values = np.array([o[1] for o in observations])
    scores = np.array([o[2] for o in observations])
    if len(times)<12 or scores.max()<.60:
        continue
    start,end = int(times[0]),int(times[-1])
    if start<8:
        start=0
    if len(raw)-end<8:
        end=len(raw)-1
    grid=np.arange(start,end+1)
    interpolated=np.column_stack([np.interp(grid,times,values[:,i]) for i in range(4)])
    smoothed=interpolated.copy()
    smoothed[:,:2]=gaussian_filter1d(interpolated[:,:2],2.5,axis=0,mode='nearest')
    smoothed[:,2:]=np.exp(gaussian_filter1d(np.log(median_filter(interpolated[:,2:],size=(9,1),mode='nearest')),5,axis=0,mode='nearest'))
    accepted.append({'id':track['id'],'start':start,'end':end,'states':smoothed.tolist(),'observations':observations})
    table.append({'id':track['id'],'start':start,'end':end,'observations':len(times),'max_score':round(float(scores.max()),3),'median_center':np.median(values[:,:2],axis=0).round(1).tolist(),'median_size':np.median(values[:,2:],axis=0).round(1).tolist()})
Path(sys.argv[2]).write_text(json.dumps(accepted))
print(json.dumps(table))
