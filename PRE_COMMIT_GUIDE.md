# Pre-commit Hooks Guide

## 🎯 Overview

This project uses **pre-commit hooks** to ensure code quality, security, and consistency before code is committed to the repository. Pre-commit hooks run automatically on every `git commit` and will prevent commits if any check fails.

## 📦 What's Included

### Code Quality Hooks

#### 1. **Ruff** - Linting & Formatting

- **Purpose**: Fast Python linter and formatter (replaces black, isort, flake8)
- **What it checks**:
  - Code style (PEP 8)
  - Import sorting
  - Code complexity
  - Best practices
  - Common bugs
- **Auto-fix**: ✅ Yes

#### 2. **Bandit** - Security Scanner

- **Purpose**: Find common security issues in Python code
- **What it checks**:
  - SQL injection vulnerabilities
  - Hardcoded passwords
  - Insecure temporary files
  - Use of `eval()` and `exec()`
  - Weak cryptography
- **Auto-fix**: ❌ No (requires manual review)

#### 3. **Mypy** - Type Checker

- **Purpose**: Static type checking for Python
- **What it checks**:
  - Type annotations
  - Type consistency
  - Missing type hints
  - Type errors
- **Auto-fix**: ❌ No (requires manual fixes)

### File Quality Hooks

#### 4. **Pre-commit-hooks** - File Checks

- **trailing-whitespace**: Remove trailing spaces
- **end-of-file-fixer**: Ensure files end with newline
- **mixed-line-ending**: Convert to LF line endings
- **check-yaml**: Validate YAML files
- **check-toml**: Validate TOML files
- **check-json**: Validate JSON files
- **check-ast**: Check Python syntax
- **check-docstring-first**: Ensure docstrings are first
- **debug-statements**: Find leftover debug code
- **check-added-large-files**: Prevent committing large files (>1MB)
- **check-merge-conflict**: Find merge conflict markers
- **detect-private-key**: Find accidentally committed private keys

#### 5. **Shellcheck** - Shell Script Linter

- **Purpose**: Find bugs in shell scripts
- **What it checks**:
  - Common shell scripting errors
  - Portability issues
  - Security issues
  - Best practices
- **Auto-fix**: ❌ No

#### 6. **Markdownlint** - Markdown Linter

- **Purpose**: Enforce markdown style consistency
- **What it checks**:
  - Heading styles
  - List formatting
  - Link validity
  - Code block formatting
- **Auto-fix**: ✅ Yes (most rules)

#### 7. **Conventional Commits** - Commit Message Validator

- **Purpose**: Enforce conventional commit message format
- **What it checks**:
  - Commit message format
  - Type prefix (feat, fix, docs, etc.)
  - Description clarity
- **Auto-fix**: ❌ No (requires rewriting commit message)

## 🚀 Installation

### First Time Setup

```bash
# Install all dependencies including pre-commit
uv sync --all-extras

# Install git hooks
uv run pre-commit install --install-hooks

# Install commit message hook
uv run pre-commit install --hook-type commit-msg
```

### Verify Installation

```bash
# Check if hooks are installed
ls -la .git/hooks/

# Should see:
# - pre-commit
# - commit-msg
```

## 💻 Usage

### Automatic (Recommended)

Pre-commit hooks run automatically on `git commit`:

```bash
# Make changes
vim src/cythonize_package/app.py

# Stage changes
git add src/cythonize_package/app.py

# Commit (hooks run automatically)
git commit -m "feat: add new endpoint"

# If hooks pass: ✅ Commit succeeds
# If hooks fail: ❌ Commit is blocked, fix issues
```

### Manual Run

Run hooks on all files:

```bash
# Run all hooks
uv run pre-commit run --all-files

# Run specific hook
uv run pre-commit run ruff --all-files
uv run pre-commit run mypy --all-files
```

Run hooks on staged files only:

```bash
uv run pre-commit run
```

### Skipping Hooks (Not Recommended)

⚠️ **Only use in emergencies!**

```bash
# Skip pre-commit hooks (NOT RECOMMENDED)
git commit --no-verify -m "emergency fix"

# Skip specific hook
SKIP=mypy git commit -m "wip: work in progress"
```

## 🔧 Configuration

### Pre-commit Config

Location: `.pre-commit-config.yaml`

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.8.4
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
```

### Ruff Config

Location: `pyproject.toml` or `.ruff.toml`

```toml
[tool.ruff]
line-length = 88
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "UP", "ANN", "S", "B"]
ignore = ["ANN101", "ANN102"]
```

## 🎯 What Happens During Commit

### Step-by-Step Flow

```
1. You run: git commit -m "feat: add feature"
   ↓
2. Pre-commit hook activates
   ↓
3. Runs checks in order:
   ├─ Ruff linter       (auto-fixes code issues)
   ├─ Ruff formatter    (formats code)
   ├─ Bandit            (security scan)
   ├─ Mypy              (type checking)
   ├─ File checks       (YAML, trailing spaces, etc.)
   ├─ Shellcheck        (shell scripts)
   └─ Markdownlint      (markdown files)
   ↓
4. If all pass: ✅ Commit succeeds
   If any fail: ❌ Commit blocked
   ↓
5. Fix issues and try again
```

## 📋 Common Scenarios

### Scenario 1: Formatting Issues

```bash
$ git commit -m "feat: add feature"

ruff...................................................Failed
- hook id: ruff
- exit code: 1

src/cythonize_package/app.py:10:1: E501 Line too long

# Fix: Run formatter
$ uv run ruff format .
$ git add .
$ git commit -m "feat: add feature"
✅ Success!
```

### Scenario 2: Type Errors

```bash
$ git commit -m "feat: add function"

mypy...................................................Failed
- hook id: mypy
- exit code: 1

src/cythonize_package/models.py:15: error: Missing return type

# Fix: Add type hints
def get_user() -> User:  # Add -> User
    ...

$ git add .
$ git commit -m "feat: add function"
✅ Success!
```

### Scenario 3: Security Issues

```bash
$ git commit -m "feat: add database"

bandit.................................................Failed
- hook id: bandit
- exit code: 1

>> Issue: Use of insecure MD5 hash function
   Severity: Medium   Confidence: High

# Fix: Use secure hash
import hashlib
# Bad:  hashlib.md5(data)
# Good: hashlib.sha256(data)

$ git add .
$ git commit -m "feat: add database"
✅ Success!
```

### Scenario 4: Commit Message Format

```bash
$ git commit -m "added new feature"

Conventional Commit....................................Failed
- hook id: conventional-pre-commit
- exit code: 1

Commit message does not follow Conventional Commits format

# Fix: Use proper format
$ git commit -m "feat: add new feature"
✅ Success!
```

## 🛠️ Troubleshooting

### Hooks Not Running

```bash
# Reinstall hooks
uv run pre-commit uninstall
uv run pre-commit install --install-hooks
uv run pre-commit install --hook-type commit-msg
```

### Hooks Taking Too Long

```bash
# First run is slow (installing environments)
# Subsequent runs are fast (cached)

# Clear cache if needed
uv run pre-commit clean
```

### Hook Errors

```bash
# Update hooks to latest version
uv run pre-commit autoupdate

# Run with verbose output
uv run pre-commit run --all-files --verbose
```

### Can't Fix Issues

```bash
# See detailed error output
uv run pre-commit run ruff --all-files --verbose

# Run tool directly
uv run ruff check src/cythonize_package/app.py --show-fixes
```

## 📚 Best Practices

### 1. Commit Often

```bash
# Good: Small, frequent commits
git commit -m "feat: add user model"
git commit -m "feat: add user service"
git commit -m "test: add user tests"

# Bad: Large, infrequent commits
git commit -m "feat: add everything"
```

### 2. Fix Issues Before Committing

```bash
# Run checks manually first
uv run pre-commit run --all-files

# Fix all issues
uv run ruff check --fix .
uv run ruff format .

# Then commit
git add .
git commit -m "feat: add feature"
```

### 3. Use Meaningful Commit Messages

```bash
# Good
git commit -m "feat: add user authentication with JWT tokens"
git commit -m "fix: resolve race condition in user service"

# Bad
git commit -m "feat: stuff"
git commit -m "fix: fix"
```

### 4. Don't Skip Hooks

```bash
# Never do this in production
git commit --no-verify

# Always fix issues instead
uv run ruff check --fix .
git add .
git commit -m "feat: add feature"
```

## 🎓 Learning Resources

- [Pre-commit Documentation](https://pre-commit.com/)
- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Mypy Documentation](https://mypy.readthedocs.io/)
- [Bandit Documentation](https://bandit.readthedocs.io/)

## 🔍 Hook Details

### Complete Hook List

| Hook                    | Purpose                | Auto-fix | Speed  |
| ----------------------- | ---------------------- | -------- | ------ |
| ruff (lint)             | Code quality           | ✅        | Fast   |
| ruff-format             | Code formatting        | ✅        | Fast   |
| bandit                  | Security scanning      | ❌        | Medium |
| mypy                    | Type checking          | ❌        | Slow   |
| trailing-whitespace     | Remove trailing spaces | ✅        | Fast   |
| end-of-file-fixer       | Fix EOF                | ✅        | Fast   |
| mixed-line-ending       | Convert line endings   | ✅        | Fast   |
| check-yaml              | Validate YAML          | ❌        | Fast   |
| check-toml              | Validate TOML          | ❌        | Fast   |
| check-json              | Validate JSON          | ❌        | Fast   |
| check-ast               | Check Python syntax    | ❌        | Fast   |
| check-docstring-first   | Docstring order        | ❌        | Fast   |
| debug-statements        | Find debug code        | ❌        | Fast   |
| check-added-large-files | Prevent large files    | ❌        | Fast   |
| check-merge-conflict    | Find merge markers     | ❌        | Fast   |
| detect-private-key      | Find private keys      | ❌        | Fast   |
| shellcheck              | Shell script linting   | ❌        | Fast   |
| markdownlint            | Markdown linting       | ✅        | Fast   |
| conventional-pre-commit | Commit message format  | ❌        | Fast   |

## 💡 Pro Tips

1. **Run hooks before staging**: `uv run pre-commit run --all-files`
2. **Auto-fix most issues**: Ruff handles 90% of formatting/linting
3. **Type hints help**: Add types as you code, easier than retrofitting
4. **Security first**: Address Bandit warnings immediately
5. **Commit message matters**: Clear messages help team understand changes
6. **Update regularly**: `uv run pre-commit autoupdate` monthly
7. **Test locally**: Run `./test-ci-locally.sh` before pushing

---

**Questions?** Check `DEVELOPMENT.md` for more details! 🚀
