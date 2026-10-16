#!/bin/sh
set -e
VIDEO="$1"
OUT="${2:-$(dirname "$VIDEO")/critique}"
AT="${3:-}"
mkdir -p "$OUT"
ffmpeg -loglevel error -y -i "$VIDEO" -vf "fps=2,scale=320:-1,tile=8x5" -frames:v 1 "$OUT/contact.png"
ffmpeg -loglevel error -y -i "$VIDEO" -vf "fps=1,scale=360:-1,tile=5x4" -frames:v 1 "$OUT/phone.png"
if [ -n "$AT" ]; then
  ffmpeg -loglevel error -y -ss "$AT" -i "$VIDEO" -vf "scale=320:-1,tile=12x1" -frames:v 1 "$OUT/strip.png"
fi
if ffprobe -v error -select_streams a -show_entries stream=codec_type -of csv=p=0 "$VIDEO" | grep -q audio; then
  ffmpeg -loglevel error -y -i "$VIDEO" -filter_complex "[0:a]showwavespic=s=2000x140:colors=#ff5cbe[w];[0:a]showspectrumpic=s=2000x320:legend=0:scale=log:stop=3000[s];[w][s]vstack" -frames:v 1 "$OUT/audio.png"
  ffmpeg -nostats -i "$VIDEO" -af ebur128 -f null - 2>&1 | grep " I:" | tail -1
fi
ffprobe -v error -show_entries format=duration,size:stream=codec_name,width,height -of compact "$VIDEO"
echo "$OUT"
