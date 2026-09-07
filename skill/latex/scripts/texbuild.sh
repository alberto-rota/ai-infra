#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: texbuild.sh <file.tex> [--outdir DIR] [extra tectonic args...]"
  echo ""
  echo "Compile a LaTeX file with Tectonic."
  echo "On success prints the PDF path and warning count."
  echo "On failure keeps the .log and prints a summarized error report."
}

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
  exit 0
fi

input="$1"
shift

if [[ ! -f "$input" ]]; then
  echo "texbuild: no such file: $input"
  exit 2
fi

outdir=""
pass_args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --outdir)
      [[ $# -ge 2 ]] || { echo "texbuild: --outdir needs a value"; exit 2; }
      outdir="$2"
      pass_args+=(--outdir "$2")
      shift 2
      ;;
    *)
      pass_args+=("$1")
      shift
      ;;
  esac
done

base=$(basename "${input%.*}")
srcdir=$(cd "$(dirname "$input")" && pwd)
logpath="$srcdir/$base.log"
[[ -n "$outdir" ]] && logpath="$outdir/$base.log"

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

rc=0
tectonic -p --keep-logs ${pass_args[@]+"${pass_args[@]}"} "$input" >"$tmp" 2>&1 || rc=$?

if [[ $rc -eq 0 ]]; then
  pdfdir="${outdir:-$srcdir}"
  warns=$(grep -ciE 'warning' "$tmp" || true)
  echo "BUILD OK: $pdfdir/$base.pdf ($warns warning lines)"
else
  echo "BUILD FAILED (tectonic exit $rc)"
  echo "--- errors ---"
  grep -nE '^!|^error:|Emergency stop|Fatal error' "$tmp" | head -20 || true
  if [[ -f "$logpath" && -s "$logpath" ]]; then
    echo "--- context from $logpath ---"
    grep -n -B1 -A4 '^!' "$logpath" | head -40 || true
  fi
fi

exit "$rc"
