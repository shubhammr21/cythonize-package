"""Cython configuration for example-service."""
# ruff: noqa: T201, PLR2004

import os
import sys
from pathlib import Path

from setuptools import find_packages, setup
from setuptools.command.build_py import build_py as _build_py

PACKAGE_NAME = "example_service"
USE_CYTHON = os.environ.get("USE_CYTHON", "0") == "1"

# Files to compile with Cython (business logic)
INCLUDE_FILE_PATTERNS = [
    "example_service.main",  # ✅ Compile: FastAPI app
    "example_service.handlers",  # ✅ Compile: Request handlers
    "example_service.routes",  # ✅ Compile: Route definitions
    "example_service.config",  # ✅ Compile: Configuration
]

# Files NOT to compile (entry points)
EXCLUDE_FILE_PATTERNS = [
    "example_service.__init__",  # ❌ Don't compile: Entry point
]

ext_modules = []

if USE_CYTHON:
    try:
        from Cython.Build import cythonize

        py_files = []
        package_dir = Path(__file__).parent / PACKAGE_NAME

        for pattern in INCLUDE_FILE_PATTERNS:
            parts = pattern.split(".")
            if len(parts) == 2:
                file_path = package_dir / f"{parts[1]}.py"
                if file_path.exists():
                    py_files.append(str(file_path))

        if py_files:
            ext_modules = cythonize(
                py_files,
                compiler_directives={
                    "language_level": "3",
                    "embedsignature": True,
                    "boundscheck": False,
                    "wraparound": False,
                },
                build_dir="build",
            )
            print(f"✓ Cythonizing {len(py_files)} files: {', '.join(py_files)}")
        else:
            print("⚠️  No files found to cythonize")
    except ImportError:
        print("⚠️  Cython not found. Install with: uv add --dev Cython")
        sys.exit(1)


class CustomBuildPy(_build_py):
    """Custom build command that removes .py files after Cython compilation."""

    def run(self):
        super().run()

        if USE_CYTHON and ext_modules:
            # Remove original .py files (keep only .so)
            for pattern in INCLUDE_FILE_PATTERNS:
                parts = pattern.split(".")
                if len(parts) == 2:
                    py_file = Path(self.build_lib) / parts[0] / f"{parts[1]}.py"
                    if py_file.exists():
                        py_file.unlink()
                        print(f"✓ Removed {py_file} (replaced with .so)")


setup(
    name=PACKAGE_NAME,
    packages=find_packages(),
    ext_modules=ext_modules,
    cmdclass={"build_py": CustomBuildPy} if USE_CYTHON else {},
    package_data={
        PACKAGE_NAME: ["py.typed"],
    },
    zip_safe=False,
)
