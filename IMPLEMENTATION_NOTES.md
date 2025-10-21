# Implementation Notes

## What Was Adopted from Provided Links

### From Link 1: PyTauri Cython Tutorial

**URL**: <https://pytauri.github.io/pytauri/latest/usage/tutorial/build-standalone-cython/>

#### Adopted Concepts

1. ✅ **USE_CYTHON Environment Variable Pattern**
   - Used `USE_CYTHON=1` to conditionally enable Cython compilation
   - Allows development builds without Cython

2. ✅ **INCLUDE_FILE_PATTERNS and EXCLUDE_FILE_PATTERNS**
   - `INCLUDE_FILE_PATTERNS`: Files to cythonize (app.py, models.py, service.py)
   - `EXCLUDE_FILE_PATTERNS`: Files to keep as Python (**init**.py, **main**.py)

3. ✅ **Custom install Command**
   - Subclassed `setuptools.command.install.install`
   - Removes protected .py files from wheel after compilation
   - Cleans up .c, .cpp, and bytecode files

4. ✅ **Cythonize Configuration**
   - Used `Cython.Build.cythonize()` function
   - Set `language_level: "3"` for Python 3
   - Set `embedsignature: True` for better introspection

5. ✅ **File Pattern Logic**
   - `norm_files_set()` function to normalize file paths
   - Used `include_files_set.difference(exclude_files_set)` logic

#### What Was Modified

- Removed PyTauri-specific code (RustExtension, PYTAURI_STANDALONE)
- Simplified to focus on pure Cython compilation
- Adapted paths for our project structure (`src/` prefix)

### From Link 2: UV Build Backend Documentation

**URL**: <https://docs.astral.sh/uv/concepts/build-backend/#include-and-exclude-syntax>

#### Adopted Concepts

1. ✅ **Project Structure**
   - Used `src/` layout with package under `src/cythonize_package/`
   - Standard Python package structure

2. ✅ **Build Backend Configuration**
   - Initially tried `uv_build` but switched to `setuptools.build_meta`
   - Reason: uv_build doesn't support extension modules yet

3. ✅ **Package Discovery**
   - Used `[tool.setuptools]` with `packages = {find = {where = ["src"]}}`

#### What Was NOT Used

- `tool.uv.build-backend` settings (not compatible with Cython)
- File inclusion/exclusion patterns from uv (using setup.py instead)
- Native uv build backend (requires setuptools for extensions)

### Why setuptools Instead of uv_build?

From the documentation:
> "The uv build backend currently only supports pure Python code."

**Decision**: Use setuptools because:

1. Cython requires build hooks via setup.py
2. Extension modules need C compiler integration
3. Mature ecosystem for native extensions
4. uv_build will support this in the future

## Current Architecture

```
Build Process Flow:
1. uv reads pyproject.toml
2. Sees build-backend = "setuptools.build_meta"
3. Calls setup.py for build instructions
4. If USE_CYTHON=1:
   - Cython compiles .py → .c
   - C compiler builds .c → .so
   - Custom install removes .py files
5. Creates wheel with only .so files
```

## Key Differences from PyTauri

| Aspect         | PyTauri          | Our Implementation  |
| -------------- | ---------------- | ------------------- |
| Focus          | Tauri GUI apps   | FastAPI web service |
| Language       | Python + Rust    | Python only         |
| Extension      | PyO3 + Cython    | Cython only         |
| Build Backend  | setuptools       | setuptools          |
| Extra Features | Rust integration | None                |

## Summary

**From PyTauri Tutorial (Link 1):**

- ✅ Entire setup.py structure
- ✅ Custom install command
- ✅ File pattern system
- ✅ Cython configuration
- ✅ Environment variable control

**From UV Documentation (Link 2):**

- ✅ Project structure guidelines
- ✅ Package discovery setup
- ⚠️ Build backend (switched to setuptools)

**Original Contributions:**

- FastAPI service implementation
- Pydantic models
- Build automation scripts
- Verification scripts
- Documentation
