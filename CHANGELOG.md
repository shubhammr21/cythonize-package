# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.0.0 (2025-10-22)


### 🚀 Features

* add comprehensive development workflow with pre-commit, ruff, and ci/cd ([709c62f](https://github.com/shubhammr21/cythonize-package/commit/709c62f74d9e2d23823197438e82ad14777a00f0))
* add template reusability system with automated setup script ([585666b](https://github.com/shubhammr21/cythonize-package/commit/585666b85d97706e642501fa71327f7dedaa23b3))
* FastAPI service with Cython source code protection using uv ([259f3f4](https://github.com/shubhammr21/cythonize-package/commit/259f3f4a7eaf6db804ad3be2cafea65e25719ed3))
* implement automated build artifact cleanup system ([693b7a4](https://github.com/shubhammr21/cythonize-package/commit/693b7a4f22495e72e85de9e5eaa63f61f093e729))
* implement semantic versioning with automated changelog generation ([826e643](https://github.com/shubhammr21/cythonize-package/commit/826e643f9c3f103c631c8c3c60a7e0b0d4c5ee59))


### 🐛 Bug Fixes

* resolve shellcheck and markdownlint issues in pre-commit hooks ([8620b5e](https://github.com/shubhammr21/cythonize-package/commit/8620b5e8864a9dd82d6a7cd1e06f5d68f6d95a52))
* use TestClient from FastAPI for tests and allow README.md in Docker ([1c273c5](https://github.com/shubhammr21/cythonize-package/commit/1c273c5022a946432667cdee535ca2b350982863))


### 📚 Documentation

* add comprehensive GitHub Actions testing summary ([bd059c1](https://github.com/shubhammr21/cythonize-package/commit/bd059c1879f60b96104d829a70f1140799abe3d7))
* add comprehensive project summary ([9d72b16](https://github.com/shubhammr21/cythonize-package/commit/9d72b160ce70e859c797c206b40e7ee082f59c4c))
* add comprehensive release management summary ([980147e](https://github.com/shubhammr21/cythonize-package/commit/980147e4cd94f325f6f12ff7bd1d82862da9112e))
* add comprehensive setup summary and update markdownlint config ([e89ea15](https://github.com/shubhammr21/cythonize-package/commit/e89ea15514b5526926582e0f3936b630c10e831d))

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
