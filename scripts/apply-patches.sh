#!/usr/bin/env bash
set -euo pipefail

MESA_DIR="$1"
PATCH_DIR="$2"

shopt -s nullglob
patches=("$PATCH_DIR"/*.patch)

if [ "${#patches[@]}" -eq 0 ]; then
  echo "No patches in $PATCH_DIR; building unpatched upstream."
  exit 0
fi

for p in "${patches[@]}"; do
  echo "==> Checking $p"
  git -C "$MESA_DIR" apply --check "$p"
  echo "==> Applying $p"
  git -C "$MESA_DIR" apply "$p"
done
