#!/usr/bin/env python3
"""sheet.py out.png a.png b.png ... : contact sheet, 3 columns, labelled with the file names"""
import sys, os
from PIL import Image, ImageDraw
out, files = sys.argv[1], sys.argv[2:]
W = 620
ims = []
for f in files:
    im = Image.open(f).convert("RGB")
    im = im.resize((W, int(im.height * W / im.width)))
    d = ImageDraw.Draw(im)
    label = os.path.basename(f)[:-4]
    d.rectangle([0, 0, 9 * len(label) + 10, 18], fill=(0, 0, 0))
    d.text((5, 3), label, fill=(255, 255, 0))
    ims.append(im)
cols = 3
rows = (len(ims) + cols - 1) // cols
H = ims[0].height
sheet = Image.new("RGB", (W * cols, H * rows))
for i, im in enumerate(ims):
    sheet.paste(im, ((i % cols) * W, (i // cols) * H))
sheet.save(out)
print("sheet", out, sheet.size)
