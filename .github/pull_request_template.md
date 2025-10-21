## Description

<!-- Provide a brief description of the changes in this PR -->

## Type of Change

<!-- Mark the relevant option with an "x" -->

- [ ] 🐛 Bug fix (patch) - `fix:`
- [ ] 🚀 New feature (minor) - `feat:`
- [ ] 💥 Breaking change (major) - `feat!:` or `fix!:` or `BREAKING CHANGE:`
- [ ] 📚 Documentation update - `docs:`
- [ ] ♻️ Code refactoring - `refactor:`
- [ ] ⚡ Performance improvement - `perf:`
- [ ] ✅ Test update - `test:`
- [ ] 🔨 Build/tooling change - `build:`
- [ ] 👷 CI/CD change - `ci:`
- [ ] 🔧 Chore/maintenance - `chore:`

## Commit Message Format

This project follows [Conventional Commits](https://www.conventionalcommits.org/).

**Example commit messages:**
```bash
feat: add user authentication endpoint
fix: resolve memory leak in cache
docs: update API documentation
feat!: redesign API response structure (BREAKING CHANGE)
```

**Your commit(s) should:**
- [ ] Follow conventional commit format: `type(scope): description`
- [ ] Use present tense ("add feature" not "added feature")
- [ ] Use imperative mood ("move cursor to..." not "moves cursor to...")
- [ ] Reference issues/PRs if applicable (e.g., "fixes #123")

## Semantic Versioning Impact

This PR will trigger a **[PATCH/MINOR/MAJOR]** version bump.

<!--
Automatic versioning based on commit types:
- feat: → MINOR bump (0.x.0)
- fix: → PATCH bump (0.0.x)
- BREAKING CHANGE: → MAJOR bump (x.0.0)
- docs/refactor/perf/build: → PATCH bump
- ci/test/chore: → No version bump
-->

## Changes Made

<!-- List the specific changes in this PR -->

-
-
-## Related Issues

<!-- Link to related issues -->

Closes #
Fixes #
Relates to #

## Testing

<!-- Describe how you tested these changes -->

- [ ] Unit tests pass (`uv run pytest test_api.py -v`)
- [ ] Linting passes (`uv run ruff check .`)
- [ ] Type checking passes (`uv run mypy src/`)
- [ ] Pre-commit hooks pass (`uv run pre-commit run --all-files`)
- [ ] Build succeeds (`./build.sh cython`)
- [ ] Manual testing performed

**Test environment:**
- Python version:
- OS:

## Checklist

<!-- Check all applicable items -->

- [ ] My code follows the project's code style
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published

## Breaking Changes

<!-- If this is a breaking change, describe the impact and migration path -->

**Is this a breaking change?** Yes / No

If yes:
- **What breaks:**
- **Why it's necessary:**
- **Migration guide:**

## Additional Context

<!-- Add any other context, screenshots, or information about the PR here -->

## Changelog Entry

<!-- This will be automatically generated, but you can preview it here -->

**Category:** [Features/Bug Fixes/Documentation/etc.]

**Entry:**
```
- [Description of change] ([#PR_NUMBER](link)) by [@YOUR_USERNAME](link)
```

---

**Note:** This PR will be included in the next release with proper versioning and changelog generation. Your contribution will be automatically credited! 🎉
