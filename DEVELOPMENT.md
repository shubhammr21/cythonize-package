# Development Guide

## 🛠️ Development Setup

### Prerequisites

- Python 3.11+
- uv (package manager)
- Docker (for local CI testing)
- Git

### Initial Setup

```bash
# Clone the repository
git clone <repository-url>
cd cythonize-package

# Install all dependencies (including dev tools)
uv sync --all-extras

# Install pre-commit hooks
uv run pre-commit install --install-hooks
uv run pre-commit install --hook-type commit-msg
```

## 🔍 Code Quality Tools

### Ruff (Linting & Formatting)

**Ruff** replaces multiple tools: black, isort, flake8, pylint, and more.

```bash
# Run linter with auto-fix
uv run ruff check --fix .

# Format all files
uv run ruff format .

# Check without fixing
uv run ruff check .
```

**Configuration:** See `[tool.ruff]` in `pyproject.toml` or `.ruff.toml`

**Enabled Rules:**

- E, W (pycodestyle)
- F (pyflakes)
- I (isort)
- N (pep8-naming)
- UP (pyupgrade)
- ANN (annotations)
- S (bandit/security)
- B (bugbear)
- C4 (comprehensions)
- And 40+ more rule sets!

### Bandit (Security Scanning)

```bash
# Run security scan
uv run bandit -r src/ -c pyproject.toml

# Generate JSON report
uv run bandit -r src/ -c pyproject.toml -f json -o bandit-report.json
```

### Mypy (Type Checking)

```bash
# Run type checker
uv run mypy src/ --strict --ignore-missing-imports

# Check specific file
uv run mypy src/cythonize_package/app.py
```

**Configuration:** See `[tool.mypy]` in `pyproject.toml`

### Pre-commit Hooks

Pre-commit hooks automatically run before each commit to ensure code quality.

**Installed Hooks:**

- ✅ Ruff (linting & formatting)
- ✅ Bandit (security)
- ✅ Mypy (type checking)
- ✅ File checks (trailing whitespace, EOF, etc.)
- ✅ YAML/JSON/TOML validation
- ✅ Shellcheck (shell scripts)
- ✅ Markdownlint (markdown files)
- ✅ Conventional commits (commit message format)

```bash
# Run hooks manually
uv run pre-commit run --all-files

# Update hooks to latest versions
uv run pre-commit autoupdate

# Skip hooks (not recommended)
git commit --no-verify
```

## 📝 Commit Message Convention

We use **Conventional Commits** format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Test changes
- `chore`: Build/tooling changes
- `ci`: CI/CD changes
- `perf`: Performance improvements
- `build`: Build system changes

**Examples:**

```bash
# Good commits
git commit -m "feat: add user authentication endpoint"
git commit -m "fix: resolve memory leak in service layer"
git commit -m "docs: update installation instructions"
git commit -m "ci: add Python 3.12 to test matrix"

# Bad commits (will be rejected)
git commit -m "fixed stuff"
git commit -m "WIP"
git commit -m "Update code"
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
uv run pytest test_api.py -v

# Run with coverage
uv run pytest test_api.py -v --cov=src --cov-report=html

# Run specific test
uv run pytest test_api.py::test_root -v
```

### Test Structure

```python
"""Test suite for the Cythonized FastAPI service."""
from httpx import Client
from cythonize_package import get_app

client = Client(app=get_app(), base_url="http://testserver")

def test_root() -> None:
    """Test the root endpoint."""
    response = client.get("/")
    assert response.status_code == 200
```

## 🏗️ Building

### Development Build

```bash
# Build with Python source (fast, for development)
./build.sh

# Or manually
uv build
```

### Production Build

```bash
# Build with Cython (slow, for distribution)
./build.sh cython

# Or manually
USE_CYTHON=1 uv build
```

### Verification

```bash
# Verify the build
./verify.sh

# Manually check wheel contents
unzip -l dist/*.whl
```

## 🐳 Docker Development

### Build Docker Image

```bash
# Build the image
docker build -t cythonize-package:local .

# Or use docker-compose
docker-compose build
```

### Run Locally

```bash
# Run with docker-compose
docker-compose up

# Or run directly
docker run -p 8000:8000 cythonize-package:local
```

### Test in Docker

```bash
# Test the endpoint
curl http://localhost:8000/
```

## 🔄 GitHub Actions Testing (Local)

### Using Act

Install [act](https://github.com/nektos/act) to test GitHub Actions locally:

```bash
# Install act (macOS)
brew install act

# Install act (Linux)
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
```

### Run Workflows Locally

```bash
# Run all workflows
act

# Run specific job
act -j lint
act -j test
act -j build-prod

# Run with Docker
act --container-architecture linux/amd64

# List available workflows
act -l
```

### Using Docker Compose (Alternative)

```bash
# Create a test container
docker-compose run --rm app uv run pytest test_api.py -v

# Run linting in container
docker-compose run --rm app uv run ruff check .

# Run type checking in container
docker-compose run --rm app uv run mypy src/
```

## 🧹 Cleanup

### Clean Build Artifacts

```bash
# Clean everything
./clean.sh

# Or manually
rm -rf dist/ build/ src/*.egg-info src/**/*.c src/**/*.so __pycache__
```

### Clean Development Environment

```bash
# Remove virtual environment
rm -rf .venv

# Reinstall dependencies
uv sync --all-extras
```

## 📊 Code Quality Checklist

Before pushing code, ensure:

- [ ] All tests pass: `uv run pytest test_api.py -v`
- [ ] Linting passes: `uv run ruff check .`
- [ ] Formatting applied: `uv run ruff format .`
- [ ] Type checking passes: `uv run mypy src/`
- [ ] Security scan clean: `uv run bandit -r src/ -c pyproject.toml`
- [ ] Pre-commit hooks pass: `uv run pre-commit run --all-files`
- [ ] Build succeeds: `./build.sh cython`
- [ ] Verification passes: `./verify.sh`
- [ ] Commit message follows convention

**Tip:** Pre-commit hooks will automatically check most of these!

## 🚀 Development Workflow

### Standard Workflow

```bash
# 1. Create feature branch
git checkout -b feat/my-new-feature

# 2. Make changes
vim src/cythonize_package/app.py

# 3. Run tests
uv run pytest test_api.py -v

# 4. Check code quality (auto-run by pre-commit)
uv run ruff check --fix .
uv run ruff format .

# 5. Commit (pre-commit hooks run automatically)
git add .
git commit -m "feat: add new feature"

# 6. Push
git push origin feat/my-new-feature

# 7. Create Pull Request
```

### Hot Fix Workflow

```bash
# 1. Create hotfix branch
git checkout -b fix/urgent-bug

# 2. Fix the bug
vim src/cythonize_package/service.py

# 3. Test thoroughly
uv run pytest test_api.py -v
./build.sh cython
./verify.sh

# 4. Commit and push
git add .
git commit -m "fix: resolve critical bug in service layer"
git push origin fix/urgent-bug
```

## 🔧 Troubleshooting

### Pre-commit Hooks Fail

```bash
# Update hooks
uv run pre-commit autoupdate

# Clear cache
uv run pre-commit clean

# Reinstall
uv run pre-commit uninstall
uv run pre-commit install --install-hooks
```

### Linting Issues

```bash
# Auto-fix most issues
uv run ruff check --fix --unsafe-fixes .

# Check specific file
uv run ruff check src/cythonize_package/app.py
```

### Build Failures

```bash
# Clean and rebuild
./clean.sh
uv sync --all-extras
./build.sh cython
```

### Docker Issues

```bash
# Clean Docker cache
docker-compose down -v
docker system prune -a

# Rebuild from scratch
docker-compose build --no-cache
```

## 📚 Additional Resources

- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [Pre-commit Documentation](https://pre-commit.com/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Mypy Documentation](https://mypy.readthedocs.io/)
- [Bandit Documentation](https://bandit.readthedocs.io/)
- [Act Documentation](https://github.com/nektos/act)

## 🎯 Best Practices

1. **Always use pre-commit hooks** - They catch issues before CI
2. **Write meaningful commit messages** - Follow conventional commits
3. **Test before pushing** - Run full test suite locally
4. **Keep dependencies updated** - Run `uv sync` regularly
5. **Use type hints** - Helps catch bugs early
6. **Document your code** - Write docstrings for public APIs
7. **Security first** - Address Bandit warnings
8. **Clean builds** - Run `./clean.sh` between builds

## 💡 Tips

- Use `uv run` prefix for all dev tools to ensure correct environment
- Pre-commit hooks can be slow first time (installing environments)
- GitHub Actions cache speeds up CI significantly
- Docker multi-stage builds keep image size small
- Ruff is faster than running black + isort + flake8 separately
- Type hints help IDEs provide better autocomplete

---

**Happy coding! 🎉**
