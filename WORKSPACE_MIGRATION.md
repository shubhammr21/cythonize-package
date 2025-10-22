# 🔄 Migrating Existing Monorepo to Cython-Protected Workspace

Guide for migrating your existing `fastapi-tracing-monorepo` to support Cython compilation for all services and packages.

## 🎯 Goal

Transform your existing monorepo:

**Before:**
- ❌ Source code visible in production
- ❌ No source code protection
- ❌ Business logic exposed

**After:**
- ✅ Each service Cython-compiled independently
- ✅ Each package Cython-compiled independently
- ✅ Source code hidden in `.so` binaries
- ✅ Business logic protected

## 📊 Current vs Target Structure

### Current Structure
```
fastapi-tracing-monorepo/
├── pyproject.toml              # Workspace config
├── uv.lock
├── services/
│   ├── service-a/
│   │   ├── pyproject.toml
│   │   └── service_a/
│   │       └── *.py            # ❌ Exposed source
│   └── ...
└── packages/
    └── telemetry/
        ├── pyproject.toml
        └── telemetry/
            └── *.py            # ❌ Exposed source
```

### Target Structure
```
fastapi-tracing-monorepo/
├── pyproject.toml
├── uv.lock
├── build-all.sh                # ✅ Build everything
├── clean-all.sh                # ✅ Clean artifacts
├── scripts/
│   ├── setup-template.py       # ✅ Cython template
│   ├── build-template.sh       # ✅ Build template
│   └── add-package.sh          # ✅ Add new packages
├── services/
│   ├── service-a/
│   │   ├── pyproject.toml      # ✅ Updated with build-system
│   │   ├── setup.py            # ✅ Cython config
│   │   ├── build.sh            # ✅ Build script
│   │   └── service_a/
│   │       ├── __init__.py     # Visible (entry point)
│   │       └── main.py         # ✅ → .so binary
│   └── ...
└── packages/
    └── telemetry/
        ├── pyproject.toml      # ✅ Updated
        ├── setup.py            # ✅ Cython config
        ├── build.sh            # ✅ Build script
        └── telemetry/
            ├── __init__.py     # Visible (entry point)
            └── tracer.py       # ✅ → .so binary
```

## 🚀 Migration Steps

### Step 1: Backup Your Project

```bash
# Create backup
cd /path/to/fastapi-tracing-monorepo
git checkout -b backup-before-cython
git push origin backup-before-cython

# Create working branch
git checkout -b feat/add-cython-protection
```

### Step 2: Update Root Configuration

**Update `pyproject.toml`:**

```toml
[project]
name = "fastapi-tracing-monorepo"
version = "1.0.0"
description = "FastAPI microservices with Cython protection"
requires-python = ">=3.11"

[tool.uv.workspace]
members = [
    "services/*",
    "packages/*",
]

[tool.uv]
dev-dependencies = [
    "pytest>=8.0.0",
    "pytest-asyncio>=0.24.0",
    "ruff>=0.8.0",
    "mypy>=1.13.0",
    "Cython>=3.0.0,<4.0.0",  # ✅ Add this
]
```

```bash
# Sync to install Cython
uv sync
```

### Step 3: Create Helper Scripts

Create `scripts/` directory:

```bash
mkdir -p scripts
```

**Copy from this template repo:**

```bash
# If you have access to this repo
cp /path/to/cythonize-package/scripts/setup-template.py scripts/
cp /path/to/cythonize-package/scripts/build-template.sh scripts/
cp /path/to/cythonize-package/scripts/add-package.sh scripts/

chmod +x scripts/*.sh
```

Or create manually (see `MONOREPO_SETUP.md` for content).

### Step 4: Create Root Build Scripts

**`build-all.sh`:**

```bash
#!/bin/bash
# Build all services and packages
set -e

MODE=${1:-dev}

echo "🏗️  Building all workspace packages..."

# Build packages first
for package in packages/*/; do
    if [ -f "$package/build.sh" ]; then
        (cd "$package" && ./build.sh "$MODE")
    fi
done

# Build services
for service in services/*/; do
    if [ -f "$service/build.sh" ]; then
        (cd "$service" && ./build.sh "$MODE")
    fi
done
```

**`clean-all.sh`:**

```bash
#!/bin/bash
# Clean all build artifacts
for dir in packages/*/ services/*/; do
    if [ -d "$dir" ]; then
        rm -rf "$dir/dist" "$dir/build" "$dir"/*.egg-info
        find "$dir" -name "*.c" -delete 2>/dev/null || true
        find "$dir" -name "*.so" -delete 2>/dev/null || true
    fi
done
```

```bash
chmod +x build-all.sh clean-all.sh
```

### Step 5: Migrate Telemetry Package

**1. Update `packages/telemetry/pyproject.toml`:**

```toml
[build-system]
requires = ["setuptools>=75.0.0", "Cython>=3.0.0,<4.0.0"]
build-backend = "setuptools.build_meta"

[project]
name = "telemetry"
version = "1.0.0"
description = "Telemetry package with Cython protection"
requires-python = ">=3.11"

dependencies = [
    "opentelemetry-api>=1.27.0",
    "opentelemetry-sdk>=1.27.0",
    "opentelemetry-instrumentation-fastapi>=0.48b0",
    "uptrace>=1.26.0",
]
```

**2. Create `packages/telemetry/setup.py`:**

```python
"""Cython configuration for telemetry package."""
import os
import sys
from pathlib import Path
from setuptools import setup, find_packages
from setuptools.command.build_py import build_py as _build_py

PACKAGE_NAME = "telemetry"
USE_CYTHON = os.environ.get("USE_CYTHON", "0") == "1"

# Customize: Which files to compile
INCLUDE_FILE_PATTERNS = [
    "telemetry.tracer",
    "telemetry.middleware",
    "telemetry.config",
    # Add more modules as needed
]

EXCLUDE_FILE_PATTERNS = [
    "telemetry.__init__",
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
                },
                build_dir="build",
            )
    except ImportError:
        print("⚠️  Cython not found")
        sys.exit(1)


class CustomBuildPy(_build_py):
    def run(self):
        super().run()

        if USE_CYTHON and ext_modules:
            for pattern in INCLUDE_FILE_PATTERNS:
                parts = pattern.split(".")
                if len(parts) == 2:
                    py_file = Path(self.build_lib) / parts[0] / f"{parts[1]}.py"
                    if py_file.exists():
                        py_file.unlink()


setup(
    name=PACKAGE_NAME,
    packages=find_packages(),
    ext_modules=ext_modules,
    cmdclass={"build_py": CustomBuildPy} if USE_CYTHON else {},
    zip_safe=False,
)
```

**3. Copy `build.sh` template:**

```bash
cp scripts/build-template.sh packages/telemetry/build.sh
chmod +x packages/telemetry/build.sh
```

**4. Test build:**

```bash
cd packages/telemetry

# Development build
./build.sh

# Production build with Cython
./build.sh cython

# Verify
unzip -l dist/*.whl | grep telemetry
# Should show .so files!
```

### Step 6: Migrate Service A

**1. Update `services/service-a/pyproject.toml`:**

```toml
[build-system]
requires = ["setuptools>=75.0.0", "Cython>=3.0.0,<4.0.0"]
build-backend = "setuptools.build_meta"

[project]
name = "service-a"
version = "1.0.0"
description = "Service A with Cython protection"
requires-python = ">=3.11"

dependencies = [
    "fastapi[standard]>=0.119.0",
    "uvicorn>=0.32.0",
    "telemetry",
]

[tool.uv.sources]
telemetry = { workspace = true }
```

**2. Create `services/service-a/setup.py`:**

```python
"""Cython configuration for service-a."""
import os
import sys
from pathlib import Path
from setuptools import setup, find_packages
from setuptools.command.build_py import build_py as _build_py

PACKAGE_NAME = "service_a"
USE_CYTHON = os.environ.get("USE_CYTHON", "0") == "1"

# Customize: Which files to compile
INCLUDE_FILE_PATTERNS = [
    "service_a.main",
    "service_a.handlers",
    "service_a.routes",
    # Add your modules
]

EXCLUDE_FILE_PATTERNS = [
    "service_a.__init__",
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
                },
                build_dir="build",
            )
    except ImportError:
        print("⚠️  Cython not found")
        sys.exit(1)


class CustomBuildPy(_build_py):
    def run(self):
        super().run()

        if USE_CYTHON and ext_modules:
            for pattern in INCLUDE_FILE_PATTERNS:
                parts = pattern.split(".")
                if len(parts) == 2:
                    py_file = Path(self.build_lib) / parts[0] / f"{parts[1]}.py"
                    if py_file.exists():
                        py_file.unlink()


setup(
    name=PACKAGE_NAME,
    packages=find_packages(),
    ext_modules=ext_modules,
    cmdclass={"build_py": CustomBuildPy} if USE_CYTHON else {},
    zip_safe=False,
)
```

**3. Copy `build.sh` template:**

```bash
cp scripts/build-template.sh services/service-a/build.sh
chmod +x services/service-a/build.sh
```

**4. Test build:**

```bash
cd services/service-a

# Build with Cython
./build.sh cython

# Verify - should show .so files
unzip -l dist/*.whl | grep service_a
```

### Step 7: Repeat for Other Services/Packages

Repeat Steps 5-6 for:
- `services/service-b`
- `services/service-c`
- Any other packages

Each needs:
- Updated `pyproject.toml` with `[build-system]`
- New `setup.py` with Cython config
- New `build.sh` script

### Step 8: Test Complete Build

```bash
# Return to root
cd /path/to/fastapi-tracing-monorepo

# Sync workspace
uv sync

# Build all in development mode
./build-all.sh

# Build all with Cython
./build-all.sh cython

# Verify all wheels
find . -name "*.whl" -type f
```

### Step 9: Test Runtime

```bash
# Install cythonized wheels
uv pip install packages/telemetry/dist/*.whl
uv pip install services/service-a/dist/*.whl

# Try to import
uv run python -c "from telemetry import setup_tracing; print('✓')"
uv run python -c "from service_a import app; print('✓')"

# Try to read source (should fail!)
uv run python << 'EOF'
import inspect
from service_a import main
try:
    source = inspect.getsource(main.root)
    print("❌ Source code is visible!")
except:
    print("✓ Source code is protected!")
EOF
```

### Step 10: Update Docker

Update your Dockerfiles to build with Cython:

**`services/service-a/Dockerfile`:**

```dockerfile
FROM python:3.11-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y gcc g++ make && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy workspace
COPY pyproject.toml uv.lock ./
COPY packages/ ./packages/
COPY services/service-a/ ./services/service-a/

# Build with Cython
RUN cd packages/telemetry && USE_CYTHON=1 uv build
RUN cd services/service-a && USE_CYTHON=1 uv build

# Runtime stage
FROM python:3.11-slim

WORKDIR /app

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Install built wheels
COPY --from=builder /app/packages/telemetry/dist/*.whl /tmp/
COPY --from=builder /app/services/service-a/dist/*.whl /tmp/

RUN uv pip install --system /tmp/*.whl && rm /tmp/*.whl

# Run service
CMD ["uvicorn", "service_a.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Step 11: Update CI/CD

Update your GitHub Actions or CI/CD pipeline:

**`.github/workflows/build.yml`:**

```yaml
name: Build and Test

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install uv
        run: curl -LsSf https://astral.sh/uv/install.sh | sh

      - name: Sync dependencies
        run: uv sync

      - name: Build all packages (Cython)
        run: ./build-all.sh cython

      - name: Test imports
        run: |
          uv pip install packages/*/dist/*.whl
          uv pip install services/*/dist/*.whl
          uv run python -c "from telemetry import setup_tracing"
          uv run python -c "from service_a import app"

      - name: Upload wheels
        uses: actions/upload-artifact@v4
        with:
          name: wheels
          path: |
            packages/*/dist/*.whl
            services/*/dist/*.whl
```

## ✅ Verification Checklist

After migration, verify:

- [ ] `uv sync` works without errors
- [ ] `./build-all.sh` builds all packages (dev mode)
- [ ] `./build-all.sh cython` builds with Cython
- [ ] All wheels contain `.so` files (not `.py`)
- [ ] Services can import and run
- [ ] `inspect.getsource()` fails on compiled modules
- [ ] Docker builds work
- [ ] CI/CD pipeline passes

## 🐛 Troubleshooting

### Issue: "Cython not found"

```bash
uv add --dev "Cython>=3.0.0,<4.0.0"
uv sync
```

### Issue: "Module not found" after Cython build

Check that `__init__.py` is NOT in `INCLUDE_FILE_PATTERNS` in `setup.py`.

### Issue: Wheel only contains `.py` files

Ensure `USE_CYTHON=1` is set:
```bash
USE_CYTHON=1 ./build.sh
# Or
./build.sh cython
```

### Issue: Compilation errors

Check that all files in `INCLUDE_FILE_PATTERNS` exist:
```bash
ls service_a/*.py
```

## 📚 Additional Resources

- `MONOREPO_SETUP.md` - Complete monorepo guide
- `WORKSPACE_GUIDE.md` - uv workspace reference
- Original single-package setup for comparison

## 🎉 Success

Your monorepo now has:
- ✅ Cython protection for all services
- ✅ Cython protection for all packages
- ✅ Source code hidden in production
- ✅ Automated build system
- ✅ Docker support

**Next:** Push your changes and deploy with confidence!

```bash
git add .
git commit -m "feat: add Cython protection to all workspace packages"
git push origin feat/add-cython-protection
```
