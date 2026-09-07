#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: newpaper.sh <target-dir> [\"Paper Title\"]"
  echo ""
  echo "Scaffold a new LaTeX paper project: main.tex, refs.bib, .gitignore, figures/."
}

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
  exit 0
fi

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="$1"
title="${2:-Untitled Paper}"

if [[ -e "$target/main.tex" ]]; then
  echo "newpaper: $target/main.tex already exists, refusing to overwrite"
  exit 2
fi

mkdir -p "$target/figures"
cp "$skill_dir/templates/main.tex" "$target/main.tex"
cp "$skill_dir/templates/refs.bib" "$target/refs.bib"
cp "$skill_dir/templates/gitignore" "$target/.gitignore"

sed_i() {
  if sed --version >/dev/null 2>&1; then
    sed -i "s|$1|$2|" "$3"
  else
    sed -i '' "s|$1|$2|" "$3"
  fi
}
sed_i "TITLE PLACEHOLDER" "$title" "$target/main.tex"

echo "Scaffolded paper in $target"
find "$target" -type f | sort | sed 's/^/  /'
