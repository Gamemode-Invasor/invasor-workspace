#!/usr/bin/env bash
# Generates the installable zip of every module repository next to the core:
# enters each folder here except "invasor" and, for each module folder inside it
# (the one with a module.json), runs the core's pack_module.py. Zips end up in dist/.
# Usage: build-modules.sh [module-or-repo ...]   (no arguments: all of them)
set -uo pipefail

cd "$(dirname "$0")"
here="$(pwd)"
out="$here/dist"
mkdir -p "$out"
failed=0
packed=0

for repo in */; do
  repo="${repo%/}"
  [[ "$repo" == "invasor" || "$repo" == "dist" ]] && continue
  for mod in "$repo"/*/; do
    mod="${mod%/}"
    [[ -f "$mod/module.json" ]] || continue
    name="$(basename "$mod")"
    if (( $# > 0 )); then
      want=0
      for arg in "$@"; do
        [[ "$arg" == "$name" || "$arg" == "$repo" ]] && want=1
      done
      (( want )) || continue
    fi
    packed=1
    echo "== $repo/$name"
    if ! (cd "$repo" && python3 ../invasor/tools/pack_module.py "$name" --out "$out"); then
      echo "!! $repo/$name: not packed" >&2
      failed=1
    fi
  done
done

if (( $# > 0 && ! packed )); then
  echo "!! no module matches: $*" >&2
  exit 1
fi

echo
ls -1 "$out"/*.zip 2>/dev/null || echo "(no zips)"
exit $failed
