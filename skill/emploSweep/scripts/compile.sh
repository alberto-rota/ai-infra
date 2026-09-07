#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: compile.sh <path/to/main.tex> [OutName.pdf]" >&2
  echo ""
  echo "Compile a LaTeX file with tectonic."
  echo "The optional second argument copies the resulting main.pdf up into the"
  echo "parent application folder under that name."
  echo ""
  echo "Convention: point to cv/main.tex or coverletter/main.tex in an application folder"
}

if [[ $# -lt 1 ]] || [ -z "$1" ]; then
  usage
  exit 2
fi

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
  exit 0
fi

# Parse --root flag if present at the beginning
root=""
if [[ "$1" == "--root" ]]; then
  root="$2"
  shift 2
fi

tex_file="$1"
out_name="${2:-}"

# If --root was not provided, derive from script location
if [ -z "$root" ]; then
  # Derive project root from script location
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  current="$script_dir"
  root=""

for _ in {1..20}; do
  bn="$(basename "$current")"
  if [ -d "$current/Alberto_Rota_CV_TEMPLATE" ] || [ -d "$current/Applications" ] || [ "$bn" = "EmploSweep" ] || [ "$bn" = "emploSweep" ]; then
    root="$current"
    break
  fi
  current="$(dirname "$current")"
  # Stop at filesystem root
  if [ "$current" = "/" ]; then
    break
  fi
done
fi

if [ -z "$root" ]; then
  root="$(pwd)"
fi

command -v tectonic >/dev/null 2>&1 || { echo "tectonic not found on PATH (brew install tectonic)" >&2; exit 1; }
[ -f "$tex_file" ] || { echo "no such file: $tex_file" >&2; exit 1; }

tex_dir="$(cd "$(dirname "$tex_file")" && pwd)"
tex_base="$(basename "$tex_file")"
tex_base="${tex_base%.*}"

cd "$tex_dir"
tectonic "$tex_base.tex"

pdf="$tex_dir/$tex_base.pdf"
[ -f "$pdf" ] || { echo "expected PDF not produced: $pdf" >&2; exit 1; }
echo "OK: $pdf"

if [ -n "$out_name" ]; then
  app_folder="$(dirname "$tex_dir")"
  cp -f "$pdf" "$app_folder/$out_name"
  echo "COPIED: $app_folder/$out_name"
fi