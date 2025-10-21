#!/bin/bash
# Automated setup script for creating a new project from this template
# Usage: ./scripts/setup-new-project.sh
#
# This script will:
# 1. Prompt for project details
# 2. Rename package directories
# 3. Update all configuration files
# 4. Replace all references to old project name
# 5. Initialize new git repository

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║   FastAPI + Cython Project Setup                    ║"
echo "║   Create a new project from this template           ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f "pyproject.toml" ]; then
    echo -e "${RED}❌ Error: Must be run from project root directory${NC}"
    exit 1
fi

# Get project details
echo -e "${BLUE}📝 Project Information${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Project name (e.g., 'My Awesome API'): " PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}❌ Project name cannot be empty${NC}"
    exit 1
fi

# Generate slug from project name
PROJECT_SLUG="${PROJECT_NAME// /-}"
PROJECT_SLUG="${PROJECT_SLUG,,}"
PROJECT_SLUG="${PROJECT_SLUG//[^a-z0-9-]/}"

read -p "Project slug (default: $PROJECT_SLUG): " CUSTOM_SLUG
if [ -n "$CUSTOM_SLUG" ]; then
    PROJECT_SLUG="$CUSTOM_SLUG"
fi

# Generate package name from slug
DEFAULT_PACKAGE="${PROJECT_SLUG//-/_}"
read -p "Python package name (default: $DEFAULT_PACKAGE): " PACKAGE_NAME
PACKAGE_NAME="${PACKAGE_NAME:-$DEFAULT_PACKAGE}"

# Validate package name
if [[ ! "$PACKAGE_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
    echo -e "${RED}❌ Invalid package name. Must start with letter, contain only lowercase, numbers, and underscores${NC}"
    exit 1
fi

read -p "Project description: " DESCRIPTION
if [ -z "$DESCRIPTION" ]; then
    DESCRIPTION="A FastAPI service with Cython source protection"
fi

read -p "Author name: " AUTHOR_NAME
if [ -z "$AUTHOR_NAME" ]; then
    AUTHOR_NAME="Your Name"
fi

read -p "Author email: " AUTHOR_EMAIL
if [ -z "$AUTHOR_EMAIL" ]; then
    AUTHOR_EMAIL="you@example.com"
fi

read -p "GitHub username: " GITHUB_USERNAME
if [ -z "$GITHUB_USERNAME" ]; then
    GITHUB_USERNAME="yourusername"
fi

REPO_URL="https://github.com/${GITHUB_USERNAME}/${PROJECT_SLUG}"

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📋 Summary${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "  Project Name:    $PROJECT_NAME"
echo "  Project Slug:    $PROJECT_SLUG"
echo "  Package Name:    $PACKAGE_NAME"
echo "  Description:     $DESCRIPTION"
echo "  Author:          $AUTHOR_NAME <$AUTHOR_EMAIL>"
echo "  Repository:      $REPO_URL"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Continue with these settings? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Setup cancelled${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✨ Setting up project...${NC}"
echo ""

# Function to safely replace in file (works on both macOS and Linux)
replace_in_file() {
    local file="$1"
    local search="$2"
    local replace="$3"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|${search}|${replace}|g" "$file"
    else
        # Linux
        sed -i "s|${search}|${replace}|g" "$file"
    fi
}

# 1. Rename package directory
echo -e "${BLUE}1️⃣  Renaming package directory...${NC}"
if [ -d "src/cythonize_package" ]; then
    mv src/cythonize_package "src/${PACKAGE_NAME}"
    echo -e "   ${GREEN}✓${NC} Renamed: src/cythonize_package → src/${PACKAGE_NAME}"
else
    echo -e "   ${YELLOW}⚠${NC} Package directory already renamed or not found"
fi

# 2. Update pyproject.toml
echo -e "${BLUE}2️⃣  Updating pyproject.toml...${NC}"
if [ -f "pyproject.toml" ]; then
    replace_in_file "pyproject.toml" "cythonize-package" "$PROJECT_SLUG"
    replace_in_file "pyproject.toml" "cythonize_package" "$PACKAGE_NAME"
    replace_in_file "pyproject.toml" "A FastAPI service with Cython-protected source code using uv build backend" "$DESCRIPTION"
    replace_in_file "pyproject.toml" "Your Name" "$AUTHOR_NAME"
    replace_in_file "pyproject.toml" "you@example.com" "$AUTHOR_EMAIL"
    replace_in_file "pyproject.toml" "https://github.com/owner/repo" "$REPO_URL"
    echo -e "   ${GREEN}✓${NC} Updated project metadata"
else
    echo -e "   ${RED}✗${NC} pyproject.toml not found"
fi

# 3. Update setup.py
echo -e "${BLUE}3️⃣  Updating setup.py...${NC}"
if [ -f "setup.py" ]; then
    replace_in_file "setup.py" "cythonize_package" "$PACKAGE_NAME"
    echo -e "   ${GREEN}✓${NC} Updated Cython patterns"
else
    echo -e "   ${YELLOW}⚠${NC} setup.py not found"
fi

# 4. Update Dockerfile
echo -e "${BLUE}4️⃣  Updating Dockerfile...${NC}"
if [ -f "Dockerfile" ]; then
    replace_in_file "Dockerfile" "cythonize_package" "$PACKAGE_NAME"
    replace_in_file "Dockerfile" "cythonize-package" "$PROJECT_SLUG"
    echo -e "   ${GREEN}✓${NC} Updated Docker configuration"
else
    echo -e "   ${YELLOW}⚠${NC} Dockerfile not found"
fi

# 5. Update docker-compose.yml
echo -e "${BLUE}5️⃣  Updating docker-compose.yml...${NC}"
if [ -f "docker-compose.yml" ]; then
    replace_in_file "docker-compose.yml" "cythonize-package" "$PROJECT_SLUG"
    echo -e "   ${GREEN}✓${NC} Updated Docker Compose config"
else
    echo -e "   ${YELLOW}⚠${NC} docker-compose.yml not found"
fi

# 6. Update test files
echo -e "${BLUE}6️⃣  Updating test files...${NC}"
if [ -f "test_api.py" ]; then
    replace_in_file "test_api.py" "cythonize_package" "$PACKAGE_NAME"
    echo -e "   ${GREEN}✓${NC} Updated test_api.py"
fi

# 7. Update source code
echo -e "${BLUE}7️⃣  Updating source code imports...${NC}"
if [ -d "src/${PACKAGE_NAME}" ]; then
    find "src/${PACKAGE_NAME}" -type f -name "*.py" | while read -r file; do
        replace_in_file "$file" "cythonize_package" "$PACKAGE_NAME"
    done
    echo -e "   ${GREEN}✓${NC} Updated all Python imports"
fi

# 8. Update documentation
echo -e "${BLUE}8️⃣  Updating documentation files...${NC}"
DOCS_UPDATED=0
for file in *.md; do
    if [ -f "$file" ] && [ "$file" != "REUSABILITY_GUIDE.md" ]; then
        replace_in_file "$file" "cythonize-package" "$PROJECT_SLUG"
        replace_in_file "$file" "cythonize_package" "$PACKAGE_NAME"
        replace_in_file "$file" "Cythonize Package" "$PROJECT_NAME"
        ((DOCS_UPDATED++))
    fi
done
echo -e "   ${GREEN}✓${NC} Updated $DOCS_UPDATED documentation files"

# 9. Update GitHub configuration
echo -e "${BLUE}9️⃣  Updating GitHub configuration...${NC}"
if [ -f ".releaserc.json" ]; then
    replace_in_file ".releaserc.json" "owner/repo" "${GITHUB_USERNAME}/${PROJECT_SLUG}"
    echo -e "   ${GREEN}✓${NC} Updated .releaserc.json"
fi

if [ -f ".github/pull_request_template.md" ]; then
    replace_in_file ".github/pull_request_template.md" "cythonize-package" "$PROJECT_SLUG"
    echo -e "   ${GREEN}✓${NC} Updated PR template"
fi

# 10. Clean up build artifacts
echo -e "${BLUE}🧹 Cleaning up artifacts...${NC}"
rm -rf dist/ build/ .eggs/ src/*.egg-info 2>/dev/null || true
rm -rf .pytest_cache/ .mypy_cache/ .ruff_cache/ __pycache__/ 2>/dev/null || true
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true
find . -type f -name "*.pyo" -delete 2>/dev/null || true
find . -type f -name "*.c" -delete 2>/dev/null || true
find . -type f -name "*.so" -delete 2>/dev/null || true
echo -e "   ${GREEN}✓${NC} Cleaned build artifacts"

# 11. Update CHANGELOG
echo -e "${BLUE}📝 Resetting CHANGELOG...${NC}"
if [ -f "CHANGELOG.md" ]; then
    cat > CHANGELOG.md << EOF
# Changelog

All notable changes to $PROJECT_NAME will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial project setup from template
- FastAPI service with Cython compilation
- Comprehensive development tooling
- CI/CD pipeline with GitHub Actions
- Semantic versioning and automated releases
EOF
    echo -e "   ${GREEN}✓${NC} Reset CHANGELOG.md"
fi

# 12. Initialize new git repository
echo -e "${BLUE}📦 Initializing git repository...${NC}"
read -p "Remove existing git history and create new repo? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf .git
    git init
    git add .
    git commit -m "feat: initialize ${PROJECT_NAME} from template

- Set up project structure
- Configure build system with Cython
- Add development tooling (Ruff, Mypy, Bandit)
- Configure pre-commit hooks
- Add Docker support
- Set up GitHub Actions CI/CD
- Configure semantic versioning"
    echo -e "   ${GREEN}✓${NC} Git repository initialized"
else
    echo -e "   ${YELLOW}⚠${NC} Skipped git initialization"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📚 Next Steps:${NC}"
echo ""
echo "  1️⃣  Install dependencies:"
echo "      ${YELLOW}uv sync${NC}"
echo ""
echo "  2️⃣  Install pre-commit hooks:"
echo "      ${YELLOW}uv run pre-commit install${NC}"
echo ""
echo "  3️⃣  Customize your application:"
echo "      Edit files in ${YELLOW}src/${PACKAGE_NAME}/${NC}"
echo ""
echo "  4️⃣  Run tests:"
echo "      ${YELLOW}uv run pytest${NC}"
echo ""
echo "  5️⃣  Build development version:"
echo "      ${YELLOW}./build.sh${NC}"
echo ""
echo "  6️⃣  Build production (Cythonized):"
echo "      ${YELLOW}./build.sh cython${NC}"
echo ""
echo "  7️⃣  Test CI locally:"
echo "      ${YELLOW}./test-ci-locally.sh${NC}"
echo ""
echo "  8️⃣  Create GitHub repository:"
echo "      Visit: ${YELLOW}https://github.com/new${NC}"
echo "      Name: ${YELLOW}${PROJECT_SLUG}${NC}"
echo ""
echo "  9️⃣  Push to GitHub:"
echo "      ${YELLOW}git remote add origin ${REPO_URL}.git${NC}"
echo "      ${YELLOW}git branch -M main${NC}"
echo "      ${YELLOW}git push -u origin main${NC}"
echo ""
echo -e "${GREEN}🎉 Happy coding with ${PROJECT_NAME}!${NC}"
echo ""
