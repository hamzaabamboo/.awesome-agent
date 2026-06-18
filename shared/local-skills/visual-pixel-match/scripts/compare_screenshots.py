#!/usr/bin/env python3
import argparse
import csv
import math
import re
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFont, ImageOps


def image_ids(source_dir, current_dir, selected):
    if selected:
        return selected
    source = {path.stem for path in source_dir.glob("*.png")}
    current = {path.stem for path in current_dir.glob("*.png")}
    return sorted(source & current)


def flatten(path):
    image = Image.open(path).convert("RGBA")
    base = Image.new("RGBA", image.size, (255, 255, 255, 255))
    base.alpha_composite(image)
    return base.convert("RGB")


def pad(image, width, height):
    if image.size == (width, height):
        return image
    canvas = Image.new("RGB", (width, height), "white")
    canvas.paste(image, (0, 0))
    return canvas


def aligned(source, current):
    width = max(source.width, current.width)
    height = max(source.height, current.height)
    return pad(source, width, height), pad(current, width, height)


def rmse_fallback(source, current):
    diff = ImageChops.difference(source, current)
    histogram = diff.histogram()
    total = source.width * source.height * 3
    square_sum = sum((value % 256) ** 2 * count for value, count in enumerate(histogram))
    rmse8 = math.sqrt(square_sum / total)
    rmse16 = rmse8 * 257
    return rmse16, rmse16 / 65535


def rmse(source_path, current_path, source, current):
    magick = shutil.which("magick")
    if magick and source.size == current.size:
        process = subprocess.run(
            [magick, "compare", "-metric", "RMSE", str(source_path), str(current_path), "null:"],
            capture_output=True,
            text=True,
        )
        match = re.search(r"([0-9.]+)\s+\(([0-9.]+)\)", process.stderr)
        if match:
            return float(match.group(1)), float(match.group(2))
    return rmse_fallback(source, current)


def diff_image(source, current):
    diff = ImageChops.difference(source, current)
    return ImageOps.autocontrast(diff)


def label(image, text):
    bar = 34
    output = Image.new("RGB", (image.width, image.height + bar), "white")
    output.paste(image, (0, bar))
    draw = ImageDraw.Draw(output)
    try:
        font = ImageFont.truetype("Arial.ttf", 16)
    except OSError:
        font = ImageFont.load_default()
    draw.text((12, 9), text, fill=(20, 20, 20), font=font)
    return output


def join(images):
    width = sum(image.width for image in images)
    height = max(image.height for image in images)
    output = Image.new("RGB", (width, height), "white")
    x = 0
    for image in images:
        output.paste(image, (x, 0))
        x += image.width
    return output


def compare_one(id_, source_dir, current_dir, diff_dir, comparison_dir):
    source_path = source_dir / f"{id_}.png"
    current_path = current_dir / f"{id_}.png"
    if not source_path.exists():
        raise FileNotFoundError(source_path)
    if not current_path.exists():
        raise FileNotFoundError(current_path)

    source, current = aligned(flatten(source_path), flatten(current_path))
    value, normalized = rmse(source_path, current_path, source, current)
    visual_diff = diff_image(source, current)
    visual_diff.save(diff_dir / f"{id_}.png")
    join([label(source, "source"), label(current, "current"), label(visual_diff, "diff")]).save(
        comparison_dir / f"{id_}.png"
    )
    return {"id": id_, "rmse": f"{value:.6g}", "normalized": f"{normalized:.6g}"}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-dir", required=True, type=Path)
    parser.add_argument("--current-dir", required=True, type=Path)
    parser.add_argument("--out-dir", required=True, type=Path)
    parser.add_argument("--ids", nargs="*")
    args = parser.parse_args()

    source_dir = args.source_dir.expanduser().resolve()
    current_dir = args.current_dir.expanduser().resolve()
    out_dir = args.out_dir.expanduser().resolve()
    diff_dir = out_dir / "diff"
    comparison_dir = out_dir / "comparison"
    diff_dir.mkdir(parents=True, exist_ok=True)
    comparison_dir.mkdir(parents=True, exist_ok=True)

    rows = [
        compare_one(id_, source_dir, current_dir, diff_dir, comparison_dir)
        for id_ in image_ids(source_dir, current_dir, args.ids)
    ]

    with (out_dir / "metrics.tsv").open("w", newline="") as file:
        writer = csv.DictWriter(
            file,
            fieldnames=["id", "rmse", "normalized"],
            delimiter="\t",
            lineterminator="\n",
        )
        writer.writeheader()
        writer.writerows(rows)

    print(f"Compared {len(rows)} screenshot pairs")
    print(out_dir / "metrics.tsv")


if __name__ == "__main__":
    main()
