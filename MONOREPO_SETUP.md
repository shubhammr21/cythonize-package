# 🏗️ Monorepo Setup with Cython Protection

Complete guide for setting up a **uv workspace monorepo** where **each service and package** can be Cython-compiled for source code protection.

## 🎯 Overview

This setup allows you to:

✅ Manage multiple services in a monorepo
✅ Share common packages across services
✅ Cythonize **each service/package independently**
✅ Hide source code in production builds
✅ Use a single lock file for consistency
✅ Maintain fast development workflow

## 📁 Project Structure

```
fastapi-tracing-monorepo/
├── pyproject.toml                    # Root workspace config
├── uv.lock                           # Shared lock file
├── setup-workspace.py                # Workspace-wide Cython setup
├── build-all.sh                      # Build all services/packages
├── clean-all.sh                      # Clean all artifacts
│
├── services/                         # Microservices
│   ├── service-a/
│   │   ├── pyproject.toml           # Service config
│   │   ├── setup.py                 # Cython config
│   │   ├── build.sh                 # Build script
│   │   └── service_a/               # Source code (gets Cythonized)
│   │       ├── __init__.py          # NOT compiled
│   │       ├── main.py              # COMPILED ✓
│   │       └── handlers.py          # COMPILED ✓
│   │
│   ├── service-b/
│   │   ├── pyproject.toml
│   │   ├── setup.py
│   │   ├── build.sh
│   │   └── service_b/
│   │       └── ...
│   │
│   └── service-c/
│       └── ...
│
├── packages/                         # Shared packages
│   ├── telemetry/
│   │   ├── pyproject.toml
│   │   ├── setup.py
│   │   ├── build.sh
│   │   └── telemetry/               # Source code (gets Cythonized)
│   │       ├── __init__.py          # NOT compiled
│   │       ├── tracer.py            # COMPILED ✓
│   │       └── middleware.py        # COMPILED ✓
│   │
│   └── common/
│       ├── pyproject.toml
│       ├── setup.py
│       ├── build.sh
│       └── common/
│           └── ...
│
└── scripts/                          # Shared build scripts
    ├── cython-template.py            # Template setup.py for Cython
    ├── build-template.sh             # Template build script
    └── init-package.sh               # Initialize new package
```

## 🚀 Key Concepts

### 1. Workspace Configuration

**Root `pyproject.toml`:**
```toml
[tool.uv.workspace]
members = [
    "services/*",
    "packages/*",
]
```

This tells uv to treat all subdirectories as workspace members.

### 2. Per-Package Cython Setup

Each service/package has its own:
- `setup.py` - Defines which files to compile
- `build.sh` - Build script (dev/prod modes)
- `pyproject.toml` - Package metadata

### 3. Workspace Dependencies

Packages reference each other:

**Service A's `pyproject.toml`:**
```toml
dependencies = [
    "fastapi>=0.115.0",
    "telemetry",           # Workspace package
    "common",              # Workspace package
]

[tool.uv.sources]
telemetry = { workspace = true }
common = { workspace = true }
```

### 4. Build Modes

**Development:** Fast, source code visible
```bash
./services/service-a/build.sh
```

**Production:** Cythonized, source code hidden
```bash
USE_CYTHON=1 ./services/service-a/build.sh
```

## 📝 Step-by-Step Setup

### Step 1: Initialize Workspace Root

Create root `pyproject.toml`:

```toml
[project]
name = "fastapi-tracing-monorepo"
version = "1.0.0"
description = "FastAPI microservices monorepo with Cython protection"
requires-python = ">=3.11"

[tool.uv.workspace]
members = [
    "services/*",
    "packages/*",
]

[tool.uv]
dev-dependencies = [
    "pytest>=8.0.0",
    "ruff>=0.8.0",
    "mypy>=1.13.0",
]
```

### Step 2: Create Package Template

**Template `setup.py`** for any service/package:

```python
"""Cython build configuration for workspace package."""
import os
import sys
from pathlib import Path
from setuptools import setup, find_packages
from setuptools.command.build_py import build_py

# Get package name from directory
PACKAGE_NAME = Path(__file__).parent.name.replace("-", "_")
USE_CYTHON = os.environ.get("USE_CYTHON", "0") == "1"

# Files to compile (customize per package)
INCLUDE_FILE_PATTERNS = [
    f"{PACKAGE_NAME}.main",
    f"{PACKAGE_NAME}.handlers",
    f"{PACKAGE_NAME}.service",
    f"{PACKAGE_NAME}.models",
    # Add more as needed
]

EXCLUDE_FILE_PATTERNS = [
    f"{PACKAGE_NAME}.__init__",
]

ext_modules = []

if USE_CYTHON:
    try:
        from Cython.Build import cythonize
        from Cython.Distutils.build_ext import new_build_ext as build_ext

        # Find all .py files to compile
        py_files = []
        package_dir = Path(__file__).parent / PACKAGE_NAME

        for pattern in INCLUDE_FILE_PATTERNS:
            module_parts = pattern.split(".")
            if len(module_parts) == 2:
                file_path = package_dir / f"{module_parts[1]}.py"
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
        print("⚠️  Cython not found. Install with: uv add --dev Cython")
        sys.exit(1)


class CustomBuildPy(build_py):
    """Custom build to remove .py files after Cython compilation."""

    def run(self):
        super().run()

        if USE_CYTHON and ext_modules:
            print(f"🧹 Removing source .py files from {PACKAGE_NAME}...")

            for pattern in INCLUDE_FILE_PATTERNS:
                parts = pattern.split(".")
                if len(parts) == 2:
                    py_file = Path(self.build_lib) / parts[0] / f"{parts[1]}.py"
                    if py_file.exists():
                        py_file.unlink()
                        print(f"   Removed: {py_file}")


setup(
    name=PACKAGE_NAME,
    packages=find_packages(),
    ext_modules=ext_modules,
    cmdclass={"build_py": CustomBuildPy} if USE_CYTHON else {},
    zip_safe=False,
)
```

**Template `build.sh`:**

```bash
#!/bin/bash
# Build script for workspace package
# Usage: ./build.sh [cython]

set -e

PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NAME="$(basename "$PACKAGE_DIR")"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔨 Building ${PACKAGE_NAME}${NC}"

# Check for cython mode
if [ "$1" == "cython" ] || [ "$USE_CYTHON" == "1" ]; then
    echo -e "${YELLOW}⚙️  Cython mode enabled${NC}"
    export USE_CYTHON=1
else
    echo -e "${YELLOW}⚙️  Development mode (no Cython)${NC}"
    export USE_CYTHON=0
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$PACKAGE_DIR/dist" "$PACKAGE_DIR/build" "$PACKAGE_DIR"/*.egg-info

# Build package
cd "$PACKAGE_DIR"
echo "📦 Building wheel..."
uv build

# Show result
if [ "$USE_CYTHON" == "1" ]; then
    WHEEL=$(find dist/ -name "*.whl" ! -name "*py3-none-any.whl" | head -1)
    echo -e "${GREEN}✓ Cythonized build complete!${NC}"
else
    WHEEL=$(find dist/ -name "*py3-none-any.whl" | head -1)
    echo -e "${GREEN}✓ Development build complete!${NC}"
fi

if [ -n "$WHEEL" ]; then
    echo "📦 Wheel: $WHEEL ($(du -h "$WHEEL" | cut -f1))"
fi

# Clean intermediate files
if [ "$USE_CYTHON" == "1" ]; then
    echo "🧹 Cleaning intermediate files..."
    find . -name "*.c" -type f -delete
    find . -name "*.so" -type f ! -path "./dist/*" -delete
fi

echo -e "${GREEN}✅ Build complete!${NC}"
```

### Step 3: Create Service Example

**services/service-a/pyproject.toml:**

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
    "fastapi[standard]>=0.115.0",
    "uvicorn>=0.32.0",
    "telemetry",
    "common",
]

[tool.uv.sources]
telemetry = { workspace = true }
common = { workspace = true }
```

**services/service-a/service_a/**init**.py** (NOT compiled):

```python
"""Service A - FastAPI microservice."""
__version__ = "1.0.0"

from .main import app

__all__ = ["app"]
```

**services/service-a/service_a/main.py** (WILL be compiled):

```python
"""Main FastAPI application for Service A."""
from fastapi import FastAPI
from telemetry import setup_tracing

app = FastAPI(title="Service A")

@app.on_event("startup")
async def startup():
    setup_tracing("service-a", "1.0.0")

@app.get("/")
async def root():
    return {"service": "service-a", "status": "healthy"}

@app.get("/api/data")
async def get_data():
    # This business logic will be hidden in .so file
    result = perform_secret_calculation()
    return {"data": result}

def perform_secret_calculation():
    """Secret business logic - will be compiled to binary."""
    # Your proprietary algorithm here
    return {"secret": "value"}
```

**services/service-a/setup.py:**

```python
"""Cython configuration for service-a."""
# Copy the template setup.py here
# Customize INCLUDE_FILE_PATTERNS for your service files
```

**services/service-a/build.sh:**

```bash
#!/bin/bash
# Copy the template build.sh here
chmod +x build.sh
```

### Step 4: Create Shared Package Example

**packages/telemetry/pyproject.toml:**

```toml
[build-system]
requires = ["setuptools>=75.0.0", "Cython>=3.0.0,<4.0.0"]
build-backend = "setuptools.build_meta"

[project]
name = "telemetry"
version = "1.0.0"
description = "Shared telemetry package with Cython protection"
requires-python = ">=3.11"

dependencies = [
    "opentelemetry-api>=1.27.0",
    "opentelemetry-sdk>=1.27.0",
    "uptrace>=1.26.0",
]
```

**packages/telemetry/telemetry/**init**.py** (NOT compiled):

```python
"""Telemetry package."""
__version__ = "1.0.0"

from .tracer import setup_tracing, get_tracer

__all__ = ["setup_tracing", "get_tracer"]
```

**packages/telemetry/telemetry/tracer.py** (WILL be compiled):

```python
"""Tracing setup - will be compiled to binary."""
from opentelemetry import trace
import uptrace

def setup_tracing(service_name: str, service_version: str):
    """Configure tracing - this logic will be hidden."""
    # Your proprietary tracing setup
    uptrace.configure_opentelemetry(
        dsn="your-secret-dsn",
        service_name=service_name,
        service_version=service_version,
    )

def get_tracer(name: str):
    """Get tracer instance."""
    return trace.get_tracer(name)
```

### Step 5: Root Build Scripts

**build-all.sh** (build everything):

```bash
#!/bin/bash
# Build all services and packages
set -e

MODE=${1:-dev}

echo "🏗️  Building all workspace packages..."
echo "Mode: $MODE"
echo ""

# Build packages first (dependencies)
echo "📦 Building packages..."
for package in packages/*/; do
    if [ -f "$package/build.sh" ]; then
        echo "  → $(basename "$package")"
        (cd "$package" && ./build.sh "$MODE")
    fi
done

echo ""
echo "🚀 Building services..."
for service in services/*/; do
    if [ -f "$service/build.sh" ]; then
        echo "  → $(basename "$service")"
        (cd "$service" && ./build.sh "$MODE")
    fi
done

echo ""
echo "✅ All builds complete!"
```

**clean-all.sh** (clean everything):

```bash
#!/bin/bash
# Clean all build artifacts
echo "🧹 Cleaning all workspace packages..."

for dir in packages/*/ services/*/; do
    if [ -d "$dir" ]; then
        echo "  → $(basename "$dir")"
        rm -rf "$dir/dist" "$dir/build" "$dir"/*.egg-info
        find "$dir" -name "*.c" -type f -delete
        find "$dir" -name "*.so" -type f -delete
        find "$dir" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
    fi
done

echo "✅ Cleanup complete!"
```

### Step 6: Initialize Workspace

```bash
# 1. Sync all dependencies
uv sync

# 2. Install Cython in dev dependencies
uv add --dev "Cython>=3.0.0,<4.0.0"

# 3. Make build scripts executable
chmod +x build-all.sh clean-all.sh
find services -name "build.sh" -exec chmod +x {} \;
find packages -name "build.sh" -exec chmod +x {} \;

# 4. Build all packages (development mode)
./build-all.sh

# 5. Verify imports
uv run python -c "from telemetry import setup_tracing; print('✓ Telemetry works')"
uv run python -c "from service_a import app; print('✓ Service A works')"
```

## 🔧 Usage

### Development Workflow

```bash
# 1. Sync dependencies
uv sync

# 2. Make changes to any service/package
vim packages/telemetry/telemetry/tracer.py

# 3. Build in development mode (fast, with source)
cd packages/telemetry
./build.sh

# 4. Changes are immediately available!
cd ../../services/service-a
uv run uvicorn service_a.main:app --reload
```

### Production Build Workflow

```bash
# Build all packages with Cython
./build-all.sh cython

# Or build individual package
cd services/service-a
USE_CYTHON=1 ./build.sh

# Install production build
uv pip install dist/*.whl

# Run service (source code is now hidden)
uv run uvicorn service_a.main:app
```

### Building Specific Packages

```bash
# Build only telemetry package
cd packages/telemetry
./build.sh cython

# Build only service-a
cd services/service-a
./build.sh cython

# Build packages in specific order (if needed)
./packages/common/build.sh cython
./packages/telemetry/build.sh cython
./services/service-a/build.sh cython
```

## 🎯 What Gets Cythonized?

### ✅ Compiled (Hidden in .so files)

- `service_a/main.py` - Application logic
- `service_a/handlers.py` - Request handlers
- `service_a/service.py` - Business logic
- `telemetry/tracer.py` - Tracing implementation
- `telemetry/middleware.py` - Middleware logic

### ❌ Not Compiled (Visible .py files)

- `service_a/__init__.py` - Package entry points
- `telemetry/__init__.py` - Package entry points
- Configuration files
- Test files

## 📊 Verification

### Check What's in the Wheel

```bash
# After production build
cd services/service-a
USE_CYTHON=1 ./build.sh

# List contents
unzip -l dist/*.whl | grep service_a

# Should show:
# service_a/__init__.py          ✓ (source)
# service_a/main.cpython*.so      ✓ (binary)
# service_a/handlers.cpython*.so  ✓ (binary)
# No .py files except __init__.py!
```

### Test Import

```bash
# Install production build
uv pip install services/service-a/dist/*.whl

# Test import
uv run python -c "from service_a import app; print('✓ Works')"

# Try to read source (should fail)
uv run python -c "import inspect; from service_a import main; print(inspect.getsource(main.root))"
# Error: could not get source code
```

## 🚀 Docker Deployment

**Dockerfile for Service A:**

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy workspace files
COPY pyproject.toml uv.lock ./
COPY packages/ ./packages/
COPY services/service-a/ ./services/service-a/

# Build with Cython
RUN cd packages/telemetry && USE_CYTHON=1 uv build
RUN cd services/service-a && USE_CYTHON=1 uv build

# Install built wheels
RUN uv pip install packages/telemetry/dist/*.whl
RUN uv pip install services/service-a/dist/*.whl

# Run service
CMD ["uvicorn", "service_a.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## 🎓 Benefits

### ✅ Source Code Protection
- Each service/package compiled independently
- Business logic hidden in binary files
- Proprietary algorithms protected

### ✅ Monorepo Advantages
- Single lock file for consistency
- Shared packages across services
- Fast dependency resolution
- Easy local development

### ✅ Flexible Builds
- Development mode: Fast iteration
- Production mode: Protected source
- Per-package control
- Independent versioning

## 📚 Next Steps

1. **Read:** `WORKSPACE_MIGRATION.md` - Migrate existing project
2. **Create:** Use template to add new services
3. **Automate:** Add to CI/CD pipeline
4. **Deploy:** Use Docker for production

---

**Ready to set up your monorepo?** See `scripts/init-monorepo.sh` for automated setup!
