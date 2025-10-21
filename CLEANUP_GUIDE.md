# Build Artifacts Cleanup Guide

## Problem Statement

After building with Cython, several artifacts are left behind in the source tree:

### Leftover Files

1. **`.c` files** - Cython-generated C source files (e.g., `app.c`, `models.c`, `service.c`)
2. **`.cpp` files** - Cython C++ files (if using C++ mode)
3. **`.egg-info/` directories** - Package metadata
4. **`build/` directory** - Build intermediate files
5. **`dist/` directory** - Distribution packages (wheels, tarballs)
6. **`__pycache__/` directories** - Python bytecode cache
7. **`.so`/`.pyd` files** - Compiled extensions in source (during dev)

## Solutions Implemented

### 1. Automatic Cleanup in build.sh

The `build.sh` script now automatically cleans up after each build:

```bash
./build.sh cython
```

**What it cleans:**

- ✅ Removes `.c` and `.cpp` files from `src/`
- ✅ Removes `.egg-info` directories
- ✅ Cleans before AND after build

### 2. Manual Cleanup Script

Use `clean.sh` for complete cleanup:

```bash
./clean.sh
```

**What it removes:**

- Build directories (`build/`, `dist/`, `.eggs/`)
- Egg-info directories (`*.egg-info/`)
- Cython generated files (`*.c`, `*.cpp`)
- Compiled extensions (`*.so`, `*.pyd`)
- Python cache (`__pycache__/`, `*.pyc`, `*.pyo`)
- Test cache (`.pytest_cache/`, `.coverage`, `htmlcov/`)
- Type check cache (`.mypy_cache/`)

### 3. .gitignore Protection

The `.gitignore` file prevents these artifacts from being committed:

```gitignore
# Cython generated files
*.c
*.cpp

# Build artifacts
build/
dist/
*.egg-info/

# Compiled extensions
*.so
*.pyd
```

## Why These Files Are Generated

### During Cython Build

1. **Cython compilation** (`*.py` → `*.c`)

   ```
   app.py → app.c
   ```

2. **C compilation** (`*.c` → `*.so`)

   ```
   app.c → app.cpython-311-darwin.so
   ```

3. **Setup metadata** (`.egg-info/`)

   ```
   Package metadata for setuptools
   ```

### Build Process Flow

```
Source Files (.py)
    ↓ [Cython]
C Files (.c)              ← Generated (temporary)
    ↓ [C Compiler]
Binary Extensions (.so)   ← Final (goes in wheel)
    ↓ [Packaging]
Wheel (.whl)              ← Distribution
```

## Best Practices

### 1. Clean Before Committing

```bash
# Before git commit
./clean.sh
git status
git add .
git commit
```

### 2. Clean Between Builds

```bash
# Switch between dev and prod builds
./clean.sh
./build.sh          # Development
./clean.sh
./build.sh cython   # Production
```

### 3. Keep Source Clean

The source directory should only contain:

```
src/cythonize_package/
├── __init__.py      ✅ Source
├── app.py           ✅ Source
├── models.py        ✅ Source
├── service.py       ✅ Source
└── py.typed         ✅ Type marker
```

**NOT:**

```
src/cythonize_package/
├── app.c            ❌ Build artifact
├── models.c         ❌ Build artifact
├── service.c        ❌ Build artifact
└── __pycache__/     ❌ Runtime cache
```

## Quick Reference

| Action       | Command             | What it cleans |
| ------------ | ------------------- | -------------- |
| Clean all    | `./clean.sh`        | Everything     |
| Build dev    | `./build.sh`        | Auto-cleanup   |
| Build prod   | `./build.sh cython` | Auto-cleanup   |
| Check status | `git status`        | See leftovers  |

## Verification

### Check for Leftover Artifacts

```bash
# Check for C files
find src/ -name "*.c" -o -name "*.cpp"

# Check for egg-info
find . -name "*.egg-info" -type d

# Check for compiled extensions in source
find src/ -name "*.so" -o -name "*.pyd"
```

### Expected Output (Clean)

```bash
# All commands should return nothing
```

## Why Cleanup Matters

### 1. **Source Control Hygiene**

- Prevents committing generated files
- Keeps repository clean
- Reduces repo size

### 2. **Build Reproducibility**

- Fresh builds from clean state
- No stale artifacts
- Consistent results

### 3. **Developer Experience**

- Clear what's source vs. generated
- Easy to spot problems
- Fast workspace navigation

### 4. **Security**

- C files can leak implementation details
- Clean builds ensure no mixed artifacts
- Clear audit trail

## Common Issues

### Issue: C files still present after build

**Solution:**

```bash
./clean.sh
./build.sh cython
```

### Issue: Git showing untracked C files

**Solution:**

```bash
# Already in .gitignore, but if they show up:
git clean -fdx  # WARNING: removes all untracked files
# Or safer:
./clean.sh
```

### Issue: Build fails with "file exists" error

**Solution:**

```bash
./clean.sh
rm -rf build/ dist/
./build.sh cython
```

## Automation

### Pre-commit Hook (Optional)

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Run cleanup before commit
./clean.sh
```

```bash
chmod +x .git/hooks/pre-commit
```

## Summary

✅ **Automatic cleanup** in build.sh
✅ **Manual cleanup** via clean.sh
✅ **Git protection** via .gitignore
✅ **Documentation** (this guide)

**Result:** Clean source tree, no leftover artifacts! 🎉
