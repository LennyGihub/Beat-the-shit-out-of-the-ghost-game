#!/usr/bin/env python3
"""Batch of PS2-style shop pictures (tools/art/shop_images.txt).
  python3 tools/art/gen_shop_images.py gen [name ...] [--seed N]   # generate (no upload) into game-art/art
  python3 tools/art/gen_shop_images.py upload                      # push + upload every picture, write ids to shop_ids.json
  python3 tools/art/gen_shop_images.py module <ShopArt.luau>   # write the Shared/ShopArt module from shop_ids.json
Resumable: `gen` skips pictures that already exist (unless named), `upload` skips ids already in shop_ids.json."""
import json, os, subprocess, sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
ART = os.environ.get("GAME_ART_DIR", os.path.join(os.path.dirname(ROOT), "game-art"))
IDS = os.path.join(HERE, "shop_ids.json")
rows = [l.strip().split("|", 2) for l in open(os.path.join(HERE, "shop_images.txt")) if l.strip() and not l.startswith("#")]
args = sys.argv[1:]
seed = "7"
if "--seed" in args:
    i = args.index("--seed"); seed = args[i + 1]; del args[i:i + 2]
mode, names = args[0], set(args[1:])
if mode == "module":
    names = set()
ids = json.load(open(IDS)) if os.path.exists(IDS) else {}
for name, size, prompt in rows:
    path = os.path.join(ART, "art", name + ".png")
    if mode == "gen":
        if (names and name not in names) or (not names and os.path.exists(path)):
            continue
        r = subprocess.run([sys.executable, os.path.join(ROOT, "tools", "make_image.py"), name, prompt, "--kind", "art", "--size", size,
                            "--style", "ps2", "--no-upload", "--seed", seed], capture_output=True, text=True)
        print(name, "ok" if r.returncode == 0 else "FAILED " + (r.stderr or r.stdout)[-200:], flush=True)
    elif mode == "upload":
        if name in ids or not os.path.exists(path):
            continue
        r = subprocess.run([sys.executable, os.path.join(ROOT, "tools", "make_image.py"), name, prompt, "--kind", "art", "--upload-only"],
                           capture_output=True, text=True)
        last = (r.stdout.strip().splitlines() or [""])[-1]
        if last.startswith("rbxassetid://"):
            ids[name] = last
            json.dump(ids, open(IDS, "w"), indent=1, sort_keys=True)
            print(name, last, flush=True)
        else:
            print(name, "FAILED", (r.stderr or r.stdout)[-300:], flush=True)

if mode == "module":
    out = sys.argv[2]
    lines = ["--!strict", "-- Pictures of the lobby shop (PS2 style, made with tools/art/gen_shop_images.py): card key -> image asset.",
             "-- ult_<UltimateId>, map_<MapId>, cash1..4, pass_money2 / pass_glock / pass_admin. A missing key = no picture yet.",
             "local Art: { [string]: string } = {"]
    for name in sorted(ids):
        lines.append(f'\t{name[4:]} = "{ids[name]}",')
    lines += ["}", "return Art", ""]
    open(out, "w").write("\n".join(lines))
    print("wrote", out, len(ids), "pictures")
