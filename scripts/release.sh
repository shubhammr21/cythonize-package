#!/bin/bash
# Manual release script using standard-version
# This script helps create releases locally with proper changelog generation

set -e

echo "🚀 Manual Release Script"
echo "======================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if standard-version is installed
if ! command -v standard-version &> /dev/null; then
    echo -e "${RED}✗${NC} standard-version is not installed"
    echo ""
    echo "Install it with:"
    echo "  npm install -g standard-version"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓${NC} standard-version is installed"
echo ""

# Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo -e "${RED}✗${NC} You have uncommitted changes"
    echo ""
    git status -s
    echo ""
    echo "Please commit or stash your changes first."
    exit 1
fi

echo -e "${GREEN}✓${NC} Working directory is clean"
echo ""

# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "main" ]] && [[ "$CURRENT_BRANCH" != "develop" ]]; then
    echo -e "${YELLOW}⚠${NC}  Warning: You're on branch '$CURRENT_BRANCH'"
    echo "   Releases are typically made from 'main' or 'develop'"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Release cancelled."
        exit 1
    fi
fi

echo -e "${GREEN}✓${NC} On branch: $CURRENT_BRANCH"
echo ""

# Show current version
CURRENT_VERSION=$(grep -m 1 'version = ' pyproject.toml | cut -d'"' -f2)
echo "📦 Current version: $CURRENT_VERSION"
echo ""

# Show what would be released
echo "📝 Commits since last release:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if git describe --tags --abbrev=0 &> /dev/null; then
    LAST_TAG=$(git describe --tags --abbrev=0)
    git log "$LAST_TAG"..HEAD --oneline --pretty=format:"%h %s"
else
    echo "No previous tags found. This will be the first release."
    git log --oneline --pretty=format:"%h %s" | head -10
fi
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Determine release type
echo "What type of release?"
echo "  1) Automatic (analyze commits)"
echo "  2) Major (x.0.0) - Breaking changes"
echo "  3) Minor (0.x.0) - New features"
echo "  4) Patch (0.0.x) - Bug fixes"
echo "  5) Pre-release (alpha/beta/rc)"
echo "  6) Dry run (see what would happen)"
echo "  0) Cancel"
echo ""
read -p "Choice (1-6, 0 to cancel): " -n 1 -r CHOICE
echo ""
echo ""

case $CHOICE in
    1)
        echo "📊 Analyzing commits..."
        echo ""
        RELEASE_TYPE="auto"
        RELEASE_CMD="standard-version"
        ;;
    2)
        echo "💥 Creating MAJOR release (breaking changes)"
        echo ""
        RELEASE_TYPE="major"
        RELEASE_CMD="standard-version --release-as major"
        ;;
    3)
        echo "🚀 Creating MINOR release (new features)"
        echo ""
        RELEASE_TYPE="minor"
        RELEASE_CMD="standard-version --release-as minor"
        ;;
    4)
        echo "🐛 Creating PATCH release (bug fixes)"
        echo ""
        RELEASE_TYPE="patch"
        RELEASE_CMD="standard-version --release-as patch"
        ;;
    5)
        echo "Pre-release type:"
        echo "  1) Alpha"
        echo "  2) Beta"
        echo "  3) RC (Release Candidate)"
        echo ""
        read -p "Choice (1-3): " -n 1 -r PRERELEASE_CHOICE
        echo ""
        echo ""
        case $PRERELEASE_CHOICE in
            1) PRERELEASE_TYPE="alpha" ;;
            2) PRERELEASE_TYPE="beta" ;;
            3) PRERELEASE_TYPE="rc" ;;
            *) echo "Invalid choice"; exit 1 ;;
        esac
        echo "🧪 Creating $PRERELEASE_TYPE pre-release"
        echo ""
        RELEASE_TYPE="prerelease"
        RELEASE_CMD="standard-version --prerelease $PRERELEASE_TYPE"
        ;;
    6)
        echo "🔍 Dry run mode (no changes will be made)"
        echo ""
        RELEASE_TYPE="dry-run"
        RELEASE_CMD="standard-version --dry-run"
        ;;
    0)
        echo "Release cancelled."
        exit 0
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

# Confirm
if [[ "$RELEASE_TYPE" != "dry-run" ]]; then
    echo ""
    echo -e "${YELLOW}⚠${NC}  This will:"
    echo "   - Update CHANGELOG.md"
    echo "   - Update version in pyproject.toml"
    echo "   - Create a git commit"
    echo "   - Create a git tag"
    echo ""
    read -p "Continue? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Release cancelled."
        exit 0
    fi
    echo ""
fi

# Run release
echo "🏗️  Running release..."
echo ""
eval "$RELEASE_CMD"

if [[ "$RELEASE_TYPE" != "dry-run" ]]; then
    NEW_VERSION=$(grep -m 1 'version = ' pyproject.toml | cut -d'"' -f2)
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}✅ Release created successfully!${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📦 Version: $CURRENT_VERSION → $NEW_VERSION"
    echo "🏷️  Tag: v$NEW_VERSION"
    echo ""
    echo "Next steps:"
    echo "  1. Review the changes:"
    echo "     git show HEAD"
    echo ""
    echo "  2. Push the release:"
    echo "     git push --follow-tags origin $CURRENT_BRANCH"
    echo ""
    echo "  3. Or undo the release:"
    echo "     git reset --hard HEAD~1"
    echo "     git tag -d v$NEW_VERSION"
    echo ""
else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Dry run complete (no changes made)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
fi
