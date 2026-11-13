#!/usr/bin/env bash
set -euo pipefail

MESA_DIR="$1"
META_SRC="$2"
OUT_DIR="$3"
SHA="$4"
REPO_SLUG="Tefa2009M/Tefa-custom-drivers"

LIB_SRC="$(find "$MESA_DIR/build-android" -name 'libvulkan_freedreno.so' -type f | head -n1)"
[ -n "$LIB_SRC" ] || { echo "libvulkan_freedreno.so not found" >&2; exit 1; }

STAGE="$(mktemp -d)"
cp "$LIB_SRC" "$STAGE/vulkan.adreno.so"

patchelf --set-soname vulkan.adreno.so "$STAGE/vulkan.adreno.so"

STRIP_BIN="$(find "${ANDROID_NDK_HOME:-/nonexistent}" "${ANDROID_NDK_LATEST_HOME:-/nonexistent}" -name llvm-strip -type f 2>/dev/null | head -n1 || true)"
[ -n "$STRIP_BIN" ] || STRIP_BIN="$(find / -name llvm-strip -type f -path '*ndk*' 2>/dev/null | head -n1)"
[ -n "$STRIP_BIN" ] || { echo "llvm-strip not found" >&2; exit 1; }
"$STRIP_BIN" --strip-unneeded "$STAGE/vulkan.adreno.so"

MESA_VER="$(cat "$MESA_DIR/VERSION")"
jq --arg v "$MESA_VER-$SHA" '.driverVersion = $v' "$META_SRC" > "$STAGE/meta.json"

mkdir -p "$OUT_DIR"
ZIP="$OUT_DIR/turnip-a722-${MESA_VER}-${SHA}.zip"
(cd "$STAGE" && zip -9 "$ZIP" meta.json vulkan.adreno.so)

unzip -l "$ZIP"
echo "Built: $(basename "$ZIP")"
echo "Repo:  https://github.com/${REPO_SLUG}"
echo "Releases: https://github.com/${REPO_SLUG}/releases"
