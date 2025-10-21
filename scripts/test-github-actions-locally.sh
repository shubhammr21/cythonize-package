#!/bin/bash
# Script to test GitHub Actions workflows locally using act
# Requires: Docker and act (https://github.com/nektos/act)

set -e

echo "🎬 Testing GitHub Actions locally with act"
echo "=========================================="
echo ""

# Check if act is installed
if ! command -v act &> /dev/null; then
    echo "❌ 'act' is not installed"
    echo ""
    echo "📦 Install act:"
    echo "  macOS:   brew install act"
    echo "  Linux:   curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash"
    echo "  Or visit: https://github.com/nektos/act"
    echo ""
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running"
    echo "Please start Docker and try again"
    exit 1
fi

echo "✅ Prerequisites check passed"
echo ""

# Parse command line arguments
WORKFLOW="${1:-ci.yml}"
JOB="${2:-}"
EVENT="${3:-push}"

echo "Configuration:"
echo "  Workflow: $WORKFLOW"
echo "  Event: $EVENT"
if [ -n "$JOB" ]; then
    echo "  Job: $JOB"
else
    echo "  Job: all"
fi
echo ""

# Build act command
ACT_CMD="act $EVENT"

# Add workflow file
ACT_CMD="$ACT_CMD -W .github/workflows/$WORKFLOW"

# Add specific job if provided
if [ -n "$JOB" ]; then
    ACT_CMD="$ACT_CMD -j $JOB"
fi

# Add common flags
ACT_CMD="$ACT_CMD --container-architecture linux/amd64"

echo "🚀 Running: $ACT_CMD"
echo ""

# Run act
eval $ACT_CMD

echo ""
echo "✅ GitHub Actions test complete!"
