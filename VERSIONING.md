# Versioning Guide

This project follows [Semantic Versioning 2.0.0](https://semver.org/) and uses automated release management.

## Semantic Versioning

Given a version number `MAJOR.MINOR.PATCH` (e.g., `1.4.2`):

- **MAJOR** version (1.x.x) - Incompatible API changes (breaking changes)
- **MINOR** version (x.4.x) - New features (backward compatible)
- **PATCH** version (x.x.2) - Bug fixes (backward compatible)

### Pre-release Versions

- **Alpha**: `1.0.0-alpha.1` - Early development, unstable
- **Beta**: `1.0.0-beta.1` - Feature complete, testing phase
- **RC**: `1.0.0-rc.1` - Release candidate, final testing

## Automated Versioning

This project uses **semantic-release** to automatically:

1. Analyze commit messages
2. Determine version bump type
3. Generate changelog with PR numbers and contributors
4. Update version in `pyproject.toml`
5. Create GitHub release
6. Build and upload packages

### How It Works

Versioning is based on commit message types:

| Commit Type        | Version Bump  | Example                             |
| ------------------ | ------------- | ----------------------------------- |
| `feat:`            | MINOR (x.1.x) | `feat: add user authentication`     |
| `fix:`             | PATCH (x.x.1) | `fix: resolve memory leak`          |
| `perf:`            | PATCH (x.x.1) | `perf: optimize database queries`   |
| `docs:`            | PATCH (x.x.1) | `docs: update API documentation`    |
| `refactor:`        | PATCH (x.x.1) | `refactor: restructure auth module` |
| `build:`           | PATCH (x.x.1) | `build: update dependencies`        |
| `BREAKING CHANGE:` | MAJOR (1.x.x) | See below                           |

**No version bump:**
- `style:`, `test:`, `ci:`, `chore:`

### Breaking Changes

To trigger a MAJOR version bump, use one of these methods:

**Method 1: Exclamation mark**
```bash
git commit -m "feat!: change API endpoint structure"
```

**Method 2: Footer**
```bash
git commit -m "feat: change authentication method

BREAKING CHANGE: JWT token format has changed.
Clients must update their token parsing logic."
```

**Method 3: Body**
```bash
git commit -m "refactor: redesign user service

This is a breaking change because the User model
structure has been completely redesigned.

BREAKING CHANGE: User.get() now returns User object
instead of dict."
```

## Changelog Format

The changelog is automatically generated in `CHANGELOG.md` with:

### Standard Entry Format

```markdown
## [1.2.0](https://github.com/owner/repo/compare/v1.1.0...v1.2.0) (2025-10-22)

### 🚀 Features

* add user authentication ([#42](https://github.com/owner/repo/pull/42)) ([abc1234](https://github.com/owner/repo/commit/abc1234)), closes [#38](https://github.com/owner/repo/issues/38) by [@username](https://github.com/username)
* implement caching system ([#45](https://github.com/owner/repo/pull/45)) ([def5678](https://github.com/owner/repo/commit/def5678)) by [@contributor](https://github.com/contributor)

### 🐛 Bug Fixes

* resolve race condition in service layer ([#43](https://github.com/owner/repo/pull/43)) ([ghi9012](https://github.com/owner/repo/commit/ghi9012)) by [@developer](https://github.com/developer)
```

### What's Included

Each changelog entry includes:
- ✅ **Version number** (semantic)
- ✅ **Release date**
- ✅ **Commit categorization** (Features, Bug Fixes, etc.)
- ✅ **PR numbers** with links (e.g., `#42`)
- ✅ **Commit hashes** with links
- ✅ **Issue references** (e.g., `closes #38`)
- ✅ **Contributor usernames** (e.g., `@username`)
- ✅ **Comparison links** (previous version vs current)

## Release Process

### Automatic Release (Recommended)

1. **Merge PR to `main` branch**
   ```bash
   # Your PR is merged via GitHub
   ```

2. **GitHub Actions triggers automatically**
   - Analyzes all commits since last release
   - Determines version bump
   - Generates changelog
   - Updates `pyproject.toml`
   - Creates Git tag
   - Creates GitHub release
   - Builds packages

3. **Release is published**
   - Tagged in Git (e.g., `v1.2.0`)
   - Visible on GitHub Releases
   - Changelog updated
   - Contributors notified

### Manual Release (Alternative)

If you need to create a release manually:

```bash
# Install semantic-release
npm install -g \
  semantic-release@23 \
  @semantic-release/changelog@6 \
  @semantic-release/git@10 \
  @semantic-release/github@10 \
  @semantic-release/exec@6

# Run release
npx semantic-release
```

### Local Version Bump (Development)

For testing version bumps locally without releasing:

```bash
# Install standard-version
npm install -g standard-version

# Dry run (see what would happen)
npx standard-version --dry-run

# First release
npx standard-version --first-release

# Create release
npx standard-version

# Pre-release
npx standard-version --prerelease alpha
```

## Commit Message Examples

### Features (MINOR bump)

```bash
# Simple feature
git commit -m "feat: add email validation"

# Feature with scope
git commit -m "feat(auth): add OAuth2 support"

# Feature with body
git commit -m "feat: add user preferences

Users can now customize their dashboard layout
and notification settings."

# Feature with PR reference
git commit -m "feat: add dark mode support

Fixes #123
PR #124"
```

### Bug Fixes (PATCH bump)

```bash
# Simple fix
git commit -m "fix: resolve null pointer exception"

# Fix with scope
git commit -m "fix(api): handle timeout errors correctly"

# Fix with issue reference
git commit -m "fix: resolve memory leak in cache

Closes #45"
```

### Breaking Changes (MAJOR bump)

```bash
# Breaking change with exclamation
git commit -m "feat!: redesign API response format"

# Breaking change with footer
git commit -m "refactor: change authentication flow

BREAKING CHANGE: Old auth tokens are no longer valid.
Users must re-authenticate after upgrade."

# Multiple breaking changes
git commit -m "feat: upgrade to FastAPI 0.100

BREAKING CHANGE: Minimum Python version is now 3.11
BREAKING CHANGE: Some middleware signatures have changed"
```

### Other Commits

```bash
# Documentation
git commit -m "docs: update installation instructions"

# Performance
git commit -m "perf: optimize database queries"

# Refactoring
git commit -m "refactor: simplify user service logic"

# Build
git commit -m "build: update dependencies"

# CI/CD (no version bump)
git commit -m "ci: add Python 3.12 to test matrix"

# Chores (no version bump)
git commit -m "chore: update .gitignore"
```

## Version Workflow

### Development Workflow

```
1. Create feature branch
   ├─ feat: add feature A
   ├─ feat: add feature B
   └─ fix: resolve bug X

2. Open Pull Request
   └─ PR #123: Add features A and B

3. Merge to main
   └─ Triggers semantic-release

4. Automatic release
   ├─ Version: 1.1.0 → 1.2.0 (MINOR)
   ├─ Changelog updated
   ├─ Git tag: v1.2.0
   └─ GitHub Release created
```

### Pre-release Workflow

```bash
# Develop branch for pre-releases
git checkout -b develop

# Make changes
git commit -m "feat: experimental feature"

# Push to develop
git push origin develop

# Semantic-release creates: 1.2.0-develop.1
```

## Configuration Files

### `.releaserc.json`
Main semantic-release configuration:
- Commit analysis rules
- Changelog generation
- Version update commands
- Git and GitHub integration

### `.versionrc.json`
Standard-version configuration (alternative):
- Changelog format
- URL templates
- Commit message format

### `CHANGELOG.md`
Generated changelog file:
- All releases documented
- PR numbers and links
- Contributor information
- Categorized changes

## Best Practices

### 1. Write Clear Commit Messages

```bash
# Good
git commit -m "feat: add user password reset functionality"

# Bad
git commit -m "update stuff"
```

### 2. Reference Issues and PRs

```bash
git commit -m "fix: resolve login timeout issue

Fixes #123
PR #124"
```

### 3. Use Scopes for Context

```bash
git commit -m "feat(api): add rate limiting"
git commit -m "fix(ui): resolve button alignment"
git commit -m "docs(readme): add Docker instructions"
```

### 4. Document Breaking Changes Clearly

```bash
git commit -m "feat!: change API authentication method

BREAKING CHANGE: The old API key authentication is removed.
Use OAuth2 tokens instead. Migration guide: docs/migration.md"
```

### 5. Group Related Changes

Instead of:
```bash
git commit -m "feat: add feature 1"
git commit -m "feat: add feature 2"
git commit -m "fix: fix bug in feature 1"
```

Do:
```bash
# Squash related commits in PR
git commit -m "feat: add feature 1 and 2 with fixes"
```

## Querying Versions

### Check Current Version

```bash
# From pyproject.toml
grep version pyproject.toml

# From Git tags
git describe --tags --abbrev=0

# From changelog
head -n 10 CHANGELOG.md
```

### List All Versions

```bash
# Git tags
git tag -l "v*" --sort=-v:refname

# From changelog
grep "^## \[" CHANGELOG.md
```

### Version History

```bash
# Show commits since last tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# Show all releases
git log --oneline --decorate --all --graph --tags
```

## Troubleshooting

### No Release Created

**Problem:** Semantic-release doesn't create a release.

**Solutions:**
```bash
# 1. Check commit messages format
git log --oneline -10

# 2. Ensure commits trigger version bump
#    (feat, fix, perf, docs, refactor, build)

# 3. Check if [skip ci] in commit message

# 4. Verify GitHub token permissions
#    Settings > Actions > General > Workflow permissions
```

### Wrong Version Bump

**Problem:** Version jumped incorrectly (e.g., MINOR instead of PATCH).

**Solution:**
```bash
# Check commit types
git log --oneline --since="last release"

# feat: → MINOR bump
# fix: → PATCH bump
# BREAKING CHANGE: → MAJOR bump
```

### Changelog Missing PR Numbers

**Problem:** Changelog doesn't include PR numbers.

**Solution:**
```bash
# Use squash merge in GitHub
# Include PR number in commit message:
git commit -m "feat: new feature (#123)"

# Or reference in body:
git commit -m "feat: new feature

PR #123"
```

### Changelog Missing Contributors

**Problem:** Changelog doesn't show contributor usernames.

**Solution:**
```bash
# Contributors are extracted from:
# 1. GitHub PR author
# 2. Co-authored-by trailer:

git commit -m "feat: add feature

Co-authored-by: Username <email@example.com>"
```

## FAQ

**Q: Can I manually edit the version?**
A: Not recommended. Let semantic-release handle versioning. If needed, create a commit that triggers the correct bump.

**Q: How do I skip a release?**
A: Use commit types that don't trigger releases: `style:`, `test:`, `ci:`, `chore:`, or add `[skip ci]` to commit message.

**Q: Can I have multiple pre-release tracks?**
A: Yes! Configure branches in `.releaserc.json`:
```json
{
  "branches": [
    "main",
    { "name": "develop", "prerelease": true },
    { "name": "beta", "prerelease": "beta" }
  ]
}
```

**Q: How do I revert a bad release?**
A: Create a new release with fixes:
```bash
git revert <commit-hash>
git commit -m "revert: undo breaking change from v1.2.0"
```

**Q: Where are contributors shown?**
A: Contributors appear in:
1. `CHANGELOG.md` (with @username links)
2. GitHub Releases page
3. Release notes
4. PR comments (automatic)

## Resources

- [Semantic Versioning 2.0.0](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [semantic-release Documentation](https://semantic-release.gitbook.io/)
- [Keep a Changelog](https://keepachangelog.com/)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github)

---

**Questions?** Check the [Release Workflow](https://github.com/semantic-release/semantic-release/blob/master/docs/usage/workflow-configuration.md) documentation.
