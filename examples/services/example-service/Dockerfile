# Example FastAPI service Docker build with Cython protection
FROM python:3.11-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && \
    apt-get install -y gcc g++ make && \
    rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy workspace root files
COPY ../../pyproject.toml ../../uv.lock ./

# Copy dependencies (shared packages)
COPY ../../packages/ ./packages/

# Copy this service
COPY . ./services/example-service/

# Build shared package with Cython
RUN cd packages/example-package && \
    USE_CYTHON=1 uv build

# Build service with Cython
RUN cd services/example-service && \
    USE_CYTHON=1 uv build

# Runtime stage (slim image without build tools)
FROM python:3.11-slim

WORKDIR /app

# Install uv for package installation
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy built wheels from builder
COPY --from=builder /app/packages/example-package/dist/*.whl /tmp/
COPY --from=builder /app/services/example-service/dist/*.whl /tmp/

# Install built wheels (contains .so files, no source)
RUN uv pip install --system /tmp/*.whl && \
    rm /tmp/*.whl

# Verify source is hidden
RUN python -c "import inspect; from example_service import main; \
    try: \
    inspect.getsource(main.create_app); \
    echo 'ERROR: Source code is visible!'; \
    exit 1; \
    except: \
    echo 'SUCCESS: Source code is protected!'"

# Run service
EXPOSE 8000
CMD ["uvicorn", "example_service.main:app", "--host", "0.0.0.0", "--port", "8000"]
