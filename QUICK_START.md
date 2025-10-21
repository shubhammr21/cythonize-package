# Quick Start Guide

## 🚀 TL;DR

```bash
# Install dependencies
uv sync

# Run development server
uv run python main.py

# Run tests
uv run python test_api.py

# Build with Cython (production)
./build.sh cython

# Verify everything works
./verify.sh
```

## 📚 What This Project Does

Creates a **FastAPI service with Cython-protected source code** that:

- ✅ Compiles Python to binary (.so files)
- ✅ Hides source code from distribution
- ✅ Installs dependencies automatically
- ✅ Works like normal Python code

## 🎯 Key Commands

### Development

| Command                     | Purpose                  |
| --------------------------- | ------------------------ |
| `uv sync`                   | Install all dependencies |
| `uv run python main.py`     | Start dev server         |
| `uv run python test_api.py` | Run API tests            |
| `uv add <package>`          | Add new dependency       |

### Building

| Command                 | Purpose                  |
| ----------------------- | ------------------------ |
| `uv build`              | Build with source (dev)  |
| `USE_CYTHON=1 uv build` | Build with Cython (prod) |
| `./build.sh`            | Build dev (easier)       |
| `./build.sh cython`     | Build prod (easier)      |

### Verification

| Command               | Purpose                |
| --------------------- | ---------------------- |
| `./verify.sh`         | Run all verifications  |
| `unzip -l dist/*.whl` | Inspect wheel contents |

## 🏗️ Project Structure

```
cythonize-package/
├── src/cythonize_package/
│   ├── __init__.py      # Package init (Python)
│   ├── app.py           # FastAPI app (→ .so)
│   ├── models.py        # Pydantic models (→ .so)
│   └── service.py       # Business logic (→ .so)
├── setup.py            # Cython configuration
├── pyproject.toml      # Project config
├── main.py             # Entry point
└── test_api.py         # Tests
```

## 🔑 Important Decisions

### Why `uv init --lib`?

- Creates proper package structure
- Supports building wheels
- Best for distributable packages

### Why `setuptools` not `uv_build`?

- Cython needs setup.py hooks
- uv_build doesn't support extensions (yet)

### Which files are Cythonized?

- ✅ `app.py` - Main application
- ✅ `models.py` - Data models
- ✅ `service.py` - Business logic
- ❌ `__init__.py` - Kept as Python

## 📦 Build Outputs

### Development Build

```
cythonize_package-0.1.0-py3-none-any.whl (8 KB)
```

- Contains .py files
- Platform-independent
- Fast rebuild

### Production Build

```
cythonize_package-0.1.0-cp311-cp311-macosx_11_0_arm64.whl (72 KB)
```

- Contains .so files
- Platform-specific
- Source protected

## 🧪 Testing

### Manual Test

```bash
curl -X POST http://localhost:8000/users/ \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@example.com","age":30}'
```

### Automated Test

```bash
uv run python test_api.py
```

## 🔐 Security Features

| Feature            | Benefit            |
| ------------------ | ------------------ |
| Binary compilation | Can't read source  |
| No .py in wheel    | Can't extract code |
| C-level execution  | Harder to reverse  |

## ⚡ Performance Benefits

| Aspect    | Improvement    |
| --------- | -------------- |
| Execution | ~2-5x faster   |
| Memory    | More efficient |
| Load time | Faster imports |

## 🎓 Learning Path

1. ✅ Understand `uv` workflow
2. ✅ Learn FastAPI basics
3. ✅ Explore Cython integration
4. ✅ Practice builds
5. ✅ Verify protection

## 📝 Common Tasks

### Add New Endpoint

Edit `src/cythonize_package/app.py`:

```python
@app.get("/new-endpoint")
async def new_endpoint():
    return {"message": "Hello"}
```

### Add New Model

Edit `src/cythonize_package/models.py`:

```python
class NewModel(BaseModel):
    field: str
```

### Add Dependency

```bash
uv add requests
```

### Clean Build

```bash
rm -rf dist/ build/ src/*.egg-info src/**/*.c
```

## 🐛 Troubleshooting

### Import Errors

```bash
uv sync
```

### Build Failures

```bash
rm -rf dist/ build/
./build.sh cython
```

### C Compiler Missing

```bash
# macOS
xcode-select --install

# Linux
sudo apt-get install build-essential
```

## 📖 Documentation

- **README.md** - User documentation
- **BUILD_GUIDE.md** - Detailed build info
- **SUMMARY.md** - Project overview
- **QUICK_START.md** - This file

## 🎉 Success Checklist

- [ ] Dependencies installed (`uv sync`)
- [ ] Tests pass (`uv run python test_api.py`)
- [ ] Dev build works (`uv build`)
- [ ] Prod build works (`./build.sh cython`)
- [ ] Verification passes (`./verify.sh`)
- [ ] Source protected (no .py in wheel)

## 🚀 Next Steps

1. Customize the API endpoints
2. Add database integration
3. Deploy to production
4. Build for multiple platforms
5. Set up CI/CD

## 💡 Pro Tips

- Use `./build.sh cython` for quick prod builds
- Run `./verify.sh` before distributing
- Keep `__init__.py` as Python for debugging
- Test cythonized builds thoroughly
- Document which files are cythonized

---

**Ready to build?** Run `./build.sh cython` 🚀
**Need help?** Check `BUILD_GUIDE.md` 📚
**Want details?** Read `SUMMARY.md` 📝
