#!/bin/bash
# Cleanup script for cythonize-package
# Removes all build artifacts and generated files

echo "🧹 Cleaning build artifacts..."

# Remove build directories
echo "  Removing build directories..."
rm -rf build/
rm -rf dist/
rm -rf .eggs/

# Remove egg-info
echo "  Removing .egg-info..."
find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null

# Remove Cython generated C files
echo "  Removing Cython-generated C/C++ files..."
find src/ -name "*.c" -delete
find src/ -name "*.cpp" -delete

# Remove compiled extensions
echo "  Removing compiled extensions..."
find src/ -name "*.so" -delete
find src/ -name "*.pyd" -delete

# Remove Python cache
echo "  Removing Python cache..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
find . -type f -name "*.pyc" -delete
find . -type f -name "*.pyo" -delete

# Remove pytest cache
echo "  Removing test cache..."
rm -rf .pytest_cache/
rm -rf .coverage
rm -rf htmlcov/

# Remove mypy cache
echo "  Removing type check cache..."
rm -rf .mypy_cache/

echo "✅ Cleanup complete!"
echo ""
echo "To rebuild:"
echo "  Development: uv build"
echo "  Production:  USE_CYTHON=1 uv build"
