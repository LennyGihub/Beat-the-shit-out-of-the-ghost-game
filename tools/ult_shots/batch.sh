#!/bin/bash
# Several shots and one contact sheet (one image to read instead of many):
#   batch.sh <out dir> <sheet name> <cam> "<ult> <freezeAt> [dist] [mark]" ...
T=$(cd "$(dirname "$0")" && pwd); out=$1; name=$2; cam=$3; shift 3; files=(); mkdir -p "$out"
for spec in "$@"; do
	set -- $spec; f=$out/${cam}_$1_$2.png
	"$T/run.sh" "$1" "$2" "$f" "$cam" "${3:-16}" "${4:-cast}" | tail -1 | cut -c1-30 | grep -v Equipped
	files+=("$f")
done
python3 "$T/sheet.py" "$out/$name.png" "${files[@]}"
