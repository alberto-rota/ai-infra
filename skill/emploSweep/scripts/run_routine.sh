#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: run_routine [--root DIR] \"<Company> - <Short Role>\"" >&2
  echo ""
  echo "Run the EmploSweep daily routine."
  echo ""
  echo "Performs these operations within opencode:"
  echo "1. Scaffold a new application folder with CV and cover-letter templates"
  echo "2. Compile the CV and cover letter PDFs"
  echo ""
  echo "Conventions (from ROUTINE.md):"
  echo "- Objective must be high-level and general — about the problem/challenge, never naming the company"
  echo "- No em-dashes in generated CV/cover letter/e-mail"
  echo "- Referrals: De Momi, Pomati and Busam listed as-is"
}

# Parse --root flag if present
root=""
if [[ "$1" == "--root" ]]; then
  root="$2"
  shift 2
fi

# If --root not provided, derive from working directory
if [ -z "$root" ]; then
  # Check if CWD has the project structure
  if [ -d "Alberto_Rota_CV_TEMPLATE" ] || [ -d "Applications" ]; then
    root="$(pwd)"
  else
    # Try to find EmploSweep directory from CWD
    current="$(pwd)"
    for _ in {1..10}; do
      bn="$(basename "$current")"
      if [ "$bn" = "EmploSweep" ] || [ "$bn" = "emploSweep" ]; then
        root="$current"
        break
      fi
      current="$(dirname "$current")"
      if [ "$current" = "/" ]; then
        break
      fi
    done
  fi
fi

if [ -z "$root" ]; then
  root="$(pwd)"
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -lt 1 ]] || [ -z "$1" ]; then
  echo "=== EmploSweep Routine Summary ==="
  echo "Project root: $root"
  echo "Applications directory: $root/Applications/"
  echo ""
  echo "Use 'opencode --skill empreSweep run_routine \"<Company> - <Role>\" [--root DIR]'"
  echo "  to scaffold a new application."
  echo ""
  echo "Conventions (from ROUTINE.md):"
  echo "- Objective must be high-level and general — about the problem/challenge, never naming the company"
  echo "- No em-dashes in generated CV/cover letter/e-mail"
  echo "- Referrals: De Momi, Pomati and Busam listed as-is"
  exit 0
fi

company_role="$1"

echo "=== EmploSweep Routine ==="
echo ""

# Step 1: Scaffold new application
echo "--- Step 1: Scaffold new application ---"
bash "$script_dir/new_application.sh" --root "$root" "$company_role"
echo ""

# Step 2: Compile CV and cover letter for the new application
echo "--- Step 2: Compile CV and cover letter ---"
app_dir="$root/Applications/$company_role"

# Compile CV
if [ -f "$app_dir/cv/main.tex" ]; then
  echo "Compiling CV..."
  bash "$script_dir/compile.sh" --root "$root" "$app_dir/cv/main.tex" "CV_Alberto_Rota.pdf"
fi

# Compile cover letter
if [ -f "$app_dir/coverletter/main.tex" ]; then
  echo "Compiling cover letter..."
  bash "$script_dir/compile.sh" --root "$root" "$app_dir/coverletter/main.tex" "CoverLetter_Alberto_Rota.pdf"
fi

echo ""
echo "=== Routine Complete ==="
echo "New application scaffolded: $company_role"
echo "CV and cover letter PDFs compiled."
echo "See ROUTINE.md for the full daily procedure."
echo "For the complete routine with Notion/Gmail integration,"
echo "configure the MCP connectors in .claude/settings.local.json"