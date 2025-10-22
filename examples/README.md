# 📦 Complete Monorepo Examples

Working examples showing Cython protection in a uv workspace monorepo.

## 📂 Structure

```
examples/
├── README.md                   # This file
├── pyproject.toml              # Root workspace config
├── build-all.sh                # Build everything
├── services/
│   └── example-service/        # Complete FastAPI service
│       ├── pyproject.toml
│       ├── setup.py
│       ├── build.sh
│       ├── Dockerfile
│       └── example_service/
│           ├── __init__.py     # Not compiled
│           ├── main.py         # ✅ Compiled to .so
│           └── handlers.py     # ✅ Compiled to .so
└── packages/
    └── example-package/        # Shared library
        ├── pyproject.toml
        ├── setup.py
        ├── build.sh
        └── example_package/
            ├── __init__.py     # Not compiled
            └── utils.py        # ✅ Compiled to .so
```

## 🚀 Quick Start

```bash
cd examples/

# Initialize workspace
uv sync

# Build all packages (development mode)
./build-all.sh

# Build all with Cython protection
./build-all.sh cython

# Verify compilation
unzip -l services/example-service/dist/*.whl | grep "\.so"
unzip -l packages/example-package/dist/*.whl | grep "\.so"

# Install and test
uv pip install packages/example-package/dist/*.whl
uv pip install services/example-service/dist/*.whl

# Run service
cd services/example-service
uv run uvicorn example_service.main:app --reload
```

## 📝 What Gets Cythonized?

### Example Service (`services/example-service`)

**Compiled (hidden source):**
- `example_service/main.py` → `main.cpython-311-darwin.so`
- `example_service/handlers.py` → `handlers.cpython-311-darwin.so`

**Not compiled (visible):**
- `example_service/__init__.py` (entry point)

### Example Package (`packages/example-package`)

**Compiled (hidden source):**
- `example_package/utils.py` → `utils.cpython-311-darwin.so`

**Not compiled (visible):**
- `example_package/__init__.py` (entry point)

## 🧪 Verification

### Check Source Protection

```python
# This should fail (source is hidden)
import inspect
from example_service import main

try:
    source = inspect.getsource(main.create_app)
    print("❌ FAILED: Source is visible!")
except OSError as e:
    print("✅ PASS: Source is protected!")
    print(f"   Error: {e}")
```

### Check Wheel Contents

```bash
# Example service wheel
unzip -l services/example-service/dist/*.whl

# Should show:
# example_service/__init__.py      (text file)
# example_service/main.*.so        (binary)
# example_service/handlers.*.so    (binary)

# Example package wheel
unzip -l packages/example-package/dist/*.whl

# Should show:
# example_package/__init__.py      (text file)
# example_package/utils.*.so       (binary)
```

## 🐳 Docker Deployment

```bash
cd services/example-service

# Build with Cython protection
docker build -t example-service:latest .

# Run
docker run -p 8000:8000 example-service:latest

# Test
curl http://localhost:8000/
curl http://localhost:8000/health
```

## 📚 Learn More

- **Parent `MONOREPO_SETUP.md`**: Complete architecture guide
- **Parent `WORKSPACE_MIGRATION.md`**: Migrate existing projects
- **Individual `setup.py`**: See Cython configuration patterns
- **Individual `build.sh`**: See build scripts

## 🎯 Use This As Template

Copy this `examples/` folder to start your own monorepo:

```bash
# Option 1: Use the init script
cd ..
./scripts/init-monorepo.sh

# Option 2: Copy examples directly
cp -r examples/ my-new-project/
cd my-new-project/
# Customize pyproject.toml, service names, etc.
```

## 🔧 Customization

### Add New Service

```bash
cd examples/
./scripts/add-package.sh service my-new-service

# Edit generated files:
# - services/my-new-service/pyproject.toml
# - services/my-new-service/setup.py (update INCLUDE_FILE_PATTERNS)
# - services/my-new-service/my_new_service/*.py
```

### Add New Package

```bash
./scripts/add-package.sh package my-utils

# Edit generated files:
# - packages/my-utils/pyproject.toml
# - packages/my-utils/setup.py (update INCLUDE_FILE_PATTERNS)
# - packages/my-utils/my_utils/*.py
```

## ❓ FAQ

### Why is `__init__.py` not compiled?

It needs to be importable as an entry point. Compiling it can cause import issues.

### Can I compile everything?

Technically yes, but not recommended. Keep entry points (like `__init__.py`) as `.py` files.

### What if compilation fails?

Check:
1. Cython is installed: `uv pip list | grep Cython`
2. `USE_CYTHON=1` is set
3. Files exist in `INCLUDE_FILE_PATTERNS`
4. No syntax errors in Python code

### How do I debug Cython code?

Use development mode:
```bash
./build.sh  # Without 'cython' argument
```

This builds without Cython so you can debug normally.

## ✅ Success Checklist

- [ ] `uv sync` works
- [ ] `./build-all.sh` builds all packages
- [ ] `./build-all.sh cython` creates `.so` files
- [ ] Wheels contain `.so` binaries (check with `unzip -l`)
- [ ] Service runs: `uvicorn example_service.main:app`
- [ ] `inspect.getsource()` fails on compiled modules
- [ ] Docker build works
- [ ] All tests pass

## 🎉 You're Ready

This example demonstrates:
- ✅ Complete workspace setup
- ✅ Service with Cython protection
- ✅ Shared package with Cython protection
- ✅ Build automation
- ✅ Docker deployment
- ✅ Source code hidden in production

Start building your protected microservices!
