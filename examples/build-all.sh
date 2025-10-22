#!/bin/bash
# Build all services and packages in the examples workspace

set -e

MODE="${1:-dev}"
EXAMPLES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$EXAMPLES_DIR"

echo "🏗️  Building all workspace packages in $MODE mode..."
echo ""

# Build packages first (dependencies for services)
echo "📦 Building packages..."
for package in packages/*/; do
    if [ -f "$package/build.sh" ]; then
        echo ""
        echo "→ Building $package"
        (cd "$package" && ./build.sh "$MODE")
    fi
done

echo ""
echo "🚀 Building services..."
for service in services/*/; do
    if [ -f "$service/build.sh" ]; then
        echo ""
        echo "→ Building $service"
        (cd "$service" && ./build.sh "$MODE")
    fi
done

echo ""
echo "✅ All packages built successfully!"
echo ""

if [ "$MODE" = "cython" ]; then
    echo "📊 Summary of Cython builds:"
    echo ""
    for package in packages/*/; do
        if compgen -G "$package/dist/*.whl" > /dev/null; then
            echo "📦 $package:"
            unzip -l "$package"/dist/*.whl 2>/dev/null | grep -E '\.(py|so)$' | head -5 || true
            echo ""
        fi
    done

    for service in services/*/; do
        if compgen -G "$service/dist/*.whl" > /dev/null; then
            echo "🚀 $service:"
            unzip -l "$service"/dist/*.whl 2>/dev/null | grep -E '\.(py|so)$' | head -5 || true
            echo ""
        fi
    done
fi

echo "Build artifacts:"
find . -name "*.whl" -type f
