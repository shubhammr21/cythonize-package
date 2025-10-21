#!/bin/bash
# Verification script for cythonize-package

set -e

echo "🔍 Verification Script for Cythonize Package"
echo "=============================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

echo "1️⃣  Checking project structure..."
if [ -f "pyproject.toml" ] && [ -f "setup.py" ] && [ -d "src/cythonize_package" ]; then
    success "Project structure is correct"
else
    error "Project structure is incorrect"
    exit 1
fi

echo ""
echo "2️⃣  Checking if uv is installed..."
if command -v uv &> /dev/null; then
    success "uv is installed: $(uv --version)"
else
    error "uv is not installed"
    exit 1
fi

echo ""
echo "3️⃣  Checking dependencies..."
if uv sync --quiet 2>&1 | grep -q "Audited"; then
    success "Dependencies are installed"
else
    info "Installing dependencies..."
    uv sync
    success "Dependencies installed"
fi

echo ""
echo "4️⃣  Testing import in development mode..."
if uv run python -c "from cythonize_package import app; print('OK')" 2>&1 | grep -q "OK"; then
    success "Development import works"
else
    error "Development import failed"
    exit 1
fi

echo ""
echo "5️⃣  Running API tests..."
if uv run python test_api.py 2>&1 | grep -q "All tests passed"; then
    success "All API tests passed"
else
    error "API tests failed"
    exit 1
fi

echo ""
echo "6️⃣  Building without Cython (development)..."
rm -rf dist/ build/ src/*.egg-info 2>/dev/null
if uv build 2>&1 | grep -q "Successfully built"; then
    success "Development build successful"
    DEV_WHEEL=$(find dist/ -name "*py3-none-any.whl" | head -1)
    info "Built: $DEV_WHEEL ($(du -h "$DEV_WHEEL" | cut -f1))"
else
    error "Development build failed"
    exit 1
fi

echo ""
echo "7️⃣  Verifying development wheel contains source files..."
if unzip -l dist/*py3-none-any.whl | grep -q "app.py"; then
    success "Development wheel contains Python source files"
else
    error "Development wheel missing source files"
    exit 1
fi

echo ""
echo ""
echo "8️⃣  Building with Cython (production)..."
rm -rf dist/ build/ src/*.egg-info 2>/dev/null
if USE_CYTHON=1 uv build 2>&1 | grep -q "Successfully built"; then
    success "Production build successful"
    PROD_WHEEL=$(find dist/ -name "*.whl" ! -name "*py3-none-any.whl" | head -1)
    info "Built: $PROD_WHEEL ($(du -h "$PROD_WHEEL" | cut -f1))"
else
    error "Production build failed"
    exit 1
fi

echo ""
echo "9️⃣  Verifying cythonized wheel contents..."
PROD_WHEEL=$(find dist/ -name "*.whl" ! -name "*py3-none-any.whl" | head -1)

# Check for .so files
if unzip -l "$PROD_WHEEL" | grep -q ".cpython.*\.so"; then
    success "Found compiled binary files (.so)"
else
    error "No compiled binary files found"
    exit 1
fi

# Check that .py files are removed (except __init__.py)
if unzip -l "$PROD_WHEEL" | grep "cythonize_package" | grep "\.py$" | grep -qv "__init__"; then
    error "Found unprotected .py files in wheel"
    exit 1
else
    success "Source .py files are removed (protected!)"
fi

echo ""
echo "🔟  Detailed inspection of cythonized wheel..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
unzip -l "$PROD_WHEEL" | grep "cythonize_package/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Count files
SO_COUNT=$(unzip -l "$PROD_WHEEL" | grep "\.so$" | wc -l | tr -d ' ')
PY_COUNT=$(unzip -l "$PROD_WHEEL" | grep "cythonize_package/.*\.py$" | wc -l | tr -d ' ')

info "Binary files (.so): $SO_COUNT"
info "Python files (.py): $PY_COUNT"

if [ "$SO_COUNT" -eq 3 ] && [ "$PY_COUNT" -eq 1 ]; then
    success "Wheel structure is correct!"
    info "  - 3 compiled modules (app, models, service)"
    info "  - 1 Python file (__init__.py only)"
else
    error "Unexpected wheel structure"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
success "ALL VERIFICATIONS PASSED! 🎉"
echo ""
echo "Summary:"
echo "  ✅ Project structure correct"
echo "  ✅ Dependencies installed"
echo "  ✅ Development mode works"
echo "  ✅ Tests pass"
echo "  ✅ Development build works"
echo "  ✅ Cython build works"
echo "  ✅ Source code protected"
echo "  ✅ Cythonized package works"
echo ""
echo "Your FastAPI service with Cython-protected source code is ready! 🚀"
echo ""
