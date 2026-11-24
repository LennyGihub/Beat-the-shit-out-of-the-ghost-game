#!/usr/bin/env python3
"""Export the text patterns Client/Translate saw during a Studio playtest into a CSV for Roblox's localization table.

Play the game in Studio for a while first (toasts, the objective line, the jars tutorial, the sellers), then:
    python3 tools/localization/export_patterns.py            # -> tools/localization/patterns.csv
Upload it in Creator Hub > the experience > Localization > (table) > Upload CSV; automatic translation then fills the
languages. Patterns already in the CSV are kept (the file grows across sessions).
"""
import csv, json, os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "patterns.csv")
STUDIO = os.path.join(HERE, "..", "studio.py")

script = 'return game:GetService("Players").LocalPlayer:GetAttribute("I18nPatterns") or "[]"'
res = subprocess.run([sys.executable, STUDIO, "luau", "Client", "-"], input=script, capture_output=True, text=True)
if res.returncode != 0:
    sys.exit("studio.py failed (is a playtest running?):\n" + res.stderr[-800:])
raw = res.stdout.strip()
start, end = raw.find("["), raw.rfind("]")
if start < 0 or end < start:
    sys.exit("no pattern list in the answer:\n" + raw[-800:])
patterns = json.loads(raw[start:end + 1])

have = {}
if os.path.exists(OUT):
    with open(OUT, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            have[row["Source"]] = row
added = 0
for p in patterns:
    if p and p not in have:
        have[p] = {"Key": "", "Context": "", "Example": "", "Source": p}
        added += 1
with open(OUT, "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=["Key", "Context", "Example", "Source"])
    w.writeheader()
    for p in sorted(have):
        w.writerow({k: have[p].get(k, "") for k in ["Key", "Context", "Example", "Source"]})
print(f"{added} new pattern(s), {len(have)} in {OUT}")
