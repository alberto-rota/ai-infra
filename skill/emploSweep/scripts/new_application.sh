#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: new_application.sh \"<Company> - <Short Role>\" [--root DIR]" >&2
  echo ""
  echo "Scaffold a new application folder by duplicating the CV and cover-letter templates."
  echo "Does NOT tailor content; that is done by editing the copied main.tex files afterward."
  echo ""
  echo "Creates: Applications/<FolderName>/cv/  (copy of Alberto_Rota_CV_TEMPLATE)"
  echo "          Applications/<FolderName>/coverletter/  (copy of Alberto_Rota_Cover_Letter_TEMPLATE)"
  echo ""
  echo "Conventions (from ROUTINE.md):"
  echo "- Objective must be high-level and general — about the problem/challenge, never naming the company"
  echo "- No em-dashes in generated CV/cover letter/e-mail"
  echo "- Referrals: De Momi, Pomati and Busam listed as-is; do not comment out or add/remove referees"
}

# Parse --root flag if present
root=""
if [[ "$1" == "--root" ]]; then
  root="$2"
  shift 2
fi

folder_name="$1"
if [ -z "$folder_name" ]; then
  usage
  exit 2
fi

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

app_dir="$root/Applications/$folder_name"
cv_src="$root/Alberto_Rota_CV_TEMPLATE"
cl_src="$root/Alberto_Rota_Cover_Letter_TEMPLATE"

for src in "$cv_src" "$cl_src"; do
  [ -d "$src" ] || { echo "missing template: $src" >&2; exit 1; }
done

if [ -d "$app_dir" ]; then
  echo "EXISTS: $app_dir (leaving as-is)"
  exit 0
fi

mkdir -p "$app_dir"

# Copy templates, then strip the nested .git, sample PDFs and build artifacts.
clean_copy() {
  local src="$1" dest="$2"
  cp -R "$src" "$dest"
  rm -rf "$dest/.git"
  find "$dest" -maxdepth 1 -name '*.pdf' -delete
  find "$dest" \( -name '*.aux' -o -name '*.log' -o -name '*.out' \
               -o -name '*.bbl' -o -name '*.blg' -o -name 'compile.log' \) -delete
}

clean_copy "$cv_src" "$app_dir/cv"
clean_copy "$cl_src" "$app_dir/coverletter"

echo "CREATED: $app_dir"