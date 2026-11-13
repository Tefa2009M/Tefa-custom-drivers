# Tefa-custom-drivers

Custom Mesa Turnip (Freedreno Vulkan) driver builds for Adreno 722 (Snapdragon 7 Gen 4, vivo V60 / OriginOS), packaged for AdrenoTools and used with Eden Emulator.

Repository: https://github.com/Tefa2009M/Tefa-custom-drivers

## Build

1. Open https://github.com/Tefa2009M/Tefa-custom-drivers/actions
2. Select **Build Turnip (Adreno 722 / aarch64-android)** and click **Run workflow**.
3. Set `mesa_ref` (default `main`) and `api_level` (default `34`).
4. Download the `turnip-a722-<sha>` artifact.

## Release

```bash
git clone https://github.com/Tefa2009M/Tefa-custom-drivers.git
cd Tefa-custom-drivers
git tag v1
git push origin v1
```

The tag push builds and attaches the ZIP to https://github.com/Tefa2009M/Tefa-custom-drivers/releases

## Install

Import the ZIP in Eden's driver manager, or place `meta.json` and `vulkan.adreno.so` where your AdrenoTools loader expects them.

## Patches

`patches/*.patch` are applied in filename order against the Mesa checkout. A patch that fails `git apply --check` fails the build.
