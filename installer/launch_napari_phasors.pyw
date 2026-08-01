"""Start the bundled napari application without opening a console window."""

from __future__ import annotations

import ctypes
import os
import sys
import tempfile
import traceback
from datetime import datetime
from pathlib import Path


_LOG_STREAM = None


def _configure_environment() -> tuple[Path, Path]:
    """Configure the relocatable conda environment and writable caches."""
    prefix = Path(sys.executable).resolve().parent
    path_entries = (
        prefix,
        prefix / "Library" / "bin",
        prefix / "Scripts",
    )
    os.environ["PATH"] = os.pathsep.join(
        [*(str(path) for path in path_entries), os.environ.get("PATH", "")]
    )
    os.environ["CONDA_PREFIX"] = str(prefix)
    os.environ.pop("PYTHONHOME", None)
    os.environ.pop("PYTHONPATH", None)
    os.environ["PYTHONNOUSERSITE"] = "1"
    os.environ.setdefault("QT_API", "pyqt6")

    cache_parent = os.environ.get("LOCALAPPDATA") or tempfile.gettempdir()
    cache_root = Path(cache_parent) / "napari-phasors"
    numba_cache = cache_root / "numba-cache"
    numba_cache.mkdir(parents=True, exist_ok=True)
    os.environ.setdefault("NUMBA_CACHE_DIR", str(numba_cache))

    return prefix, cache_root


def _configure_logging(cache_root: Path) -> Path:
    """Give pythonw stdout/stderr and preserve startup diagnostics."""
    global _LOG_STREAM

    log_path = cache_root / "last-launch.log"
    if sys.stdout is None or sys.stderr is None:
        _LOG_STREAM = log_path.open(
            "w", encoding="utf-8", buffering=1, errors="replace"
        )
        if sys.stdout is None:
            sys.stdout = _LOG_STREAM
        if sys.stderr is None:
            sys.stderr = _LOG_STREAM
        print(f"napari-phasors launch: {datetime.now().isoformat()}")
    return log_path


def _show_startup_error(log_path: Path) -> None:
    """Record and display startup errors that pythonw would hide."""
    traceback.print_exc()
    message = (
        "napari-phasors could not start.\n\n"
        f"Details were written to:\n{log_path}"
    )
    try:
        ctypes.windll.user32.MessageBoxW(
            None, message, "napari-phasors", 0x10
        )
    except Exception:
        pass


def main() -> None:
    """Configure the environment and delegate to napari's CLI."""
    _, cache_root = _configure_environment()
    log_path = _configure_logging(cache_root)
    try:
        from napari.__main__ import main as napari_main

        napari_main()
    except Exception:
        _show_startup_error(log_path)
        raise


if __name__ == "__main__":
    main()
