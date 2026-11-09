#!/usr/bin/env bash
set -euo pipefail

input="${1:?usage: remove-bg.sh <input> [output] [model]}"
output="${2:-${input%.*}_nobg.png}"
model="${3:-birefnet-general}"
need_kb=$((3 * 1024 * 1024))

free_kb() { df -k "$1" | awk 'NR==2 {print $4}'; }

pick_home() {
  if [ -n "${REMBG_HOME:-}" ]; then echo "$REMBG_HOME"; return; fi
  local candidate
  for candidate in "$HOME/.cache" /Volumes/*; do
    [ -d "$candidate" ] && [ -w "$candidate" ] && [ "$(free_kb "$candidate")" -ge "$need_kb" ] && { echo "$candidate/.rembg-scratch"; return; }
  done
  echo "no writable volume with 3GB free; set REMBG_HOME" >&2
  exit 1
}

home="$(pick_home)"
mkdir -p "$home/tmp"
export TMPDIR="$home/tmp" UV_CACHE_DIR="$home/uv-cache" U2NET_HOME="$home/models" DO_NOT_TRACK=1 OMP_NUM_THREADS=2

if [ ! -x "$home/venv/bin/rembg" ]; then
  uv venv --python 3.12 "$home/venv"
  uv pip install --python "$home/venv/bin/python" --only-binary :all: "rembg[cpu,cli]" pillow
fi

"$home/venv/bin/rembg" i -m "$model" "$input" "$output" 2>&1 | grep -v -E 'it/s|B/s|OMP: Info' || true
[ -s "$output" ] || { echo "no output written" >&2; exit 1; }
echo "$output"
echo "scratch: $home"
