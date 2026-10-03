#!/usr/bin/env bash
# Generates the installable tarball of Invasor, the core, in dist/
set -uo pipefail

cd "$(dirname "$0")"
here="$(pwd)"
mkdir -p "$here/dist"
python3 invasor/tools/pack_release.py --out "$here/dist"
exit $?
