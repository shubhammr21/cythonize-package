#!/bin/bash
# Initialize a new monorepo with Cython support
# Usage: ./scripts/init-monorepo.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC2034
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║   Monorepo Initialization with Cython Support       ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Get project details
read -p "Monorepo name (e.g., 'my-microservices'): " PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
    echo "❌ Project name cannot be empty"
    exit 1
fi

PROJECT_DIR="${PROJECT_NAME}"

echo ""
echo -e "${BLUE}📁 Creating project structure...${NC}"

# Create directory structure
mkdir -p "$PROJECT_DIR"/{services,packages,scripts}

# 1. Create root pyproject.toml
cat > "$PROJECT_DIR/pyproject.toml" << 'EOF'
[project]
name = "PROJECT_NAME_PLACEHOLDER"
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
    "pytest-asyncio>=0.24.0",
    "httpx>=0.27.0",
    "ruff>=0.8.0",
    "mypy>=1.13.0",
    "Cython>=3.0.0,<4.0.0",
]
EOF

# Replace placeholder
sed -i.bak "s/PROJECT_NAME_PLACEHOLDER/${PROJECT_NAME}/g" "$PROJECT_DIR/pyproject.toml"
rm "$PROJECT_DIR/pyproject.toml.bak"

# 2. Create setup.py template
cat > "$PROJECT_DIR/scripts/setup-template.py" << 'EOF'
"""Cython build configuration template for workspace packages."""
import os
import sys
from pathlib import Path
from setuptools import setup, find_packages
from setuptools.command.build_py import build_py as _build_py

# Get package name from directory
PACKAGE_NAME = Path(__file__).parent.name.replace("-", "_")
USE_CYTHON = os.environ.get("USE_CYTHON", "0") == "1"

# Customize these patterns for your package
INCLUDE_FILE_PATTERNS = [
    f"{PACKAGE_NAME}.main",
    f"{PACKAGE_NAME}.handlers",
    f"{PACKAGE_NAME}.service",
    f"{PACKAGE_NAME}.models",
]

EXCLUDE_FILE_PATTERNS = [
    f"{PACKAGE_NAME}.__init__",
]

ext_modules = []

if USE_CYTHON:
    try:
        from Cython.Build import cythonize

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
            print(f"✓ Will compile {len(py_files)} files with Cython")
    except ImportError:
        print("⚠️  Cython not found. Install with: uv add --dev Cython")
        sys.exit(1)


class CustomBuildPy(_build_py):
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
EOF

# 3. Create build.sh template
cat > "$PROJECT_DIR/scripts/build-template.sh" << 'EOF'
#!/bin/bash
# Build script for workspace package
# Usage: ./build.sh [cython]

set -e

PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NAME="$(basename "$PACKAGE_DIR")"

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
    find . -name "*.c" -type f -delete 2>/dev/null || true
    find . -name "*.so" -type f ! -path "./dist/*" -delete 2>/dev/null || true
fi

echo -e "${GREEN}✅ Build complete!${NC}"
EOF

chmod +x "$PROJECT_DIR/scripts/build-template.sh"

# 4. Create build-all.sh
cat > "$PROJECT_DIR/build-all.sh" << 'EOF'
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
EOF

chmod +x "$PROJECT_DIR/build-all.sh"

# 5. Create clean-all.sh
cat > "$PROJECT_DIR/clean-all.sh" << 'EOF'
#!/bin/bash
# Clean all build artifacts
echo "🧹 Cleaning all workspace packages..."

for dir in packages/*/ services/*/; do
    if [ -d "$dir" ]; then
        echo "  → $(basename "$dir")"
        rm -rf "$dir/dist" "$dir/build" "$dir"/*.egg-info
        find "$dir" -name "*.c" -type f -delete 2>/dev/null || true
        find "$dir" -name "*.so" -type f -delete 2>/dev/null || true
        find "$dir" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
    fi
done

echo "✅ Cleanup complete!"
EOF

chmod +x "$PROJECT_DIR/clean-all.sh"

# 6. Create add-package.sh helper
cat > "$PROJECT_DIR/scripts/add-package.sh" << 'EOF'
#!/bin/bash
# Add a new package to the workspace
# Usage: ./scripts/add-package.sh <type> <name>
#   type: service or package
#   name: package name (e.g., service-a, telemetry)

set -e

TYPE=$1
NAME=$2

if [ -z "$TYPE" ] || [ -z "$NAME" ]; then
    echo "Usage: ./scripts/add-package.sh <service|package> <name>"
    exit 1
fi

if [ "$TYPE" != "service" ] && [ "$TYPE" != "package" ]; then
    echo "❌ Type must be 'service' or 'package'"
    exit 1
fi

DIR="${TYPE}s/${NAME}"
PACKAGE_NAME="${NAME//-/_}"

echo "Creating $TYPE: $NAME"
echo "Directory: $DIR"
echo "Package: $PACKAGE_NAME"
echo ""

# Create directory structure
mkdir -p "$DIR/$PACKAGE_NAME"

# Create pyproject.toml
cat > "$DIR/pyproject.toml" << TOML_EOF
[build-system]
requires = ["setuptools>=75.0.0", "Cython>=3.0.0,<4.0.0"]
build-backend = "setuptools.build_meta"

[project]
name = "${NAME}"
version = "1.0.0"
description = "${NAME} with Cython protection"
requires-python = ">=3.11"

dependencies = [
    "fastapi[standard]>=0.115.0",
    "uvicorn>=0.32.0",
]
TOML_EOF

# Create __init__.py
cat > "$DIR/$PACKAGE_NAME/__init__.py" << INIT_EOF
"""${NAME} package."""
__version__ = "1.0.0"
INIT_EOF

# Create main.py (for services)
if [ "$TYPE" == "service" ]; then
    cat > "$DIR/$PACKAGE_NAME/main.py" << MAIN_EOF
"""Main application for ${NAME}."""
from fastapi import FastAPI

app = FastAPI(title="${NAME}")

@app.get("/")
async def root():
    return {"service": "${NAME}", "status": "healthy"}
MAIN_EOF
fi

# Copy setup.py template
cp scripts/setup-template.py "$DIR/setup.py"

# Copy build.sh template
cp scripts/build-template.sh "$DIR/build.sh"
chmod +x "$DIR/build.sh"

echo "✅ Created $TYPE: $NAME"
echo ""
echo "Next steps:"
echo "  1. Edit $DIR/pyproject.toml (add dependencies)"
echo "  2. Edit $DIR/setup.py (customize INCLUDE_FILE_PATTERNS)"
echo "  3. Add your code to $DIR/$PACKAGE_NAME/"
echo "  4. Build: cd $DIR && ./build.sh cython"
EOF

chmod +x "$PROJECT_DIR/scripts/add-package.sh"

# 7. Create README
cat > "$PROJECT_DIR/README.md" << 'EOF'
# PROJECT_NAME_PLACEHOLDER

FastAPI microservices monorepo with Cython source code protection.

## Quick Start

```bash
# Install dependencies
uv sync

# Add a new service
./scripts/add-package.sh service my-service

# Add a shared package
./scripts/add-package.sh package my-package

# Build all (development mode)
./build-all.sh

# Build all (production with Cython)
./build-all.sh cython

# Clean all artifacts
./clean-all.sh
```

## Project Structure

```
.
├── services/           # Microservices
│   └── service-name/
│       ├── pyproject.toml
│       ├── setup.py
│       ├── build.sh
│       └── service_name/
│
├── packages/           # Shared packages
│   └── package-name/
│       ├── pyproject.toml
│       ├── setup.py
│       ├── build.sh
│       └── package_name/
│
└── scripts/            # Helper scripts
    ├── add-package.sh
    ├── setup-template.py
    └── build-template.sh
```

## Documentation

- See `MONOREPO_SETUP.md` for detailed setup guide
- See individual package README files for specific docs

## Commands

```bash
# Add new service
./scripts/add-package.sh service service-name

# Add new package
./scripts/add-package.sh package package-name

# Build all
./build-all.sh [dev|cython]

# Build specific package
cd services/service-name && ./build.sh [cython]

# Clean all
./clean-all.sh
```
EOF

# Replace placeholder in README
sed -i.bak "s/PROJECT_NAME_PLACEHOLDER/${PROJECT_NAME}/g" "$PROJECT_DIR/README.md"
rm "$PROJECT_DIR/README.md.bak"

# 8. Initialize git
cd "$PROJECT_DIR"
git init
echo "uv.lock" > .gitignore
echo "*.pyc" >> .gitignore
echo "__pycache__/" >> .gitignore
echo "*.egg-info/" >> .gitignore
echo "dist/" >> .gitignore
echo "build/" >> .gitignore
echo ".venv/" >> .gitignore

# 9. Initialize uv
uv sync

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Monorepo initialized successfully!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📁 Project created in: ${YELLOW}$PROJECT_DIR${NC}"
echo ""
echo -e "${BLUE}📚 Next steps:${NC}"
echo ""
echo "  1️⃣  Create your first service:"
echo "      ${YELLOW}cd $PROJECT_DIR${NC}"
echo "      ${YELLOW}./scripts/add-package.sh service my-service${NC}"
echo ""
echo "  2️⃣  Create a shared package:"
echo "      ${YELLOW}./scripts/add-package.sh package common${NC}"
echo ""
echo "  3️⃣  Build all packages:"
echo "      ${YELLOW}./build-all.sh${NC}"
echo ""
echo "  4️⃣  Build with Cython (production):"
echo "      ${YELLOW}./build-all.sh cython${NC}"
echo ""
echo -e "${GREEN}🎉 Happy coding!${NC}"
echo ""
