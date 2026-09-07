#!/bin/sh
# Read-only Kindle Colorsoft capability report.
set -u

outdir=/mnt/us/coverfit
report="$outdir/diagnostic.txt"
mkdir -p "$outdir" || exit 1
: >"$report" || exit 1

log() { printf '%s\n' "$*" >>"$report"; }
section() { log ""; log "== $* =="; }

log "Kindle Colorsoft CoverFit diagnostic"
log "Generated: $(date 2>/dev/null || echo unknown)"

section "System"
uname -a >>"$report" 2>&1 || true
for path in /etc/pretty_version.txt /etc/version.txt /etc/os-release; do
  if [ -r "$path" ]; then
    log "-- $path"
    sed -n '1,20p' "$path" >>"$report" 2>&1
  fi
done

section "Commands"
for command_name in sqlite3 lipc-get-prop lipc-set-prop fbink eips identify convert magick file find; do
  if command -v "$command_name" >/dev/null 2>&1; then
    log "$command_name: $(command -v "$command_name")"
  else
    log "$command_name: missing"
  fi
done

section "Content databases"
for database in /var/local/cc.db /var/local/appreg.db; do
  if [ -r "$database" ]; then
    ls -l "$database" >>"$report" 2>&1
  else
    log "$database: unavailable"
  fi
done

if command -v sqlite3 >/dev/null 2>&1 && [ -r /var/local/cc.db ]; then
  log "-- cc.db tables"
  sqlite3 -readonly /var/local/cc.db '.tables' >>"$report" 2>&1 || true
  log "-- Entries schema"
  sqlite3 -readonly /var/local/cc.db 'PRAGMA table_info(Entries);' >>"$report" 2>&1 || true
fi

section "Likely cover caches"
for root in /mnt/us/system/thumbnails /var/cache /mnt/us/.active_content_sandbox; do
  if [ -d "$root" ]; then
    log "-- $root"
    find "$root" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | sed -n '1,200p' >>"$report"
  fi
done

section "KOReader tools"
for candidate in /mnt/us/koreader/fbink /mnt/us/koreader/bin/fbink /mnt/us/koreader/luajit; do
  [ -e "$candidate" ] && ls -l "$candidate" >>"$report" 2>&1
done

log ""
log "No books, databases, firmware files, or services were changed."
echo "CoverFit report saved to $report"
