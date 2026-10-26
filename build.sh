#!/usr/bin/env bash
# Build every data/ file in dependency order, from the repo root:
#   ./build.sh            everything
#   ./build.sh cousubs    only the named scripts (code/<name>.R), in the order given
set -euo pipefail
cd "$(dirname "$0")"

scripts=(
  states
  counties
  places
  nationwide
  zip_xwalk
  cousubs
  places-cousubs
  gnis-populated-places
  gnis-places-cousubs
)

if [ "$#" -gt 0 ]; then
  scripts=("$@")
fi

for s in "${scripts[@]}"; do
  echo "== code/$s.R"
  Rscript "code/$s.R"
done
