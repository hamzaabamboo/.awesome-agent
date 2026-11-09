import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import zipfile

REVISION = "e172761a0798bef8a549d440a276218529b53edb"
ARCHIVE_SHA256 = "0b288d91da96abb71e4337fbfe84ed523a4a4c386c58c363d83188b664404bb2"
REPOSITORY = "https://github.com/SonyResearch/mimo-audio-separation.git"
ARCHIVE = "https://github.com/SonyResearch/mimo-audio-separation/releases/download/v1.0.0/mimo-bsroformer_3iter_small.zip"
PACKAGES = [
    "torch==2.5.1", "numpy==1.26.4", "soundfile==0.12.1", "librosa==0.10.2.post1",
    "omegaconf==2.3.1", "einops==0.8.2", "beartype==0.18.5",
    "rotary-embedding-torch==0.8.3", "hyper-connections==0.4.11",
]
GUARD = "try:\n    assert torch.cuda.is_available() and version.parse(torch.__version__) >= version.parse('2.0.0')\nexcept AssertionError as e:\n    raise e\n"


def run(arguments):
    return subprocess.run(arguments, check=True, env={**os.environ, "DO_NOT_TRACK": "1", "PIP_DISABLE_PIP_VERSION_CHECK": "1", "HF_HUB_DISABLE_TELEMETRY": "1"})


def sha256(path):
    result = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            result.update(block)
    return result.hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--tools", required=True, type=Path)
    parser.add_argument("--python", default="python3.12")
    args = parser.parse_args()
    tools = args.tools.resolve()
    tools.mkdir(parents=True, exist_ok=True)
    repo = tools / "upstream"
    if not repo.exists():
        run(["git", "init", str(repo)])
        run(["git", "-C", str(repo), "remote", "add", "origin", REPOSITORY])
        run(["git", "-C", str(repo), "fetch", "--depth", "1", "origin", REVISION])
        run(["git", "-C", str(repo), "checkout", "--detach", "FETCH_HEAD"])
    revision = subprocess.check_output(["git", "-C", str(repo), "rev-parse", "HEAD"], text=True).strip()
    if revision != REVISION:
        raise RuntimeError(f"Existing checkout has another revision: {revision}")
    for name in ["bsroformer.py", "melroformer.py"]:
        relative = f"src/model/backbone/bsroformer/{name}"
        original = subprocess.check_output(["git", "-C", str(repo), "show", f"HEAD:{relative}"], text=True)
        if original.count(GUARD) != 1:
            raise RuntimeError(f"Pinned CPU adaptation no longer matches {name}")
        patched = original.replace(GUARD, "", 1)
        path = repo / relative
        if path.read_text() not in [original, patched]:
            raise RuntimeError(f"Preserving unexpected local changes: {path}")
        path.write_text(patched)
    model = tools / "model"
    manifest_path = tools / "runtime.json"
    existing = json.loads(manifest_path.read_text()) if manifest_path.exists() else {}
    valid = existing.get("revision") == REVISION and all(
        (model / name).is_file() and sha256(model / name) == checksum
        for name, checksum in existing.get("model_sha256", {}).items()
    ) and set(existing.get("model_sha256", {})) == {"config.yaml", "backbone_model.pth"}
    if not valid:
        archive = tools / "checkpoint.zip"
        run(["curl", "--fail", "--location", "--silent", "--show-error", "--max-time", "120", "--output", str(archive), ARCHIVE])
        if sha256(archive) != ARCHIVE_SHA256:
            raise RuntimeError("Checkpoint archive checksum mismatch")
        model.mkdir(exist_ok=True)
        with zipfile.ZipFile(archive) as source:
            files = [entry for entry in source.infolist() if not entry.is_dir()]
            if len(files) != 2 or {Path(entry.filename).name for entry in files} != {"config.yaml", "backbone_model.pth"}:
                raise RuntimeError("Unexpected checkpoint archive contents")
            for entry in files:
                if entry.file_size > 80 * 1024 * 1024:
                    raise RuntimeError("Unexpected checkpoint member size")
                (model / Path(entry.filename).name).write_bytes(source.read(entry))
        archive.unlink()
    python = tools / "venv" / ("Scripts/python.exe" if os.name == "nt" else "bin/python")
    if not python.exists():
        run([args.python, "-m", "venv", str(tools / "venv")])
    if shutil.which("uv"):
        run(["uv", "pip", "install", "--python", str(python), *PACKAGES])
    else:
        run([str(python), "-m", "pip", "install", "--disable-pip-version-check", *PACKAGES])
    manifest = {"revision": REVISION, "archive_sha256": ARCHIVE_SHA256, "model_sha256": {name: sha256(model / name) for name in ["config.yaml", "backbone_model.pth"]}, "packages": PACKAGES, "python": str(python)}
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")
    print(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    main()
