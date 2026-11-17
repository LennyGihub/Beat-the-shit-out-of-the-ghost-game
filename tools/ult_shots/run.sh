#!/bin/bash
# Photograph one ultimate in a running Studio playtest (a match must be on: start.luau does that).
#   run.sh <ultId> <freezeAt> <out.png> [cam: fp|tp|close|far] [ghost distance] [mark: cast|act]
# The monster is held still in front of the player, the ultimate is cast, the effects' clock (UltKit) is frozen
# freezeAt seconds after the cast (mark = act: after the server's first effect) and a screenshot is taken.
# fp = the player's own view (hands), tp = a free camera placed where the room is widest.
# Every screenshot is ~0.7 MB through the tunnel (monthly cap on the free ngrok plan): shoot only what you will look at.
T=$(cd "$(dirname "$0")" && pwd); cd "$T/../.."
TMP=${ULT_TMP:-/tmp/ult_shots}; mkdir -p "$TMP"
sed -e "s/DIST/${5:-16}/" "$T/end_server.luau" > "$TMP/_end.luau"
python3 tools/studio.py luau Server "$TMP/_end.luau" >/dev/null
W=$(python3 -c "print(max(0.9, $2 + 0.7) + (0.5 if '${6:-cast}' == 'act' else 0))")
sed -e "s/ULTID/$1/" -e "s/FREEZE/$2/" -e "s/WAIT/$W/" -e "s/CAM/${4:-fp}/" -e "s/MARK/${6:-cast}/" "$T/cast.luau" > "$TMP/_cast.luau"
python3 tools/studio.py luau Client "$TMP/_cast.luau"
python3 tools/studio.py shot "$3" >/dev/null
