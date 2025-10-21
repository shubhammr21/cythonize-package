# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### 🚀 Features

- FastAPI service with Cython source code protection using uv
- Automated build artifact cleanup system
- Comprehensive development workflow with pre-commit, ruff, and ci/cd
- Pre-commit hooks with 18+ quality checks
- GitHub Actions CI/CD pipeline
- Docker support with multi-stage builds
- Local CI testing script

### 🐛 Bug Fixes

- Resolve shellcheck and markdownlint issues in pre-commit hooks
- Fix missing fi statement in verify.sh

### 📚 Documentation

- Add comprehensive setup summary
- Complete development guide (DEVELOPMENT.md)
- Pre-commit hooks guide (PRE_COMMIT_GUIDE.md)
- Build artifact cleanup guide (CLEANUP_GUIDE.md)
- Quick start guide (QUICK_START.md)

### ♻️ Code Refactoring

- Remove print statements from tests
- Add proper type hints
- Fix all Ruff linting issues in strict mode
- Replace assert with proper error handling
- Use Path.resolve() instead of abspath

---

## Contributing

When contributing to this project, please ensure your commits follow the [Conventional Commits](https://www.conventionalcommits.org/) specification. This allows automatic changelog generation and semantic versioning.

### Commit Message Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:** feat, fix, docs, style, refactor, perf, test, build, ci, chore

**Breaking Changes:** Add `BREAKING CHANGE:` in the footer or append `!` after the type.
