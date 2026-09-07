#!/bin/sh
# Aspect-fill a cover without distortion.
# Usage: coverfit.sh INPUT OUTPUT [WIDTH HEIGHT]
set -eu

if [ "$#" -lt 2 ] || [ "$#" -gt 4 ]; then
  echo "Usage: $0 INPUT OUTPUT [WIDTH HEIGHT]" >&2
  exit 64
fi

input=$1
output=$2
width=${3:-1264}
height=${4:-1680}

case "$width:$height" in
  *[!0-9:]*|:*|*:) echo "Width and height must be positive integers" >&2; exit 64 ;;
esac
[ "$width" -gt 0 ] && [ "$height" -gt 0 ] || exit 64
[ -f "$input" ] || { echo "Input image not found: $input" >&2; exit 66; }

if command -v magick >/dev/null 2>&1; then
  image_tool=magick
elif command -v convert >/dev/null 2>&1; then
  image_tool=convert
else
  echo "No compatible ImageMagick command found" >&2
  exit 69
fi

output_dir=${output%/*}
[ "$output_dir" = "$output" ] && output_dir=.
[ -d "$output_dir" ] || { echo "Output directory not found: $output_dir" >&2; exit 73; }

tmp="${output}.coverfit.$$"
trap 'rm -f "$tmp"' EXIT HUP INT TERM

"$image_tool" "$input" \
  -auto-orient \
  -filter Lanczos \
  -resize "${width}x${height}^" \
  -gravity center \
  -extent "${width}x${height}" \
  -strip \
  "png:$tmp"

mv "$tmp" "$output"
trap - EXIT HUP INT TERM
printf 'Rendered %sx%s cover: %s\n' "$width" "$height" "$output"
