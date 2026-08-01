# Installer assets

This directory contains scripts and assets used by
[constructor](https://github.com/conda/constructor) to build
standalone installers for napari-phasors.

## Adding an installer icon

To set a custom icon for the installer, place an `icon.png` file in
this directory. The build workflow will detect it automatically and
pass it to constructor via the `icon_image` field.

### Requirements

- **Format:** PNG (constructor expects PNG for `icon_image`).
- **Recommended size:** 256 × 256 pixels or larger.
- If you only have a Windows `.ico` file, convert it to PNG first
  (e.g. with ImageMagick: `magick icon.ico icon.png`).
  You may keep both files in this directory; only `icon.png` is
  referenced by the build.

### Windows shortcuts

The build workflow converts `icon.png` to `icon.ico` and ships both
files. The `post_install.bat` script uses the `.ico` for the desktop
and Start Menu shortcuts.

Windows shortcuts start `launch_napari_phasors.pyw` through the bundled
`pythonw.exe`, so launching the application does not open a console window.
The launcher also isolates the bundled Python environment and redirects
Numba's compiled-code cache to the writable per-user directory
`%LOCALAPPDATA%\napari-phasors\numba-cache`. This is required for all-user
installs under `C:\ProgramData`; otherwise Numba repeatedly attempts to write
inside the read-only installation and napari appears to hang at startup.
Startup errors are saved to
`%LOCALAPPDATA%\napari-phasors\last-launch.log`.
