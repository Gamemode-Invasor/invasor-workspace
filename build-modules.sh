#!/usr/bin/env bash
# Generates the installable zip of every module repository next to the core:
# enters each folder here except "invasor" and, for each module folder inside it
# (the one with a module.json), runs the core's pack_module.py. Zips end up in dist/.
set -uo pipefail

cd "$(dirname "$0")"
here="$(pwd)"
out="$here/dist"
mkdir -p "$out"
failed=0

for repo in */; do
  repo="${repo%/}"
  [[ "$repo" == "invasor" || "$repo" == "dist" ]] && continue
  for mod in "$repo"/*/; do
    mod="${mod%/}"
    [[ -f "$mod/module.json" ]] || continue
    name="$(basename "$mod")"
    echo "== $repo/$name"
    if ! (cd "$repo" && python3 ../invasor/tools/pack_module.py "$name" --out "$out"); then
      echo "!! $repo/$name: not packed" >&2
      failed=1
    fi
  done
done

echo
ls -1 "$out"/*.zip 2>/dev/null || echo "(no zips)"
exit $failed
