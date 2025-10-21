#!/bin/bash
# Build script for cythonize-package

set -e  # Exit on error

echo "🏗️  Building cythonize-package..."
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf dist/ build/ src/*.egg-info src/**/*.c src/**/*.so

# Check if Cython build is requested
if [ "$1" == "cython" ] || [ "$1" == "prod" ]; then
    echo "🔒 Building with Cython (production mode)..."
    USE_CYTHON=1 uv build
    echo ""
    echo "✅ Cythonized build complete!"
    echo ""
    echo "📦 Wheel contents:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    unzip -l dist/*.whl | grep -E "(cythonize_package|Length)" | head -20
    echo ""
    echo "🔍 Looking for source files..."
    if unzip -l dist/*.whl | grep -q "\.py$" | grep -v "__init__"; then
        echo "⚠️  Warning: Found .py files in wheel (besides __init__.py)"
    else
        echo "✅ No .py source files found (source code is protected!)"
    fi
else
    echo "📝 Building in development mode (with source code)..."
    uv build
    echo ""
    echo "✅ Development build complete!"
    echo ""
    echo "📦 Wheel contents:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    unzip -l dist/*.whl | grep -E "(cythonize_package|Length)" | head -20
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Built files:"
ls -lh dist/
echo ""
echo "💡 Usage:"
echo "   Development: ./build.sh"
echo "   Production:  ./build.sh cython"
echo ""
echo "📥 To install:"
echo "   pip install dist/*.whl"
