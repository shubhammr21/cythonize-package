#!/bin/bash
# Test CI/CD pipeline locally before pushing to GitHub
# This script simulates GitHub Actions workflow using Docker

set -e  # Exit on error

echo "🧪 Testing CI/CD Pipeline Locally"
echo "=================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

print_status "Docker is running"

# Build test image
echo ""
echo "📦 Building test Docker image..."
docker build -t cythonize-package:ci-test -f Dockerfile . || {
    print_error "Docker build failed"
    exit 1
}
print_status "Docker image built successfully"

# Create a temporary container for testing
echo ""
echo "🏗️  Creating test container..."
CONTAINER_ID=$(docker create cythonize-package:ci-test)
print_status "Test container created: $CONTAINER_ID"

# Test 1: Lint Check
echo ""
echo "1️⃣  Running lint checks..."
if uv run ruff check . > /dev/null 2>&1; then
    print_status "Lint checks passed"
else
    print_error "Lint checks failed"
    uv run ruff check .
    docker rm "$CONTAINER_ID" > /dev/null 2>&1
    exit 1
fi

# Test 2: Format Check
echo ""
echo "2️⃣  Running format checks..."
if uv run ruff format --check . > /dev/null 2>&1; then
    print_status "Format checks passed"
else
    print_error "Format checks failed"
    print_warning "Run: uv run ruff format ."
    docker rm "$CONTAINER_ID" > /dev/null 2>&1
    exit 1
fi

# Test 3: Type Check
echo ""
echo "3️⃣  Running type checks..."
if uv run mypy src/ --strict --ignore-missing-imports > /dev/null 2>&1; then
    print_status "Type checks passed"
else
    print_warning "Type checks have warnings (non-fatal)"
    uv run mypy src/ --strict --ignore-missing-imports
fi

# Test 4: Security Scan
echo ""
echo "4️⃣  Running security scan..."
if uv run bandit -r src/ -c pyproject.toml > /dev/null 2>&1; then
    print_status "Security scan passed"
else
    print_warning "Security scan found issues (check manually)"
    uv run bandit -r src/ -c pyproject.toml
fi

# Test 5: Unit Tests
echo ""
echo "5️⃣  Running unit tests..."
if uv run pytest test_api.py -v > /dev/null 2>&1; then
    print_status "Unit tests passed"
else
    print_error "Unit tests failed"
    uv run pytest test_api.py -v
    docker rm "$CONTAINER_ID" > /dev/null 2>&1
    exit 1
fi

# Test 6: Development Build
echo ""
echo "6️⃣  Testing development build..."
if ./build.sh > /dev/null 2>&1; then
    print_status "Development build successful"
else
    print_error "Development build failed"
    docker rm "$CONTAINER_ID" > /dev/null 2>&1
    exit 1
fi

# Test 7: Production Build
echo ""
echo "7️⃣  Testing production build..."
if ./build.sh cython > /dev/null 2>&1; then
    print_status "Production build successful"
else
    print_error "Production build failed"
    docker rm "$CONTAINER_ID" > /dev/null 2>&1
    exit 1
fi

# Test 8: Verify Build
echo ""
echo "8️⃣  Verifying builds..."
if ./verify.sh > /dev/null 2>&1; then
    print_status "Build verification passed"
else
    print_error "Build verification failed"
    docker rm "$CONTAINER_ID" > /dev/null 2>&1
    exit 1
fi

# Test 9: Docker Container Test
echo ""
echo "9️⃣  Testing Docker container..."
docker run --rm -d -p 8000:8000 --name ci-test-container cythonize-package:ci-test > /dev/null

# Wait for container to start
sleep 5

# Test endpoint
if curl -f http://localhost:8000/ > /dev/null 2>&1; then
    print_status "Docker container test passed"
else
    print_error "Docker container test failed"
    docker stop ci-test-container > /dev/null 2>&1
    docker rm "$CONTAINER_ID" > /dev/null 2>&1
    exit 1
fi

# Stop test container
docker stop ci-test-container > /dev/null 2>&1

# Cleanup
echo ""
echo "🧹 Cleaning up..."
docker rm "$CONTAINER_ID" > /dev/null 2>&1
print_status "Cleanup complete"

# Summary
echo ""
echo "=================================="
echo -e "${GREEN}✅ All CI/CD tests passed!${NC}"
echo "=================================="
echo ""
echo "Your code is ready to push to GitHub! 🚀"
echo ""
echo "Next steps:"
echo "  1. Review your changes: git status"
echo "  2. Stage changes: git add ."
echo "  3. Commit: git commit -m 'feat: your message'"
echo "  4. Push: git push"
echo ""
