#!/usr/bin/env bash
# Sets up the Invasor workspace: clones every repository listed in repos.conf next to this
# script (the ones already there are left alone) and checks the tools the build needs.
#
#   ./bootstrap.sh <base-url>          e.g. ./bootstrap.sh git@github.com:Gamemode-Invasor
#   INVASOR_GIT_BASE=<base-url> ./bootstrap.sh
#
# Each repository is cloned from <base-url>/<name>.git
set -uo pipefail

cd "$(dirname "$0")"
base="${1:-${INVASOR_GIT_BASE:-}}"
failed=0

while read -r repo _; do
  [[ -z "$repo" || "$repo" == \#* ]] && continue
  if [[ -d "$repo/.git" ]]; then
    echo "ok     $repo (already here)"
  elif [[ -z "$base" ]]; then
    echo "!!     $repo: missing, and no base URL given (see the header of this script)" >&2
    failed=1
  elif git clone --quiet "$base/$repo.git" "$repo"; then
    echo "clone  $repo"
  else
    echo "!!     $repo: clone failed" >&2
    failed=1
  fi
done < repos.conf

echo
for tool in git python3 node npm; do
  command -v "$tool" >/dev/null 2>&1 && echo "tool   $tool" || { echo "!!     $tool not found" >&2; failed=1; }
done

if [[ -d invasor/frontend && ! -d invasor/frontend/node_modules ]]; then
  echo
  echo "Next: (cd invasor/frontend && npm install), then ./build-core.sh and ./build-modules.sh"
fi
exit $failed
