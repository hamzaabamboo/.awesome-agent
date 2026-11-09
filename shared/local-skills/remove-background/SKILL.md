---
name: remove-background
description: Use when the user asks to remove, cut out or delete the background of an image or photo, make a transparent PNG, or isolate a person or subject. Runs BiRefNet locally through rembg, handles a full disk by using an external volume, and verifies the cutout visually.
---

# Remove Background

Local, offline cutout with BiRefNet (`birefnet-general`, best open model for photos with people, hair and fine edges). No cloud services, no uploads.

## Run

```
scripts/remove-bg.sh <input> [output] [model]
```

- Output defaults to `<input>_nobg.png` beside the source, full resolution RGBA. The original is never modified.
- First run builds a venv and downloads the ~970 MB model into a scratch dir (`<volume>/.rembg-scratch`). Later runs reuse it.
- Scratch dir goes to `~/.cache` if that volume has 3 GB free, else the first `/Volumes/*` that does. Override with `REMBG_HOME`. On a full disk, do not ask the user to free space; the script picks another volume.
- Other models: `birefnet-portrait` for portraits, `isnet-general-use` or `u2net` as faster fallbacks.

## Gotchas

- Intel macOS has no `llvmlite` wheel for the newest numba, so a plain `pip install rembg` fails building llvmlite. The script installs with `--only-binary :all:` so the resolver picks older wheels.
- Keep `OMP_NUM_THREADS=2`; uncapped CPU runs freeze the machine.
- Keep `DO_NOT_TRACK=1`. The model download hits GitHub releases once; that is the only network use.

## Verify

Composite the PNG over a solid green (or any contrasting) background and look at it before reporting. Check hair, hands, held objects, shoes and thin straps for halos or missing parts:

```
python -c "from PIL import Image; im=Image.open('out.png').convert('RGBA'); bg=Image.new('RGBA',im.size,(0,200,80,255)); bg.alpha_composite(im); bg.convert('RGB').resize((im.width//2,im.height//2)).save('check.jpg')"
```

Run it with the scratch venv python. Put `check.jpg` in the session scratchpad, not next to the user's files.

## Cleanup

Scratch dir is regenerable. When the user wants it cleaned up, `rm -rf` the `scratch:` path the script printed, plus the check image. Mention how long the next run will take (reinstall plus model download).
