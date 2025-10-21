# Cythonize Package

A FastAPI service with Cython-protected source code using uv build backend.

## Features

- FastAPI web service with Pydantic models
- Business logic protected by Cython compilation
- Source code hidden in compiled `.so`/`.pyd` binary modules
- Built using uv build backend
- Easy installation with all dependencies

## Project Structure

```
cythonize-package/
├── src/
│   └── cythonize_package/
│       ├── __init__.py          # Package init (not cythonized)
│       ├── app.py               # FastAPI app (cythonized)
│       ├── models.py            # Pydantic models (cythonized)
│       └── service.py           # Business logic (cythonized)
├── setup.py                     # Cython build configuration
├── pyproject.toml              # Project configuration
└── main.py                     # Entry point
```

## Development

### Prerequisites

- Python >= 3.11
- uv package manager

### Setup

1. Install dependencies:

```bash
uv sync
```

2. Run the development server:

```bash
uv run python main.py
```

3. Access the API:
   - API: <http://localhost:8000>
   - Docs: <http://localhost:8000/docs>

## Building with Cython

### Build without Cython (development)

For development, build normally to keep source code readable:

```bash
uv build
```

This creates a standard wheel with `.py` files.

### Build with Cython (production)

To protect source code, build with Cython enabled:

```bash
USE_CYTHON=1 uv build
```

This will:

1. Compile `app.py`, `models.py`, and `service.py` into C extensions (`.so`/`.pyd`)
2. Remove the original `.py` source files from the wheel
3. Keep `__init__.py` as readable Python for package imports

### Install the built package

After building, install the wheel:

```bash
# Development build (with source code)
pip install dist/cythonize_package-0.1.0-py3-none-any.whl

# Production build (cythonized)
USE_CYTHON=1 uv build
pip install dist/cythonize_package-0.1.0-*.whl
```

## API Endpoints

### Root

- **GET** `/` - Welcome message

### Users

- **POST** `/users/` - Create a new user
- **GET** `/users/{user_id}` - Get user by ID
- **GET** `/users/` - List all users

## Example Usage

```bash
# Create a user
curl -X POST "http://localhost:8000/users/" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30
  }'

# Get user by ID
curl "http://localhost:8000/users/1"

# List all users
curl "http://localhost:8000/users/"
```

## How Cythonization Works

1. **setup.py**: Configures which files to cythonize
   - `INCLUDE_FILE_PATTERNS`: Files to compile (app.py, models.py, service.py)
   - `EXCLUDE_FILE_PATTERNS`: Files to keep as Python (**init**.py)

2. **Environment Variable**: `USE_CYTHON=1` triggers Cython compilation

3. **Build Process**:
   - Cython converts Python code to C
   - C compiler creates binary extensions (.so on Linux/Mac, .pyd on Windows)
   - Original .py files are removed from the wheel
   - Binary modules are imported like normal Python modules

4. **Result**: Protected source code that cannot be easily reversed engineered

## Dependencies

### Runtime Dependencies

- fastapi >= 0.115.0
- pydantic >= 2.9.0
- uvicorn >= 0.32.0

### Build Dependencies

- setuptools >= 75.0.0
- Cython >= 3.0.0, < 4.0.0

### Development Dependencies

- pytest >= 8.0.0
- httpx >= 0.27.0

## License

MIT License
