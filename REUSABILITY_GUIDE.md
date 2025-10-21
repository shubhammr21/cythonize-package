# 🔄 Reusability Guide - Creating New Projects from This Template

This guide explains how to reuse this setup for new projects and what needs to be changed.

## 📋 Table of Contents

1. [Current Project-Specific Items](#current-project-specific-items)
2. [Quick Setup for New Project](#quick-setup-for-new-project)
3. [Manual Customization Steps](#manual-customization-steps)
4. [Making It a Template/Boilerplate](#making-it-a-templateboilerplate)
5. [Automated Setup Script](#automated-setup-script)

---

## 🎯 Current Project-Specific Items

### Files That Need Customization

| File                      | What to Change                                              | Example                                         |
| ------------------------- | ----------------------------------------------------------- | ----------------------------------------------- |
| `pyproject.toml`          | Project name, version, description, authors, repository URL | `name = "cythonize-package"` → `"your-project"` |
| `README.md`               | Project title, description, installation steps, URLs        | Update all references to `cythonize-package`    |
| `src/` directory          | Package name                                                | `src/cythonize_package/` → `src/your_package/`  |
| `setup.py`                | Package name in include/exclude patterns                    | `"cythonize_package.*"` → `"your_package.*"`    |
| `Dockerfile`              | Package name in ENTRYPOINT                                  | `cythonize_package:app` → `your_package:app`    |
| `docker-compose.yml`      | Service name, image name                                    | `cythonize-package` → `your-project`            |
| `test_api.py`             | Import statements                                           | `from cythonize_package` → `from your_package`  |
| `.releaserc.json`         | Repository URL in changelog links                           | Update GitHub repo URL                          |
| `.github/workflows/*.yml` | Repository-specific settings                                | Usually works as-is                             |
| Documentation files       | All references to `cythonize-package`                       | Find & replace                                  |

### Files That Work As-Is (No Changes Needed)

✅ `.pre-commit-config.yaml` - Tool configurations are generic
✅ `build.sh` - Uses environment variables and auto-detection
✅ `clean.sh` - Generic cleanup script
✅ `verify.sh` - Auto-detects package name
✅ `test-ci-locally.sh` - Generic CI testing
✅ `scripts/release.sh` - Works for any project
✅ `.versionrc.json` - Generic version config
✅ `.dockerignore` - Generic exclusions
✅ `.gitignore` - Generic Python exclusions
✅ `.markdownlint.json` - Generic markdown rules

---

## ⚡ Quick Setup for New Project

### Option 1: Manual Copy & Customize

```bash
# 1. Copy the template
cp -r cythonize-package my-new-project
cd my-new-project

# 2. Remove git history
rm -rf .git
git init

# 3. Rename the package directory
mv src/cythonize_package src/my_new_package

# 4. Find and replace package name
# macOS:
find . -type f -not -path '*/\.git/*' -exec sed -i '' 's/cythonize-package/my-new-project/g' {} +
find . -type f -not -path '*/\.git/*' -exec sed -i '' 's/cythonize_package/my_new_package/g' {} +

# Linux:
find . -type f -not -path '*/\.git/*' -exec sed -i 's/cythonize-package/my-new-project/g' {} +
find . -type f -not -path '*/\.git/*' -exec sed -i 's/cythonize_package/my_new_package/g' {} +

# 5. Update project metadata in pyproject.toml
# Edit: name, version, description, authors, repository

# 6. Update README.md with your project details

# 7. Initialize dependencies
uv sync

# 8. Install pre-commit hooks
uv run pre-commit install

# 9. Initial commit
git add .
git commit -m "feat: initialize project from cythonize-package template"
```

### Option 2: Use GitHub Template (Recommended)

1. Push this project to GitHub
2. Go to repository Settings → Template repository ✅
3. Use "Use this template" button for new projects
4. Clone and run the setup script (see below)

### Option 3: Cookiecutter Template (Most Automated)

Create a `cookiecutter.json` configuration (see below)

---

## 📝 Manual Customization Steps

### Step 1: Project Metadata (`pyproject.toml`)

```toml
[project]
name = "my-new-project"              # Change this
version = "0.1.0"                    # Keep or change
description = "Your description"     # Change this
authors = [
    { name = "Your Name", email = "your.email@example.com" }  # Change
]
license = { text = "MIT" }           # Change if needed
readme = "README.md"
requires-python = ">=3.11"

[project.urls]
Homepage = "https://github.com/yourusername/my-new-project"      # Change
Repository = "https://github.com/yourusername/my-new-project"    # Change
Issues = "https://github.com/yourusername/my-new-project/issues" # Change
```

### Step 2: Package Source Code

```bash
# Rename package directory
mv src/cythonize_package src/my_new_package

# Update imports in __init__.py, app.py, models.py, service.py
# Change: from cythonize_package import X
# To:     from my_new_package import X
```

### Step 3: Setup.py Patterns

```python
# In setup.py, update these patterns:
INCLUDE_FILE_PATTERNS = [
    "my_new_package.app",      # Changed
    "my_new_package.models",   # Changed
    "my_new_package.service",  # Changed
]

EXCLUDE_FILE_PATTERNS = [
    "my_new_package.__init__",  # Changed
]

# Update package name in setup() call:
packages=find_packages(where="src", include=["my_new_package*"]),  # Changed
```

### Step 4: Docker Configuration

**Dockerfile:**
```dockerfile
# No changes needed! Uses environment
CMD ["uvicorn", "cythonize_package:app", "--host", "0.0.0.0", "--port", "8000"]
# Change to:
CMD ["uvicorn", "my_new_package:app", "--host", "0.0.0.0", "--port", "8000"]
```

**docker-compose.yml:**
```yaml
services:
  my-new-project:  # Change service name
    image: my-new-project:latest  # Change image name
    container_name: my-new-project-dev  # Change container name
```

### Step 5: Test Files

**test_api.py:**
```python
# Change imports
from my_new_package import get_app  # Changed

# Update test data if your models are different
```

### Step 6: GitHub Actions

**.releaserc.json:**
```json
{
  "plugins": [
    [
      "@semantic-release/changelog",
      {
        "changelogFile": "CHANGELOG.md",
        "changelogTitle": "# My New Project - Changelog"  // Change this
      }
    ]
  ]
}
```

**Repository URLs:**
- Update in README.md links
- Update in .releaserc.json if using custom templates
- Update in pyproject.toml URLs section

### Step 7: Documentation

Update all documentation files:
- `README.md` - Project title, description, features
- `QUICK_START.md` - Installation steps with new name
- `DEVELOPMENT.md` - Development workflows
- `VERSIONING.md` - (Usually no changes needed)
- `RELEASE_NOTES.md` - Update project references

---

## 🎁 Making It a Template/Boilerplate

### Create a GitHub Template Repository

1. **Push to GitHub:**
   ```bash
   git remote add origin https://github.com/yourusername/python-fastapi-cython-template
   git push -u origin main
   ```

2. **Enable Template:**
   - Go to repository Settings
   - Check ✅ "Template repository"
   - Save changes

3. **Add Template Instructions:**
   Create a `TEMPLATE_SETUP.md` file

### Create a Cookiecutter Template

**Directory structure:**
```
cookiecutter-fastapi-cython/
├── cookiecutter.json
├── hooks/
│   └── post_gen_project.py
└── {{cookiecutter.project_slug}}/
    ├── src/
    │   └── {{cookiecutter.package_name}}/
    ├── pyproject.toml
    ├── README.md
    └── ... (all other files)
```

**cookiecutter.json:**
```json
{
  "project_name": "My FastAPI Project",
  "project_slug": "{{ cookiecutter.project_name.lower().replace(' ', '-') }}",
  "package_name": "{{ cookiecutter.project_slug.replace('-', '_') }}",
  "project_short_description": "A FastAPI service with Cython source protection",
  "author_name": "Your Name",
  "author_email": "you@example.com",
  "github_username": "yourusername",
  "python_version": "3.11",
  "version": "0.1.0",
  "license": ["MIT", "Apache-2.0", "GPL-3.0", "BSD-3-Clause"],
  "use_docker": "y",
  "use_semantic_release": "y",
  "use_precommit": "y"
}
```

**Usage:**
```bash
pip install cookiecutter
cookiecutter gh:yourusername/cookiecutter-fastapi-cython
```

### Use Copier (Modern Alternative to Cookiecutter)

**copier.yml:**
```yaml
_subdirectory: template
_templates_suffix: .jinja

project_name:
  type: str
  help: What is your project name?
  default: My FastAPI Project

project_slug:
  type: str
  help: What is your project slug?
  default: "{{ project_name.lower().replace(' ', '-') }}"

package_name:
  type: str
  help: What is your Python package name?
  default: "{{ project_slug.replace('-', '_') }}"

author_name:
  type: str
  help: What is your name?
  default: Your Name

author_email:
  type: str
  help: What is your email?
  default: you@example.com

github_username:
  type: str
  help: What is your GitHub username?
  default: yourusername

license:
  type: str
  help: Choose a license
  choices:
    - MIT
    - Apache-2.0
    - GPL-3.0
    - BSD-3-Clause
  default: MIT

use_docker:
  type: bool
  help: Include Docker support?
  default: true

use_semantic_release:
  type: bool
  help: Use semantic versioning and automated releases?
  default: true
```

**Usage:**
```bash
pip install copier
copier copy gh:yourusername/python-fastapi-cython-template my-new-project
```

---

## 🤖 Automated Setup Script

I'll create a setup script that automates the customization process.

**`scripts/setup-new-project.sh`:**

```bash
#!/bin/bash
# Automated setup script for creating a new project from this template
# Usage: ./scripts/setup-new-project.sh

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 FastAPI + Cython Project Setup${NC}"
echo "===================================="
echo ""

# Get project details
read -p "Project name (e.g., my-awesome-api): " PROJECT_NAME
PROJECT_SLUG="${PROJECT_NAME// /-}"
PROJECT_SLUG="${PROJECT_SLUG,,}"

read -p "Package name (default: ${PROJECT_SLUG//-/_}): " PACKAGE_NAME
PACKAGE_NAME="${PACKAGE_NAME:-${PROJECT_SLUG//-/_}}"

read -p "Project description: " DESCRIPTION

read -p "Author name: " AUTHOR_NAME
read -p "Author email: " AUTHOR_EMAIL

read -p "GitHub username: " GITHUB_USERNAME
REPO_URL="https://github.com/${GITHUB_USERNAME}/${PROJECT_SLUG}"

echo ""
echo -e "${YELLOW}📋 Summary:${NC}"
echo "  Project: $PROJECT_NAME"
echo "  Slug: $PROJECT_SLUG"
echo "  Package: $PACKAGE_NAME"
echo "  Description: $DESCRIPTION"
echo "  Author: $AUTHOR_NAME <$AUTHOR_EMAIL>"
echo "  Repository: $REPO_URL"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo -e "${GREEN}✨ Setting up project...${NC}"

# 1. Rename package directory
echo "1️⃣  Renaming package directory..."
if [ -d "src/cythonize_package" ]; then
    mv src/cythonize_package "src/${PACKAGE_NAME}"
fi

# 2. Update pyproject.toml
echo "2️⃣  Updating pyproject.toml..."
cat > pyproject.toml << EOF
[build-system]
requires = ["setuptools>=75.0.0", "Cython>=3.0.0,<4.0.0"]
build-backend = "setuptools.build_meta"

[project]
name = "${PROJECT_SLUG}"
version = "0.1.0"
description = "${DESCRIPTION}"
authors = [
    { name = "${AUTHOR_NAME}", email = "${AUTHOR_EMAIL}" }
]
license = { text = "MIT" }
readme = "README.md"
requires-python = ">=3.11"
keywords = ["fastapi", "cython", "api", "microservice"]
classifiers = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
    "Framework :: FastAPI",
]

dependencies = [
    "fastapi>=0.115.0",
    "pydantic[email]>=2.9.0",
    "uvicorn[standard]>=0.32.0",
]

[project.urls]
Homepage = "${REPO_URL}"
Repository = "${REPO_URL}"
Issues = "${REPO_URL}/issues"
Changelog = "${REPO_URL}/blob/main/CHANGELOG.md"

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "pytest-cov>=6.0.0",
    "httpx>=0.27.0",
    "ruff>=0.8.0",
    "mypy>=1.13.0",
    "bandit>=1.7.0",
    "pre-commit>=4.0.0",
]

# ... (rest of pyproject.toml remains the same)
EOF

# 3. Update setup.py
echo "3️⃣  Updating setup.py..."
sed -i.bak "s/cythonize_package/${PACKAGE_NAME}/g" setup.py && rm setup.py.bak

# 4. Update Dockerfile
echo "4️⃣  Updating Dockerfile..."
sed -i.bak "s/cythonize_package/${PACKAGE_NAME}/g" Dockerfile && rm Dockerfile.bak

# 5. Update docker-compose.yml
echo "5️⃣  Updating docker-compose.yml..."
sed -i.bak "s/cythonize-package/${PROJECT_SLUG}/g" docker-compose.yml && rm docker-compose.yml.bak

# 6. Update test_api.py
echo "6️⃣  Updating test_api.py..."
sed -i.bak "s/cythonize_package/${PACKAGE_NAME}/g" test_api.py && rm test_api.bak

# 7. Update all documentation
echo "7️⃣  Updating documentation..."
for file in *.md; do
    if [ -f "$file" ]; then
        sed -i.bak "s/cythonize-package/${PROJECT_SLUG}/g" "$file"
        sed -i.bak "s/cythonize_package/${PACKAGE_NAME}/g" "$file"
        sed -i.bak "s/Cythonize Package/${PROJECT_NAME}/g" "$file"
        rm "${file}.bak"
    fi
done

# 8. Update .releaserc.json
echo "8️⃣  Updating release configuration..."
sed -i.bak "s|owner/repo|${GITHUB_USERNAME}/${PROJECT_SLUG}|g" .releaserc.json && rm .releaserc.json.bak

# 9. Update source code imports
echo "9️⃣  Updating source code imports..."
find "src/${PACKAGE_NAME}" -type f -name "*.py" -exec sed -i.bak "s/cythonize_package/${PACKAGE_NAME}/g" {} \;
find "src/${PACKAGE_NAME}" -type f -name "*.bak" -delete

# 10. Clean up old artifacts
echo "🧹 Cleaning up..."
rm -rf dist/ build/ .eggs/ *.egg-info
rm -rf .pytest_cache/ .mypy_cache/ .ruff_cache/
rm -rf src/*.egg-info

# 11. Initialize git
echo "📦 Initializing git repository..."
rm -rf .git
git init
git add .
git commit -m "feat: initialize ${PROJECT_NAME} from template"

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review and customize README.md"
echo "  2. Update your application logic in src/${PACKAGE_NAME}/"
echo "  3. Install dependencies: uv sync"
echo "  4. Install pre-commit hooks: uv run pre-commit install"
echo "  5. Run tests: uv run pytest"
echo "  6. Create GitHub repository: ${REPO_URL}"
echo "  7. Push code: git remote add origin ${REPO_URL}.git && git push -u origin main"
echo ""
echo -e "${BLUE}Happy coding! 🎉${NC}"
```

---

## 🎯 Comparison: Different Approaches

| Approach            | Setup Time | Flexibility | Maintenance | Best For        |
| ------------------- | ---------- | ----------- | ----------- | --------------- |
| **Manual Copy**     | 30 min     | ⭐⭐⭐⭐⭐       | Hard        | One-time use    |
| **Setup Script**    | 5 min      | ⭐⭐⭐⭐        | Medium      | Team projects   |
| **GitHub Template** | 2 min      | ⭐⭐⭐         | Easy        | Frequent reuse  |
| **Cookiecutter**    | 2 min      | ⭐⭐⭐⭐⭐       | Easy        | Public template |
| **Copier**          | 2 min      | ⭐⭐⭐⭐⭐       | Very Easy   | Modern projects |

---

## 🔧 What Changes for Different Project Types?

### Microservice (Current Template)
✅ Perfect as-is - FastAPI + Cython + Docker

### CLI Tool
- Remove: `app.py`, `models.py`, API endpoints
- Add: `cli.py` with Click/Typer
- Update: `pyproject.toml` scripts section

### Library/SDK
- Remove: FastAPI, uvicorn
- Keep: Cython compilation, packaging
- Focus: Public API in `__init__.py`

### Data Processing Pipeline
- Keep: Cython for performance
- Add: pandas, numpy dependencies
- Add: Pipeline modules

### ML Service
- Add: torch, tensorflow, scikit-learn
- Keep: FastAPI for inference API
- Add: Model serving endpoints

---

## 📚 Resources

- **Template Repositories:** <https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-template-repository>
- **Cookiecutter:** <https://cookiecutter.readthedocs.io/>
- **Copier:** <https://copier.readthedocs.io/>
- **Project Templates Best Practices:** <https://github.com/rochacbruno/python-project-template>

---

## ✅ Checklist for New Project

- [ ] Run setup script or manual customization
- [ ] Update `pyproject.toml` metadata
- [ ] Rename package directory
- [ ] Update all imports
- [ ] Customize `README.md`
- [ ] Update `setup.py` patterns
- [ ] Modify Dockerfile CMD
- [ ] Update docker-compose.yml
- [ ] Test import: `python -c "import your_package"`
- [ ] Run tests: `uv run pytest`
- [ ] Install pre-commit: `uv run pre-commit install`
- [ ] Build development: `./build.sh`
- [ ] Build production: `./build.sh cython`
- [ ] Test CI locally: `./test-ci-locally.sh`
- [ ] Create GitHub repository
- [ ] Push to GitHub
- [ ] Verify GitHub Actions run successfully

---

**Next:** See `scripts/setup-new-project.sh` for automated setup!
