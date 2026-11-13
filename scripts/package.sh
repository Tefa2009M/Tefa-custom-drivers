#!/usr/bin/env bash
set -euo pipefail

MESA_DIR="$1"
META_SRC="$2"
OUT_DIR="$3"
SHA="$4"
NDK_ROOT="${5:?NDK_ROOT (5th argument) is required}"
REPO_SLUG="Tefa2009M/Tefa-custom-drivers"

STRIP_BIN="$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip"
[ -x "$STRIP_BIN" ] || { echo "ERROR: llvm-strip not found at $STRIP_BIN" >&2; exit 1; }

LIB_SRC="$(find "$MESA_DIR/build-android" -type f \( -name 'libvulkan_freedreno.so' -o -name 'vulkan.freedreno.so' \) -print -quit)"
if [ -z "$LIB_SRC" ]; then
  echo "ERROR: Turnip library not found under $MESA_DIR/build-android. Candidate .so files:" >&2
  find "$MESA_DIR/build-android" -type f -name '*.so' -print >&2
  exit 1
fi
echo "==> Library: $LIB_SRC"

STAGE="$(mktemp -d)"
cp "$LIB_SRC" "$STAGE/vulkan.adreno.so"

patchelf --set-soname vulkan.adreno.so "$STAGE/vulkan.adreno.so"
"$STRIP_BIN" --strip-unneeded "$STAGE/vulkan.adreno.so"

MESA_VER="$(cat "$MESA_DIR/VERSION")"
jq --arg v "$MESA_VER-$SHA" '.driverVersion = $v' "$META_SRC" > "$STAGE/meta.json"

mkdir -p "$OUT_DIR"
ZIP="$OUT_DIR/turnip-a722-${MESA_VER}-${SHA}.zip"
rm -f "$ZIP"
(cd "$STAGE" && zip -9 "$ZIP" meta.json vulkan.adreno.so)

unzip -l "$ZIP"
echo "Built: $(basename "$ZIP")"
echo "Repo:  https://github.com/${REPO_SLUG}"
echo "Releases: https://github.com/${REPO_SLUG}/releases"
