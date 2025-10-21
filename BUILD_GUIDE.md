# Build Guide for Cythonized Package

## Summary

✅ **Successfully created a FastAPI service with Cython-protected source code using uv!**

## What Was Built

A complete Python package with:
- **FastAPI** web service with RESTful endpoints
- **Pydantic** models for data validation
- **Cython** compilation to hide source code
- **setuptools** build backend for Cython integration
- **uv** for fast dependency management

## Project Structure Decision

Based on `uv init --help`, we chose:

**`--lib` option**: Creates a library project with proper package structure

This was the best choice because:
1. It sets up a proper `src/` layout
2. Enables building distributable packages
3. Includes all necessary build configuration
4. Supports both development and production builds

## Key Files

### 1. `pyproject.toml`
- Defines project metadata and dependencies
- Uses `setuptools.build_meta` as build backend (required for Cython)
- Runtime deps: FastAPI, Pydantic, Uvicorn
- Build deps: setuptools, Cython

### 2. `setup.py`
- Configures which files to cythonize
- `INCLUDE_FILE_PATTERNS`: Files to compile (app.py, models.py, service.py)
- `EXCLUDE_FILE_PATTERNS`: Files to keep as Python (__init__.py)
- Custom install command to remove .py files from wheel
- Controlled by `USE_CYTHON=1` environment variable

### 3. Source Files
- `src/cythonize_package/__init__.py` - Package entry point (NOT cythonized)
- `src/cythonize_package/app.py` - FastAPI app (CYTHONIZED)
- `src/cythonize_package/models.py` - Pydantic models (CYTHONIZED)
- `src/cythonize_package/service.py` - Business logic (CYTHONIZED)

## Build Commands

### Development Build (with source code)

```bash
uv build
```

Output: `dist/cythonize_package-0.1.0-py3-none-any.whl`
- Contains `.py` source files
- Fast rebuild
- Easy debugging

### Production Build (Cythonized)

```bash
USE_CYTHON=1 uv build
```

Output: `dist/cythonize_package-0.1.0-cp311-cp311-macosx_11_0_arm64.whl`
- Contains `.so`/`.pyd` binary files
- No Python source code
- Protected from reverse engineering

## How Cythonization Works

1. **setup.py** reads `USE_CYTHON` environment variable
2. If enabled, Cython converts `.py` files to `.c` files
3. C compiler builds `.c` files into binary extensions (`.so` on Mac/Linux, `.pyd` on Windows)
4. Custom install command removes original `.py` files from wheel
5. Result: Only compiled binaries are distributed

## Installation

### Install Development Build

```bash
pip install dist/cythonize_package-0.1.0-py3-none-any.whl
```

### Install Production Build

```bash
pip install dist/cythonize_package-0.1.0-cp311-cp311-macosx_11_0_arm64.whl
```

## Verification

### 1. Check Wheel Contents

```bash
unzip -l dist/cythonize_package-0.1.0-cp311-cp311-macosx_11_0_arm64.whl
```

You should see:
- `__init__.py` ✅ (readable Python)
- `app.cpython-311-darwin.so` ✅ (binary)
- `models.cpython-311-darwin.so` ✅ (binary)
- `service.cpython-311-darwin.so` ✅ (binary)

NO `.py` files for app, models, or service!

### 2. Test Import

```bash
python -c "from cythonize_package import app; print('Success!')"
```

### 3. Run Tests

```bash
uv run python test_api.py
```

## Running the Service

### Development Mode

```bash
uv run python main.py
```

### Access Endpoints

- API: http://localhost:8000
- Docs: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## API Endpoints

```bash
# Root
GET /

# Create user
POST /users/
{
  "name": "John Doe",
  "email": "john@example.com",
  "age": 30
}

# Get user
GET /users/{user_id}

# List users
GET /users/
```

## Important Notes

### Build Backend Choice

We use **setuptools** instead of **uv_build** because:
- Cython integration requires setup.py hooks
- setuptools has mature Cython support
- uv_build is pure Python only (no extension modules yet)

### Dependencies Management

- Use `uv sync` to install dependencies
- Use `uv add <package>` to add new dependencies
- Dependencies are automatically included in wheel

### Platform-Specific Builds

The cythonized wheel is platform-specific:
- macOS ARM64: `cp311-cp311-macosx_11_0_arm64.whl`
- Linux x86_64: `cp311-cp311-linux_x86_64.whl`
- Windows: `cp311-cp311-win_amd64.whl`

Build on each platform for distribution.

## Troubleshooting

### C Compiler Not Found

Install build tools:
- macOS: `xcode-select --install`
- Linux: `apt-get install build-essential`
- Windows: Install Visual Studio Build Tools

### Import Errors

Ensure all dependencies are installed:
```bash
uv sync
```

### Build Failures

Clean and rebuild:
```bash
rm -rf dist/ build/ src/*.egg-info src/**/*.c
USE_CYTHON=1 uv build
```

## Next Steps

1. ✅ FastAPI service created
2. ✅ Cython compilation working
3. ✅ Source code protected
4. ✅ Dependencies managed
5. ✅ Tests passing

You can now:
- Add more endpoints to `app.py`
- Add more models to `models.py`
- Add business logic to `service.py`
- Build and distribute your protected package!
