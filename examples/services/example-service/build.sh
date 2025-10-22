#!/bin/bash
# Build script for example-service

set -e

MODE="${1:-dev}"
SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SERVICE_DIR"

echo "🏗️  Building example-service in $MODE mode..."

# Clean previous builds
rm -rf dist/ build/ *.egg-info
find . -name "*.c" -delete 2>/dev/null || true
find . -name "*.so" -delete 2>/dev/null || true

if [ "$MODE" = "cython" ]; then
    echo "✓ Building with Cython (source code will be hidden)"
    USE_CYTHON=1 uv build
    echo ""
    echo "📦 Verifying Cython compilation..."
    if compgen -G "dist/*.whl" > /dev/null; then
        echo "Contents of wheel:"
        unzip -l dist/*.whl | grep example_service
        echo ""
        if unzip -l dist/*.whl | grep -q "\.so"; then
            echo "✅ SUCCESS: Cython .so files found in wheel!"
        else
            echo "❌ WARNING: No .so files found. Cython compilation may have failed."
        fi
    fi
else
    echo "✓ Building in development mode (source code visible)"
    USE_CYTHON=0 uv build
fi

echo ""
echo "✓ Build complete! Wheel: dist/$(ls dist/ | head -1)"
