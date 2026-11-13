#!/usr/bin/env bash
set -euo pipefail

MESA_DIR="$1"
NDK_ROOT="$2"
API="$3"

BIN="$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin"
CROSS="$MESA_DIR/android-aarch64.cross"

cat > "$CROSS" <<EOF
[binaries]
c = ['$BIN/aarch64-linux-android${API}-clang']
cpp = ['$BIN/aarch64-linux-android${API}-clang++']
ar = '$BIN/llvm-ar'
strip = '$BIN/llvm-strip'
ranlib = '$BIN/llvm-ranlib'
pkg-config = '/usr/bin/pkg-config'

[host_machine]
system = 'android'
cpu_family = 'aarch64'
cpu = 'armv9'
endian = 'little'

[built-in options]
c_args = ['-O3', '-march=armv9-a+i8mm+dotprod', '-ffunction-sections', '-fdata-sections', '-flto=thin', '-fno-semantic-interposition']
cpp_args = ['-O3', '-march=armv9-a+i8mm+dotprod', '-ffunction-sections', '-fdata-sections', '-flto=thin', '-fno-semantic-interposition']
c_link_args = ['-fuse-ld=lld', '-flto=thin', '-Wl,--gc-sections', '-Wl,-z,max-page-size=16384']
cpp_link_args = ['-fuse-ld=lld', '-flto=thin', '-Wl,--gc-sections', '-Wl,-z,max-page-size=16384']
EOF

cd "$MESA_DIR"

meson setup build-android \
  --cross-file "$CROSS" \
  -Dbuildtype=release \
  -Dplatforms=android \
  -Dplatform-sdk-version="$API" \
  -Dandroid-stub=true \
  -Dandroid-libbacktrace=disabled \
  -Dgallium-drivers= \
  -Dvulkan-drivers=freedreno \
  -Dfreedreno-kmds=kgsl \
  -Dvulkan-layers= \
  -Dglx=disabled \
  -Degl=disabled \
  -Dgbm=disabled \
  -Dopengl=false \
  -Dgles1=disabled \
  -Dgles2=disabled \
  -Dllvm=disabled \
  -Dxmlconfig=disabled \
  -Dvalgrind=disabled \
  -Dlibunwind=disabled \
  -Dlmsensors=disabled \
  -Dzstd=disabled \
  -Dwrap_mode=forcefallback \
  -Dstrip=false

ninja -C build-android -j"$(nproc)"
