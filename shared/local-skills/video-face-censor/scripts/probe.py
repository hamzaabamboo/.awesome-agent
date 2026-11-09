import json
import subprocess
import sys


def probe(path):
    out = subprocess.run(['ffprobe', '-v', 'error', '-select_streams', 'v:0', '-count_frames', '-show_entries', 'stream=width,height,avg_frame_rate,nb_read_frames:stream_side_data=rotation', '-of', 'json', path], capture_output=True, text=True, check=True).stdout
    stream = json.loads(out)['streams'][0]
    width, height = stream['width'], stream['height']
    rotation = 0
    for data in stream.get('side_data_list', []):
        rotation = data.get('rotation', rotation)
    if abs(int(rotation)) % 180 == 90:
        width, height = height, width
    return dict(width=width, height=height, rate=stream['avg_frame_rate'], frames=int(stream['nb_read_frames']))


def decoder(path, threads=2):
    return subprocess.Popen(['ffmpeg', '-v', 'error', '-threads', str(threads), '-i', path, '-f', 'rawvideo', '-pix_fmt', 'bgr24', '-fps_mode', 'passthrough', '-threads', str(threads), '-'], stdout=subprocess.PIPE)


if __name__ == '__main__':
    print(json.dumps(probe(sys.argv[1])))
