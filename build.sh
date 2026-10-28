#!/usr/bin/env bash
# Build every data/ file in dependency order, from the repo root:
#   ./build.sh            everything
#   ./build.sh places     only the named scripts (code/<name>.R), in the order given
set -euo pipefail
cd "$(dirname "$0")"

scripts=(
  states
  counties
  blocks
  places
  nationwide
  zip_xwalk
  county-subdivisions
  places-county-subdivisions
  gnis-populated-places
  gnis-places-county-subdivisions
)

if [ "$#" -gt 0 ]; then
  scripts=("$@")
fi

for s in "${scripts[@]}"; do
  echo "== code/$s.R"
  Rscript "code/$s.R"
done
