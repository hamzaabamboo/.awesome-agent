import argparse
import json
import math
import os
from pathlib import Path
import subprocess
import sys

from setup_mimo import REVISION, sha256


ENV = {**os.environ, "DO_NOT_TRACK": "1", "HF_HUB_DISABLE_TELEMETRY": "1", "WANDB_MODE": "disabled", "OMP_NUM_THREADS": "2", "OPENBLAS_NUM_THREADS": "1", "VECLIB_MAXIMUM_THREADS": "1"}


def run(arguments):
    return subprocess.run(arguments, check=True, capture_output=True, env=ENV).stdout


def probe(path):
    return json.loads(run(["ffprobe", "-v", "error", "-show_format", "-show_streams", "-of", "json", str(path)]))


def seconds(value):
    parts = value.split(":")
    if len(parts) > 3:
        raise argparse.ArgumentTypeError("Use seconds, MM:SS, or HH:MM:SS")
    try:
        numbers = [float(part) for part in parts]
    except ValueError as error:
        raise argparse.ArgumentTypeError(str(error)) from error
    if any(not math.isfinite(n) or n < 0 for n in numbers) or any(n >= 60 for n in numbers[1:]):
        raise argparse.ArgumentTypeError("Invalid time")
    return sum(n * 60 ** i for i, n in enumerate(reversed(numbers)))


def new_output(path):
    path = path.resolve()
    if path.exists():
        raise FileExistsError(f"Preserving existing output: {path}")
    path.parent.mkdir(parents=True, exist_ok=True)
    return path


def write_report(path, report):
    path.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2), flush=True)


def clip(args):
    if args.end <= args.start:
        raise ValueError("End must be after start")
    output = new_output(args.output)
    metadata = new_output(output.with_suffix(".json"))
    duration = args.end - args.start
    command = ["ffmpeg", "-nostdin", "-v", "error", "-threads", "1", "-ss", str(args.start), "-i", str(args.input), "-t", str(duration), "-map", "0:v:0", "-map", "0:a:0?"]
    command += ["-c:v", "libx264", "-preset", "fast", "-crf", "18", "-threads:v", "2", "-c:a", "aac", "-threads:a", "1", "-b:a", "320k"] if args.accurate else ["-c", "copy"]
    run(command + ["-movflags", "+faststart", str(output)])
    write_report(metadata, {"operation": "clip-only", "audio_treatment": "none", "requested_start": args.start, "requested_duration": duration, "stream_copy": not args.accurate, "actual": probe(output)})


def separate(args):
    import numpy as np
    import soundfile as sf
    import torch
    from omegaconf import OmegaConf

    if args.threads < 1:
        raise ValueError("Threads must be positive")
    tools = args.tools.resolve()
    runtime = json.loads((tools / "runtime.json").read_text())
    if runtime["revision"] != REVISION:
        raise RuntimeError("Run the pinned setup helper first")
    for name, checksum in runtime["model_sha256"].items():
        if sha256(tools / "model" / name) != checksum:
            raise RuntimeError(f"Model checksum mismatch: {name}")
    output = args.output_dir.resolve()
    if output.exists() and any(output.iterdir()):
        raise FileExistsError(f"Preserving existing stem directory: {output}")
    output.mkdir(parents=True, exist_ok=True)
    source = output / ".source.wav"
    run(["ffmpeg", "-nostdin", "-v", "error", "-threads", "1", "-i", str(args.input), "-vn", "-ac", "2", "-ar", "44100", "-c:a", "pcm_f32le", str(source)])
    torch.set_num_threads(args.threads)
    torch.set_num_interop_threads(1)
    sys.path.insert(0, str(tools / "upstream/src"))
    from model.mimo_base import MIMOBase
    from model.backbone.bsroformer.bsroformer import MultiSourceBSRoformer

    config = OmegaConf.to_container(OmegaConf.load(tools / "model/config.yaml"), resolve=True)
    model_config = config["model"]
    backbone_config = model_config.pop("backbone_model")
    if backbone_config.pop("_target_") != "model.backbone.MultiSourceBSRoformer":
        raise RuntimeError("Unexpected backbone configuration")
    for key in ["_target_", "discriminator", "loss_modules", "loss_lambdas"]:
        model_config.pop(key, None)
    if (model_config["num_channels"], model_config["num_sources"], model_config["max_iter"]) != (2, 2, 3):
        raise RuntimeError("Unexpected model dimensions")
    model = MIMOBase(backbone_model=MultiSourceBSRoformer(**backbone_config), **model_config).eval()
    weights = torch.load(tools / "model/backbone_model.pth", map_location="cpu", weights_only=True)
    model.backbone_model.load_state_dict(weights, strict=True)
    chunk = config["data"]["train"]["sample_length"]
    hop = chunk // 2
    buffer = np.zeros((2, 2, chunk), dtype="float64")
    denominator = np.zeros(chunk)
    error = 0.0
    paths = [output / ".vocals.partial.wav", output / ".music.partial.wav"]
    with sf.SoundFile(source) as audio, sf.SoundFile(paths[0], "w", samplerate=44100, channels=2, subtype="FLOAT") as vocals, sf.SoundFile(paths[1], "w", samplerate=44100, channels=2, subtype="FLOAT") as music, torch.inference_mode():
        length = len(audio)
        if length == 0:
            raise ValueError("Empty source audio")
        total = math.ceil(length / hop)
        for index, start in enumerate(range(0, length, hop)):
            audio.seek(start)
            section = audio.read(chunk, dtype="float32", always_2d=True).T
            padded = np.pad(section, ((0, 0), (0, chunk - section.shape[1])))
            prediction = model.inference(torch.from_numpy(padded.copy())[None], iters=[3])[0][0].numpy()
            window = np.ones(chunk)
            if index:
                window[:hop] = np.linspace(0, 1, hop, endpoint=False)
            if index < total - 1:
                window[-hop:] = np.linspace(1, 0, hop, endpoint=False)
            buffer += prediction * window
            denominator += window
            count = min(hop, length - start)
            block = buffer[..., :count] / denominator[:count]
            if not np.isfinite(block).all():
                raise RuntimeError("Non-finite model output")
            error = max(error, float(np.max(np.abs(block.sum(axis=0) - section[:, :count]))))
            if error > 1e-5:
                raise RuntimeError(f"Mixture reconstruction error: {error}")
            vocals.write(block[0].T)
            music.write(block[1].T)
            buffer[..., :hop] = buffer[..., hop:]
            buffer[..., hop:] = 0
            denominator[:hop] = denominator[hop:]
            denominator[hop:] = 0
            print(f"window {index + 1}/{total}", flush=True)
    for source_path, name in zip(paths, ["vocals.wav", "music.wav"]):
        source_path.rename(output / name)
    source.unlink()
    write_report(output / "separation.json", {"model": "Sony MIMO BS-RoFormer small", "revision": REVISION, "iterations": 3, "sample_rate": 44100, "frames": length, "mixture_max_error": error, "threads": args.threads, "input": str(args.input.resolve())})


def mix(args):
    import numpy as np
    import soundfile as sf

    output = new_output(args.output)
    metadata = new_output(output.with_suffix(".json"))
    gains = np.power(10.0, np.array([args.vocal_db, args.music_db]) / 20)
    if not np.isfinite(gains).all():
        raise ValueError("Gains must be finite")
    peak = 0.0
    with sf.SoundFile(args.stems / "vocals.wav") as vocals, sf.SoundFile(args.stems / "music.wav") as music:
        if (len(vocals), vocals.samplerate, vocals.channels) != (len(music), music.samplerate, music.channels) or vocals.channels != 2 or len(vocals) == 0:
            raise ValueError("Stems must be matching nonempty stereo files")
        for block in vocals.blocks(blocksize=65536, always_2d=True):
            combined = block * gains[0] + music.read(len(block), always_2d=True) * gains[1]
            if not np.isfinite(combined).all():
                raise ValueError("Non-finite mix")
            peak = max(peak, float(np.max(np.abs(combined))))
        if peak >= 1:
            raise ValueError(f"Mix would clip ({20 * math.log10(peak):.2f} dBFS); reduce gains")
        vocals.seek(0)
        music.seek(0)
        with sf.SoundFile(output, "w", samplerate=vocals.samplerate, channels=2, subtype="PCM_24") as target:
            for block in vocals.blocks(blocksize=65536, always_2d=True):
                target.write(block * gains[0] + music.read(len(block), always_2d=True) * gains[1])
        frames, rate = len(vocals), vocals.samplerate
    write_report(metadata, {"vocal_gain_dB": args.vocal_db, "music_gain_dB": args.music_db, "normalization": None, "denoiser": None, "peak_dBFS": 20 * math.log10(peak) if peak else None, "frames": frames, "sample_rate": rate, "duration": frames / rate, "stems": str(args.stems.resolve())})


def mux(args):
    output = new_output(args.output)
    run(["ffmpeg", "-nostdin", "-v", "error", "-threads", "1", "-i", str(args.video), "-i", str(args.wav), "-map", "0:v:0", "-map", "1:a:0", "-c:v", "copy", "-c:a", "aac", "-threads:a", "1", "-b:a", "320k", "-movflags", "+faststart", str(output)])
    print(output)


def verify(args):
    import numpy as np
    import soundfile as sf
    from scipy.signal import correlate, correlation_lags

    xx = yy = xy = 0.0
    peak = 0.0
    best_power = -1.0
    best = None
    command = ["ffmpeg", "-nostdin", "-v", "error", "-threads", "1", "-i", str(args.video), "-vn"]
    with sf.SoundFile(args.wav) as target:
        rate, frames = target.samplerate, len(target)
        if target.channels != 2 or frames == 0:
            raise ValueError("Expected nonempty stereo WAV")
        command += ["-ar", str(rate), "-ac", "2", "-f", "f32le", "-"]
        decoded = 0
        with subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=ENV) as process:
            while True:
                raw = process.stdout.read(rate * 2 * 4)
                if not raw:
                    break
                if len(raw) % 8:
                    raise RuntimeError("Incomplete decoded audio frame")
                audio = np.frombuffer(raw, dtype="float32").reshape(-1, 2).astype("float64")
                decoded += len(audio)
                if not np.isfinite(audio).all():
                    raise RuntimeError("Non-finite decoded audio")
                peak = max(peak, float(np.max(np.abs(audio))))
                expected = target.read(len(audio), always_2d=True)
                audio = audio[:len(expected)]
                if len(expected):
                    power = float(np.sum(expected * expected))
                    xx += power
                    yy += float(np.sum(audio * audio))
                    xy += float(np.sum(expected * audio))
                    if power > best_power:
                        best_power, best = power, (expected[:, 0], audio[:, 0])
            error = process.stderr.read().decode()
            if process.wait():
                raise RuntimeError(error)
    correlation = xy / math.sqrt(xx * yy) if xx and yy else None
    lag = None
    if best_power > 1e-12:
        expected, audio = best
        cross = correlate(audio, expected, method="fft")
        lags = correlation_lags(len(audio), len(expected))
        allowed = np.abs(lags) <= 2048
        lag = int(lags[allowed][np.argmax(cross[allowed])])
    if decoded < frames or decoded - frames > 2048 or peak >= 1 or (correlation is not None and correlation < 0.98) or (lag is not None and lag != 0):
        raise RuntimeError(f"Audio verification failed: frames={frames}/{decoded}, peak={peak}, correlation={correlation}, lag={lag}")
    actual = probe(args.video)
    video = next(stream for stream in actual["streams"] if stream["codec_type"] == "video")
    audio = next(stream for stream in actual["streams"] if stream["codec_type"] == "audio")
    if abs(float(audio.get("start_time", 0)) - float(video.get("start_time", 0))) > 1 / rate:
        raise RuntimeError("Audio/video start mismatch")
    if abs(float(audio["duration"]) - frames / rate) > 2048 / rate:
        raise RuntimeError("Audio duration mismatch")
    unchanged = None
    if args.reference_video:
        def stream_hash(path):
            return run(["ffmpeg", "-nostdin", "-v", "error", "-threads", "1", "-i", str(path), "-map", "0:v:0", "-c", "copy", "-f", "streamhash", "-hash", "sha256", "-"])
        unchanged = stream_hash(args.video) == stream_hash(args.reference_video)
        if not unchanged:
            raise RuntimeError("Video stream changed")
    write_report(args.video.with_suffix(".verification.json"), {"WAV_frames": frames, "decoded_AAC_frames": decoded, "audio_correlation": correlation, "audio_offset_samples": lag, "AAC_peak_dBFS": 20 * math.log10(peak) if peak else None, "video_stream_unchanged": unchanged, "WAV_duration": frames / rate, "MP4_duration": float(actual["format"]["duration"]), "video_duration": float(video["duration"]), "audio_duration": float(audio["duration"]), "listening_quality": "not established by numerical verification"})


def main():
    parser = argparse.ArgumentParser()
    commands = parser.add_subparsers(dest="command", required=True)
    command = commands.add_parser("clip")
    command.add_argument("--input", required=True, type=Path)
    command.add_argument("--start", required=True, type=seconds)
    command.add_argument("--end", required=True, type=seconds)
    command.add_argument("--output", required=True, type=Path)
    command.add_argument("--accurate", action="store_true")
    command = commands.add_parser("separate")
    command.add_argument("--input", required=True, type=Path)
    command.add_argument("--tools", required=True, type=Path)
    command.add_argument("--output-dir", required=True, type=Path)
    command.add_argument("--threads", default=2, type=int)
    command = commands.add_parser("mix")
    command.add_argument("--stems", required=True, type=Path)
    command.add_argument("--vocal-db", required=True, type=float)
    command.add_argument("--music-db", required=True, type=float)
    command.add_argument("--output", required=True, type=Path)
    command = commands.add_parser("mux")
    command.add_argument("--video", required=True, type=Path)
    command.add_argument("--wav", required=True, type=Path)
    command.add_argument("--output", required=True, type=Path)
    command = commands.add_parser("verify")
    command.add_argument("--video", required=True, type=Path)
    command.add_argument("--wav", required=True, type=Path)
    command.add_argument("--reference-video", type=Path)
    args = parser.parse_args()
    globals()[args.command](args)


if __name__ == "__main__":
    main()
