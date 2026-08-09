#!/bin/bash
# 渲染单个 HTML 为 1080x1440 PNG
# usage: bash scripts/render.sh <input.html> <output.png> [width] [height]
set -e
IN="$1"; OUT="$2"; W="${3:-1080}"; H="${4:-1440}"
[ -z "$IN" ] || [ -z "$OUT" ] && { echo "usage: render.sh <input.html> <output.png> [w] [h]"; exit 1; }
command -v playwright >/dev/null || { echo "缺少 playwright，先装: pip install playwright && playwright install chromium"; exit 1; }
CHANNEL="--channel chrome"
playwright screenshot $CHANNEL --viewport-size "$W,$H" --wait-for-timeout 3500 \
  "file://$(cd "$(dirname "$IN")" && pwd)/$(basename "$IN")" "$OUT" 2>/dev/null \
  || playwright screenshot --viewport-size "$W,$H" --wait-for-timeout 3500 \
     "file://$(cd "$(dirname "$IN")" && pwd)/$(basename "$IN")" "$OUT"
echo "→ $OUT"
