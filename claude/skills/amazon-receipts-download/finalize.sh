#!/usr/bin/env bash
# Desktop に落ちた amazon_*.html を headless Chrome で PDF 化し、amazon_*.pdf を整合チェックして DEST へ移動する。
# usage: finalize.sh <DEST_DIR> [WORK_DIR]
set -u
DEST="$1"
WORK="${2:-$(mktemp -d)}"
DL="$HOME/Desktop"
CH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

mkdir -p "$WORK/html" "$DEST"
shopt -s nullglob

for f in "$DL"/amazon_*.html; do
  mv "$f" "$WORK/html/"
done

for f in "$WORK"/html/amazon_*.html; do
  base=$(basename "$f" .html)
  id=${base#amazon_*_}
  grep -q "$id" "$f" || echo "ID MISMATCH: $base"
  out="$DL/$base.pdf"
  # headless Chrome は PDF 書き出し後もプロセスが終わらないことがあるので、ファイル出現を待って kill する
  "$CH" --headless=new --disable-gpu --no-pdf-header-footer \
    --user-data-dir="$WORK/chrome-profile" --print-to-pdf="$out" "file://$f" >/dev/null 2>&1 &
  pid=$!
  for _ in $(seq 1 60); do [ -s "$out" ] && sleep 2 && break; sleep 1; done
  kill "$pid" 2>/dev/null
  pkill -f "user-data-dir=$WORK/chrome-profile" 2>/dev/null
  sleep 1
done

for f in "$DL"/amazon_*.pdf; do
  tail -c 32 "$f" | grep -aq '%%EOF' || echo "INCOMPLETE: $(basename "$f")"
done

mv -n "$DL"/amazon_*.pdf "$DEST"/
ls -la "$DEST"
echo "Desktop に残った amazon_*: $(ls "$DL" | grep -c '^amazon_')"
