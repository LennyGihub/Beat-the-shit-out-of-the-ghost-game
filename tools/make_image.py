#!/usr/bin/env python3
"""Generate a game image and turn it into a Roblox asset id, with no human step.

  python3 tools/make_image.py coin "shiny gold coin game icon"            # icon (cut-out PNG)
  python3 tools/make_image.py lobby_bg "sunny cartoon island" --kind art --size 1024x576

Pipeline: Pollinations (free Z-Image model; key added by the proxy) -> white
background removed for icons -> pushed to the public game-art repo -> Studio's
upload_image via the localhost image relay on Lenny's PC -> rbxassetid.
Needs: the bridge running (gateway + ngrok + image relay), the game-art repo
cloned at ../game-art with push access. Prints the asset id last.
Images are also kept in game-art/icons or game-art/art (a record of every asset).
"""
import argparse
import json
import os
import subprocess
import sys
import urllib.parse
import urllib.request

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import export_studio as E  # noqa: E402  (MCP bridge client)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART = os.environ.get("GAME_ART_DIR", os.path.join(os.path.dirname(ROOT), "game-art"))
STYLE = ("bright cartoon roblox simulator style, bold shapes, thick dark outline, glossy highlights, "
         "saturated colours, no text, no letters, no watermark")
# --style ps2: this game's look (Beat the Ghost): PlayStation 2 era survival horror
# (no "PlayStation" / "console" / "video game" words in it: the model then draws controllers and logos)
STYLE_PS2 = ("early 2000s survival horror style, low-poly 3D render, chunky polygons, "
             "low resolution pixelated textures, gritty muted colours with one strong accent colour, hard dramatic "
             "lighting, slightly grainy, no text, no letters, no numbers, no watermark, no logos")
STYLES = {"cartoon": STYLE, "ps2": STYLE_PS2}


def generate(prompt, w, h, seed, kind, style="cartoon"):
    st = STYLES[style]
    if kind == "icon":
        prompt = f"single {prompt}, game icon, {st}, centered, isolated on a flat solid pure white background, no shadow"
    else:
        prompt = f"{prompt}, {st}"
    url = (f"https://gen.pollinations.ai/image/{urllib.parse.quote(prompt)}"
           f"?model=z-image&width={w}&height={h}&seed={seed}")
    with urllib.request.urlopen(url, timeout=240) as r:
        data = r.read()
    if data[:1] == b"{":
        sys.exit("Pollinations error: " + data[:300].decode("utf-8", "replace"))
    from io import BytesIO
    return Image.open(BytesIO(data)).convert("RGB")


def cut_white(im):
    import cv2
    a = np.array(im)
    light = (a.min(axis=2) >= 225).astype(np.uint8)
    _, lab = cv2.connectedComponents(light, connectivity=4)
    border = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
    alpha = np.where(np.isin(lab, list(border)), 0, 255).astype(np.uint8)
    alpha = cv2.GaussianBlur(alpha, (3, 3), 0.8)
    ys, xs = np.where(alpha > 10)
    if len(ys) == 0:
        sys.exit("Cut-out failed: the whole image looked like background.")
    rgba = np.dstack([a, alpha])
    p = 6
    rgba = rgba[max(ys.min() - p, 0):ys.max() + p, max(xs.min() - p, 0):xs.max() + p]
    return Image.fromarray(rgba, "RGBA")


def git(*args):
    return subprocess.run(["git", "-C", ART, *args], check=True, capture_output=True, text=True).stdout.strip()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("name", help="file name, e.g. coin (letters, digits, _ -)")
    ap.add_argument("prompt")
    ap.add_argument("--kind", choices=["icon", "art"], default="icon")
    ap.add_argument("--size", default="512x512")
    ap.add_argument("--seed", type=int, default=7)
    ap.add_argument("--no-upload", action="store_true", help="only generate + save locally (to look at it first)")
    ap.add_argument("--style", choices=sorted(STYLES), default="cartoon", help="ps2 = this game's PS2 horror look")
    ap.add_argument("--upload-only", action="store_true", help="skip generating: push + upload the PNG already saved under this name")
    a = ap.parse_args()
    w, h = (int(x) for x in a.size.lower().split("x"))
    if not os.path.isdir(os.path.join(ART, ".git")):
        sys.exit(f"game-art repo not found at {ART} (attach lennygihub/game-art with push access and clone it there).")

    folder = "icons" if a.kind == "icon" else "art"
    rel = f"{folder}/{a.name}.png"
    if not a.upload_only:
        im = generate(a.prompt, w, h, a.seed, a.kind, a.style)
        out = cut_white(im) if a.kind == "icon" else im
        if a.kind == "icon":
            out.thumbnail((512, 512), Image.LANCZOS)
        os.makedirs(os.path.join(ART, folder), exist_ok=True)
        out.save(os.path.join(ART, rel), optimize=True)
        print("saved", os.path.join(ART, rel), out.size)
    if a.no_upload:
        return

    git("pull", "-q", "--rebase", "origin", "main")
    git("add", rel)
    if git("diff", "--cached", "--name-only"):
        git("commit", "-q", "-m", f"Add {rel}")
    git("push", "-q", "origin", "HEAD:main")
    sha = git("rev-parse", "HEAD")

    b = E.Bridge()
    studios, _ = E.open_studios(b)
    if not studios:
        sys.exit("No Studio connected to the bridge: image saved and pushed, not uploaded.")
    url = f"http://localhost:8770/{sha}/{rel}"
    res = json.loads(b.call("upload_image", {"studio_id": studios[0]["id"], "imagePaths": [url]}))
    asset = res.get(url, "")
    if not asset.startswith("rbxassetid://"):
        sys.exit(f"Upload failed: {asset} (is the 'Image relay' window running on the PC?)")
    print(asset)


if __name__ == "__main__":
    main()
