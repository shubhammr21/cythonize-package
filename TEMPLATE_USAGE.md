# 🎯 Using This as a Template

This project can be used as a **template/boilerplate** for creating new FastAPI services with Cython source protection.

## 🚀 Quick Start - 3 Methods

### Method 1: Automated Setup Script (Recommended) ⭐

**Fastest and most reliable way!**

```bash
# 1. Clone or copy this repository
git clone <this-repo-url> my-new-project
cd my-new-project

# 2. Run the setup script
./scripts/setup-new-project.sh

# 3. Follow the prompts:
#    - Project name: My Awesome API
#    - Package name: my_awesome_api
#    - Description: A cool API service
#    - Author info: Your Name, email
#    - GitHub username: yourusername

# 4. Done! Your project is ready
uv sync
uv run pre-commit install
uv run pytest
```

**What the script does:**
- ✅ Renames package directories
- ✅ Updates all configuration files
- ✅ Replaces project references
- ✅ Cleans build artifacts
- ✅ Initializes new git repo
- ✅ Creates initial commit

### Method 2: GitHub Template Repository

**Best for repeated use!**

```bash
# 1. Make this a GitHub template (one-time setup)
#    - Push to GitHub
#    - Go to Settings → Check "Template repository"

# 2. Create new project from template
#    - Click "Use this template" on GitHub
#    - Name your new repository
#    - Clone it

# 3. Run setup script
cd my-new-project
./scripts/setup-new-project.sh
```

### Method 3: Manual Setup

**Maximum control, more work:**

```bash
# 1. Copy repository
cp -r cythonize-package my-new-project
cd my-new-project

# 2. Rename package
mv src/cythonize_package src/my_new_package

# 3. Find & replace everywhere
# macOS:
find . -type f -not -path '*/\.git/*' -exec sed -i '' 's/cythonize-package/my-new-project/g' {} +
find . -type f -not -path '*/\.git/*' -exec sed -i '' 's/cythonize_package/my_new_package/g' {} +

# Linux:
find . -type f -not -path '*/\.git/*' -exec sed -i 's/cythonize-package/my-new-project/g' {} +
find . -type f -not -path '*/\.git/*' -exec sed -i 's/cythonize_package/my_new_package/g' {} +

# 4. Update pyproject.toml manually
#    - name, version, description
#    - authors, license
#    - repository URLs

# 5. Reset git
rm -rf .git
git init
git add .
git commit -m "feat: initialize project"
```

## 📋 What Gets Changed

| Component | Old Value | New Value (Example) |
|-----------|-----------|---------------------|
| **Project Name** | Cythonize Package | My Awesome API |
| **Project Slug** | cythonize-package | my-awesome-api |
| **Package Name** | cythonize_package | my_awesome_api |
| **Repository** | owner/repo | yourusername/my-awesome-api |
| **Author** | Your Name | Jane Developer |

## ✅ What Stays the Same (Reusable)

These components work for **any** FastAPI + Cython project:

- ✅ Build system (`build.sh`, `clean.sh`, `verify.sh`)
- ✅ Cython compilation setup (`setup.py`)
- ✅ Pre-commit hooks configuration
- ✅ GitHub Actions workflows
- ✅ Docker configuration structure
- ✅ Testing setup (`pytest`, test structure)
- ✅ Code quality tools (Ruff, Mypy, Bandit)
- ✅ Semantic versioning system
- ✅ Release automation

## 🎯 Use Cases

### Use Case 1: New Microservice

```bash
./scripts/setup-new-project.sh
# Name: User Auth Service
# Package: user_auth_service
# → Ready for authentication microservice
```

### Use Case 2: Internal API

```bash
./scripts/setup-new-project.sh
# Name: Data Processing API
# Package: data_processing_api
# → Ready for data processing service
```

### Use Case 3: Client Library

```bash
./scripts/setup-new-project.sh
# Name: Payment Gateway SDK
# Package: payment_sdk
# → Ready for SDK development
# (Remove FastAPI, keep Cython protection)
```

## 🔧 Customization After Setup

### For Different Python Versions

Edit `pyproject.toml`:

```toml
[project]
requires-python = ">=3.12"  # Change from 3.11
```

### For Different Dependencies

Edit `pyproject.toml`:

```toml
dependencies = [
    "fastapi>=0.115.0",
    "your-package>=1.0.0",  # Add your deps
]
```

### For Different Frameworks

**Django instead of FastAPI:**

1. Replace FastAPI deps with Django
2. Update `src/` structure
3. Modify `setup.py` include patterns
4. Update Dockerfile CMD

**Flask instead of FastAPI:**

1. Replace FastAPI with Flask
2. Update application factory pattern
3. Modify imports in tests

### For CLI Tools

1. Remove API-related files
2. Add Click/Typer dependency
3. Create `cli.py` module
4. Update `pyproject.toml` scripts:

```toml
[project.scripts]
mytool = "my_package.cli:main"
```

## 📦 Files Overview

### Must Customize

| File | What to Change |
|------|---------------|
| `pyproject.toml` | Name, version, description, author, URLs |
| `README.md` | Project description, features, installation |
| `src/<package>/` | Your application logic |
| `test_api.py` | Your test cases |

### Auto-Customized by Script

| File | Auto-Updated |
|------|-------------|
| `setup.py` | Package patterns |
| `Dockerfile` | Package name in CMD |
| `docker-compose.yml` | Service/image names |
| `.releaserc.json` | Repository URLs |
| All `.md` files | Project references |

### No Changes Needed

| File | Why |
|------|-----|
| `build.sh` | Generic build logic |
| `clean.sh` | Generic cleanup |
| `.pre-commit-config.yaml` | Tool configs are universal |
| `.github/workflows/*.yml` | Generic CI/CD |
| `.dockerignore` | Generic exclusions |
| `.gitignore` | Generic Python exclusions |

## 🧪 Testing Your New Project

After setup, verify everything works:

```bash
# 1. Install dependencies
uv sync

# 2. Run linting
uv run ruff check .

# 3. Run type checking
uv run mypy src/

# 4. Run tests
uv run pytest -v

# 5. Build development
./build.sh

# 6. Build production
./build.sh cython

# 7. Test imports
python -c "import your_package; print('✅ Import works!')"

# 8. Test CI locally
./test-ci-locally.sh

# 9. Start service
uv run uvicorn your_package:app --reload

# 10. Test API
curl http://localhost:8000
```

## 🚀 Deployment

After customization:

```bash
# 1. Create GitHub repository
# Visit: https://github.com/new

# 2. Push code
git remote add origin https://github.com/yourusername/your-project.git
git branch -M main
git push -u origin main

# 3. GitHub Actions will automatically:
#    - Run all tests
#    - Build Docker image
#    - Create releases (on main merge)
```

## 📚 Additional Resources

- **Full Guide:** See `REUSABILITY_GUIDE.md` for detailed customization
- **Development:** See `DEVELOPMENT.md` for development workflow
- **Versioning:** See `VERSIONING.md` for release management
- **Testing:** See `TESTING_SUMMARY.md` for CI/CD testing

## 💡 Tips

### Tip 1: Keep Template Updated

```bash
# In your template repo
git remote add template https://github.com/original/template.git
git fetch template
git merge template/main --allow-unrelated-histories
```

### Tip 2: Create Multiple Variants

```bash
# Microservice variant
cythonize-package-template-microservice/

# CLI tool variant
cythonize-package-template-cli/

# Library variant
cythonize-package-template-lib/
```

### Tip 3: Use with Copier

```bash
pip install copier
copier copy gh:yourusername/template-repo my-new-project
```

## ❓ FAQ

**Q: Can I use this for non-FastAPI projects?**
A: Yes! Remove FastAPI deps and modify the application structure.

**Q: Will GitHub Actions work immediately?**
A: Yes! Workflows are generic and work for any Python project.

**Q: Can I add more pre-commit hooks?**
A: Yes! Edit `.pre-commit-config.yaml` and add your hooks.

**Q: How do I update existing projects with template changes?**
A: Add template as remote, fetch, and merge changes manually.

**Q: Can I use different version control platforms?**
A: Yes! GitLab CI/CD and Azure DevOps can use similar patterns.

## 🎉 You're Ready

Run the setup script and start building your new project:

```bash
./scripts/setup-new-project.sh
```

Happy coding! 🚀
